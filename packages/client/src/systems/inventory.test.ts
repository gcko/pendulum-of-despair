import { describe, test, expect } from "vitest";
import { addItem, removeItem, getItemCount, equipItem, getEquipmentBonuses } from "./inventory.js";
import type { InventoryEntry, EquippedCharacter, ItemDef } from "./inventory.js";

describe("addItem", () => {
  test("adds a new item to empty inventory", () => {
    const inv: InventoryEntry[] = [];
    addItem(inv, "potion", 3);
    expect(inv).toEqual([{ itemId: "potion", qty: 3 }]);
  });

  test("stacks with existing item", () => {
    const inv: InventoryEntry[] = [{ itemId: "potion", qty: 2 }];
    addItem(inv, "potion", 5);
    expect(inv[0]!.qty).toBe(7);
  });
});

describe("removeItem", () => {
  test("reduces quantity", () => {
    const inv: InventoryEntry[] = [{ itemId: "potion", qty: 5 }];
    const result = removeItem(inv, "potion", 2);
    expect(result).toBe(true);
    expect(inv[0]!.qty).toBe(3);
  });

  test("removes entry when qty reaches 0", () => {
    const inv: InventoryEntry[] = [{ itemId: "potion", qty: 1 }];
    removeItem(inv, "potion", 1);
    expect(inv.length).toBe(0);
  });

  test("returns false if not enough", () => {
    const inv: InventoryEntry[] = [{ itemId: "potion", qty: 1 }];
    expect(removeItem(inv, "potion", 5)).toBe(false);
  });

  test("returns false for missing item", () => {
    expect(removeItem([], "potion")).toBe(false);
  });
});

describe("getItemCount", () => {
  test("returns qty for existing item", () => {
    expect(getItemCount([{ itemId: "potion", qty: 3 }], "potion")).toBe(3);
  });

  test("returns 0 for missing item", () => {
    expect(getItemCount([], "potion")).toBe(0);
  });
});

describe("equipItem", () => {
  test("equips a weapon and returns null when slot was empty", () => {
    const character: EquippedCharacter = {
      equipment: { weapon: null, armor: null, accessory: null },
    };
    const itemDef: ItemDef = { id: "iron_sword", name: "Iron Sword", type: "weapon", slot: "weapon", effect: { str: 5 } };
    const inv: InventoryEntry[] = [{ itemId: "iron_sword", qty: 1 }];

    const previous = equipItem(character, itemDef, inv);
    expect(previous).toBeNull();
    expect(character.equipment.weapon).toBe("iron_sword");
    expect(inv.length).toBe(0);
  });

  test("swaps equipment and returns old item", () => {
    const character: EquippedCharacter = {
      equipment: { weapon: "bronze_sword", armor: null, accessory: null },
    };
    const itemDef: ItemDef = { id: "iron_sword", name: "Iron Sword", type: "weapon", slot: "weapon", effect: { str: 5 } };
    const inv: InventoryEntry[] = [{ itemId: "iron_sword", qty: 1 }];

    const previous = equipItem(character, itemDef, inv);
    expect(previous).toBe("bronze_sword");
    expect(character.equipment.weapon).toBe("iron_sword");
    expect(inv).toEqual([{ itemId: "bronze_sword", qty: 1 }]);
  });

  test("returns null for non-equippable items", () => {
    const character: EquippedCharacter = {
      equipment: { weapon: null, armor: null, accessory: null },
    };
    const itemDef: ItemDef = { id: "potion", name: "Potion", type: "consumable" };
    const inv: InventoryEntry[] = [{ itemId: "potion", qty: 1 }];

    const result = equipItem(character, itemDef, inv);
    expect(result).toBeNull();
  });

  test("allows equipping accessories", () => {
    const character: EquippedCharacter = {
      equipment: { weapon: null, armor: null, accessory: null },
    };
    const itemDef: ItemDef = { id: "ring", name: "Ring", type: "accessory", slot: "accessory", effect: { lck: 3 } };
    const inv: InventoryEntry[] = [{ itemId: "ring", qty: 1 }];

    const previous = equipItem(character, itemDef, inv);
    expect(previous).toBeNull();
    expect(character.equipment.accessory).toBe("ring");
  });
});

describe("getEquipmentBonuses", () => {
  test("sums bonuses from equipped items", () => {
    const character: EquippedCharacter = {
      equipment: { weapon: "iron_sword", armor: null, accessory: null },
    };
    const itemDefs: ItemDef[] = [{ id: "iron_sword", name: "Iron Sword", type: "weapon", effect: { str: 5, spd: 1 } }];
    const bonuses = getEquipmentBonuses(character, itemDefs);
    expect(bonuses.str).toBe(5);
    expect(bonuses.spd).toBe(1);
    expect(bonuses.def).toBe(0);
  });

  test("returns zeroes for empty equipment", () => {
    const character: EquippedCharacter = {
      equipment: { weapon: null, armor: null, accessory: null },
    };
    const bonuses = getEquipmentBonuses(character, []);
    expect(bonuses.str).toBe(0);
    expect(bonuses.def).toBe(0);
  });
});
