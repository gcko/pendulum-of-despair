/**
 * src/main.ts
 * Pendulum of Despair -- Phaser 3 game entry point.
 */

import Phaser from "phaser";
import BootScene from "./scenes/BootScene.js";
import TitleScene from "./scenes/TitleScene.js";
import WorldMapScene from "./scenes/WorldMapScene.js";
import BattleScene from "./scenes/BattleScene.js";
import DialogueScene from "./scenes/DialogueScene.js";

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  width: 800,
  height: 600,
  backgroundColor: "#000022",
  parent: "game-container",

  scene: [
    BootScene,
    TitleScene,
    WorldMapScene,
    BattleScene,
    DialogueScene,
  ],

  physics: {
    default: "arcade",
    arcade: { debug: false },
  },

  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
};

new Phaser.Game(config);
