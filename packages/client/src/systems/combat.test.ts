import { describe, test, expect } from "vitest";
import { buildCombatant, tickAtb, resolveAction, applyExpGain, getEnemyAction, GAUGE_MAX } from "./combat.js";
import type { CharDef, Ability, AbilityMap } from "./combat.js";

describe("buildCombatant", () => {
  test("creates a combatant with base stats at level 1", () => {
    const def: CharDef = {
      id: "terra", name: "Terra",
      baseStats: { hp: 50, mp: 30, str: 10, def: 8, mag: 15, mdef: 10, spd: 8, lck: 5 },
      growthRates: { hp: 10, mp: 5, str: 2, def: 1, mag: 3, mdef: 2, spd: 1, lck: 0 },
      startingAbilities: ["attack", "fire"],
    };
    const c = buildCombatant(def, {}, true);
    expect(c.name).toBe("Terra");
    expect(c.hp).toBe(50);
    expect(c.maxHp).toBe(50);
    expect(c.isParty).toBe(true);
    expect(c.atbGauge).toBe(0);
  });

  test("applies level scaling via growth rates", () => {
    const def: CharDef = {
      id: "terra", name: "Terra",
      baseStats: { hp: 50, mp: 30, str: 10, def: 8, mag: 15, mdef: 10, spd: 8, lck: 5 },
      growthRates: { hp: 10, mp: 5, str: 2, def: 1, mag: 3, mdef: 2, spd: 1, lck: 0 },
      startingAbilities: ["attack"],
    };
    const c = buildCombatant(def, { level: 5 }, true);
    expect(c.maxHp).toBe(50 + 10 * 4);
    expect(c.str).toBe(10 + 2 * 4);
  });
});

describe("tickAtb", () => {
  test("fills ATB gauge based on speed", () => {
    const c = { hp: 10, maxHp: 10, spd: 10, atbGauge: 0 };
    tickAtb([c], 100);
    expect(c.atbGauge).toBeGreaterThan(0);
  });

  test("does not fill gauge for KO'd combatants", () => {
    const c = { hp: 0, maxHp: 10, spd: 10, atbGauge: 0 };
    tickAtb([c], 100);
    expect(c.atbGauge).toBe(0);
  });

  test("caps gauge at GAUGE_MAX", () => {
    const c = { hp: 10, maxHp: 10, spd: 100, atbGauge: 999 };
    tickAtb([c], 10000);
    expect(c.atbGauge).toBe(GAUGE_MAX);
  });
});

describe("resolveAction", () => {
  test("deals damage and reduces target HP", () => {
    const actor = buildCombatant({
      id: "terra", name: "Terra",
      baseStats: { hp: 100, mp: 30, str: 20, def: 10, mag: 15, mdef: 10, spd: 10, lck: 5 },
      startingAbilities: ["attack"],
    }, {}, true);
    actor.atbGauge = 1000;

    const target = buildCombatant({
      id: "goblin", name: "Goblin",
      hp: 100, mp: 0, str: 10, def: 5, mag: 0, mdef: 5, spd: 10, lck: 1,
      resistances: [], weaknesses: [],
    }, {}, false);

    const ability: Ability = { id: "attack", name: "Attack", type: "physical", power: 1, mpCost: 0, target: "single" };
    const abilityMap: AbilityMap = { attack: ability };
    const results = resolveAction(actor, ability, [target], abilityMap);
    expect(results.length).toBe(1);
    expect(["damage", "miss"]).toContain(results[0]!.type);
    if (results[0]!.type === "damage") {
      expect(target.hp).toBeLessThan(100);
    }
  });

  test("defend sets defend status", () => {
    const actor = buildCombatant({
      id: "locke", name: "Locke",
      baseStats: { hp: 100, mp: 10, str: 15, def: 10, mag: 8, mdef: 8, spd: 10, lck: 5 },
      startingAbilities: ["attack"],
    }, {}, true);
    actor.atbGauge = 1000;

    const ability: Ability = { id: "defend", name: "Defend", effect: "defend" };
    const results = resolveAction(actor, ability, [actor], {});
    expect(results[0]!.type).toBe("status");
    expect(actor.statuses["defend"]).toBe(true);
  });
});

describe("applyExpGain", () => {
  test("distributes EXP among alive party members", () => {
    const charDef: CharDef = {
      id: "terra", name: "Terra",
      baseStats: { hp: 50, mp: 30, str: 10, def: 8, mag: 15, mdef: 10, spd: 8, lck: 5 },
      growthRates: { hp: 10, mp: 5, str: 2, def: 1, mag: 3, mdef: 2, spd: 1, lck: 0 },
      startingAbilities: ["attack"],
    };
    const party = [buildCombatant(charDef, {}, true)];
    const enemy = buildCombatant({
      id: "goblin", name: "Goblin",
      hp: 1, mp: 0, str: 10, def: 10, mag: 0, mdef: 8, spd: 10,
      expReward: 50,
    }, {}, false);
    enemy.hp = 0;

    applyExpGain(party, [enemy], [charDef]);
    expect(party[0]!.exp).toBeGreaterThan(0);
  });
});

describe("getEnemyAction", () => {
  test("returns an action for a basic_attack enemy", () => {
    const enemy = buildCombatant({
      id: "goblin", name: "Goblin",
      hp: 50, mp: 0, str: 10, def: 10, mag: 0, mdef: 8, spd: 10,
      abilities: ["attack"],
      ai: "basic_attack",
    }, {}, false);
    const partyMember = buildCombatant({
      id: "terra", name: "Terra",
      baseStats: { hp: 50, mp: 30, str: 10, def: 8, mag: 15, mdef: 10, spd: 8, lck: 5 },
      startingAbilities: ["attack"],
    }, {}, true);

    const abilityMap: AbilityMap = {
      attack: { id: "attack", name: "Attack", type: "physical", power: 1, mpCost: 0, target: "single" },
    };

    const action = getEnemyAction(enemy, [partyMember], abilityMap);
    expect(action).not.toBeNull();
    expect(action!.ability.id).toBe("attack");
    expect(action!.targets.length).toBeGreaterThan(0);
  });

  test("returns null when no alive party members", () => {
    const enemy = buildCombatant({
      id: "goblin", name: "Goblin",
      hp: 50, mp: 0, str: 10, def: 10, mag: 0, mdef: 8, spd: 10,
      abilities: ["attack"],
      ai: "basic_attack",
    }, {}, false);
    const deadMember = buildCombatant({
      id: "terra", name: "Terra",
      baseStats: { hp: 50, mp: 30, str: 10, def: 8, mag: 15, mdef: 10, spd: 8, lck: 5 },
      startingAbilities: ["attack"],
    }, {}, true);
    deadMember.hp = 0;

    const abilityMap: AbilityMap = {
      attack: { id: "attack", name: "Attack", type: "physical", power: 1, mpCost: 0, target: "single" },
    };

    const action = getEnemyAction(enemy, [deadMember], abilityMap);
    expect(action).toBeNull();
  });
});
