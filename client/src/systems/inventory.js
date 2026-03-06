/**
 * systems/inventory.js
 * Inventory and equipment management.
 * Party inventory is a flat array of { itemId, qty } objects.
 * Equipment is per-character { weapon, armor, accessory }.
 */

/**
 * @typedef {Object} InventoryEntry
 * @property {string} itemId
 * @property {number} qty
 */

/**
 * Adds qty of itemId to inventory. Stacks with existing entries.
 * @param {InventoryEntry[]} inventory
 * @param {string} itemId
 * @param {number} [qty=1]
 * @returns {InventoryEntry[]}
 */
export function addItem(inventory, itemId, qty = 1) {
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
 * @param {InventoryEntry[]} inventory
 * @param {string} itemId
 * @param {number} [qty=1]
 * @returns {boolean}
 */
export function removeItem(inventory, itemId, qty = 1) {
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
 * @param {InventoryEntry[]} inventory
 * @param {string} itemId
 * @returns {number}
 */
export function getItemCount(inventory, itemId) {
  const entry = inventory.find((e) => e.itemId === itemId);
  return entry ? entry.qty : 0;
}

/**
 * Equips an item to a character. Returns the previously equipped item (if any)
 * to put back in the party inventory.
 *
 * @param {Object} character    - Character object with an `equipment` field
 * @param {Object} itemDef      - Item definition from items.json
 * @param {InventoryEntry[]} inventory
 * @returns {string|null} - ID of the item that was unequipped, or null
 */
export function equipItem(character, itemDef, inventory) {
  if (!itemDef || itemDef.type !== 'weapon' && itemDef.type !== 'armor') return null;

  const slot = itemDef.slot; // 'weapon' | 'armor' | 'head' | 'accessory'
  const equip = character.equipment || {};
  const previous = equip[slot] || null;

  // Remove the new item from inventory (qty 1)
  removeItem(inventory, itemDef.id);

  // Put the previously equipped item back in inventory
  if (previous) addItem(inventory, previous);

  equip[slot] = itemDef.id;
  character.equipment = equip;

  return previous;
}

/**
 * Computes total stat bonuses from all equipped items.
 * @param {Object}   character  - Character with `equipment` field
 * @param {Object[]} itemDefs   - All item definitions
 * @returns {{ str, def, mag, mdef, spd, lck, hp, mp }} Stat bonuses
 */
export function getEquipmentBonuses(character, itemDefs) {
  const bonuses = { str: 0, def: 0, mag: 0, mdef: 0, spd: 0, lck: 0, hp: 0, mp: 0 };
  const equip = character.equipment || {};
  for (const slot of Object.values(equip)) {
    if (!slot) continue;
    const def = itemDefs.find((i) => i.id === slot);
    if (!def || !def.effect) continue;
    for (const [stat, val] of Object.entries(def.effect)) {
      if (stat in bonuses) bonuses[stat] += val;
    }
  }
  return bonuses;
}

/**
 * Applies equipment bonuses to a combatant's stats (in-place).
 * Call this after buildCombatant to include gear stats.
 * @param {Object} combatant
 * @param {Object} bonuses
 */
export function applyEquipmentBonuses(combatant, bonuses) {
  for (const [stat, val] of Object.entries(bonuses)) {
    if (stat in combatant) combatant[stat] += val;
  }
  combatant.maxHp += bonuses.hp || 0;
  combatant.maxMp += bonuses.mp || 0;
}

/**
 * Sorts inventory by item type then name for display purposes.
 * @param {InventoryEntry[]} inventory
 * @param {Object[]} itemDefs
 * @returns {InventoryEntry[]}
 */
export function sortInventory(inventory, itemDefs) {
  const typeOrder = { consumable: 0, weapon: 1, armor: 2, key_item: 3 };
  return [...inventory].sort((a, b) => {
    const da = itemDefs.find((i) => i.id === a.itemId);
    const db = itemDefs.find((i) => i.id === b.itemId);
    const ta = da ? (typeOrder[da.type] ?? 99) : 99;
    const tb = db ? (typeOrder[db.type] ?? 99) : 99;
    if (ta !== tb) return ta - tb;
    return (da?.name || a.itemId).localeCompare(db?.name || b.itemId);
  });
}
