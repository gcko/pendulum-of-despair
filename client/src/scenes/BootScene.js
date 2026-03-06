/**
 * scenes/BootScene.js
 * Phaser BootScene — first scene to run.
 * Loads all static JSON data and generates placeholder textures via Phaser's
 * built-in graphics, since we don't have actual sprite sheets yet.
 *
 * All asset keys created here are referenced by other scenes.
 */

export default class BootScene extends Phaser.Scene {
  constructor() {
    super({ key: 'BootScene' });
  }

  preload() {
    // Progress bar background
    const { width, height } = this.cameras.main;
    const barBg = this.add.graphics();
    barBg.fillStyle(0x111122, 1);
    barBg.fillRect(width / 2 - 160, height / 2 - 16, 320, 32);

    const barFill = this.add.graphics();

    this.load.on('progress', (value) => {
      barFill.clear();
      barFill.fillStyle(0x4488ff, 1);
      barFill.fillRect(width / 2 - 158, height / 2 - 14, 316 * value, 28);
    });

    // Load JSON data files
    this.load.json('characters', 'src/data/characters.json');
    this.load.json('enemies',    'src/data/enemies.json');
    this.load.json('items',      'src/data/items.json');
    this.load.json('abilities',  'src/data/abilities.json');
    this.load.json('dialogue',   'src/data/dialogue.json');
    this.load.json('map_overworld', 'src/data/maps/overworld.json');
  }

  create() {
    // Generate placeholder textures using Phaser graphics API.
    // In a full project, replace these with actual sprite sheets.
    this._generateTileTextures();
    this._generateCharacterSprite();
    this._generateEnemySprites();
    this._generateUITextures();

    // Build ability lookup map and store in global registry
    const abilitiesData = this.cache.json.get('abilities');
    const abilityMap = {};
    for (const ab of abilitiesData.abilities) {
      abilityMap[ab.id] = ab;
    }
    this.registry.set('abilityMap', abilityMap);

    this.scene.start('TitleScene');
  }

  // ── Texture generators ──────────────────────────────────────────────────────

  _generateTileTextures() {
    const TILE = 32;
    const tileColors = {
      grass:    0x4a8c3f,
      water:    0x3a6ea8,
      forest:   0x2d6620,
      mountain: 0x7a6a5a,
      town:     0xc8a046,
      dungeon:  0x440000,
      path:     0x8c7854,
    };

    for (const [name, color] of Object.entries(tileColors)) {
      const g = this.make.graphics({ x: 0, y: 0, add: false });
      g.fillStyle(color, 1);
      g.fillRect(0, 0, TILE, TILE);
      // Add a subtle border for depth
      g.lineStyle(1, 0x000000, 0.2);
      g.strokeRect(0, 0, TILE, TILE);
      // Add texture details per tile type
      if (name === 'grass') {
        g.fillStyle(0x5aa84f, 0.5);
        g.fillRect(4, 4, 6, 2); g.fillRect(14, 8, 5, 2); g.fillRect(22, 3, 4, 2);
      } else if (name === 'forest') {
        g.fillStyle(0x1a5010, 1);
        g.fillTriangle(16, 2, 6, 18, 26, 18);
        g.fillTriangle(16, 8, 8, 22, 24, 22);
      } else if (name === 'mountain') {
        g.fillStyle(0x9a8a7a, 1);
        g.fillTriangle(16, 4, 4, 28, 28, 28);
        g.fillStyle(0xeeeeee, 0.7);
        g.fillTriangle(16, 4, 11, 14, 21, 14);
      } else if (name === 'town') {
        g.fillStyle(0x885522, 1);
        g.fillRect(8, 12, 16, 14);
        g.fillStyle(0xcc3333, 1);
        g.fillTriangle(16, 4, 6, 14, 26, 14);
      } else if (name === 'water') {
        g.fillStyle(0x5a9ed0, 0.4);
        g.fillRect(0, 8, 32, 3); g.fillRect(0, 20, 32, 3);
      } else if (name === 'dungeon') {
        g.fillStyle(0x660000, 1);
        g.fillRect(10, 8, 12, 16);
        g.fillStyle(0x000000, 0.8);
        g.fillRect(12, 10, 8, 14);
      } else if (name === 'path') {
        g.fillStyle(0xaa9966, 0.5);
        g.fillRect(2, 14, 28, 4);
      }
      g.generateTexture(`tile_${name}`, TILE, TILE);
      g.destroy();
    }
  }

  _generateCharacterSprite() {
    // Simple 32x32 placeholder character with 4-directional animation frames
    // Frame layout: [down0, down1, up0, up1, left0, left1, right0, right1]
    const W = 32, H = 32, FRAMES = 8;
    const g = this.make.graphics({ x: 0, y: 0, add: false });
    const colors = [0x4488ff, 0x3366cc]; // body colors

    for (let f = 0; f < FRAMES; f++) {
      const ox = f * W;
      const step = f % 2; // animation step
      const dir  = Math.floor(f / 2); // 0=down,1=up,2=left,3=right

      // Shadow
      g.fillStyle(0x000000, 0.3);
      g.fillEllipse(ox + 16, H - 6, 20, 6);

      // Body
      g.fillStyle(colors[step], 1);
      g.fillRoundedRect(ox + 9, 14, 14, 14, 3);

      // Head
      g.fillStyle(0xffcc88, 1);
      g.fillCircle(ox + 16, 10, 8);

      // Legs (walking animation)
      g.fillStyle(colors[step], 1);
      if (step === 0) {
        g.fillRect(ox + 9, 27, 6, 4);
        g.fillRect(ox + 17, 27, 6, 4);
      } else {
        g.fillRect(ox + 8, 27, 6, 5);
        g.fillRect(ox + 18, 26, 6, 4);
      }

      // Direction indicator (small mark on head)
      g.fillStyle(0x000000, 0.5);
      if (dir === 0) g.fillRect(ox + 13, 8, 6, 2);       // down: line at bottom
      else if (dir === 1) g.fillRect(ox + 13, 5, 6, 2);  // up: line at top
      else if (dir === 2) g.fillRect(ox + 8, 8, 2, 6);   // left
      else g.fillRect(ox + 22, 8, 2, 6);                  // right
    }

    g.generateTexture('character', W * FRAMES, H);
    g.destroy();
  }

  _generateEnemySprites() {
    const enemyData = this.cache.json.get('enemies');
    for (const enemy of enemyData.enemies) {
      const color = parseInt(enemy.color.replace('#', '0x'));
      const g = this.make.graphics({ x: 0, y: 0, add: false });

      // Simple monster shape
      g.fillStyle(color, 1);
      if (enemy.isBoss) {
        // Boss: large and imposing
        g.fillRect(10, 8, 44, 40);
        g.fillStyle(0x000000, 0.3);
        g.fillRect(14, 12, 10, 10); // left eye
        g.fillRect(40, 12, 10, 10); // right eye
        g.fillStyle(0xffffff, 0.8);
        g.fillRect(16, 14, 6, 6);
        g.fillRect(42, 14, 6, 6);
        g.generateTexture(`enemy_${enemy.id}`, 64, 56);
      } else {
        // Regular enemy: 32x32
        g.fillRect(8, 6, 16, 18);
        g.fillStyle(0x000000, 0.4);
        g.fillRect(10, 9, 4, 4);  // left eye
        g.fillRect(18, 9, 4, 4);  // right eye
        g.generateTexture(`enemy_${enemy.id}`, 32, 32);
      }
      g.destroy();
    }
  }

  _generateUITextures() {
    // FF6-style dark blue dialog box panel
    const g = this.make.graphics({ x: 0, y: 0, add: false });
    g.fillStyle(0x000033, 0.92);
    g.fillRoundedRect(0, 0, 256, 64, 6);
    g.lineStyle(2, 0x5577cc, 1);
    g.strokeRoundedRect(0, 0, 256, 64, 6);
    g.lineStyle(1, 0x8899dd, 0.5);
    g.strokeRoundedRect(2, 2, 252, 60, 5);
    g.generateTexture('dialog_panel', 256, 64);
    g.destroy();

    // HP/MP bar backgrounds
    const bar = this.make.graphics({ x: 0, y: 0, add: false });
    bar.fillStyle(0x220000, 1);
    bar.fillRect(0, 0, 100, 8);
    bar.generateTexture('bar_bg', 100, 8);
    bar.destroy();

    const hpBar = this.make.graphics({ x: 0, y: 0, add: false });
    hpBar.fillStyle(0x44cc44, 1);
    hpBar.fillRect(0, 0, 100, 8);
    hpBar.generateTexture('bar_hp', 100, 8);
    hpBar.destroy();

    const mpBar = this.make.graphics({ x: 0, y: 0, add: false });
    mpBar.fillStyle(0x4444cc, 1);
    mpBar.fillRect(0, 0, 100, 8);
    mpBar.generateTexture('bar_mp', 100, 8);
    mpBar.destroy();

    const atbBar = this.make.graphics({ x: 0, y: 0, add: false });
    atbBar.fillStyle(0xccaa00, 1);
    atbBar.fillRect(0, 0, 100, 8);
    atbBar.generateTexture('bar_atb', 100, 8);
    atbBar.destroy();

    // Menu cursor
    const cursor = this.make.graphics({ x: 0, y: 0, add: false });
    cursor.fillStyle(0xffffff, 1);
    cursor.fillTriangle(0, 4, 8, 0, 8, 8);
    cursor.generateTexture('cursor', 10, 10);
    cursor.destroy();
  }
}
