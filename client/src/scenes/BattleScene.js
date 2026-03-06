/**
 * scenes/BattleScene.js
 * ATB (Active Time Battle) system — inspired by Final Fantasy VI.
 *
 * Features:
 * - Per-combatant ATB gauge filling based on SPD stat
 * - Player chooses action when their gauge is full (Attack / Magic / Item / Defend / Run)
 * - Enemies act automatically via AI when their gauge fills
 * - Animated damage numbers and status messages
 * - Victory / Game Over handling with EXP + GP distribution
 * - Persists updated party stats back to gameState registry
 *
 * Launched via: this.scene.launch('BattleScene', { enemies, gameState, onBattleEnd })
 */

import { buildCombatant, tickAtb, resolveAction, getEnemyAction, applyExpGain, GAUGE_MAX } from '../systems/combat.js';

/** UI layout constants */
const UI = {
  PARTY_BOX_X:  8,
  PARTY_BOX_Y:  (h) => h - 170,
  PARTY_BOX_W:  220,
  PARTY_BOX_H:  160,
  ENEMY_AREA_Y: 40,
  CMD_X:        240,
  CMD_Y:        (h) => h - 170,
};

export default class BattleScene extends Phaser.Scene {
  constructor() {
    super({ key: 'BattleScene' });
  }

  init(data) {
    this._enemyDefs  = data.enemies;
    this._gameState  = data.gameState;
    this._onBattleEnd = data.onBattleEnd || (() => {});
    this._phase      = 'atb';      // 'atb' | 'player_input' | 'resolving' | 'end'
    this._pendingActor = null;     // Combatant whose turn it is
    this._messageQueue = [];       // Queued messages to display
    this._showingMessage = false;
    this._selectedCmd  = 0;
    this._selectedTarget = 0;
    this._inputMode    = 'command'; // 'command' | 'target' | 'magic' | 'item'
  }

  create() {
    const { width, height } = this.cameras.main;

    // ── Background ────────────────────────────────────────────────────────────
    this._bg = this.add.graphics();
    this._bg.fillGradientStyle(0x220011, 0x220011, 0x110022, 0x110022, 1);
    this._bg.fillRect(0, 0, width, height);

    // ── Build combatants ──────────────────────────────────────────────────────
    const charDefs = this.cache.json.get('characters').characters;
    const abilityMap = this.registry.get('abilityMap') || {};

    this._party = this._gameState.party.map((saved) => {
      const def = charDefs.find((c) => c.id === saved.id);
      if (!def) return null;
      const c = buildCombatant(def, saved, true);
      c.abilities = saved.abilities || def.startingAbilities;
      c.maxHp = saved.maxHp || c.maxHp;
      c.maxMp = saved.maxMp || c.maxMp;
      c.hp    = saved.hp;
      c.mp    = saved.mp;
      return c;
    }).filter(Boolean);

    this._enemies = this._enemyDefs.map((def) => buildCombatant(def, {}, false));

    this._abilityMap = abilityMap;

    // ── Enemy sprites ─────────────────────────────────────────────────────────
    this._enemySprites = this._enemies.map((enemy, i) => {
      const cols   = Math.min(this._enemies.length, 3);
      const spacing = width / (cols + 1);
      const x = spacing * (i % cols + 1);
      const y = UI.ENEMY_AREA_Y + Math.floor(i / 3) * 80 + (enemy.isBoss ? 20 : 0);
      const key = `enemy_${enemy.id}`;
      const sprite = this.add.image(x, y, key).setOrigin(0.5, 0);

      // HP bar above enemy
      const barW = enemy.isBoss ? 120 : 60;
      const barBg = this.add.rectangle(x, y - 10, barW, 6, 0x220000).setOrigin(0.5, 0);
      const barFill = this.add.rectangle(x - barW / 2, y - 10, barW, 6, 0x44cc44).setOrigin(0, 0);
      const nameLabel = this.add.text(x, y - 20, enemy.name, {
        fontFamily: '"Press Start 2P", monospace', fontSize: '7px', color: '#ff8888',
        stroke: '#000000', strokeThickness: 2,
      }).setOrigin(0.5, 1);

      return { enemy, sprite, barBg, barFill, barW, nameLabel, x, y };
    });

    // ── Party status panel ────────────────────────────────────────────────────
    this._partyPanel = this.add.graphics();
    this._buildPartyPanel(width, height);
    this._partyHudObjs = this._party.map((c, i) => this._buildMemberHud(c, i, height));

    // ── Command menu ──────────────────────────────────────────────────────────
    this._cmdPanel = this.add.graphics().setVisible(false);
    this._cmdTexts = [];
    this._targetCursor = this.add.text(0, 0, '►', {
      fontFamily: '"Press Start 2P", monospace', fontSize: '9px', color: '#ffff00',
    }).setVisible(false);

    // ── Message area ──────────────────────────────────────────────────────────
    this._msgBg = this.add.graphics();
    this._msgBg.fillStyle(0x000022, 0.85);
    this._msgBg.fillRect(0, height * 0.42, width, 28);
    this._msgText = this.add.text(width / 2, height * 0.42 + 8, '', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize:   '8px',
      color:      '#ffffcc',
      stroke:     '#000000',
      strokeThickness: 2,
    }).setOrigin(0.5, 0);

    // ── Input keys ────────────────────────────────────────────────────────────
    this._keys = this.input.keyboard.addKeys({
      up: 'UP', down: 'DOWN', left: 'LEFT', right: 'RIGHT',
      confirm: 'SPACE', confirmAlt: 'ENTER', cancel: 'ESC',
    });
    this._keys.confirm.on('down',    () => this._onConfirm());
    this._keys.confirmAlt.on('down', () => this._onConfirm());
    this._keys.cancel.on('down',     () => this._onCancel());
    this._keys.up.on('down',         () => this._onNav(-1));
    this._keys.down.on('down',       () => this._onNav(1));

    // ── ATB tick ─────────────────────────────────────────────────────────────
    this._atbPaused = false;
  }

  update(_, delta) {
    if (this._phase === 'end' || this._showingMessage) return;

    if (this._phase === 'atb' || this._phase === 'player_input') {
      if (!this._atbPaused) {
        this._tickAtbAndCheck(delta);
      }
      this._updateHud();
    }
  }

  // ── ATB logic ────────────────────────────────────────────────────────────────

  _tickAtbAndCheck(delta) {
    const allCombatants = [...this._party, ...this._enemies];

    // Don't tick if currently waiting for player input
    const pause = this._phase === 'player_input';
    if (!pause) tickAtb(allCombatants, delta);

    // Check for ready enemies (auto-act)
    for (const enemy of this._enemies) {
      if (enemy.hp <= 0 || enemy.atbGauge < GAUGE_MAX) continue;
      const action = getEnemyAction(enemy, this._party, this._abilityMap);
      if (action) {
        this._resolveAndAnimate(enemy, action.ability, action.targets);
      } else {
        enemy.atbGauge = 0;
      }
      return; // Process one action at a time
    }

    // Check for ready party members (request input)
    if (this._phase !== 'player_input') {
      for (const member of this._party) {
        if (member.hp <= 0 || member.atbGauge < GAUGE_MAX) continue;
        this._requestPlayerInput(member);
        return;
      }
    }
  }

  _requestPlayerInput(member) {
    this._phase        = 'player_input';
    this._pendingActor = member;
    this._inputMode    = 'command';
    this._selectedCmd  = 0;
    this._atbPaused    = true;
    this._showCommandMenu(member);
  }

  // ── Command menu ─────────────────────────────────────────────────────────────

  _showCommandMenu(actor) {
    const { width, height } = this.cameras.main;
    const x = UI.CMD_X;
    const y = UI.CMD_Y(height);

    this._cmdPanel.setVisible(true);
    this._cmdPanel.clear();
    this._cmdPanel.fillStyle(0x000033, 0.93);
    this._cmdPanel.fillRoundedRect(x - 4, y - 4, 150, 130, 5);
    this._cmdPanel.lineStyle(2, 0x5577cc, 1);
    this._cmdPanel.strokeRoundedRect(x - 4, y - 4, 150, 130, 5);

    const COMMANDS = [
      { label: 'FIGHT',   icon: '⚔️' },
      { label: 'MAGIC',   icon: '✨' },
      { label: 'ITEM',    icon: '🎒' },
      { label: 'DEFEND',  icon: '🛡️' },
      { label: 'RUN',     icon: '💨' },
    ];

    // Active member name above menu
    this._clearCmdTexts();
    this.add.text(x, y - 18, actor.name, {
      fontFamily: '"Press Start 2P", monospace', fontSize: '7px', color: '#aaddff',
    }).setName('cmdLabel');

    this._cmdTexts = COMMANDS.map((cmd, i) => {
      const t = this.add.text(x + 14, y + i * 22, cmd.label, {
        fontFamily: '"Press Start 2P", monospace', fontSize: '9px',
        color: i === this._selectedCmd ? '#ffff88' : '#ccddff',
      }).setInteractive({ useHandCursor: true });

      t.on('pointerover',  () => { this._selectedCmd = i; this._refreshCmdColors(); });
      t.on('pointerdown',  () => { this._selectedCmd = i; this._onConfirm(); });
      return t;
    });

    this._refreshCmdColors();
  }

  _refreshCmdColors() {
    this._cmdTexts.forEach((t, i) => {
      t.setColor(i === this._selectedCmd ? '#ffff88' : '#ccddff');
    });
  }

  _clearCmdTexts() {
    this.children.getAll().filter((c) => c.name === 'cmdLabel').forEach((c) => c.destroy());
    this._cmdTexts.forEach((t) => t.destroy());
    this._cmdTexts = [];
  }

  _hideCommandMenu() {
    this._cmdPanel.setVisible(false);
    this._clearCmdTexts();
    this._targetCursor.setVisible(false);
  }

  // ── Input handlers ────────────────────────────────────────────────────────────

  _onNav(dir) {
    if (this._inputMode === 'command') {
      this._selectedCmd = Phaser.Math.Clamp(this._selectedCmd + dir, 0, 4);
      this._refreshCmdColors();
    } else if (this._inputMode === 'target') {
      const targets = this._getEnemyTargets();
      this._selectedTarget = Phaser.Math.Clamp(this._selectedTarget + dir, 0, targets.length - 1);
      this._updateTargetCursor();
    }
  }

  _onConfirm() {
    if (this._inputMode === 'command') {
      this._handleCommandSelect(this._selectedCmd);
    } else if (this._inputMode === 'target') {
      const targets = this._getEnemyTargets();
      const target = targets[this._selectedTarget];
      if (!target) return;
      const ability = this._abilityMap['attack'];
      this._executePlayerAction(this._pendingActor, ability, [target.enemy]);
    }
  }

  _onCancel() {
    if (this._inputMode === 'target') {
      this._inputMode  = 'command';
      this._selectedCmd = 0;
      this._targetCursor.setVisible(false);
      this._showCommandMenu(this._pendingActor);
    }
  }

  _handleCommandSelect(cmdIndex) {
    const actor = this._pendingActor;
    switch (cmdIndex) {
      case 0: // FIGHT
        this._inputMode      = 'target';
        this._selectedTarget = 0;
        this._hideCommandMenu();
        this._showTargetSelect();
        break;

      case 1: // MAGIC — for simplicity, use first damaging magic spell
        this._hideCommandMenu();
        this._executeMagicQuick(actor);
        break;

      case 2: // ITEM
        this._hideCommandMenu();
        this._executeItemQuick(actor);
        break;

      case 3: // DEFEND
        this._executePlayerAction(actor, this._abilityMap['defend'], [actor]);
        break;

      case 4: // RUN
        this._tryRun();
        break;
    }
  }

  _showTargetSelect() {
    const targets = this._getEnemyTargets();
    if (targets.length === 0) { this._endBattle('victory'); return; }
    this._inputMode      = 'target';
    this._selectedTarget = 0;
    this._updateTargetCursor();
  }

  _updateTargetCursor() {
    const targets = this._getEnemyTargets();
    const t = targets[this._selectedTarget];
    if (!t) return;
    this._targetCursor.setPosition(t.x - 24, t.y + 16).setVisible(true);
  }

  _getEnemyTargets() {
    return this._enemySprites.filter((es) => es.enemy.hp > 0);
  }

  _executeMagicQuick(actor) {
    // Pick the first offensive magic spell the actor knows
    const spell = actor.abilities.find((id) => {
      const ab = this._abilityMap[id];
      return ab && ab.type === 'magic' && ab.target === 'single_enemy' && (ab.mpCost || 0) <= actor.mp;
    });
    if (!spell) {
      this._showMessage(`${actor.name} has no usable magic!`, 1500, () => {
        this._showCommandMenu(actor);
      });
      return;
    }
    const ability = this._abilityMap[spell];
    const targets = [this._enemies.find((e) => e.hp > 0)];
    if (!targets[0]) { this._endBattle('victory'); return; }
    this._executePlayerAction(actor, ability, targets);
  }

  _executeItemQuick(actor) {
    const inv = this._gameState.inventory || [];
    const usable = inv.find((e) => {
      const itemDef = this.cache.json.get('items').items.find((i) => i.id === e.itemId);
      return itemDef && itemDef.type === 'consumable' && !itemDef.overworld_only;
    });
    if (!usable) {
      this._showMessage('No usable items!', 1500, () => this._showCommandMenu(actor));
      return;
    }
    const itemDef = this.cache.json.get('items').items.find((i) => i.id === usable.itemId);
    // Remove from inventory
    usable.qty--;
    if (usable.qty <= 0) {
      const idx = inv.indexOf(usable);
      if (idx > -1) inv.splice(idx, 1);
    }
    // Apply item effect to first party member needing HP
    const target = this._party.find((p) => p.hp < p.maxHp && p.hp > 0) || this._party[0];
    const result = { type: 'heal', amount: 0, message: '' };
    if (itemDef.effect?.type === 'heal_hp') {
      const heal = Math.min(target.maxHp - target.hp, itemDef.effect.amount);
      target.hp += heal;
      result.amount = heal;
      result.message = `${actor.name} used ${itemDef.name}! ${target.name} recovered ${heal} HP.`;
    } else if (itemDef.effect?.type === 'heal_mp') {
      const healMp = Math.min(target.maxMp - target.mp, itemDef.effect.amount);
      target.mp += healMp;
      result.message = `${actor.name} used ${itemDef.name}! ${target.name} recovered ${healMp} MP.`;
    } else {
      result.message = `${actor.name} used ${itemDef.name}!`;
    }
    actor.atbGauge = 0;
    this._hideCommandMenu();
    this._showMessage(result.message, 1500, () => this._finishAction());
  }

  _executePlayerAction(actor, ability, targets) {
    this._hideCommandMenu();
    this._atbPaused = false;
    this._phase     = 'resolving';

    const results = resolveAction(actor, ability, targets, this._abilityMap);
    this._processResults(results, () => {
      this._finishAction();
    });
  }

  _tryRun() {
    this._hideCommandMenu();
    // 50% base chance to run + 5% per level above average enemy level
    const avgEnemyLv = this._enemies.reduce((s, e) => s + (e.level || 1), 0) / this._enemies.length;
    const partyAvgLv = this._party.reduce((s, p) => s + p.level, 0) / this._party.length;
    const chance = 0.50 + (partyAvgLv - avgEnemyLv) * 0.05;
    if (Math.random() < chance) {
      this._showMessage('The party escapes!', 1500, () => this._endBattle('escape'));
    } else {
      this._pendingActor.atbGauge = 0;
      this._showMessage('Couldn\'t escape!', 1200, () => this._finishAction());
    }
  }

  _processResults(results, callback) {
    if (results.length === 0) { callback(); return; }

    let i = 0;
    const processNext = () => {
      if (i >= results.length) { callback(); return; }
      const result = results[i++];

      // Flash effect on target
      this._flashCombatant(result.target);

      // Spawn floating damage number
      if (result.amount > 0) {
        this._spawnDamageNumber(result.target, result.amount, result.type);
      }

      this._showMessage(result.message, 1200, processNext);
    };
    processNext();
  }

  _finishAction() {
    this._phase = 'atb';
    this._atbPaused = false;

    // Check win/loss
    const allEnemiesDown = this._enemies.every((e) => e.hp <= 0);
    const allPartyDown   = this._party.every((p) => p.hp <= 0);

    if (allEnemiesDown) { this._endBattle('victory'); return; }
    if (allPartyDown)   { this._endBattle('defeat');  return; }
  }

  // ── Battle end ────────────────────────────────────────────────────────────────

  _endBattle(result) {
    this._phase = 'end';
    this._hideCommandMenu();

    if (result === 'victory') {
      const totalGp  = this._enemies.reduce((s, e) => s + (e.gpReward || 0), 0);
      this._gameState.gp = (this._gameState.gp || 0) + totalGp;

      const charDefs = this.cache.json.get('characters').characters;
      const levelUps = applyExpGain(this._party, this._enemies, charDefs);

      // Persist updated party stats
      this._party.forEach((c, i) => {
        if (this._gameState.party[i]) {
          Object.assign(this._gameState.party[i], {
            hp: c.hp, maxHp: c.maxHp,
            mp: c.mp, maxMp: c.maxMp,
            str: c.str, def: c.def, mag: c.mag, mdef: c.mdef, spd: c.spd, lck: c.lck,
            level: c.level, exp: c.exp,
          });
        }
      });
      this.registry.set('gameState', this._gameState);

      const totalExp = this._enemies.reduce((s, e) => s + (e.expReward || 0), 0);
      let victMsg = `Victory! +${totalExp} EXP  +${totalGp} GP`;

      this._showMessage(victMsg, 2000, () => {
        if (levelUps.length > 0) {
          const lvMsg = levelUps.map((lu) => `${lu.combatant.name} reached Lv.${lu.newLevel}!`).join('  ');
          this._showMessage(lvMsg, 2000, () => this._onBattleEnd('victory'));
        } else {
          this._onBattleEnd('victory');
        }
      });

    } else if (result === 'defeat') {
      this._showMessage('The party was defeated...', 2000, () => {
        this._onBattleEnd('gameover');
      });

    } else { // escape
      this._onBattleEnd('escape');
    }
  }

  // ── HUD helpers ───────────────────────────────────────────────────────────────

  _buildPartyPanel(width, height) {
    const x = UI.PARTY_BOX_X;
    const y = UI.PARTY_BOX_Y(height);
    const w = UI.PARTY_BOX_W;
    const h = UI.PARTY_BOX_H;
    this._partyPanel.fillStyle(0x000033, 0.92);
    this._partyPanel.fillRoundedRect(x, y, w, h, 6);
    this._partyPanel.lineStyle(2, 0x5577cc, 1);
    this._partyPanel.strokeRoundedRect(x, y, w, h, 6);
  }

  _buildMemberHud(member, index, height) {
    const x = UI.PARTY_BOX_X + 10;
    const y = UI.PARTY_BOX_Y(height) + 12 + index * 46;

    const nameText = this.add.text(x, y, member.name, {
      fontFamily: '"Press Start 2P", monospace', fontSize: '7px', color: '#aaddff',
    });

    const hpText = this.add.text(x, y + 12, `HP ${member.hp}/${member.maxHp}`, {
      fontFamily: '"Press Start 2P", monospace', fontSize: '6px', color: '#44ff44',
    });

    const mpText = this.add.text(x, y + 22, `MP ${member.mp}/${member.maxMp}`, {
      fontFamily: '"Press Start 2P", monospace', fontSize: '6px', color: '#4488ff',
    });

    // ATB gauge
    const atbBg   = this.add.rectangle(x, y + 33, 90, 5, 0x222244).setOrigin(0, 0);
    const atbFill = this.add.rectangle(x, y + 33, 0, 5, 0xddaa00).setOrigin(0, 0);

    return { member, nameText, hpText, mpText, atbBg, atbFill };
  }

  _updateHud() {
    // Update party HUD
    this._partyHudObjs.forEach(({ member, hpText, mpText, atbFill }) => {
      const hpColor = member.hp / member.maxHp < 0.25 ? '#ff4444' : '#44ff44';
      const hpPct   = member.hp / member.maxHp;
      const mpPct   = member.mp / member.maxMp;
      const atbPct  = member.atbGauge / GAUGE_MAX;

      hpText.setText(`HP ${member.hp}/${member.maxHp}`).setColor(hpColor);
      mpText.setText(`MP ${member.mp}/${member.maxMp}`);
      atbFill.setSize(Math.floor(90 * atbPct), 5);
    });

    // Update enemy HP bars
    this._enemySprites.forEach(({ enemy, barFill, barW, sprite }) => {
      const pct = Math.max(0, enemy.hp / enemy.maxHp);
      barFill.setSize(barW * pct, 6);
      const barColor = pct > 0.5 ? 0x44cc44 : pct > 0.25 ? 0xcccc00 : 0xcc4444;
      barFill.setFillColor(barColor);
      sprite.setAlpha(enemy.hp <= 0 ? 0.2 : 1);
    });
  }

  _flashCombatant(target) {
    // Flash enemy sprite or party HUD entry
    const enemySpr = this._enemySprites.find((es) => es.enemy === target);
    if (enemySpr) {
      this.tweens.add({
        targets: enemySpr.sprite,
        alpha: 0.1,
        duration: 80,
        yoyo: true,
        repeat: 2,
      });
    }
  }

  _spawnDamageNumber(target, amount, type) {
    const isEnemy = !target.isParty;
    let x, y;

    if (isEnemy) {
      const spr = this._enemySprites.find((es) => es.enemy === target);
      x = spr ? spr.x : this.cameras.main.width / 2;
      y = spr ? spr.y + 20 : 100;
    } else {
      const idx = this._party.indexOf(target);
      x = UI.PARTY_BOX_X + 80;
      y = UI.PARTY_BOX_Y(this.cameras.main.height) + 20 + idx * 46;
    }

    const color = type === 'heal' ? '#44ff44' : type === 'miss' ? '#888888' : '#ffffff';
    const txt = this.add.text(x, y, type === 'miss' ? 'MISS' : String(amount), {
      fontFamily: '"Press Start 2P", monospace',
      fontSize:   '12px',
      color,
      stroke: '#000000',
      strokeThickness: 3,
    }).setOrigin(0.5, 0.5).setDepth(20);

    this.tweens.add({
      targets: txt, y: y - 40, alpha: 0, duration: 900,
      onComplete: () => txt.destroy(),
    });
  }

  _showMessage(text, duration, callback) {
    this._showingMessage = true;
    this._msgText.setText(text);
    this.time.delayedCall(duration, () => {
      this._showingMessage = false;
      callback?.();
    });
  }
}
