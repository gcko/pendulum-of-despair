/**
 * scenes/TitleScene.js
 * Title screen with login/register UI.
 *
 * Flow:
 *   1. Animated title + menu (New Game / Continue)
 *   2. Login/Register form (HTML overlay rendered via DOM)
 *   3. On success → WorldMapScene with fresh or loaded game state
 */

import { login, register, listSaves, isLoggedIn } from '../systems/saveLoad.js';

/** Default starting party (character IDs). */
const STARTING_PARTY = ['terra', 'locke'];

export default class TitleScene extends Phaser.Scene {
  constructor() {
    super({ key: 'TitleScene' });
    this._particles = [];
    this._authDiv   = null;
  }

  create() {
    const { width, height } = this.cameras.main;

    // ── Dark gradient background ──────────────────────────────────────────────
    const bg = this.add.graphics();
    bg.fillGradientStyle(0x000022, 0x000022, 0x000044, 0x000044, 1);
    bg.fillRect(0, 0, width, height);

    // ── Animated star field ───────────────────────────────────────────────────
    this._particles = [];
    for (let i = 0; i < 80; i++) {
      const x = Math.random() * width;
      const y = Math.random() * height;
      const r = Math.random() * 2 + 0.5;
      const star = this.add.circle(x, y, r, 0xffffff, Math.random() * 0.8 + 0.2);
      this._particles.push({ obj: star, speed: Math.random() * 0.3 + 0.05 });
    }

    // ── Title text ────────────────────────────────────────────────────────────
    this.add.text(width / 2, height * 0.22, 'PENDULUM', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: '28px',
      color: '#aaccff',
      stroke: '#002266',
      strokeThickness: 6,
    }).setOrigin(0.5);

    this.add.text(width / 2, height * 0.35, 'OF DESPAIR', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: '20px',
      color: '#7799ee',
      stroke: '#001144',
      strokeThickness: 4,
    }).setOrigin(0.5);

    this.add.text(width / 2, height * 0.48, '~ Echoes of a Forgotten Age ~', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: '8px',
      color: '#445588',
    }).setOrigin(0.5);

    // ── Menu options ──────────────────────────────────────────────────────────
    this._menuOptions = [];
    const opts = ['NEW GAME', 'CONTINUE'];
    opts.forEach((label, i) => {
      const y = height * 0.65 + i * 44;
      const txt = this.add.text(width / 2, y, label, {
        fontFamily: '"Press Start 2P", monospace',
        fontSize: '14px',
        color: '#ddddff',
        stroke: '#000022',
        strokeThickness: 3,
      }).setOrigin(0.5).setInteractive({ useHandCursor: true });

      txt.on('pointerover',  () => txt.setColor('#ffffff'));
      txt.on('pointerout',   () => txt.setColor('#ddddff'));
      txt.on('pointerdown',  () => this._onMenuSelect(i));
      this._menuOptions.push(txt);
    });

    // ── Blinking "Press Enter" prompt ─────────────────────────────────────────
    const pressEnter = this.add.text(width / 2, height * 0.9, 'Press Enter', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: '10px',
      color: '#8899cc',
    }).setOrigin(0.5);
    this.tweens.add({ targets: pressEnter, alpha: 0, duration: 600, yoyo: true, repeat: -1 });

    // ── Keyboard: Enter → New Game by default ─────────────────────────────────
    this.input.keyboard.once('keydown-ENTER', () => this._onMenuSelect(0));

    // ── Version label ─────────────────────────────────────────────────────────
    this.add.text(8, height - 20, 'v0.1.0 — Alpha', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: '7px',
      color: '#334466',
    });
  }

  update() {
    // Slowly drift stars down for a parallax feel
    for (const star of this._particles) {
      star.obj.y += star.speed;
      if (star.obj.y > this.cameras.main.height + 4) {
        star.obj.y = -4;
        star.obj.x = Math.random() * this.cameras.main.width;
      }
    }
  }

  // ── Internal handlers ──────────────────────────────────────────────────────

  /** Called when the user selects a menu option (0 = New Game, 1 = Continue). */
  _onMenuSelect(index) {
    this._removeAuthDiv();
    this._showAuthForm(index === 0 ? 'new' : 'continue');
  }

  /**
   * Shows an HTML overlay form for login/register.
   * @param {'new'|'continue'} mode
   */
  _showAuthForm(mode) {
    this._removeAuthDiv();

    const div = document.createElement('div');
    div.id = 'auth-overlay';
    div.style.cssText = `
      position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
      background: rgba(0,0,40,0.97); border: 2px solid #5577cc;
      border-radius: 8px; padding: 28px 36px; color: #ccddff;
      font-family: 'Press Start 2P', monospace; font-size: 10px; z-index: 100;
      min-width: 320px; text-align: center; box-shadow: 0 4px 32px #0008;
    `;

    const title = mode === 'new' ? 'CREATE ACCOUNT' : 'SIGN IN';
    div.innerHTML = `
      <h2 style="font-size:13px;margin:0 0 18px;color:#aaccff">${title}</h2>
      <p style="font-size:8px;color:#667799;margin:0 0 16px">
        ${mode === 'new' ? 'Choose a name for your legend.' : 'Welcome back, traveller.'}
      </p>
      <div style="text-align:left;margin-bottom:10px">
        <label style="display:block;margin-bottom:4px;color:#8899cc">USERNAME</label>
        <input id="auth-user" type="text" maxlength="32"
          style="width:100%;box-sizing:border-box;padding:6px 8px;background:#001133;
                 border:1px solid #3355aa;color:#ffffff;font-family:inherit;font-size:10px;
                 border-radius:3px;" />
      </div>
      <div style="text-align:left;margin-bottom:16px">
        <label style="display:block;margin-bottom:4px;color:#8899cc">PASSPHRASE</label>
        <input id="auth-pass" type="password" maxlength="128"
          style="width:100%;box-sizing:border-box;padding:6px 8px;background:#001133;
                 border:1px solid #3355aa;color:#ffffff;font-family:inherit;font-size:10px;
                 border-radius:3px;" />
      </div>
      <div id="auth-error" style="color:#ff6666;font-size:8px;min-height:16px;margin-bottom:10px"></div>
      <button id="auth-submit"
        style="background:#224488;color:#ffffff;border:1px solid #5577cc;padding:8px 20px;
               font-family:inherit;font-size:10px;cursor:pointer;border-radius:3px;margin-right:8px">
        ${mode === 'new' ? 'BEGIN JOURNEY' : 'ENTER WORLD'}
      </button>
      <button id="auth-cancel"
        style="background:#330022;color:#cc8888;border:1px solid #662244;padding:8px 14px;
               font-family:inherit;font-size:10px;cursor:pointer;border-radius:3px">
        BACK
      </button>
      ${mode === 'continue'
        ? `<p style="font-size:7px;color:#445566;margin-top:12px">No account? <a id="auth-switch"
            style="color:#6688aa;cursor:pointer;text-decoration:underline">Create one</a></p>`
        : `<p style="font-size:7px;color:#445566;margin-top:12px">Already a hero? <a id="auth-switch"
            style="color:#6688aa;cursor:pointer;text-decoration:underline">Sign in</a></p>`}
    `;

    document.body.appendChild(div);
    this._authDiv = div;

    // Focus username field
    setTimeout(() => document.getElementById('auth-user')?.focus(), 50);

    document.getElementById('auth-submit').addEventListener('click', () => {
      this._handleAuthSubmit(mode);
    });
    document.getElementById('auth-cancel').addEventListener('click', () => {
      this._removeAuthDiv();
    });
    const switchLink = document.getElementById('auth-switch');
    if (switchLink) {
      switchLink.addEventListener('click', () => this._showAuthForm(mode === 'new' ? 'continue' : 'new'));
    }

    // Allow Enter key to submit
    div.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') this._handleAuthSubmit(mode);
    });
  }

  /** Handles form submission for login or register. */
  async _handleAuthSubmit(mode) {
    const username   = document.getElementById('auth-user')?.value?.trim() || '';
    const passphrase = document.getElementById('auth-pass')?.value || '';
    const errorEl    = document.getElementById('auth-error');

    errorEl.textContent = '';

    if (!username || !passphrase) {
      errorEl.textContent = 'Username and passphrase are required.';
      return;
    }

    const btn = document.getElementById('auth-submit');
    btn.textContent = '...';
    btn.disabled = true;

    try {
      if (mode === 'new') {
        await register(username, passphrase);
        this._removeAuthDiv();
        this._startNewGame();
      } else {
        await login(username, passphrase);
        this._removeAuthDiv();
        this._loadSaveOrNew();
      }
    } catch (err) {
      errorEl.textContent = err.message || 'An error occurred. Please try again.';
      btn.textContent = mode === 'new' ? 'BEGIN JOURNEY' : 'ENTER WORLD';
      btn.disabled = false;
    }
  }

  /** Removes the HTML auth overlay if present. */
  _removeAuthDiv() {
    if (this._authDiv) {
      this._authDiv.remove();
      this._authDiv = null;
    }
  }

  /** Starts a brand-new game with the default party. */
  _startNewGame() {
    const charData = this.cache.json.get('characters');
    const charDefs = charData.characters;

    const party = STARTING_PARTY.map((id) => {
      const def = charDefs.find((c) => c.id === id);
      return {
        id:        def.id,
        name:      def.name,
        level:     1,
        exp:       0,
        hp:        def.baseStats.hp,
        mp:        def.baseStats.mp,
        abilities: [...def.startingAbilities],
        equipment: { weapon: null, armor: null, accessory: null },
      };
    });

    const gameState = {
      party,
      inventory:    [{ itemId: 'potion', qty: 3 }],
      gp:           150,
      worldFlags:   {},
      currentMap:   'overworld',
      currentPosition: { x: 11, y: 9 },
      playtime:     0,
      saveSlot:     1,
    };

    this.registry.set('gameState', gameState);
    this.scene.start('WorldMapScene');
  }

  /** After login, shows save slots and lets the player choose to continue or start fresh. */
  async _loadSaveOrNew() {
    try {
      const saves = await listSaves();
      const hasSave = saves.some((s) => !s.empty);

      if (!hasSave) {
        this._startNewGame();
        return;
      }

      this._showSaveSelectUI(saves);
    } catch {
      this._startNewGame();
    }
  }

  /** Shows save slot selection UI (Continue flow). */
  _showSaveSelectUI(saves) {
    this._removeAuthDiv();

    const { loadSave } = window.__gameModules || {};
    const div = document.createElement('div');
    div.id = 'auth-overlay';
    div.style.cssText = `
      position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
      background: rgba(0,0,40,0.97); border: 2px solid #5577cc;
      border-radius: 8px; padding: 28px 36px; color: #ccddff;
      font-family: 'Press Start 2P', monospace; font-size: 10px; z-index: 100;
      min-width: 360px; box-shadow: 0 4px 32px #0008;
    `;

    const slotsHtml = saves.map((s) => {
      if (s.empty) {
        return `<div class="save-slot" data-slot="${s.slot}"
          style="padding:10px;margin:6px 0;border:1px solid #334466;border-radius:4px;
                 cursor:pointer;color:#445566;">
          Slot ${s.slot} — Empty (New Game)
        </div>`;
      }
      const mins = Math.floor((s.playtime || 0) / 60);
      const hrs  = Math.floor(mins / 60);
      const timeStr = `${hrs}h ${mins % 60}m`;
      const party = (s.party || []).map((p) => `${p.name} Lv.${p.level}`).join(' / ');
      return `<div class="save-slot" data-slot="${s.slot}"
        style="padding:10px;margin:6px 0;border:1px solid #5577cc;border-radius:4px;cursor:pointer;">
        <div style="color:#aaccff">Slot ${s.slot}</div>
        <div style="font-size:8px;color:#8899cc;margin-top:4px">${party}</div>
        <div style="font-size:7px;color:#556688;margin-top:2px">${s.location || '?'} · ${timeStr}</div>
      </div>`;
    }).join('');

    div.innerHTML = `
      <h2 style="font-size:12px;margin:0 0 14px;color:#aaccff">SELECT SAVE</h2>
      ${slotsHtml}
      <button id="save-cancel"
        style="margin-top:12px;background:#330022;color:#cc8888;border:1px solid #662244;
               padding:7px 14px;font-family:inherit;font-size:9px;cursor:pointer;border-radius:3px">
        BACK
      </button>
    `;

    document.body.appendChild(div);
    this._authDiv = div;

    div.querySelectorAll('.save-slot').forEach((el) => {
      el.addEventListener('pointerenter', () => { el.style.background = '#112244'; });
      el.addEventListener('pointerleave', () => { el.style.background = ''; });
      el.addEventListener('click', async () => {
        const slot = parseInt(el.dataset.slot, 10);
        const save = saves.find((s) => s.slot === slot);
        this._removeAuthDiv();
        if (save && !save.empty) {
          try {
            const { data } = await (window.saveLoadModule.loadSave(slot));
            this.registry.set('gameState', { ...data, saveSlot: slot });
            this.scene.start('WorldMapScene');
          } catch {
            this._startNewGame();
          }
        } else {
          this._startNewGame();
        }
      });
    });

    document.getElementById('save-cancel').addEventListener('click', () => {
      this._removeAuthDiv();
    });
  }

  shutdown() {
    this._removeAuthDiv();
  }
}
