/**
 * scenes/WorldMapScene.ts
 * Tile-based overworld map with scrolling camera, grid movement,
 * encounter system, and town/dungeon transitions.
 */

import Phaser from "phaser";
import { writeSave } from "../systems/saveLoad.js";

const TILE = { GRASS: 0, WATER: 1, FOREST: 2, MOUNTAIN: 3, TOWN: 4, DUNGEON: 5, PATH: 6 } as const;

const TILE_TEXTURES: Record<number, string> = {
  [TILE.GRASS]: "tile_grass",
  [TILE.WATER]: "tile_water",
  [TILE.FOREST]: "tile_forest",
  [TILE.MOUNTAIN]: "tile_mountain",
  [TILE.TOWN]: "tile_town",
  [TILE.DUNGEON]: "tile_dungeon",
  [TILE.PATH]: "tile_path",
};

const DIR = { DOWN: 0, UP: 1, LEFT: 2, RIGHT: 3 } as const;
const MOVE_DELAY_MS = 180;

interface TileProperty {
  name: string;
  walkable: boolean;
  encounterRate: number;
  color: string;
}

interface MapObject {
  id: string;
  type: string;
  name: string;
  x: number;
  y: number;
  mapTarget?: string;
  dialogue?: string[];
}

interface MapData {
  id: string;
  name: string;
  width: number;
  height: number;
  tileSize: number;
  startPosition: { x: number; y: number };
  tiles: number[];
  tileProperties: Record<string, TileProperty>;
  objects: MapObject[];
  encounterGroups: Record<string, string[]>;
}

interface DialogueEntry {
  id: string;
  speaker?: string;
  pages: string[];
  next?: string | null;
  choices?: Array<{ text: string; next?: string | null; action?: string }>;
}

interface DialogueData {
  dialogues: DialogueEntry[];
}

interface EnemyDef {
  id: string;
  name: string;
  [key: string]: unknown;
}

interface EnemiesData {
  enemies: EnemyDef[];
}

interface PartyMemberState {
  id: string;
  name: string;
  level: number;
  hp: number;
  mp: number;
  maxHp?: number;
  maxMp?: number;
  [key: string]: unknown;
}

interface GameState {
  party: PartyMemberState[];
  inventory: Array<{ itemId: string; qty: number }>;
  gp: number;
  worldFlags: Record<string, boolean>;
  currentMap: string;
  currentPosition: { x: number; y: number };
  playtime: number;
  saveSlot: number;
}

interface PartyTextEntry {
  member: PartyMemberState;
  nameText: Phaser.GameObjects.Text;
  hpText: Phaser.GameObjects.Text;
  mpText: Phaser.GameObjects.Text;
}

export default class WorldMapScene extends Phaser.Scene {
  private _mapData!: MapData;
  private _gameState!: GameState;
  private _tileSize!: number;
  private _mapW!: number;
  private _mapH!: number;
  private _tiles!: number[];
  private _objects!: MapObject[];
  private _tileProps!: Record<string, TileProperty>;
  private _moveTimer: number = 0;
  private _facing: number = DIR.DOWN;
  private _stepAnim: number = 0;
  private _stepsToEncounter: number = 0;
  private _stepsSinceEncounter: number = 0;
  private _dialogueVisible: boolean = false;
  private _tileSprites: Phaser.GameObjects.Image[][] = [];
  private _objectGroup: Array<{ data: MapObject; label: Phaser.GameObjects.Text }> = [];
  private _player!: Phaser.GameObjects.Image;
  private _playerTile!: { x: number; y: number };
  private _playerName!: Phaser.GameObjects.Text;
  private _partyTexts: PartyTextEntry[] = [];
  private _gpText!: Phaser.GameObjects.Text;
  private _locationText!: Phaser.GameObjects.Text;
  private _cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private _wasd!: Record<string, Phaser.Input.Keyboard.Key>;
  private _input!: Record<string, Phaser.Input.Keyboard.Key>;

  constructor() {
    super({ key: "WorldMapScene" });
  }

  create(): void {
    this._mapData = this.cache.json.get("map_overworld") as MapData;
    this._gameState = this.registry.get("gameState") as GameState;
    this._tileSize = this._mapData.tileSize;
    this._mapW = this._mapData.width;
    this._mapH = this._mapData.height;
    this._tiles = this._mapData.tiles;
    this._objects = this._mapData.objects;
    this._tileProps = this._mapData.tileProperties;
    this._moveTimer = 0;
    this._facing = DIR.DOWN;
    this._stepAnim = 0;
    this._stepsToEncounter = this._rollEncounterThreshold();
    this._stepsSinceEncounter = 0;
    this._dialogueVisible = false;

    this._buildMap();
    this._buildPlayer();
    this._buildObjectSprites();
    this._buildUI();
    this._setupCamera();
    this._setupKeys();

    void this._autoSave();

    if (!this._gameState.worldFlags["map_visited"]) {
      this._gameState.worldFlags["map_visited"] = true;
      this._dialogueVisible = true;
      this.time.delayedCall(500, () => {
        const allDialogues = (this.cache.json.get("dialogue") as DialogueData).dialogues;
        this.scene.launch("DialogueScene", {
          dialogue: allDialogues.find((d) => d.id === "intro_001"),
          allDialogues,
          onClose: () => {
            this._dialogueVisible = false;
            this.scene.stop("DialogueScene");
          },
        });
      });
    }
  }

  update(_time: number, delta: number): void {
    if (this._dialogueVisible) return;

    this._moveTimer -= delta;
    if (this._moveTimer <= 0) {
      this._handleMovement();
    }

    this._updateUI();
  }

  private _buildMap(): void {
    this._tileSprites = [];

    for (let row = 0; row < this._mapH; row++) {
      this._tileSprites[row] = [];
      for (let col = 0; col < this._mapW; col++) {
        const tileId = this._tiles[row * this._mapW + col] ?? 0;
        const texKey = TILE_TEXTURES[tileId] ?? "tile_grass";
        const x = col * this._tileSize;
        const y = row * this._tileSize;
        const sprite = this.add.image(x, y, texKey).setOrigin(0, 0);
        this._tileSprites[row]![col] = sprite;
      }
    }
  }

  private _buildObjectSprites(): void {
    this._objectGroup = [];
    for (const obj of this._objects) {
      const x = obj.x * this._tileSize + this._tileSize / 2;
      const y = obj.y * this._tileSize + this._tileSize / 2;

      const label = this.add.text(x, y - this._tileSize * 0.8, obj.name, {
        fontFamily: '"Press Start 2P", monospace',
        fontSize: "6px",
        color: obj.type === "dungeon" ? "#ff4444" : "#ffffaa",
        stroke: "#000000",
        strokeThickness: 3,
      }).setOrigin(0.5, 1);

      this._objectGroup.push({ data: obj, label });
    }
  }

  private _buildPlayer(): void {
    const pos = this._gameState.currentPosition ?? this._mapData.startPosition;
    const x = pos.x * this._tileSize + this._tileSize / 2;
    const y = pos.y * this._tileSize + this._tileSize / 2;

    this._player = this.add.image(x, y, "character").setOrigin(0.5, 0.5);
    this._playerTile = { ...pos };
    this._updatePlayerFrame();

    this._playerName = this.add.text(x, y - 24, this._gameState.party[0]?.name ?? "", {
      fontFamily: '"Press Start 2P", monospace',
      fontSize: "7px",
      color: "#aaddff",
      stroke: "#000000",
      strokeThickness: 3,
    }).setOrigin(0.5, 1);
  }

  private _buildUI(): void {
    const { width, height } = this.cameras.main;

    this.add.graphics().setScrollFactor(0).setDepth(10);
    const uiBarBg = this.add.graphics().setScrollFactor(0).setDepth(9);
    uiBarBg.fillStyle(0x000022, 0.75);
    uiBarBg.fillRect(0, height - 60, width, 60);

    this._partyTexts = this._gameState.party.map((member, i) => {
      const x = 16 + i * 200;
      const y = height - 52;
      const nameText = this.add.text(x, y, member.name, {
        fontFamily: '"Press Start 2P", monospace', fontSize: "7px", color: "#aaccff",
      }).setScrollFactor(0).setDepth(11);

      const hpText = this.add.text(x, y + 14, `HP ${member.hp}/${member.maxHp ?? member.hp}`, {
        fontFamily: '"Press Start 2P", monospace', fontSize: "6px", color: "#44ff44",
      }).setScrollFactor(0).setDepth(11);

      const mpText = this.add.text(x, y + 26, `MP ${member.mp}/${member.maxMp ?? member.mp}`, {
        fontFamily: '"Press Start 2P", monospace', fontSize: "6px", color: "#4488ff",
      }).setScrollFactor(0).setDepth(11);

      return { member, nameText, hpText, mpText };
    });

    this.add.text(width - 8, height - 52, this._mapData.name, {
      fontFamily: '"Press Start 2P", monospace', fontSize: "8px", color: "#7799cc",
    }).setScrollFactor(0).setDepth(11).setOrigin(1, 0);

    this._gpText = this.add.text(width - 8, height - 38, `${this._gameState.gp ?? 0} GP`, {
      fontFamily: '"Press Start 2P", monospace', fontSize: "7px", color: "#ddbb44",
    }).setScrollFactor(0).setDepth(11).setOrigin(1, 0);

    this._locationText = this.add.text(width / 2, 16, "", {
      fontFamily: '"Press Start 2P", monospace', fontSize: "9px", color: "#ffffaa",
      stroke: "#000000", strokeThickness: 3,
    }).setScrollFactor(0).setDepth(11).setOrigin(0.5, 0).setAlpha(0);
  }

  private _setupCamera(): void {
    const totalW = this._mapW * this._tileSize;
    const totalH = this._mapH * this._tileSize;
    this.cameras.main.setBounds(0, 0, totalW, totalH);
    this.cameras.main.startFollow(this._player, true, 0.12, 0.12);
    this.cameras.main.setZoom(1.5);
  }

  private _setupKeys(): void {
    this._cursors = this.input.keyboard!.createCursorKeys();
    this._wasd = this.input.keyboard!.addKeys({ up: "W", down: "S", left: "A", right: "D" }) as Record<string, Phaser.Input.Keyboard.Key>;
    this._input = this.input.keyboard!.addKeys({ action: "SPACE", menu: "ESC" }) as Record<string, Phaser.Input.Keyboard.Key>;
    this._input["menu"]!.on("down", () => this._openPauseMenu());
  }

  private _handleMovement(): void {
    let dx = 0, dy = 0;
    const c = this._cursors, w = this._wasd;

    if (c.left.isDown || w["left"]!.isDown) { dx = -1; this._facing = DIR.LEFT; }
    else if (c.right.isDown || w["right"]!.isDown) { dx = 1; this._facing = DIR.RIGHT; }
    else if (c.up.isDown || w["up"]!.isDown) { dy = -1; this._facing = DIR.UP; }
    else if (c.down.isDown || w["down"]!.isDown) { dy = 1; this._facing = DIR.DOWN; }
    else return;

    const newTileX = this._playerTile.x + dx;
    const newTileY = this._playerTile.y + dy;

    if (newTileX < 0 || newTileX >= this._mapW || newTileY < 0 || newTileY >= this._mapH) return;

    const tileId = this._tiles[newTileY * this._mapW + newTileX];
    const tileInfo = this._tileProps[String(tileId)];
    if (!tileInfo || !tileInfo.walkable) {
      this._facing = dy > 0 ? DIR.DOWN : dy < 0 ? DIR.UP : dx < 0 ? DIR.LEFT : DIR.RIGHT;
      this._updatePlayerFrame();
      this._moveTimer = MOVE_DELAY_MS;
      return;
    }

    this._playerTile.x = newTileX;
    this._playerTile.y = newTileY;
    this._stepAnim ^= 1;
    this._updatePlayerFrame();

    const worldX = newTileX * this._tileSize + this._tileSize / 2;
    const worldY = newTileY * this._tileSize + this._tileSize / 2;
    this._player.setPosition(worldX, worldY);
    this._playerName.setPosition(worldX, worldY - 24);

    this._moveTimer = MOVE_DELAY_MS;

    this._checkObjectInteraction(newTileX, newTileY);

    if (tileInfo.encounterRate > 0) {
      this._stepsSinceEncounter++;
      if (this._stepsSinceEncounter >= this._stepsToEncounter) {
        const roll = Math.random();
        if (roll < tileInfo.encounterRate) {
          this._triggerEncounter(tileId ?? 0);
          return;
        }
      }
    }

    this._gameState.currentPosition = { x: newTileX, y: newTileY };
  }

  private _updatePlayerFrame(): void {
    const frameIndex = this._facing * 2 + this._stepAnim;
    this._player.setCrop(frameIndex * 32, 0, 32, 32);
  }

  private _checkObjectInteraction(tileX: number, tileY: number): void {
    const obj = this._objects.find((o) => o.x === tileX && o.y === tileY);
    if (!obj) return;

    this._dialogueVisible = true;
    const dial = {
      id: `obj_${obj.id}`,
      speaker: obj.name,
      pages: obj.dialogue ?? [`Entering ${obj.name}...`],
      next: null,
    };

    this.scene.launch("DialogueScene", {
      dialogue: dial,
      onClose: () => {
        this._dialogueVisible = false;
        this.scene.stop("DialogueScene");
        this._flashLocation(obj.name);
      },
    });
  }

  private _rollEncounterThreshold(): number {
    return Math.floor(Math.random() * 12) + 8;
  }

  private _triggerEncounter(tileId: number): void {
    this._stepsSinceEncounter = 0;
    this._stepsToEncounter = this._rollEncounterThreshold();

    const tileType = ["grass", "water", "forest", "mountain", "town", "dungeon", "path"][tileId] ?? "grass";
    const groups = this._mapData.encounterGroups;
    const pool = groups[tileType] ?? groups["grass"] ?? [];

    const enemiesData = (this.cache.json.get("enemies") as EnemiesData).enemies;
    const count = Math.floor(Math.random() * 2) + 1;
    const enemyIds: string[] = [];
    for (let i = 0; i < count; i++) {
      enemyIds.push(pool[Math.floor(Math.random() * pool.length)]!);
    }
    const enemies = enemyIds.map((id) => enemiesData.find((e) => e.id === id)).filter(Boolean);

    this.cameras.main.flash(300, 255, 255, 255);
    this.time.delayedCall(300, () => {
      this.scene.launch("BattleScene", {
        enemies,
        gameState: this._gameState,
        onBattleEnd: (result: string) => {
          this.scene.stop("BattleScene");
          if (result === "gameover") {
            this.scene.start("TitleScene");
          } else {
            this._gameState = this.registry.get("gameState") as GameState;
            void this._autoSave();
          }
        },
      });
    });
  }

  private _updateUI(): void {
    const state = this._gameState;
    this._partyTexts.forEach(({ hpText, mpText }, i) => {
      const live = state.party[i];
      if (!live) return;
      const maxHp = (live.maxHp ?? live.hp);
      const hpColor = live.hp / maxHp < 0.25 ? "#ff4444" : "#44ff44";
      hpText.setText(`HP ${live.hp}/${maxHp}`).setColor(hpColor);
      mpText.setText(`MP ${live.mp}/${live.maxMp ?? live.mp}`);
    });
    this._gpText.setText(`${state.gp ?? 0} GP`);
  }

  private _flashLocation(name: string): void {
    this._locationText.setText(name).setAlpha(1);
    this.tweens.add({ targets: this._locationText, alpha: 0, delay: 2000, duration: 800 });
  }

  private _openPauseMenu(): void {
    // Future: launch pause/menu scene
  }

  private async _autoSave(): Promise<void> {
    try {
      const state = this._gameState;
      if (!state) return;
      const slot = state.saveSlot ?? 1;
      await writeSave(slot, {
        party: state.party,
        inventory: state.inventory,
        gp: state.gp,
        worldFlags: state.worldFlags,
        currentMap: state.currentMap,
        currentPosition: state.currentPosition,
        playtime: state.playtime ?? 0,
      });
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : "Unknown error";
      console.warn("[AutoSave] Failed:", message);
    }
  }
}
