/**
 * scenes/BattleScene.ts
 * ATB (Active Time Battle) system inspired by Final Fantasy VI.
 */

import Phaser from "phaser";
import { buildCombatant, tickAtb, resolveAction, getEnemyAction, applyExpGain, GAUGE_MAX } from "../systems/combat.js";
import type { Combatant, CharDef, Ability, AbilityMap, ActionResult } from "../systems/combat.js";

const UI = {
  PARTY_BOX_X: 8,
  PARTY_BOX_Y: (h: number): number => h - 170,
  PARTY_BOX_W: 220,
  PARTY_BOX_H: 160,
  ENEMY_AREA_Y: 40,
  CMD_X: 240,
  CMD_Y: (h: number): number => h - 170,
} as const;

interface BattleInitData {
  enemies: CharDef[];
  gameState: GameState;
  onBattleEnd: (result: string) => void;
}

interface SavedPartyMember {
  id: string;
  name: string;
  level: number;
  hp: number;
  mp: number;
  maxHp?: number;
  maxMp?: number;
  abilities?: string[];
  [key: string]: unknown;
}

interface GameState {
  party: SavedPartyMember[];
  inventory: Array<{ itemId: string; qty: number }>;
  gp: number;
  worldFlags: Record<string, boolean>;
  currentMap: string;
  currentPosition: { x: number; y: number };
  playtime: number;
  saveSlot: number;
}

interface CharactersData {
  characters: CharDef[];
}

interface ItemDef {
  id: string;
  name: string;
  type: string;
  effect?: { type?: string; amount?: number; [key: string]: unknown } | null;
  overworld_only?: boolean;
}

interface ItemsData {
  items: ItemDef[];
}

interface EnemySpriteEntry {
  enemy: Combatant;
  sprite: Phaser.GameObjects.Image;
  barBg: Phaser.GameObjects.Rectangle;
  barFill: Phaser.GameObjects.Rectangle;
  barW: number;
  nameLabel: Phaser.GameObjects.Text;
  x: number;
  y: number;
}

interface MemberHudEntry {
  member: Combatant;
  nameText: Phaser.GameObjects.Text;
  hpText: Phaser.GameObjects.Text;
  mpText: Phaser.GameObjects.Text;
  atbBg: Phaser.GameObjects.Rectangle;
  atbFill: Phaser.GameObjects.Rectangle;
}

type BattlePhase = "atb" | "player_input" | "resolving" | "end";
type InputMode = "command" | "target" | "magic" | "item";

export default class BattleScene extends Phaser.Scene {
  private _enemyDefs: CharDef[] = [];
  private _gameState!: GameState;
  private _onBattleEnd: (result: string) => void = () => {};
  private _phase: BattlePhase = "atb";
  private _pendingActor: Combatant | null = null;
  private _showingMessage: boolean = false;
  private _selectedCmd: number = 0;
  private _selectedTarget: number = 0;
  private _inputMode: InputMode = "command";
  private _party: Combatant[] = [];
  private _enemies: Combatant[] = [];
  private _abilityMap: AbilityMap = {};
  private _enemySprites: EnemySpriteEntry[] = [];
  private _partyPanel!: Phaser.GameObjects.Graphics;
  private _partyHudObjs: MemberHudEntry[] = [];
  private _cmdPanel!: Phaser.GameObjects.Graphics;
  private _cmdTexts: Phaser.GameObjects.Text[] = [];
  private _targetCursor!: Phaser.GameObjects.Text;
  private _msgText!: Phaser.GameObjects.Text;
  private _keys!: Record<string, Phaser.Input.Keyboard.Key>;
  private _atbPaused: boolean = false;

  constructor() {
    super({ key: "BattleScene" });
  }

  init(data: BattleInitData): void {
    this._enemyDefs = data.enemies;
    this._gameState = data.gameState;
    this._onBattleEnd = data.onBattleEnd ?? (() => {});
    this._phase = "atb";
    this._pendingActor = null;
    this._showingMessage = false;
    this._selectedCmd = 0;
    this._selectedTarget = 0;
    this._inputMode = "command";
  }

  create(): void {
    const { width, height } = this.cameras.main;

    const bg = this.add.graphics();
    bg.fillGradientStyle(0x220011, 0x220011, 0x110022, 0x110022, 1);
    bg.fillRect(0, 0, width, height);

    const charDefs = (this.cache.json.get("characters") as CharactersData).characters;
    const abilityMap = (this.registry.get("abilityMap") as AbilityMap | undefined) ?? {};

    this._party = this._gameState.party.map((saved) => {
      const def = charDefs.find((c) => c.id === saved.id);
      if (!def) return null;
      const c = buildCombatant(def, saved, true);
      c.abilities = saved.abilities ?? def.startingAbilities ?? ["attack"];
      c.maxHp = saved.maxHp ?? c.maxHp;
      c.maxMp = saved.maxMp ?? c.maxMp;
      c.hp = saved.hp;
      c.mp = saved.mp;
      return c;
    }).filter((c): c is Combatant => c !== null);

    this._enemies = this._enemyDefs.map((def) => buildCombatant(def, {}, false));

    this._abilityMap = abilityMap;

    this._enemySprites = this._enemies.map((enemy, i) => {
      const cols = Math.min(this._enemies.length, 3);
      const spacing = width / (cols + 1);
      const x = spacing * (i % cols + 1);
      const y = UI.ENEMY_AREA_Y + Math.floor(i / 3) * 80 + (enemy.isBoss ? 20 : 0);
      const key = `enemy_${enemy.id}`;
      const sprite = this.add.image(x, y, key).setOrigin(0.5, 0);

      const barW = enemy.isBoss ? 120 : 60;
      const barBg = this.add.rectangle(x, y - 10, barW, 6, 0x220000).setOrigin(0.5, 0);
      const barFill = this.add.rectangle(x - barW / 2, y - 10, barW, 6, 0x44cc44).setOrigin(0, 0);
      const nameLabel = this.add.text(x, y - 20, enemy.name, {
        fontFamily: '"Press Start 2P", monospace', fontSize: "7px", color: "#ff8888",
        stroke: "#000000", strokeThickness: 2,
      }).setOrigin(0.5, 1);

      return { enemy, sprite, barBg, barFill, barW, nameLabel, x, y };
    });

    this._partyPanel = this.add.graphics();
    this._buildPartyPanel(width, height);
    this._partyHudObjs = this._party.map((c, i) => this._buildMemberHud(c, i, height));

    this._cmdPanel = this.add.graphics().setVisible(false);
    this._cmdTexts = [];
    this._targetCursor = this.add.text(0, 0, "\u25ba", {
      fontFamily: '"Press Start 2P", monospace', fontSize: "9px", color: "#ffff00",
    }).setVisible(false);

    const msgBg = this.add.graphics();
    msgBg.fillStyle(0x000022, 0.85);
    msgBg.fillRect(0, height * 0.42, width, 28);
    this._msgText = this.add.text(width / 2, height * 0.42 + 8, "", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "8px",
      color: "#ffffcc",
      stroke: "#000000",
      strokeThickness: 2,
    }).setOrigin(0.5, 0);

    this._keys = this.input.keyboard!.addKeys({
      up: "UP", down: "DOWN", left: "LEFT", right: "RIGHT",
      confirm: "SPACE", confirmAlt: "ENTER", cancel: "ESC",
    }) as Record<string, Phaser.Input.Keyboard.Key>;
    this._keys["confirm"]!.on("down", () => this._onConfirm());
    this._keys["confirmAlt"]!.on("down", () => this._onConfirm());
    this._keys["cancel"]!.on("down", () => this._onCancel());
    this._keys["up"]!.on("down", () => this._onNav(-1));
    this._keys["down"]!.on("down", () => this._onNav(1));

    this._atbPaused = false;
  }

  update(_: number, delta: number): void {
    if (this._phase === "end" || this._showingMessage) return;

    if (this._phase === "atb" || this._phase === "player_input") {
      if (!this._atbPaused) {
        this._tickAtbAndCheck(delta);
      }
      this._updateHud();
    }
  }

  private _tickAtbAndCheck(delta: number): void {
    const allCombatants = [...this._party, ...this._enemies];

    const pause = this._phase === "player_input";
    if (!pause) tickAtb(allCombatants, delta);

    for (const enemy of this._enemies) {
      if (enemy.hp <= 0 || enemy.atbGauge < GAUGE_MAX) continue;
      const action = getEnemyAction(enemy, this._party, this._abilityMap);
      if (action) {
        this._executeEnemyAction(enemy, action.ability, action.targets);
      } else {
        enemy.atbGauge = 0;
      }
      return;
    }

    if (this._phase !== "player_input") {
      for (const member of this._party) {
        if (member.hp <= 0 || member.atbGauge < GAUGE_MAX) continue;
        this._requestPlayerInput(member);
        return;
      }
    }
  }

  private _executeEnemyAction(enemy: Combatant, ability: Ability, targets: Combatant[]): void {
    this._phase = "resolving";
    const results = resolveAction(enemy, ability, targets, this._abilityMap);
    this._processResults(results, () => {
      this._finishAction();
    });
  }

  private _requestPlayerInput(member: Combatant): void {
    this._phase = "player_input";
    this._pendingActor = member;
    this._inputMode = "command";
    this._selectedCmd = 0;
    this._atbPaused = true;
    this._showCommandMenu(member);
  }

  private _showCommandMenu(actor: Combatant): void {
    const { height } = this.cameras.main;
    const x = UI.CMD_X;
    const y = UI.CMD_Y(height);

    this._cmdPanel.setVisible(true);
    this._cmdPanel.clear();
    this._cmdPanel.fillStyle(0x000033, 0.93);
    this._cmdPanel.fillRoundedRect(x - 4, y - 4, 150, 130, 5);
    this._cmdPanel.lineStyle(2, 0x5577cc, 1);
    this._cmdPanel.strokeRoundedRect(x - 4, y - 4, 150, 130, 5);

    const COMMANDS = [
      { label: "FIGHT" },
      { label: "MAGIC" },
      { label: "ITEM" },
      { label: "DEFEND" },
      { label: "RUN" },
    ];

    this._clearCmdTexts();
    this.add.text(x, y - 18, actor.name, {
      fontFamily: '"Press Start 2P", monospace', fontSize: "7px", color: "#aaddff",
    }).setName("cmdLabel");

    this._cmdTexts = COMMANDS.map((cmd, i) => {
      const t = this.add.text(x + 14, y + i * 22, cmd.label, {
        fontFamily: '"Press Start 2P", monospace', fontSize: "9px",
        color: i === this._selectedCmd ? "#ffff88" : "#ccddff",
      }).setInteractive({ useHandCursor: true });

      t.on("pointerover", () => { this._selectedCmd = i; this._refreshCmdColors(); });
      t.on("pointerdown", () => { this._selectedCmd = i; this._onConfirm(); });
      return t;
    });

    this._refreshCmdColors();
  }

  private _refreshCmdColors(): void {
    this._cmdTexts.forEach((t, i) => {
      t.setColor(i === this._selectedCmd ? "#ffff88" : "#ccddff");
    });
  }

  private _clearCmdTexts(): void {
    this.children.getAll().filter((c) => c.name === "cmdLabel").forEach((c) => c.destroy());
    this._cmdTexts.forEach((t) => t.destroy());
    this._cmdTexts = [];
  }

  private _hideCommandMenu(): void {
    this._cmdPanel.setVisible(false);
    this._clearCmdTexts();
    this._targetCursor.setVisible(false);
  }

  private _onNav(dir: number): void {
    if (this._inputMode === "command") {
      this._selectedCmd = Phaser.Math.Clamp(this._selectedCmd + dir, 0, 4);
      this._refreshCmdColors();
    } else if (this._inputMode === "target") {
      const targets = this._getEnemyTargets();
      this._selectedTarget = Phaser.Math.Clamp(this._selectedTarget + dir, 0, targets.length - 1);
      this._updateTargetCursor();
    }
  }

  private _onConfirm(): void {
    if (this._inputMode === "command") {
      this._handleCommandSelect(this._selectedCmd);
    } else if (this._inputMode === "target") {
      const targets = this._getEnemyTargets();
      const target = targets[this._selectedTarget];
      if (!target) return;
      const ability = this._abilityMap["attack"];
      if (!ability || !this._pendingActor) return;
      this._executePlayerAction(this._pendingActor, ability, [target.enemy]);
    }
  }

  private _onCancel(): void {
    if (this._inputMode === "target" && this._pendingActor) {
      this._inputMode = "command";
      this._selectedCmd = 0;
      this._targetCursor.setVisible(false);
      this._showCommandMenu(this._pendingActor);
    }
  }

  private _handleCommandSelect(cmdIndex: number): void {
    const actor = this._pendingActor;
    if (!actor) return;

    switch (cmdIndex) {
      case 0: // FIGHT
        this._inputMode = "target";
        this._selectedTarget = 0;
        this._hideCommandMenu();
        this._showTargetSelect();
        break;

      case 1: // MAGIC
        this._hideCommandMenu();
        this._executeMagicQuick(actor);
        break;

      case 2: // ITEM
        this._hideCommandMenu();
        this._executeItemQuick(actor);
        break;

      case 3: { // DEFEND
        const defendAbility = this._abilityMap["defend"];
        if (defendAbility) {
          this._executePlayerAction(actor, defendAbility, [actor]);
        }
        break;
      }

      case 4: // RUN
        this._tryRun();
        break;
    }
  }

  private _showTargetSelect(): void {
    const targets = this._getEnemyTargets();
    if (targets.length === 0) { this._endBattle("victory"); return; }
    this._inputMode = "target";
    this._selectedTarget = 0;
    this._updateTargetCursor();
  }

  private _updateTargetCursor(): void {
    const targets = this._getEnemyTargets();
    const t = targets[this._selectedTarget];
    if (!t) return;
    this._targetCursor.setPosition(t.x - 24, t.y + 16).setVisible(true);
  }

  private _getEnemyTargets(): EnemySpriteEntry[] {
    return this._enemySprites.filter((es) => es.enemy.hp > 0);
  }

  private _executeMagicQuick(actor: Combatant): void {
    const spell = actor.abilities.find((id) => {
      const ab = this._abilityMap[id];
      return ab && ab.type === "magic" && ab.target === "single_enemy" && (ab.mpCost ?? 0) <= actor.mp;
    });
    if (!spell) {
      this._showMessage(`${actor.name} has no usable magic!`, 1500, () => {
        this._showCommandMenu(actor);
      });
      return;
    }
    const ability = this._abilityMap[spell];
    if (!ability) return;
    const target = this._enemies.find((e) => e.hp > 0);
    if (!target) { this._endBattle("victory"); return; }
    this._executePlayerAction(actor, ability, [target]);
  }

  private _executeItemQuick(actor: Combatant): void {
    const inv = this._gameState.inventory ?? [];
    const itemsData = (this.cache.json.get("items") as ItemsData).items;

    const usable = inv.find((e) => {
      const itemDef = itemsData.find((i) => i.id === e.itemId);
      return itemDef && itemDef.type === "consumable" && !itemDef.overworld_only;
    });
    if (!usable) {
      this._showMessage("No usable items!", 1500, () => this._showCommandMenu(actor));
      return;
    }
    const itemDef = itemsData.find((i) => i.id === usable.itemId);
    if (!itemDef) return;

    usable.qty--;
    if (usable.qty <= 0) {
      const idx = inv.indexOf(usable);
      if (idx > -1) inv.splice(idx, 1);
    }

    const target = this._party.find((p) => p.hp < p.maxHp && p.hp > 0) ?? this._party[0];
    if (!target) return;

    let resultMessage: string;
    if (itemDef.effect?.type === "heal_hp") {
      const amount = typeof itemDef.effect["amount"] === "number" ? itemDef.effect["amount"] : 0;
      const heal = Math.min(target.maxHp - target.hp, amount);
      target.hp += heal;
      resultMessage = `${actor.name} used ${itemDef.name}! ${target.name} recovered ${heal} HP.`;
    } else if (itemDef.effect?.type === "heal_mp") {
      const amount = typeof itemDef.effect["amount"] === "number" ? itemDef.effect["amount"] : 0;
      const healMp = Math.min(target.maxMp - target.mp, amount);
      target.mp += healMp;
      resultMessage = `${actor.name} used ${itemDef.name}! ${target.name} recovered ${healMp} MP.`;
    } else {
      resultMessage = `${actor.name} used ${itemDef.name}!`;
    }
    actor.atbGauge = 0;
    this._hideCommandMenu();
    this._showMessage(resultMessage, 1500, () => this._finishAction());
  }

  private _executePlayerAction(actor: Combatant, ability: Ability, targets: Combatant[]): void {
    this._hideCommandMenu();
    this._atbPaused = false;
    this._phase = "resolving";

    const results = resolveAction(actor, ability, targets, this._abilityMap);
    this._processResults(results, () => {
      this._finishAction();
    });
  }

  private _tryRun(): void {
    this._hideCommandMenu();
    const avgEnemyLv = this._enemies.reduce((s, e) => s + (e.level), 0) / this._enemies.length;
    const partyAvgLv = this._party.reduce((s, p) => s + p.level, 0) / this._party.length;
    const chance = 0.50 + (partyAvgLv - avgEnemyLv) * 0.05;
    if (Math.random() < chance) {
      this._showMessage("The party escapes!", 1500, () => this._endBattle("escape"));
    } else {
      if (this._pendingActor) this._pendingActor.atbGauge = 0;
      this._showMessage("Couldn't escape!", 1200, () => this._finishAction());
    }
  }

  private _processResults(results: ActionResult[], callback: () => void): void {
    if (results.length === 0) { callback(); return; }

    let i = 0;
    const processNext = (): void => {
      if (i >= results.length) { callback(); return; }
      const result = results[i]!;
      i++;

      this._flashCombatant(result.target);

      if (result.amount && result.amount > 0) {
        this._spawnDamageNumber(result.target, result.amount, result.type);
      }

      this._showMessage(result.message, 1200, processNext);
    };
    processNext();
  }

  private _finishAction(): void {
    this._phase = "atb";
    this._atbPaused = false;

    const allEnemiesDown = this._enemies.every((e) => e.hp <= 0);
    const allPartyDown = this._party.every((p) => p.hp <= 0);

    if (allEnemiesDown) { this._endBattle("victory"); return; }
    if (allPartyDown) { this._endBattle("defeat"); return; }
  }

  private _endBattle(result: string): void {
    this._phase = "end";
    this._hideCommandMenu();

    if (result === "victory") {
      const totalGp = this._enemies.reduce((s, e) => s + (e.gpReward), 0);
      this._gameState.gp = (this._gameState.gp ?? 0) + totalGp;

      const charDefs = (this.cache.json.get("characters") as CharactersData).characters;
      const levelUps = applyExpGain(this._party, this._enemies, charDefs);

      this._party.forEach((c, i) => {
        const saved = this._gameState.party[i];
        if (saved) {
          Object.assign(saved, {
            hp: c.hp, maxHp: c.maxHp,
            mp: c.mp, maxMp: c.maxMp,
            str: c.str, def: c.def, mag: c.mag, mdef: c.mdef, spd: c.spd, lck: c.lck,
            level: c.level, exp: c.exp,
          });
        }
      });
      this.registry.set("gameState", this._gameState);

      const totalExp = this._enemies.reduce((s, e) => s + (e.expReward), 0);
      const victMsg = `Victory! +${totalExp} EXP  +${totalGp} GP`;

      this._showMessage(victMsg, 2000, () => {
        if (levelUps.length > 0) {
          const lvMsg = levelUps.map((lu) => `${lu.combatant.name} reached Lv.${lu.newLevel}!`).join("  ");
          this._showMessage(lvMsg, 2000, () => this._onBattleEnd("victory"));
        } else {
          this._onBattleEnd("victory");
        }
      });

    } else if (result === "defeat") {
      this._showMessage("The party was defeated...", 2000, () => {
        this._onBattleEnd("gameover");
      });

    } else {
      this._onBattleEnd("escape");
    }
  }

  private _buildPartyPanel(_width: number, height: number): void {
    const x = UI.PARTY_BOX_X;
    const y = UI.PARTY_BOX_Y(height);
    const w = UI.PARTY_BOX_W;
    const h = UI.PARTY_BOX_H;
    this._partyPanel.fillStyle(0x000033, 0.92);
    this._partyPanel.fillRoundedRect(x, y, w, h, 6);
    this._partyPanel.lineStyle(2, 0x5577cc, 1);
    this._partyPanel.strokeRoundedRect(x, y, w, h, 6);
  }

  private _buildMemberHud(member: Combatant, index: number, height: number): MemberHudEntry {
    const x = UI.PARTY_BOX_X + 10;
    const y = UI.PARTY_BOX_Y(height) + 12 + index * 46;

    const nameText = this.add.text(x, y, member.name, {
      fontFamily: '"Press Start 2P", monospace', fontSize: "7px", color: "#aaddff",
    });

    const hpText = this.add.text(x, y + 12, `HP ${member.hp}/${member.maxHp}`, {
      fontFamily: '"Press Start 2P", monospace', fontSize: "6px", color: "#44ff44",
    });

    const mpText = this.add.text(x, y + 22, `MP ${member.mp}/${member.maxMp}`, {
      fontFamily: '"Press Start 2P", monospace', fontSize: "6px", color: "#4488ff",
    });

    const atbBg = this.add.rectangle(x, y + 33, 90, 5, 0x222244).setOrigin(0, 0);
    const atbFill = this.add.rectangle(x, y + 33, 0, 5, 0xddaa00).setOrigin(0, 0);

    return { member, nameText, hpText, mpText, atbBg, atbFill };
  }

  private _updateHud(): void {
    this._partyHudObjs.forEach(({ member, hpText, mpText, atbFill }) => {
      const hpColor = member.hp / member.maxHp < 0.25 ? "#ff4444" : "#44ff44";
      const atbPct = member.atbGauge / GAUGE_MAX;

      hpText.setText(`HP ${member.hp}/${member.maxHp}`).setColor(hpColor);
      mpText.setText(`MP ${member.mp}/${member.maxMp}`);
      atbFill.setSize(Math.floor(90 * atbPct), 5);
    });

    this._enemySprites.forEach(({ enemy, barFill, barW, sprite }) => {
      const pct = Math.max(0, enemy.hp / enemy.maxHp);
      barFill.setSize(barW * pct, 6);
      const barColor = pct > 0.5 ? 0x44cc44 : pct > 0.25 ? 0xcccc00 : 0xcc4444;
      barFill.setFillStyle(barColor);
      sprite.setAlpha(enemy.hp <= 0 ? 0.2 : 1);
    });
  }

  private _flashCombatant(target: Combatant): void {
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

  private _spawnDamageNumber(target: Combatant, amount: number, type: string): void {
    const isEnemy = !target.isParty;
    let x: number, y: number;

    if (isEnemy) {
      const spr = this._enemySprites.find((es) => es.enemy === target);
      x = spr ? spr.x : this.cameras.main.width / 2;
      y = spr ? spr.y + 20 : 100;
    } else {
      const idx = this._party.indexOf(target);
      x = UI.PARTY_BOX_X + 80;
      y = UI.PARTY_BOX_Y(this.cameras.main.height) + 20 + idx * 46;
    }

    const color = type === "heal" ? "#44ff44" : type === "miss" ? "#888888" : "#ffffff";
    const txt = this.add.text(x, y, type === "miss" ? "MISS" : String(amount), {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "12px",
      color,
      stroke: "#000000",
      strokeThickness: 3,
    }).setOrigin(0.5, 0.5).setDepth(20);

    this.tweens.add({
      targets: txt, y: y - 40, alpha: 0, duration: 900,
      onComplete: () => txt.destroy(),
    });
  }

  private _showMessage(text: string, duration: number, callback?: () => void): void {
    this._showingMessage = true;
    this._msgText.setText(text);
    this.time.delayedCall(duration, () => {
      this._showingMessage = false;
      callback?.();
    });
  }
}
