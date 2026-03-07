/**
 * systems/combat.ts
 * ATB (Active Time Battle) combat system inspired by Final Fantasy VI.
 */

/** Maximum ATB gauge value before acting. */
export const GAUGE_MAX = 1000;

/** Base fill rate multiplier. Higher = faster battles. */
const BASE_RATE = 80;

/** Base stat block used for character/enemy definitions */
export interface BaseStats {
  hp: number;
  mp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  lck?: number;
}

/** Growth rates per level for a character */
export interface GrowthRates {
  hp: number;
  mp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  lck: number;
}

/** Drop entry from enemy definitions */
export interface DropEntry {
  itemId: string;
  weight: number;
}

/** Character/Enemy definition as loaded from JSON */
export interface CharDef {
  id: string;
  name: string;
  color?: string;
  baseStats?: BaseStats;
  // Flat stats (enemy style)
  hp?: number;
  mp?: number;
  str?: number;
  def?: number;
  mag?: number;
  mdef?: number;
  spd?: number;
  lck?: number;
  growthRates?: GrowthRates;
  startingAbilities?: string[];
  abilities?: string[];
  resistances?: string[];
  weaknesses?: string[];
  drops?: DropEntry[];
  expReward?: number;
  gpReward?: number;
  isBoss?: boolean;
  ai?: string;
}

/** Saved stats that can override character definition values */
export interface SavedStats {
  level?: number;
  hp?: number;
  mp?: number;
  exp?: number;
  abilities?: string[];
  maxHp?: number;
  maxMp?: number;
}

/** A combatant in battle */
export interface Combatant {
  id: string;
  name: string;
  color: string;
  hp: number;
  maxHp: number;
  mp: number;
  maxMp: number;
  str: number;
  def: number;
  mag: number;
  mdef: number;
  spd: number;
  lck: number;
  level: number;
  exp: number;
  atbGauge: number;
  isParty: boolean;
  abilities: string[];
  statuses: Record<string, boolean>;
  resistances: string[];
  weaknesses: string[];
  drops: DropEntry[];
  expReward: number;
  gpReward: number;
  isBoss: boolean;
  ai?: string;
  _patternIndex?: number;
}

/** Ability definition from abilities.json */
export interface Ability {
  id: string;
  name: string;
  type?: string;
  description?: string;
  mpCost?: number;
  element?: string | null;
  power?: number;
  target?: string;
  effect?: string;
  icon?: string;
  overworld_only?: boolean;
}

/** Map of ability IDs to ability definitions */
export type AbilityMap = Record<string, Ability>;

/** Result of resolving a combat action */
export interface ActionResult {
  actor: Combatant;
  target: Combatant;
  ability: Ability;
  type: "damage" | "heal" | "miss" | "status" | "escape" | "steal" | "runic_absorb";
  amount?: number;
  crit?: boolean;
  status?: string;
  success?: boolean;
  itemId?: string;
  message: string;
}

/**
 * Builds a Combatant from a character definition and current stats.
 */
export function buildCombatant(charDef: CharDef, savedStats: SavedStats = {}, isParty: boolean = true): Combatant {
  const level = savedStats.level ?? 1;
  const gr = charDef.growthRates ?? { hp: 0, mp: 0, str: 0, def: 0, mag: 0, mdef: 0, spd: 0, lck: 0 };

  // Support both nested baseStats (characters) and flat stat fields (enemies)
  const base = charDef.baseStats ?? charDef;

  const baseHp = base.hp ?? 0;
  const baseMp = base.mp ?? 0;
  const baseStr = base.str ?? 0;
  const baseDef = base.def ?? 0;
  const baseMag = base.mag ?? 0;
  const baseMdef = base.mdef ?? 0;
  const baseSpd = base.spd ?? 0;
  const baseLck = base.lck ?? 0;

  const maxHp = baseHp + (gr.hp) * (level - 1);
  const maxMp = baseMp + (gr.mp) * (level - 1);
  const str = baseStr + (gr.str) * (level - 1);
  const def = baseDef + (gr.def) * (level - 1);
  const mag = baseMag + (gr.mag) * (level - 1);
  const mdef = baseMdef + (gr.mdef) * (level - 1);
  const spd = baseSpd + (gr.spd) * (level - 1);
  const lck = baseLck + (gr.lck) * (level - 1);

  return {
    id: charDef.id,
    name: charDef.name,
    color: charDef.color ?? "#ffffff",
    hp: savedStats.hp ?? maxHp,
    maxHp,
    mp: savedStats.mp ?? maxMp,
    maxMp,
    str, def, mag, mdef, spd, lck,
    level,
    exp: savedStats.exp ?? 0,
    atbGauge: 0,
    isParty,
    abilities: savedStats.abilities ?? charDef.startingAbilities ?? charDef.abilities ?? ["attack"],
    statuses: {},
    resistances: charDef.resistances ?? [],
    weaknesses: charDef.weaknesses ?? [],
    drops: charDef.drops ?? [],
    expReward: charDef.expReward ?? 0,
    gpReward: charDef.gpReward ?? 0,
    isBoss: charDef.isBoss ?? false,
    ai: charDef.ai,
  };
}

/** Minimal shape required for tickAtb */
interface AtbTarget {
  hp: number;
  spd: number;
  atbGauge: number;
}

/**
 * Advances the ATB gauges for all combatants by deltaTime (ms).
 * Returns a list of combatants whose gauge just became full.
 */
export function tickAtb<T extends AtbTarget>(combatants: T[], deltaMs: number): T[] {
  const ready: T[] = [];
  for (const c of combatants) {
    if (c.hp <= 0) continue;
    if (c.atbGauge >= GAUGE_MAX) continue;

    const fillAmount = (c.spd * BASE_RATE * deltaMs) / 10000;
    c.atbGauge = Math.min(GAUGE_MAX, c.atbGauge + fillAmount);

    if (c.atbGauge >= GAUGE_MAX) {
      ready.push(c);
    }
  }
  return ready;
}

/**
 * Computes the result of one combatant using an ability on targets.
 * Returns an array of ActionResult objects (one per target).
 */
export function resolveAction(
  actor: Combatant,
  ability: Ability,
  targets: Combatant[],
  _abilityDb: AbilityMap = {},
): ActionResult[] {
  // After acting, reset ATB gauge
  actor.atbGauge = 0;

  // Deduct MP cost
  if (ability.mpCost && ability.mpCost > 0) {
    actor.mp = Math.max(0, actor.mp - ability.mpCost);
  }

  // Clear defend status after acting
  if (actor.statuses["defend"] && ability.id !== "defend") {
    delete actor.statuses["defend"];
  }

  // Handle special non-damage effects
  if (ability.effect === "defend") {
    actor.statuses["defend"] = true;
    return [{ actor, target: actor, ability, type: "status", status: "defend", message: `${actor.name} is defending!` }];
  }
  if (ability.effect === "runic") {
    actor.statuses["runic"] = true;
    return [{ actor, target: actor, ability, type: "status", status: "runic", message: `${actor.name} readies the Runic blade!` }];
  }
  if (ability.effect === "escape") {
    return [{ actor, target: actor, ability, type: "escape", message: "The party escapes!" }];
  }
  if (ability.effect === "steal") {
    return resolveSteal(actor, targets[0]!);
  }

  const results: ActionResult[] = [];
  for (const target of targets) {
    // Check if target is intercepted by Runic
    if (ability.type === "magic" && target.statuses?.["runic"]) {
      const mpGain = Math.floor((ability.mpCost ?? 0) * 1.5);
      target.mp = Math.min(target.maxMp, target.mp + mpGain);
      delete target.statuses["runic"];
      results.push({ actor, target, ability, type: "runic_absorb", amount: mpGain, message: `Runic absorbed ${ability.name}! ${target.name} restored ${mpGain} MP.` });
      continue;
    }

    if (ability.effect === "heal_hp") {
      results.push(resolveHeal(actor, target, ability));
    } else {
      results.push(resolveDamage(actor, target, ability));
    }
  }
  return results;
}

/**
 * Resolves a physical or magical damage hit.
 */
function resolveDamage(actor: Combatant, target: Combatant, ability: Ability): ActionResult {
  // Hit check: base 90% + luck bonus
  const hitChance = Math.min(0.98, 0.90 + (actor.lck - target.lck) * 0.005);
  if (Math.random() > hitChance) {
    return { actor, target, ability, type: "miss", amount: 0, message: `${actor.name}'s ${ability.name} missed!` };
  }

  const power = ability.power ?? 1;

  let rawDamage: number;
  if (ability.type === "magic") {
    rawDamage = Math.floor((actor.mag * 4 + 32) * power);
    const magDefFactor = Math.max(0.1, 1 - target.mdef / 128);
    rawDamage = Math.floor(rawDamage * magDefFactor);
  } else {
    rawDamage = Math.floor((actor.str * 2 + 16) * power);
    let defFactor = Math.max(0.1, 1 - target.def / 128);
    if (target.statuses?.["defend"]) defFactor *= 0.5;
    rawDamage = Math.floor(rawDamage * defFactor);
  }

  // Elemental modifier
  if (ability.element) {
    if (target.resistances.includes(ability.element)) rawDamage = Math.floor(rawDamage * 0.5);
    if (target.weaknesses.includes(ability.element)) rawDamage = Math.floor(rawDamage * 1.5);
  }

  // Variance: +/-15%
  const variance = 0.85 + Math.random() * 0.30;
  rawDamage = Math.max(1, Math.floor(rawDamage * variance));

  // Critical hit (2x damage, ~5% + luck chance)
  const critChance = 0.05 + actor.lck * 0.001;
  const crit = Math.random() < critChance;
  if (crit) rawDamage = Math.floor(rawDamage * 2);

  target.hp = Math.max(0, target.hp - rawDamage);

  const critText = crit ? " Critical hit!" : "";
  return {
    actor, target, ability, type: "damage", amount: rawDamage, crit,
    message: `${actor.name} used ${ability.name} on ${target.name} for ${rawDamage} damage!${critText}`,
  };
}

/**
 * Resolves a healing ability.
 */
function resolveHeal(actor: Combatant, target: Combatant, ability: Ability): ActionResult {
  if (target.hp <= 0) {
    return { actor, target, ability, type: "miss", amount: 0, message: `${target.name} is KO'd and cannot be healed!` };
  }
  const power = ability.power ?? 1;
  const healAmount = Math.floor((actor.mag * 2 + 20) * power);
  const variance = 0.90 + Math.random() * 0.20;
  const actual = Math.min(target.maxHp - target.hp, Math.floor(healAmount * variance));
  target.hp = Math.min(target.maxHp, target.hp + actual);
  return {
    actor, target, ability, type: "heal", amount: actual,
    message: `${actor.name} used ${ability.name} on ${target.name} for ${actual} HP!`,
  };
}

/**
 * Resolves a steal attempt.
 */
function resolveSteal(thief: Combatant, target: Combatant): ActionResult[] {
  const stealAbility: Ability = { id: "steal", name: "Steal" };
  if (!target.drops || target.drops.length === 0) {
    return [{ actor: thief, target, ability: stealAbility, type: "steal", success: false, message: `${thief.name} couldn't find anything to steal!` }];
  }
  const stealChance = Math.min(0.75, 0.30 + thief.lck * 0.01);
  if (Math.random() > stealChance) {
    return [{ actor: thief, target, ability: stealAbility, type: "steal", success: false, message: `${thief.name}'s steal attempt failed!` }];
  }
  const totalWeight = target.drops.reduce((s, d) => s + d.weight, 0);
  let roll = Math.random() * totalWeight;
  let stolen: string | null = null;
  for (const drop of target.drops) {
    roll -= drop.weight;
    if (roll <= 0) { stolen = drop.itemId; break; }
  }
  stolen = stolen ?? target.drops[0]!.itemId;
  return [{ actor: thief, target, ability: stealAbility, type: "steal", success: true, itemId: stolen, message: `${thief.name} stole a ${stolen} from ${target.name}!` }];
}

/** Level-up event result */
export interface LevelUpEvent {
  combatant: Combatant;
  oldLevel: number;
  newLevel: number;
}

/**
 * Computes EXP gained and applies level-ups after battle.
 */
export function applyExpGain(party: Combatant[], enemies: Combatant[], charDefs: CharDef[]): LevelUpEvent[] {
  const totalExp = enemies.reduce((s, e) => s + (e.expReward), 0);
  const alive = party.filter((c) => c.hp > 0);
  if (alive.length === 0 || totalExp === 0) return [];

  const perMember = Math.floor(totalExp / alive.length);
  const levelUps: LevelUpEvent[] = [];

  for (const c of alive) {
    const charDef = charDefs.find((d) => d.id === c.id);
    if (!charDef) continue;

    c.exp += perMember;
    const oldLevel = c.level;

    while (true) {
      const needed = c.level * 100;
      if (c.exp < needed) break;
      c.exp -= needed;
      c.level += 1;

      const gr = charDef.growthRates ?? { hp: 0, mp: 0, str: 0, def: 0, mag: 0, mdef: 0, spd: 0, lck: 0 };
      c.maxHp = Math.floor(c.maxHp + gr.hp * (1 + Math.random() * 0.2));
      c.maxMp = Math.floor(c.maxMp + gr.mp * (1 + Math.random() * 0.2));
      c.str += gr.str + (Math.random() < 0.5 ? 1 : 0);
      c.def += gr.def + (Math.random() < 0.3 ? 1 : 0);
      c.mag += gr.mag + (Math.random() < 0.5 ? 1 : 0);
      c.mdef += gr.mdef + (Math.random() < 0.3 ? 1 : 0);
      c.spd += gr.spd;
      c.lck += gr.lck;

      c.hp = c.maxHp;
      c.mp = c.maxMp;
    }

    if (c.level > oldLevel) {
      levelUps.push({ combatant: c, oldLevel, newLevel: c.level });
    }
  }

  return levelUps;
}

/**
 * Determines enemy AI action given the current battle state.
 */
export function getEnemyAction(
  enemy: Combatant,
  partyMembers: Combatant[],
  abilityDb: AbilityMap,
): { ability: Ability; targets: Combatant[] } | null {
  const alive = partyMembers.filter((p) => p.hp > 0);
  if (alive.length === 0) return null;

  let chosenAbilityId = "attack";

  switch (enemy.ai) {
    case "basic_attack":
      chosenAbilityId = "attack";
      break;

    case "aggressive":
      chosenAbilityId = Math.random() < 0.8 ? "attack"
        : (enemy.abilities.find((a) => a !== "attack") ?? "attack");
      break;

    case "defensive": {
      const hp_pct = enemy.hp / enemy.maxHp;
      if (hp_pct < 0.3 && enemy.abilities.includes("defend")) {
        chosenAbilityId = "defend";
      } else {
        const magic = enemy.abilities.filter((a) => {
          const d = abilityDb[a];
          return d && d.type === "magic" && (d.mpCost ?? 0) <= enemy.mp;
        });
        chosenAbilityId = magic.length > 0 && Math.random() < 0.35
          ? magic[Math.floor(Math.random() * magic.length)]!
          : "attack";
      }
      break;
    }

    case "magic_focus": {
      const magic = enemy.abilities.filter((a) => {
        const d = abilityDb[a];
        return d && d.type === "magic" && (d.mpCost ?? 0) <= enemy.mp;
      });
      chosenAbilityId = magic.length > 0 && Math.random() < 0.70
        ? magic[Math.floor(Math.random() * magic.length)]!
        : "attack";
      break;
    }

    case "pattern": {
      const idx = enemy._patternIndex ?? -1;
      enemy._patternIndex = (idx + 1) % enemy.abilities.length;
      chosenAbilityId = enemy.abilities[enemy._patternIndex]!;
      break;
    }

    default:
      chosenAbilityId = "attack";
  }

  const ability = abilityDb[chosenAbilityId] ?? abilityDb["attack"];
  if (!ability) return null;

  let targets = [alive[Math.floor(Math.random() * alive.length)]!];
  if (ability.target === "all_enemies") {
    targets = alive;
  }

  return { ability, targets };
}
