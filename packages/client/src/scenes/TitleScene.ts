/**
 * scenes/TitleScene.ts
 * Title screen with login/register UI.
 */

import Phaser from "phaser";
import { login, register, listSaves, loadSave } from "../systems/saveLoad.js";

interface CharacterDef {
  id: string;
  name: string;
  baseStats: {
    hp: number;
    mp: number;
    str: number;
    def: number;
    mag: number;
    mdef: number;
    spd: number;
    lck: number;
  };
  startingAbilities: string[];
}

interface CharactersData {
  characters: CharacterDef[];
}

interface SaveSlot {
  slot: number;
  empty?: boolean;
  playtime?: number;
  location?: string;
  party?: Array<{ name: string; level: number }>;
}

interface GameState {
  party: Array<{
    id: string;
    name: string;
    level: number;
    exp: number;
    hp: number;
    mp: number;
    abilities: string[];
    equipment: { weapon: string | null; armor: string | null; accessory: string | null };
    [key: string]: unknown;
  }>;
  inventory: Array<{ itemId: string; qty: number }>;
  gp: number;
  worldFlags: Record<string, boolean>;
  currentMap: string;
  currentPosition: { x: number; y: number };
  playtime: number;
  saveSlot: number;
}

const STARTING_PARTY = ["terra", "locke"];

export default class TitleScene extends Phaser.Scene {
  private _particles: Array<{ obj: Phaser.GameObjects.Arc; speed: number }> = [];
  private _authDiv: HTMLDivElement | null = null;
  private _menuOptions: Phaser.GameObjects.Text[] = [];

  constructor() {
    super({ key: "TitleScene" });
  }

  create(): void {
    const { width, height } = this.cameras.main;

    const bg = this.add.graphics();
    bg.fillGradientStyle(0x000022, 0x000022, 0x000044, 0x000044, 1);
    bg.fillRect(0, 0, width, height);

    this._particles = [];
    for (let i = 0; i < 80; i++) {
      const x = Math.random() * width;
      const y = Math.random() * height;
      const r = Math.random() * 2 + 0.5;
      const star = this.add.circle(x, y, r, 0xffffff, Math.random() * 0.8 + 0.2);
      this._particles.push({ obj: star, speed: Math.random() * 0.3 + 0.05 });
    }

    this.add.text(width / 2, height * 0.22, "PENDULUM", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "28px",
      color: "#aaccff",
      stroke: "#002266",
      strokeThickness: 6,
    }).setOrigin(0.5);

    this.add.text(width / 2, height * 0.35, "OF DESPAIR", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "20px",
      color: "#7799ee",
      stroke: "#001144",
      strokeThickness: 4,
    }).setOrigin(0.5);

    this.add.text(width / 2, height * 0.48, "~ Echoes of a Forgotten Age ~", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "8px",
      color: "#445588",
    }).setOrigin(0.5);

    this._menuOptions = [];
    const opts = ["NEW GAME", "CONTINUE"];
    opts.forEach((label, i) => {
      const y = height * 0.65 + i * 44;
      const txt = this.add.text(width / 2, y, label, {
        fontFamily: '"Press Start 2P", monospace',
        fontSize: "14px",
        color: "#ddddff",
        stroke: "#000022",
        strokeThickness: 3,
      }).setOrigin(0.5).setInteractive({ useHandCursor: true });

      txt.on("pointerover", () => txt.setColor("#ffffff"));
      txt.on("pointerout", () => txt.setColor("#ddddff"));
      txt.on("pointerdown", () => this._onMenuSelect(i));
      this._menuOptions.push(txt);
    });

    const pressEnter = this.add.text(width / 2, height * 0.9, "Press Enter", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "10px",
      color: "#8899cc",
    }).setOrigin(0.5);
    this.tweens.add({ targets: pressEnter, alpha: 0, duration: 600, yoyo: true, repeat: -1 });

    this.input.keyboard?.once("keydown-ENTER", () => this._onMenuSelect(0));

    this.add.text(8, height - 20, "v0.1.0 -- Alpha", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "7px",
      color: "#334466",
    });
  }

  update(): void {
    for (const star of this._particles) {
      star.obj.y += star.speed;
      if (star.obj.y > this.cameras.main.height + 4) {
        star.obj.y = -4;
        star.obj.x = Math.random() * this.cameras.main.width;
      }
    }
  }

  private _onMenuSelect(index: number): void {
    this._removeAuthDiv();
    this._showAuthForm(index === 0 ? "new" : "continue");
  }

  private _showAuthForm(mode: "new" | "continue"): void {
    this._removeAuthDiv();

    const div = document.createElement("div");
    div.id = "auth-overlay";
    div.style.cssText = `
      position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
      background: rgba(0,0,40,0.97); border: 2px solid #5577cc;
      border-radius: 8px; padding: 28px 36px; color: #ccddff;
      font-family: 'Press Start 2P', monospace; font-size: 10px; z-index: 100;
      min-width: 320px; text-align: center; box-shadow: 0 4px 32px #0008;
    `;

    const title = mode === "new" ? "CREATE ACCOUNT" : "SIGN IN";
    div.innerHTML = `
      <h2 style="font-size:13px;margin:0 0 18px;color:#aaccff">${title}</h2>
      <p style="font-size:8px;color:#667799;margin:0 0 16px">
        ${mode === "new" ? "Choose a name for your legend." : "Welcome back, traveller."}
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
        ${mode === "new" ? "BEGIN JOURNEY" : "ENTER WORLD"}
      </button>
      <button id="auth-cancel"
        style="background:#330022;color:#cc8888;border:1px solid #662244;padding:8px 14px;
               font-family:inherit;font-size:10px;cursor:pointer;border-radius:3px">
        BACK
      </button>
      ${mode === "continue"
        ? `<p style="font-size:7px;color:#445566;margin-top:12px">No account? <a id="auth-switch"
            style="color:#6688aa;cursor:pointer;text-decoration:underline">Create one</a></p>`
        : `<p style="font-size:7px;color:#445566;margin-top:12px">Already a hero? <a id="auth-switch"
            style="color:#6688aa;cursor:pointer;text-decoration:underline">Sign in</a></p>`}
    `;

    document.body.appendChild(div);
    this._authDiv = div;

    setTimeout(() => (document.getElementById("auth-user") as HTMLInputElement | null)?.focus(), 50);

    document.getElementById("auth-submit")?.addEventListener("click", () => {
      void this._handleAuthSubmit(mode);
    });
    document.getElementById("auth-cancel")?.addEventListener("click", () => {
      this._removeAuthDiv();
    });
    const switchLink = document.getElementById("auth-switch");
    if (switchLink) {
      switchLink.addEventListener("click", () => this._showAuthForm(mode === "new" ? "continue" : "new"));
    }

    div.addEventListener("keydown", (e: KeyboardEvent) => {
      if (e.key === "Enter") void this._handleAuthSubmit(mode);
    });
  }

  private async _handleAuthSubmit(mode: "new" | "continue"): Promise<void> {
    const username = (document.getElementById("auth-user") as HTMLInputElement | null)?.value?.trim() ?? "";
    const passphrase = (document.getElementById("auth-pass") as HTMLInputElement | null)?.value ?? "";
    const errorEl = document.getElementById("auth-error");

    if (errorEl) errorEl.textContent = "";

    if (!username || !passphrase) {
      if (errorEl) errorEl.textContent = "Username and passphrase are required.";
      return;
    }

    const btn = document.getElementById("auth-submit") as HTMLButtonElement | null;
    if (btn) {
      btn.textContent = "...";
      btn.disabled = true;
    }

    try {
      if (mode === "new") {
        await register(username, passphrase);
        this._removeAuthDiv();
        this._startNewGame();
      } else {
        await login(username, passphrase);
        this._removeAuthDiv();
        await this._loadSaveOrNew();
      }
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "An error occurred. Please try again.";
      if (errorEl) errorEl.textContent = message;
      if (btn) {
        btn.textContent = mode === "new" ? "BEGIN JOURNEY" : "ENTER WORLD";
        btn.disabled = false;
      }
    }
  }

  private _removeAuthDiv(): void {
    if (this._authDiv) {
      this._authDiv.remove();
      this._authDiv = null;
    }
  }

  private _startNewGame(): void {
    const charData = this.cache.json.get("characters") as CharactersData;
    const charDefs = charData.characters;

    const party = STARTING_PARTY.map((id) => {
      const def = charDefs.find((c) => c.id === id);
      if (!def) throw new Error(`Character definition not found: ${id}`);
      return {
        id: def.id,
        name: def.name,
        level: 1,
        exp: 0,
        hp: def.baseStats.hp,
        mp: def.baseStats.mp,
        abilities: [...def.startingAbilities],
        equipment: { weapon: null, armor: null, accessory: null },
      };
    });

    const gameState: GameState = {
      party,
      inventory: [{ itemId: "potion", qty: 3 }],
      gp: 150,
      worldFlags: {},
      currentMap: "overworld",
      currentPosition: { x: 11, y: 9 },
      playtime: 0,
      saveSlot: 1,
    };

    this.registry.set("gameState", gameState);
    this.scene.start("WorldMapScene");
  }

  private async _loadSaveOrNew(): Promise<void> {
    try {
      const saves = await listSaves();
      const hasSave = saves.some((s) => !s.empty);

      if (!hasSave) {
        this._startNewGame();
        return;
      }

      this._showSaveSelectUI(saves as SaveSlot[]);
    } catch {
      this._startNewGame();
    }
  }

  private _showSaveSelectUI(saves: SaveSlot[]): void {
    this._removeAuthDiv();

    const div = document.createElement("div");
    div.id = "auth-overlay";
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
          Slot ${s.slot} -- Empty (New Game)
        </div>`;
      }
      const mins = Math.floor((s.playtime ?? 0) / 60);
      const hrs = Math.floor(mins / 60);
      const timeStr = `${hrs}h ${mins % 60}m`;
      const partyStr = (s.party ?? []).map((p) => `${p.name} Lv.${p.level}`).join(" / ");
      return `<div class="save-slot" data-slot="${s.slot}"
        style="padding:10px;margin:6px 0;border:1px solid #5577cc;border-radius:4px;cursor:pointer;">
        <div style="color:#aaccff">Slot ${s.slot}</div>
        <div style="font-size:8px;color:#8899cc;margin-top:4px">${partyStr}</div>
        <div style="font-size:7px;color:#556688;margin-top:2px">${s.location ?? "?"} - ${timeStr}</div>
      </div>`;
    }).join("");

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

    div.querySelectorAll(".save-slot").forEach((el) => {
      const htmlEl = el as HTMLElement;
      htmlEl.addEventListener("pointerenter", () => { htmlEl.style.background = "#112244"; });
      htmlEl.addEventListener("pointerleave", () => { htmlEl.style.background = ""; });
      htmlEl.addEventListener("click", () => {
        const slot = parseInt(htmlEl.dataset["slot"] ?? "1", 10);
        const save = saves.find((s) => s.slot === slot);
        this._removeAuthDiv();
        if (save && !save.empty) {
          void (async () => {
            try {
              const loaded = await loadSave(slot);
              this.registry.set("gameState", { ...loaded.data, saveSlot: slot });
              this.scene.start("WorldMapScene");
            } catch {
              this._startNewGame();
            }
          })();
        } else {
          this._startNewGame();
        }
      });
    });

    document.getElementById("save-cancel")?.addEventListener("click", () => {
      this._removeAuthDiv();
    });
  }

  shutdown(): void {
    this._removeAuthDiv();
  }
}
