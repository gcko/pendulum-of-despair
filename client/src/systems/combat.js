/**
 * systems/combat.js
 * ATB (Active Time Battle) combat system inspired by Final Fantasy VI.
 *
 * Each combatant has an ATB gauge that fills based on their SPD stat.
 * When the gauge reaches 1000 (GAUGE_MAX), they are ready to act.
 * The game waits for player input when a party member is ready.
 * Enemies act automatically when their gauge is full.
 */

/** Maximum ATB gauge value before acting. */
export const GAUGE_MAX = 1000;

/** Base fill rate multiplier. Higher = faster battles. */
const BASE_RATE = 80;

/**
 * @typedef {Object} Combatant
 * @property {string}  id          - Unique identifier
 * @property {string}  name        - Display name
 * @property {number}  hp          - Current HP
 * @property {number}  maxHp       - Max HP
 * @property {number}  mp          - Current MP
 * @property {number}  maxMp       - Max MP
 * @property {number}  str         - Strength (physical attack)
 * @property {number}  def         - Physical defense
 * @property {number}  mag         - Magic power
 * @property {number}  mdef        - Magic defense
 * @property {number}  spd         - Speed (determines ATB fill rate)
 * @property {number}  lck         - Luck (affects hit/crit rate)
 * @property {number}  atbGauge    - Current ATB gauge value (0–GAUGE_MAX)
 * @property {boolean} isParty     - True if this is a player character
 * @property {string[]} abilities  - List of known ability IDs
 * @property {Object}  statuses    - Active status effects { poison, defend, runic, ... }
 * @property {string[]} resistances - Elemental resistances
 * @property {string[]} weaknesses  - Elemental weaknesses
 */

/**
 * Builds a Combatant from a character definition and current stats.
 * @param {Object} charDef - Character or enemy data from JSON
 * @param {Object} [savedStats] - Optional overrides (level, hp, mp, etc.)
 * @param {boolean} [isParty=true]
 * @returns {Combatant}
 */
export function buildCombatant(charDef, savedStats = {}, isParty = true) {
  const level = savedStats.level || 1;
  const gr = charDef.growthRates || {};

  const maxHp  = (charDef.baseStats.hp  + (gr.hp  || 0) * (level - 1));
  const maxMp  = (charDef.baseStats.mp  + (gr.mp  || 0) * (level - 1));
  const str    = charDef.baseStats.str  + (gr.str  || 0) * (level - 1);
  const def    = charDef.baseStats.def  + (gr.def  || 0) * (level - 1);
  const mag    = charDef.baseStats.mag  + (gr.mag  || 0) * (level - 1);
  const mdef   = charDef.baseStats.mdef + (gr.mdef || 0) * (level - 1);
  const spd    = charDef.baseStats.spd  + (gr.spd  || 0) * (level - 1);
  const lck    = charDef.baseStats.lck  + (gr.lck  || 0) * (level - 1);

  return {
    id:          charDef.id,
    name:        charDef.name,
    color:       charDef.color || '#ffffff',
    hp:          savedStats.hp  ?? maxHp,
    maxHp,
    mp:          savedStats.mp  ?? maxMp,
    maxMp,
    str, def, mag, mdef, spd, lck,
    level,
    exp:         savedStats.exp || 0,
    atbGauge:    0,
    isParty,
    abilities:   savedStats.abilities || charDef.startingAbilities || charDef.abilities || ['attack'],
    statuses:    {},
    resistances: charDef.resistances || [],
    weaknesses:  charDef.weaknesses  || [],
    drops:       charDef.drops || [],
    expReward:   charDef.expReward || 0,
    gpReward:    charDef.gpReward  || 0,
    isBoss:      charDef.isBoss   || false,
  };
}

/**
 * Advances the ATB gauges for all combatants by deltaTime (ms).
 * Returns a list of combatants whose gauge just became full.
 *
 * @param {Combatant[]} combatants
 * @param {number} deltaMs
 * @returns {Combatant[]} - Combatants that are now ready to act
 */
export function tickAtb(combatants, deltaMs) {
  const ready = [];
  for (const c of combatants) {
    if (c.hp <= 0) continue;           // KO'd combatants don't fill
    if (c.atbGauge >= GAUGE_MAX) continue; // already full

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
 *
 * @param {Combatant}   actor   - The acting combatant
 * @param {Object}      ability - Ability definition from abilities.json
 * @param {Combatant[]} targets - List of target combatants
 * @param {Object}      [abilityDb] - Full ability map (id -> def), for runic lookup
 * @returns {ActionResult[]}
 */
export function resolveAction(actor, ability, targets, abilityDb = {}) {
  // After acting, reset ATB gauge
  actor.atbGauge = 0;

  // Clear defend status after acting
  if (actor.statuses.defend && ability.id !== 'defend') {
    delete actor.statuses.defend;
  }

  // Handle special non-damage effects
  if (ability.effect === 'defend') {
    actor.statuses.defend = true;
    return [{ actor, target: actor, ability, type: 'status', status: 'defend', message: `${actor.name} is defending!` }];
  }
  if (ability.effect === 'runic') {
    actor.statuses.runic = true;
    return [{ actor, target: actor, ability, type: 'status', status: 'runic', message: `${actor.name} readies the Runic blade!` }];
  }
  if (ability.effect === 'escape') {
    return [{ actor, target: actor, ability, type: 'escape', message: 'The party escapes!' }];
  }
  if (ability.effect === 'steal') {
    return resolveSteal(actor, targets[0]);
  }

  const results = [];
  for (const target of targets) {
    // Check if target is intercepted by Runic
    if (ability.type === 'magic' && target.statuses && target.statuses.runic) {
      const mpGain = Math.floor(ability.mpCost * 1.5);
      target.mp = Math.min(target.maxMp, target.mp + mpGain);
      delete target.statuses.runic;
      results.push({ actor, target, ability, type: 'runic_absorb', amount: mpGain, message: `Runic absorbed ${ability.name}! ${target.name} restored ${mpGain} MP.` });
      continue;
    }

    if (ability.effect === 'heal_hp') {
      results.push(resolveHeal(actor, target, ability));
    } else {
      results.push(resolveDamage(actor, target, ability));
    }
  }
  return results;
}

/**
 * @typedef {Object} ActionResult
 * @property {Combatant} actor
 * @property {Combatant} target
 * @property {Object}    ability
 * @property {string}    type      - 'damage'|'heal'|'miss'|'status'|'escape'|'steal'|'runic_absorb'
 * @property {number}    [amount]  - Damage or healing amount
 * @property {boolean}   [crit]    - True if critical hit
 * @property {string}    message   - Human-readable description
 */

/**
 * Resolves a physical or magical damage hit.
 * @param {Combatant} actor
 * @param {Combatant} target
 * @param {Object}    ability
 * @returns {ActionResult}
 */
function resolveDamage(actor, target, ability) {
  // Hit check: base 90% + luck bonus
  const hitChance = Math.min(0.98, 0.90 + (actor.lck - target.lck) * 0.005);
  if (Math.random() > hitChance) {
    return { actor, target, ability, type: 'miss', amount: 0, message: `${actor.name}'s ${ability.name} missed!` };
  }

  let rawDamage;
  if (ability.type === 'magic') {
    // Magic damage formula (inspired by FF6)
    rawDamage = Math.floor((actor.mag * 4 + 32) * ability.power);
    const magDefFactor = Math.max(0.1, 1 - target.mdef / 128);
    rawDamage = Math.floor(rawDamage * magDefFactor);
  } else {
    // Physical damage formula
    rawDamage = Math.floor((actor.str * 2 + 16) * ability.power);
    let defFactor = Math.max(0.1, 1 - target.def / 128);
    if (target.statuses && target.statuses.defend) defFactor *= 0.5; // Defend halves damage
    rawDamage = Math.floor(rawDamage * defFactor);
  }

  // Elemental modifier
  if (ability.element) {
    if (target.resistances.includes(ability.element)) rawDamage = Math.floor(rawDamage * 0.5);
    if (target.weaknesses.includes(ability.element))  rawDamage = Math.floor(rawDamage * 1.5);
  }

  // Variance: ±15%
  const variance = 0.85 + Math.random() * 0.30;
  rawDamage = Math.max(1, Math.floor(rawDamage * variance));

  // Critical hit (2x damage, ~5% + luck chance)
  const critChance = 0.05 + actor.lck * 0.001;
  const crit = Math.random() < critChance;
  if (crit) rawDamage = Math.floor(rawDamage * 2);

  target.hp = Math.max(0, target.hp - rawDamage);

  const critText = crit ? ' Critical hit!' : '';
  return {
    actor, target, ability, type: 'damage', amount: rawDamage, crit,
    message: `${actor.name} used ${ability.name} on ${target.name} for ${rawDamage} damage!${critText}`,
  };
}

/**
 * Resolves a healing ability.
 * @param {Combatant} actor
 * @param {Combatant} target
 * @param {Object}    ability
 * @returns {ActionResult}
 */
function resolveHeal(actor, target, ability) {
  if (target.hp <= 0) {
    return { actor, target, ability, type: 'miss', amount: 0, message: `${target.name} is KO'd and cannot be healed!` };
  }
  const healAmount = Math.floor((actor.mag * 2 + 20) * ability.power);
  const variance = 0.90 + Math.random() * 0.20;
  const actual = Math.min(target.maxHp - target.hp, Math.floor(healAmount * variance));
  target.hp = Math.min(target.maxHp, target.hp + actual);
  return {
    actor, target, ability, type: 'heal', amount: actual,
    message: `${actor.name} used ${ability.name} on ${target.name} for ${actual} HP!`,
  };
}

/**
 * Resolves a steal attempt.
 * @param {Combatant} thief
 * @param {Combatant} target
 * @returns {ActionResult[]}
 */
function resolveSteal(thief, target) {
  if (!target.drops || target.drops.length === 0) {
    return [{ actor: thief, target, ability: { id: 'steal', name: 'Steal' }, type: 'steal', success: false, message: `${thief.name} couldn't find anything to steal!` }];
  }
  const stealChance = Math.min(0.75, 0.30 + thief.lck * 0.01);
  if (Math.random() > stealChance) {
    return [{ actor: thief, target, ability: { id: 'steal', name: 'Steal' }, type: 'steal', success: false, message: `${thief.name}'s steal attempt failed!` }];
  }
  // Pick a random drop weighted by weight
  const totalWeight = target.drops.reduce((s, d) => s + d.weight, 0);
  let roll = Math.random() * totalWeight;
  let stolen = null;
  for (const drop of target.drops) {
    roll -= drop.weight;
    if (roll <= 0) { stolen = drop.itemId; break; }
  }
  stolen = stolen || target.drops[0].itemId;
  return [{ actor: thief, target, ability: { id: 'steal', name: 'Steal' }, type: 'steal', success: true, itemId: stolen, message: `${thief.name} stole a ${stolen} from ${target.name}!` }];
}

/**
 * Computes EXP gained and applies level-ups after battle.
 * Returns an array of level-up events.
 *
 * @param {Combatant[]} party   - Surviving party members
 * @param {Combatant[]} enemies - Defeated enemies
 * @param {Object[]}    charDefs - Character definitions from characters.json
 * @returns {{ combatant: Combatant, oldLevel: number, newLevel: number }[]}
 */
export function applyExpGain(party, enemies, charDefs) {
  const totalExp = enemies.reduce((s, e) => s + (e.expReward || 0), 0);
  const alive = party.filter((c) => c.hp > 0);
  if (alive.length === 0 || totalExp === 0) return [];

  const perMember = Math.floor(totalExp / alive.length);
  const levelUps = [];

  for (const c of alive) {
    const charDef = charDefs.find((d) => d.id === c.id);
    if (!charDef) continue;

    c.exp += perMember;
    const oldLevel = c.level;

    // Level-up loop: each level requires level * 100 EXP accumulated
    while (true) {
      const needed = c.level * 100;
      if (c.exp < needed) break;
      c.exp -= needed;
      c.level += 1;

      // Apply stat growth
      const gr = charDef.growthRates;
      c.maxHp  = Math.floor(c.maxHp  + gr.hp  * (1 + Math.random() * 0.2));
      c.maxMp  = Math.floor(c.maxMp  + gr.mp  * (1 + Math.random() * 0.2));
      c.str    += gr.str  + (Math.random() < 0.5 ? 1 : 0);
      c.def    += gr.def  + (Math.random() < 0.3 ? 1 : 0);
      c.mag    += gr.mag  + (Math.random() < 0.5 ? 1 : 0);
      c.mdef   += gr.mdef + (Math.random() < 0.3 ? 1 : 0);
      c.spd    += gr.spd;
      c.lck    += gr.lck;

      // Restore HP/MP on level up
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
 * Returns { ability, targets } ready for resolveAction().
 *
 * @param {Combatant}   enemy
 * @param {Combatant[]} partyMembers - Living party members (targets)
 * @param {Object}      abilityDb    - Map of ability ID -> definition
 * @returns {{ ability: Object, targets: Combatant[] }}
 */
export function getEnemyAction(enemy, partyMembers, abilityDb) {
  const alive = partyMembers.filter((p) => p.hp > 0);
  if (alive.length === 0) return null;

  let chosenAbilityId = 'attack';

  switch (enemy.ai) {
    case 'basic_attack':
      chosenAbilityId = 'attack';
      break;

    case 'aggressive':
      // 80% attack, 20% special if available
      chosenAbilityId = Math.random() < 0.8 ? 'attack'
        : (enemy.abilities.find((a) => a !== 'attack') || 'attack');
      break;

    case 'defensive': {
      // Use a buff or magic 30% of the time
      const hp_pct = enemy.hp / enemy.maxHp;
      if (hp_pct < 0.3 && enemy.abilities.includes('defend')) {
        chosenAbilityId = 'defend';
      } else {
        const magic = enemy.abilities.filter((a) => {
          const def = abilityDb[a];
          return def && def.type === 'magic' && (def.mpCost || 0) <= enemy.mp;
        });
        chosenAbilityId = magic.length > 0 && Math.random() < 0.35
          ? magic[Math.floor(Math.random() * magic.length)]
          : 'attack';
      }
      break;
    }

    case 'magic_focus': {
      const magic = enemy.abilities.filter((a) => {
        const def = abilityDb[a];
        return def && def.type === 'magic' && (def.mpCost || 0) <= enemy.mp;
      });
      chosenAbilityId = magic.length > 0 && Math.random() < 0.70
        ? magic[Math.floor(Math.random() * magic.length)]
        : 'attack';
      break;
    }

    case 'pattern': {
      // Boss pattern: cycle through abilities in order, tracking state on enemy object
      enemy._patternIndex = ((enemy._patternIndex || 0) + 1) % enemy.abilities.length;
      chosenAbilityId = enemy.abilities[enemy._patternIndex];
      break;
    }

    default:
      chosenAbilityId = 'attack';
  }

  const ability = abilityDb[chosenAbilityId] || abilityDb['attack'];

  // Determine targets based on ability target type
  let targets = [alive[Math.floor(Math.random() * alive.length)]]; // default: single random
  if (ability.target === 'all_enemies') {
    targets = alive; // "enemies" from enemy perspective = party members
  }

  return { ability, targets };
}
