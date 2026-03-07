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
  name: string;
  characterId: string;
  level: number;
  hp: number;
  mp: number;
  stats: CharacterStats;
  abilities: string[];
  equipment: Equipment;
  statusEffects: string[];
}

/** Equipment slots */
export interface Equipment {
  weapon: string | null;
  armor: string | null;
  accessory: string | null;
}

/** Inventory item with quantity */
export interface InventoryItem {
  id: string;
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

/** Enemy definition from enemies.json */
export interface EnemyDefinition {
  id: string;
  name: string;
  hp: number;
  mp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  exp: number;
  gp: number;
  aiPattern: EnemyAiPattern;
  abilities: string[];
  weaknesses: string[];
  resistances: string[];
  steals: string[];
}

/** Ability definition from abilities.json */
export interface AbilityDefinition {
  id: string;
  name: string;
  type: "physical" | "magical" | "special" | "item";
  element?: string;
  power: number;
  mpCost: number;
  target: "single" | "all" | "self" | "ally" | "allAllies";
  description: string;
}

/** Item definition from items.json */
export interface ItemDefinition {
  id: string;
  name: string;
  type: "consumable" | "weapon" | "armor" | "accessory" | "key";
  description: string;
  effect?: Record<string, number>;
  stats?: Partial<CharacterStats>;
  price: number;
}
