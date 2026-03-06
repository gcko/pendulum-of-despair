/**
 * scenes/WorldMapScene.js
 * Tile-based overworld map with:
 *  - Scrolling camera that follows the player
 *  - Grid-based movement (one tile per keypress)
 *  - Encounter system: random battles trigger on walkable grass/forest tiles
 *  - Town/dungeon transitions via interactive objects
 *  - Auto-save on map entry
 *
 * Inspired by the overworld traversal in Final Fantasy VI and Chrono Trigger.
 */

import { writeSave } from '../systems/saveLoad.js';

/** Tile ID constants — must match overworld.json tileProperties keys */
const TILE = { GRASS: 0, WATER: 1, FOREST: 2, MOUNTAIN: 3, TOWN: 4, DUNGEON: 5, PATH: 6 };

const TILE_TEXTURES = {
  [TILE.GRASS]:    'tile_grass',
  [TILE.WATER]:    'tile_water',
  [TILE.FOREST]:   'tile_forest',
  [TILE.MOUNTAIN]: 'tile_mountain',
  [TILE.TOWN]:     'tile_town',
  [TILE.DUNGEON]:  'tile_dungeon',
  [TILE.PATH]:     'tile_path',
};

/** Player movement directions. */
const DIR = { DOWN: 0, UP: 1, LEFT: 2, RIGHT: 3 };
const MOVE_DELAY_MS = 180; // ms between tile steps (movement speed)

export default class WorldMapScene extends Phaser.Scene {
  constructor() {
    super({ key: 'WorldMapScene' });
  }

  create() {
    this._mapData    = this.cache.json.get('map_overworld');
    this._gameState  = this.registry.get('gameState');
    this._tileSize   = this._mapData.tileSize;
    this._mapW       = this._mapData.width;
    this._mapH       = this._mapData.height;
    this._tiles      = this._mapData.tiles;
    this._objects    = this._mapData.objects;
    this._tileProps  = this._mapData.tileProperties;
    this._moveTimer  = 0;
    this._facing     = DIR.DOWN;
    this._stepAnim   = 0;
    this._stepsToEncounter = this._rollEncounterThreshold();
    this._stepsSinceEncounter = 0;
    this._dialogueVisible = false;

    this._buildMap();
    this._buildPlayer();
    this._buildObjectSprites();
    this._buildUI();
    this._setupCamera();
    this._setupKeys();

    // Auto-save on map entry (async, non-blocking)
    this._autoSave();

    // Show intro text on first visit
    if (!this._gameState.worldFlags.map_visited) {
      this._gameState.worldFlags.map_visited = true;
      this.time.delayedCall(500, () => {
        this.scene.launch('DialogueScene', {
          dialogue: this.cache.json.get('dialogue').dialogues.find((d) => d.id === 'intro_001'),
          onClose: () => this.scene.stop('DialogueScene'),
        });
      });
    }
  }

  update(time, delta) {
    if (this._dialogueVisible) return;

    this._moveTimer -= delta;
    if (this._moveTimer <= 0) {
      this._handleMovement();
    }

    this._updateUI();
  }

  // ── Map building ─────────────────────────────────────────────────────────────

  _buildMap() {
    this._tileSprites = [];
    const { width: camW, height: camH } = this.cameras.main;

    for (let row = 0; row < this._mapH; row++) {
      this._tileSprites[row] = [];
      for (let col = 0; col < this._mapW; col++) {
        const tileId  = this._tiles[row * this._mapW + col];
        const texKey  = TILE_TEXTURES[tileId] || 'tile_grass';
        const x = col * this._tileSize;
        const y = row * this._tileSize;
        const sprite = this.add.image(x, y, texKey).setOrigin(0, 0);
        this._tileSprites[row][col] = sprite;
      }
    }
  }

  _buildObjectSprites() {
    this._objectGroup = [];
    for (const obj of this._objects) {
      const x = obj.x * this._tileSize + this._tileSize / 2;
      const y = obj.y * this._tileSize + this._tileSize / 2;

      // Label above the object tile
      const label = this.add.text(x, y - this._tileSize * 0.8, obj.name, {
        fontFamily: '"Press Start 2P", monospace',
        fontSize:   '6px',
        color:      obj.type === 'dungeon' ? '#ff4444' : '#ffffaa',
        stroke:     '#000000',
        strokeThickness: 3,
      }).setOrigin(0.5, 1);

      this._objectGroup.push({ data: obj, label });
    }
  }

  _buildPlayer() {
    const pos = this._gameState.currentPosition || this._mapData.startPosition;
    const x = pos.x * this._tileSize + this._tileSize / 2;
    const y = pos.y * this._tileSize + this._tileSize / 2;

    // Character sprite sheet (8 frames × 32px wide)
    this._player = this.add.image(x, y, 'character').setOrigin(0.5, 0.5);
    this._playerTile = { ...pos };
    this._updatePlayerFrame();

    // Name tag
    this._playerName = this.add.text(x, y - 24, this._gameState.party[0]?.name || '', {
      fontFamily: '"Press Start 2P", monospace',
      fontSize:   '7px',
      color:      '#aaddff',
      stroke:     '#000000',
      strokeThickness: 3,
    }).setOrigin(0.5, 1);
  }

  _buildUI() {
    const { width, height } = this.cameras.main;

    // Semi-transparent map info bar at bottom
    this._uiBar = this.add.graphics().setScrollFactor(0).setDepth(10);
    this._uiBarBg = this.add.graphics().setScrollFactor(0).setDepth(9);
    this._uiBarBg.fillStyle(0x000022, 0.75);
    this._uiBarBg.fillRect(0, height - 60, width, 60);

    // Party HP display
    this._partyTexts = this._gameState.party.map((member, i) => {
      const x = 16 + i * 200;
      const y = height - 52;
      const nameText = this.add.text(x, y, member.name, {
        fontFamily: '"Press Start 2P", monospace', fontSize: '7px', color: '#aaccff',
      }).setScrollFactor(0).setDepth(11);

      const hpText = this.add.text(x, y + 14, `HP ${member.hp}/${member.hp}`, {
        fontFamily: '"Press Start 2P", monospace', fontSize: '6px', color: '#44ff44',
      }).setScrollFactor(0).setDepth(11);

      const mpText = this.add.text(x, y + 26, `MP ${member.mp}/${member.mp}`, {
        fontFamily: '"Press Start 2P", monospace', fontSize: '6px', color: '#4488ff',
      }).setScrollFactor(0).setDepth(11);

      return { member, nameText, hpText, mpText };
    });

    // Map name
    this._mapNameText = this.add.text(width - 8, height - 52, this._mapData.name, {
      fontFamily: '"Press Start 2P", monospace', fontSize: '8px', color: '#7799cc',
    }).setScrollFactor(0).setDepth(11).setOrigin(1, 0);

    // GP counter
    this._gpText = this.add.text(width - 8, height - 38, `${this._gameState.gp || 0} GP`, {
      fontFamily: '"Press Start 2P", monospace', fontSize: '7px', color: '#ddbb44',
    }).setScrollFactor(0).setDepth(11).setOrigin(1, 0);

    // Location info (shown briefly when entering a new tile near a landmark)
    this._locationText = this.add.text(width / 2, 16, '', {
      fontFamily: '"Press Start 2P", monospace', fontSize: '9px', color: '#ffffaa',
      stroke: '#000000', strokeThickness: 3,
    }).setScrollFactor(0).setDepth(11).setOrigin(0.5, 0).setAlpha(0);
  }

  _setupCamera() {
    const totalW = this._mapW * this._tileSize;
    const totalH = this._mapH * this._tileSize;
    this.cameras.main.setBounds(0, 0, totalW, totalH);
    this.cameras.main.startFollow(this._player, true, 0.12, 0.12);
    this.cameras.main.setZoom(1.5);
  }

  _setupKeys() {
    this._cursors = this.input.keyboard.createCursorKeys();
    this._wasd    = this.input.keyboard.addKeys({ up: 'W', down: 'S', left: 'A', right: 'D' });
    this._input   = this.input.keyboard.addKeys({ action: 'SPACE', menu: 'ESC' });
    this._input.menu.on('down', () => this._openPauseMenu());
  }

  // ── Movement & encounters ────────────────────────────────────────────────────

  _handleMovement() {
    let dx = 0, dy = 0;
    const c = this._cursors, w = this._wasd;

    if      (c.left.isDown  || w.left.isDown)  { dx = -1; this._facing = DIR.LEFT; }
    else if (c.right.isDown || w.right.isDown) { dx =  1; this._facing = DIR.RIGHT; }
    else if (c.up.isDown    || w.up.isDown)    { dy = -1; this._facing = DIR.UP; }
    else if (c.down.isDown  || w.down.isDown)  { dy =  1; this._facing = DIR.DOWN; }
    else return;

    const newTileX = this._playerTile.x + dx;
    const newTileY = this._playerTile.y + dy;

    // Bounds check
    if (newTileX < 0 || newTileX >= this._mapW || newTileY < 0 || newTileY >= this._mapH) return;

    // Collision check
    const tileId   = this._tiles[newTileY * this._mapW + newTileX];
    const tileInfo = this._tileProps[String(tileId)];
    if (!tileInfo || !tileInfo.walkable) {
      this._facing = dy > 0 ? DIR.DOWN : dy < 0 ? DIR.UP : dx < 0 ? DIR.LEFT : DIR.RIGHT;
      this._updatePlayerFrame();
      this._moveTimer = MOVE_DELAY_MS;
      return;
    }

    // Move
    this._playerTile.x = newTileX;
    this._playerTile.y = newTileY;
    this._stepAnim ^= 1;
    this._updatePlayerFrame();

    const worldX = newTileX * this._tileSize + this._tileSize / 2;
    const worldY = newTileY * this._tileSize + this._tileSize / 2;
    this._player.setPosition(worldX, worldY);
    this._playerName.setPosition(worldX, worldY - 24);

    this._moveTimer = MOVE_DELAY_MS;

    // Check for object interaction (entering a town/dungeon tile)
    this._checkObjectInteraction(newTileX, newTileY);

    // Random encounter check
    if (tileInfo.encounterRate > 0) {
      this._stepsSinceEncounter++;
      if (this._stepsSinceEncounter >= this._stepsToEncounter) {
        const roll = Math.random();
        if (roll < tileInfo.encounterRate) {
          this._triggerEncounter(tileId);
          return;
        }
      }
    }

    // Save position to game state
    this._gameState.currentPosition = { x: newTileX, y: newTileY };
  }

  _updatePlayerFrame() {
    // Character texture is a 1-row sprite sheet: 8 frames × 32px
    // Frame = facing * 2 + animStep
    const frameIndex  = this._facing * 2 + this._stepAnim;
    const totalFrames = 8;
    const frameW      = 1 / totalFrames;

    this._player.setCrop(frameIndex * 32, 0, 32, 32);
    // Since setCrop uses pixel coords and the texture is 256px wide:
    // We don't need UV adjustment — setCrop handles it
  }

  _checkObjectInteraction(tileX, tileY) {
    const obj = this._objects.find((o) => o.x === tileX && o.y === tileY);
    if (!obj) return;

    this._dialogueVisible = true;
    const dialData = this.cache.json.get('dialogue');
    const dial = {
      id: `obj_${obj.id}`,
      speaker: obj.name,
      pages: obj.dialogue || [`Entering ${obj.name}...`],
      next: null,
    };

    this.scene.launch('DialogueScene', {
      dialogue: dial,
      onClose: () => {
        this._dialogueVisible = false;
        this.scene.stop('DialogueScene');
        // If it's a town or dungeon, show location notice
        this._flashLocation(obj.name);
      },
    });
  }

  _rollEncounterThreshold() {
    // Steps before encounter checks begin: random between 8 and 20
    return Math.floor(Math.random() * 12) + 8;
  }

  _triggerEncounter(tileId) {
    this._stepsSinceEncounter = 0;
    this._stepsToEncounter    = this._rollEncounterThreshold();

    const tileType = ['grass', 'water', 'forest', 'mountain', 'town', 'dungeon', 'path'][tileId] || 'grass';
    const groups   = this._mapData.encounterGroups;
    const pool     = groups[tileType] || groups.grass;

    // Pick 1–3 enemies from the pool
    const enemiesData = this.cache.json.get('enemies').enemies;
    const count = Math.floor(Math.random() * 2) + 1;
    const enemyIds = [];
    for (let i = 0; i < count; i++) {
      enemyIds.push(pool[Math.floor(Math.random() * pool.length)]);
    }
    const enemies = enemyIds.map((id) => enemiesData.find((e) => e.id === id)).filter(Boolean);

    // Flash transition before battle
    this.cameras.main.flash(300, 255, 255, 255);
    this.time.delayedCall(300, () => {
      this.scene.launch('BattleScene', {
        enemies,
        gameState: this._gameState,
        onBattleEnd: (result) => {
          this.scene.stop('BattleScene');
          if (result === 'gameover') {
            this.scene.start('TitleScene');
          } else {
            // Update game state after battle
            this._gameState = this.registry.get('gameState');
            this._autoSave();
          }
        },
      });
    });
  }

  // ── UI helpers ───────────────────────────────────────────────────────────────

  _updateUI() {
    const state = this._gameState;
    this._partyTexts.forEach(({ member, hpText, mpText }, i) => {
      const live = state.party[i];
      if (!live) return;
      const hpColor = live.hp / live.maxHp < 0.25 ? '#ff4444' : '#44ff44';
      hpText.setText(`HP ${live.hp}/${live.maxHp || live.hp}`).setColor(hpColor);
      mpText.setText(`MP ${live.mp}/${live.maxMp || live.mp}`);
    });
    this._gpText.setText(`${state.gp || 0} GP`);
  }

  _flashLocation(name) {
    this._locationText.setText(name).setAlpha(1);
    this.tweens.add({ targets: this._locationText, alpha: 0, delay: 2000, duration: 800 });
  }

  _openPauseMenu() {
    // Future: launch pause/menu scene
    console.log('[WorldMap] Pause menu not yet implemented');
  }

  async _autoSave() {
    try {
      const state = this._gameState;
      if (!state) return;
      const slot = state.saveSlot || 1;
      await writeSave(slot, {
        party:           state.party,
        inventory:       state.inventory,
        gp:              state.gp,
        worldFlags:      state.worldFlags,
        currentMap:      state.currentMap,
        currentPosition: state.currentPosition,
        playtime:        state.playtime || 0,
      });
    } catch (e) {
      console.warn('[AutoSave] Failed:', e.message);
    }
  }
}
