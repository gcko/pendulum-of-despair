/**
 * systems/inventory.ts
 * Inventory and equipment management.
 */

/** A single inventory slot */
export interface InventoryEntry {
  itemId: string;
  qty: number;
}

/** Item definition from items.json */
export interface ItemDef {
  id: string;
  name: string;
  type: string;
  slot?: string;
  description?: string;
  effect?: Record<string, number | string> | null;
  target?: string;
  price?: number;
  icon?: string;
  overworld_only?: boolean;
}

/** Equipment slots on a character */
export interface EquipmentSlots {
  weapon: string | null;
  armor: string | null;
  accessory: string | null;
  [key: string]: string | null | undefined;
}

/** Character with equipment */
export interface EquippedCharacter {
  equipment: EquipmentSlots;
}

/** Stat bonuses from equipment */
export interface StatBonuses {
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  lck: number;
  hp: number;
  mp: number;
  [key: string]: number;
}

/**
 * Adds qty of itemId to inventory. Stacks with existing entries.
 */
export function addItem(inventory: InventoryEntry[], itemId: string, qty: number = 1): InventoryEntry[] {
  const existing = inventory.find((e) => e.itemId === itemId);
  if (existing) {
    existing.qty += qty;
  } else {
    inventory.push({ itemId, qty });
  }
  return inventory;
}

/**
 * Removes qty of itemId from inventory. Returns false if not enough.
 */
export function removeItem(inventory: InventoryEntry[], itemId: string, qty: number = 1): boolean {
  const entry = inventory.find((e) => e.itemId === itemId);
  if (!entry || entry.qty < qty) return false;
  entry.qty -= qty;
  if (entry.qty === 0) {
    const idx = inventory.indexOf(entry);
    inventory.splice(idx, 1);
  }
  return true;
}

/**
 * Returns the quantity of an item in inventory (0 if not found).
 */
export function getItemCount(inventory: InventoryEntry[], itemId: string): number {
  const entry = inventory.find((e) => e.itemId === itemId);
  return entry ? entry.qty : 0;
}

/**
 * Equips an item to a character. Returns the previously equipped item (if any)
 * to put back in the party inventory.
 */
export function equipItem(character: EquippedCharacter, itemDef: ItemDef | null | undefined, inventory: InventoryEntry[]): string | null {
  if (!itemDef || (itemDef.type !== "weapon" && itemDef.type !== "armor" && itemDef.type !== "accessory")) return null;

  const slot = itemDef.slot ?? itemDef.type;
  const equip = character.equipment;
  const previous = equip[slot] ?? null;

  // Remove the new item from inventory (qty 1)
  removeItem(inventory, itemDef.id);

  // Put the previously equipped item back in inventory
  if (previous) addItem(inventory, previous);

  equip[slot] = itemDef.id;

  return previous;
}

/**
 * Computes total stat bonuses from all equipped items.
 */
export function getEquipmentBonuses(character: EquippedCharacter, itemDefs: ItemDef[]): StatBonuses {
  const bonuses: StatBonuses = { str: 0, def: 0, mag: 0, mdef: 0, spd: 0, lck: 0, hp: 0, mp: 0 };
  const equip = character.equipment;
  for (const slot of Object.values(equip)) {
    if (!slot) continue;
    const def = itemDefs.find((i) => i.id === slot);
    if (!def || !def.effect) continue;
    for (const [stat, val] of Object.entries(def.effect)) {
      if (stat in bonuses && typeof val === "number") {
        const current = bonuses[stat];
        if (current !== undefined) bonuses[stat] = current + val;
      }
    }
  }
  return bonuses;
}

/**
 * Applies equipment bonuses to a combatant's stats (in-place).
 */
export function applyEquipmentBonuses(combatant: Record<string, unknown>, bonuses: StatBonuses): void {
  const numCombatant = combatant as Record<string, number>;
  for (const [stat, val] of Object.entries(bonuses)) {
    if (stat in combatant && typeof combatant[stat] === "number") {
      numCombatant[stat] = (numCombatant[stat] ?? 0) + val;
    }
  }
  if (typeof combatant["maxHp"] === "number") {
    numCombatant["maxHp"] = (numCombatant["maxHp"] ?? 0) + bonuses.hp;
  }
  if (typeof combatant["maxMp"] === "number") {
    numCombatant["maxMp"] = (numCombatant["maxMp"] ?? 0) + bonuses.mp;
  }
}

/**
 * Sorts inventory by item type then name for display purposes.
 */
export function sortInventory(inventory: InventoryEntry[], itemDefs: ItemDef[]): InventoryEntry[] {
  const typeOrder: Record<string, number> = { consumable: 0, weapon: 1, armor: 2, key_item: 3 };
  return [...inventory].sort((a, b) => {
    const da = itemDefs.find((i) => i.id === a.itemId);
    const db = itemDefs.find((i) => i.id === b.itemId);
    const ta = da ? (typeOrder[da.type] ?? 99) : 99;
    const tb = db ? (typeOrder[db.type] ?? 99) : 99;
    if (ta !== tb) return ta - tb;
    return (da?.name ?? a.itemId).localeCompare(db?.name ?? b.itemId);
  });
}
