import SwiftUI

// A spell APPLIES an element to a target area. Reactions are resolved by the engine.
struct SpellDef: Identifiable {
    let id: String
    let name: String
    let element: ElementKind
    let baseRange: Int          // tiles from caster
    let baseAoE: Int            // 0 = single tile, 1 = plus pattern, 2 = 3x3
    let baseDamage: Int         // direct damage applied to occupant (before reactions)
    let manaCost: Int
    let lore: String
    // Tier upgrades: 3 tiers; each tier description + its mechanical bonus
    let tier1: SpellUpgrade
    let tier2: SpellUpgrade
    let tier3: SpellUpgrade
}

struct SpellUpgrade {
    let title: String
    let desc: String
    let rangeBonus: Int
    let aoeBonus: Int
    let damageBonus: Int
    let addsReaction: Bool      // tier 3 may add a bonus reaction trigger
}

enum SpellAoEPattern {
    static func tiles(center: GridPos, aoe: Int) -> [GridPos] {
        switch aoe {
        case 0:
            return [center]
        case 1: // plus
            return [center,
                    GridPos(center.x+1, center.y), GridPos(center.x-1, center.y),
                    GridPos(center.x, center.y+1), GridPos(center.x, center.y-1)]
        default: // 3x3
            var t: [GridPos] = []
            for dx in -1...1 { for dy in -1...1 { t.append(GridPos(center.x+dx, center.y+dy)) } }
            return t
        }
    }
}

enum SpellCatalog {
    // Indexed by id. Each mage class owns 4 spells.
    static let all: [SpellDef] = pyromancer + hydromancer + stormcaller + frostweaver +
        toxicologist + geomancer + voidbinder + runesmith

    static func spell(_ id: String) -> SpellDef? { all.first { $0.id == id } }

    static func standardTiers(_ base: String, rb: Int = 1, ab: Int = 0, db: Int = 1) -> (SpellUpgrade, SpellUpgrade, SpellUpgrade) {
        (
            SpellUpgrade(title: "Extended Reach", desc: "+\(rb) range.", rangeBonus: rb, aoeBonus: 0, damageBonus: 0, addsReaction: false),
            SpellUpgrade(title: "Widened Field", desc: "+1 area of effect tier.", rangeBonus: 0, aoeBonus: 1, damageBonus: 0, addsReaction: false),
            SpellUpgrade(title: "Empowered \(base)", desc: "+\(db) damage and a stronger reaction.", rangeBonus: 0, aoeBonus: 0, damageBonus: db, addsReaction: true)
        )
    }

    // PYROMANCER — fire
    static let pyromancer: [SpellDef] = {
        let t1 = standardTiers("Flame")
        let t2 = standardTiers("Blaze", ab: 1)
        let t3 = standardTiers("Inferno", db: 2)
        let t4 = standardTiers("Ember", rb: 2)
        return [
            SpellDef(id: "pyro_firebolt", name: "Firebolt", element: .fire, baseRange: 4, baseAoE: 0, baseDamage: 3, manaCost: 2,
                     lore: "A lance of flame. Ignites oil and vines on contact.", tier1: t1.0, tier2: t1.1, tier3: t1.2),
            SpellDef(id: "pyro_flamewave", name: "Flame Wave", element: .fire, baseRange: 3, baseAoE: 1, baseDamage: 2, manaCost: 3,
                     lore: "A fan of fire across adjacent tiles.", tier1: t2.0, tier2: t2.1, tier3: t2.2),
            SpellDef(id: "pyro_eruption", name: "Eruption", element: .fire, baseRange: 3, baseAoE: 2, baseDamage: 2, manaCost: 4,
                     lore: "A bursting column of flame over a 3x3 area.", tier1: t3.0, tier2: t3.1, tier3: t3.2),
            SpellDef(id: "pyro_emberseed", name: "Ember Seed", element: .fire, baseRange: 5, baseAoE: 0, baseDamage: 1, manaCost: 1,
                     lore: "A long-range spark, perfect for lighting a distant fuse.", tier1: t4.0, tier2: t4.1, tier3: t4.2),
        ]
    }()

    // HYDROMANCER — water
    static let hydromancer: [SpellDef] = {
        let a = standardTiers("Tide"); let b = standardTiers("Surge", ab: 1)
        let c = standardTiers("Deluge", db: 2); let d = standardTiers("Spray", rb: 2)
        return [
            SpellDef(id: "hydro_waterjet", name: "Water Jet", element: .water, baseRange: 4, baseAoE: 0, baseDamage: 1, manaCost: 2,
                     lore: "A focused stream that wets a tile — a conductor for lightning.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "hydro_flood", name: "Flood", element: .water, baseRange: 3, baseAoE: 2, baseDamage: 0, manaCost: 4,
                     lore: "Soaks a 3x3 area, setting up huge chain reactions.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "hydro_quench", name: "Quench", element: .water, baseRange: 3, baseAoE: 1, baseDamage: 0, manaCost: 2,
                     lore: "Extinguishes fire and clears a plus-shaped area into steam.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "hydro_riptide", name: "Riptide", element: .water, baseRange: 2, baseAoE: 0, baseDamage: 3, manaCost: 3,
                     lore: "A crushing wave that wets and damages a nearby foe.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()

    // STORMCALLER — lightning charge
    static let stormcaller: [SpellDef] = {
        let a = standardTiers("Arc"); let b = standardTiers("Storm", ab: 1)
        let c = standardTiers("Thunder", db: 2); let d = standardTiers("Spark", rb: 2)
        return [
            SpellDef(id: "storm_shock", name: "Shock", element: .charge, baseRange: 4, baseAoE: 0, baseDamage: 3, manaCost: 2,
                     lore: "A bolt that chains across water and stuns the wet.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "storm_chainlight", name: "Chain Lightning", element: .charge, baseRange: 5, baseAoE: 0, baseDamage: 4, manaCost: 4,
                     lore: "A long arc primed to detonate every connected pool.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "storm_chargefield", name: "Charge Field", element: .charge, baseRange: 3, baseAoE: 1, baseDamage: 1, manaCost: 3,
                     lore: "Lays lingering charge over a plus pattern, awaiting water.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "storm_overload", name: "Overload", element: .charge, baseRange: 2, baseAoE: 2, baseDamage: 2, manaCost: 4,
                     lore: "A close-range burst of stunning current.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()

    // FROSTWEAVER — ice
    static let frostweaver: [SpellDef] = {
        let a = standardTiers("Frost"); let b = standardTiers("Glacier", ab: 1)
        let c = standardTiers("Blizzard", db: 2); let d = standardTiers("Rime", rb: 2)
        return [
            SpellDef(id: "frost_iceshard", name: "Ice Shard", element: .ice, baseRange: 4, baseAoE: 0, baseDamage: 3, manaCost: 2,
                     lore: "A frozen spike that freezes water into a wall.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "frost_wall", name: "Frost Wall", element: .ice, baseRange: 3, baseAoE: 1, baseDamage: 0, manaCost: 3,
                     lore: "Raises a plus-shaped barrier on wet ground.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "frost_glacialburst", name: "Glacial Burst", element: .ice, baseRange: 3, baseAoE: 2, baseDamage: 2, manaCost: 4,
                     lore: "A 3x3 freeze that locks foes and seals the field.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "frost_chillbolt", name: "Chill Bolt", element: .ice, baseRange: 5, baseAoE: 0, baseDamage: 2, manaCost: 2,
                     lore: "A long-range frost dart.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()

    // TOXICOLOGIST — poison
    static let toxicologist: [SpellDef] = {
        let a = standardTiers("Venom"); let b = standardTiers("Plague", ab: 1)
        let c = standardTiers("Blight", db: 2); let d = standardTiers("Spore", rb: 2)
        return [
            SpellDef(id: "tox_poisonbolt", name: "Poison Bolt", element: .poison, baseRange: 4, baseAoE: 0, baseDamage: 2, manaCost: 2,
                     lore: "A glob of toxin that corrodes and detonates near fire.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "tox_miasma", name: "Miasma", element: .poison, baseRange: 3, baseAoE: 2, baseDamage: 1, manaCost: 4,
                     lore: "Blankets a 3x3 in corrosive cloud.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "tox_corrode", name: "Corrode", element: .poison, baseRange: 3, baseAoE: 1, baseDamage: 3, manaCost: 3,
                     lore: "A concentrated acid spray over a plus pattern.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "tox_creepingspore", name: "Creeping Spore", element: .poison, baseRange: 5, baseAoE: 0, baseDamage: 1, manaCost: 2,
                     lore: "A spore lobbed far across the field.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()

    // GEOMANCER — vines/earth
    static let geomancer: [SpellDef] = {
        let a = standardTiers("Bramble"); let b = standardTiers("Thicket", ab: 1)
        let c = standardTiers("Grove", db: 2); let d = standardTiers("Seed", rb: 2)
        return [
            SpellDef(id: "geo_thornlash", name: "Thorn Lash", element: .vines, baseRange: 4, baseAoE: 0, baseDamage: 3, manaCost: 2,
                     lore: "Vines erupt and snare a single tile.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "geo_entangle", name: "Entangle", element: .vines, baseRange: 3, baseAoE: 1, baseDamage: 1, manaCost: 3,
                     lore: "Walls of vine in a plus pattern to block enemy paths.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "geo_overgrowth", name: "Overgrowth", element: .vines, baseRange: 3, baseAoE: 2, baseDamage: 1, manaCost: 4,
                     lore: "A 3x3 thicket that seals the field — flammable.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "geo_rootspike", name: "Root Spike", element: .vines, baseRange: 2, baseAoE: 0, baseDamage: 4, manaCost: 3,
                     lore: "A spear of root from below, heavy single-target damage.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()

    // VOIDBINDER — void (consumes/negates elements)
    static let voidbinder: [SpellDef] = {
        let a = standardTiers("Null"); let b = standardTiers("Rift", ab: 1)
        let c = standardTiers("Oblivion", db: 2); let d = standardTiers("Sink", rb: 2)
        return [
            SpellDef(id: "void_nullbolt", name: "Null Bolt", element: .voidd, baseRange: 4, baseAoE: 0, baseDamage: 4, manaCost: 2,
                     lore: "Erases a tile's element and wounds its occupant.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "void_rift", name: "Void Rift", element: .voidd, baseRange: 3, baseAoE: 1, baseDamage: 2, manaCost: 3,
                     lore: "Consumes elements across a plus pattern — a reset button.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "void_collapse", name: "Collapse", element: .voidd, baseRange: 3, baseAoE: 2, baseDamage: 3, manaCost: 4,
                     lore: "A 3x3 implosion that strips the field bare and damages all.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "void_drain", name: "Drain", element: .voidd, baseRange: 2, baseAoE: 0, baseDamage: 5, manaCost: 3,
                     lore: "Tears the life from a nearby foe, ignoring affinities.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()

    // RUNESMITH — places persistent rune tiles (modeled as element pre-seeds + damage)
    static let runesmith: [SpellDef] = {
        let a = standardTiers("Glyph"); let b = standardTiers("Ward", ab: 1)
        let c = standardTiers("Seal", db: 2); let d = standardTiers("Sigil", rb: 2)
        return [
            SpellDef(id: "rune_emberrune", name: "Ember Rune", element: .fire, baseRange: 4, baseAoE: 0, baseDamage: 2, manaCost: 2,
                     lore: "Inscribes a fire rune that ignites whatever it touches.", tier1: a.0, tier2: a.1, tier3: a.2),
            SpellDef(id: "rune_tiderune", name: "Tide Rune", element: .water, baseRange: 4, baseAoE: 0, baseDamage: 1, manaCost: 2,
                     lore: "A water rune to prime conductive chains.", tier1: b.0, tier2: b.1, tier3: b.2),
            SpellDef(id: "rune_stormrune", name: "Storm Rune", element: .charge, baseRange: 4, baseAoE: 1, baseDamage: 3, manaCost: 3,
                     lore: "A charged rune across a plus pattern.", tier1: c.0, tier2: c.1, tier3: c.2),
            SpellDef(id: "rune_wardrune", name: "Ward Rune", element: .ice, baseRange: 3, baseAoE: 1, baseDamage: 1, manaCost: 3,
                     lore: "A protective ice rune that walls and chills.", tier1: d.0, tier2: d.1, tier3: d.2),
        ]
    }()
}
