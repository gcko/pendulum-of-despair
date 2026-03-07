/** Character stat block */
export interface CharacterStats {
  hp: number;
  maxHp: number;
  mp: number;
  maxMp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  level: number;
  exp: number;
}

/** Party member as stored in save data */
export interface PartyMember {
  id: string;
  name: string;
  level: number;
  hp: number;
  mp: number;
  maxHp?: number;
  maxMp?: number;
  [key: string]: unknown;
}

/** Equipment slots */
export interface Equipment {
  weapon: string | null;
  armor: string | null;
  accessory: string | null;
}

/** Inventory item with quantity */
export interface InventoryItem {
  itemId: string;
  qty: number;
}

/** Position on the world map */
export interface MapPosition {
  x: number;
  y: number;
}

/** Full game save state — the blob stored in the saves table */
export interface GameSaveState {
  party: PartyMember[];
  inventory: InventoryItem[];
  gp: number;
  worldFlags: Record<string, boolean>;
  currentMap: string;
  currentPosition: MapPosition;
  playtime: number;
}

/** Summary shown in save slot listing */
export interface SaveSlotSummary {
  slot: number;
  updatedAt?: number;
  playtime?: number;
  location?: string;
  party?: Array<{ name: string; level: number }>;
  empty?: boolean;
  corrupted?: boolean;
}

/** Full save slot response (GET /api/save/:slot) */
export interface SaveSlotFull {
  slot: number;
  updatedAt: number;
  data: GameSaveState;
}

/** Enemy AI pattern types */
export type EnemyAiPattern =
  | "basic_attack"
  | "aggressive"
  | "defensive"
  | "magic_focus"
  | "pattern";

/** Drop entry from enemies.json */
export interface EnemyDrop {
  itemId: string;
  weight: number;
}

/** Enemy definition from enemies.json */
export interface EnemyDefinition {
  id: string;
  name: string;
  color: string;
  hp: number;
  mp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  expReward: number;
  gpReward: number;
  drops: EnemyDrop[];
  abilities: string[];
  ai: EnemyAiPattern;
  weaknesses: string[];
  resistances: string[];
  isBoss?: boolean;
}

/** Ability definition from abilities.json */
export interface AbilityDefinition {
  id: string;
  name: string;
  type: "physical" | "magic" | "special";
  element?: string | null;
  power: number;
  mpCost: number;
  target: "single_enemy" | "all_enemies" | "self" | "single_ally";
  description: string;
  icon?: string;
  effect?: string;
}

/** Item definition from items.json */
export interface ItemDefinition {
  id: string;
  name: string;
  type: "consumable" | "weapon" | "armor" | "accessory" | "key_item";
  description: string;
  effect?: Record<string, number | string> | null;
  target?: string;
  price?: number;
  icon?: string;
  slot?: string;
  overworld_only?: boolean;
}
