/**
 * src/main.js
 * Pendulum of Despair — Phaser 3 game entry point.
 *
 * Configures the Phaser game instance with all scenes and launches BootScene.
 * Uses ES module imports; bundled at runtime via importmap (see index.html).
 */

import BootScene     from './scenes/BootScene.js';
import TitleScene    from './scenes/TitleScene.js';
import WorldMapScene from './scenes/WorldMapScene.js';
import BattleScene   from './scenes/BattleScene.js';
import DialogueScene from './scenes/DialogueScene.js';

// Expose save/load module for TitleScene's save-select UI
import * as SaveLoad from './systems/saveLoad.js';
window.saveLoadModule = SaveLoad;

/** @type {Phaser.Types.Core.GameConfig} */
const config = {
  type:   Phaser.AUTO,
  width:  800,
  height: 600,
  backgroundColor: '#000022',
  parent: 'game-container',

  scene: [
    BootScene,
    TitleScene,
    WorldMapScene,
    BattleScene,
    DialogueScene,
  ],

  physics: {
    default: 'arcade',
    arcade:  { debug: false },
  },

  scale: {
    mode:       Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
};

// eslint-disable-next-line no-unused-vars
const game = new Phaser.Game(config);
