import SwiftUI

struct MageClass: Identifiable {
    let id: String
    let name: String
    let title: String
    let element: ElementKind
    let maxHP: Int
    let maxMana: Int
    let manaRegen: Int
    let spellIDs: [String]
    let unlockStars: Int     // total stars required to unlock
    let lore: String
}

enum MageRoster {
    static let all: [MageClass] = [
        MageClass(id: "pyromancer", name: "Ignara", title: "Pyromancer", element: .fire,
                  maxHP: 22, maxMana: 8, manaRegen: 3,
                  spellIDs: ["pyro_firebolt", "pyro_flamewave", "pyro_eruption", "pyro_emberseed"],
                  unlockStars: 0,
                  lore: "Born in the ash-vents of the Cinder Reach, Ignara channels the hungriest element. Her flame turns oil slicks and vine beds into racing infernos."),
        MageClass(id: "hydromancer", name: "Nerith", title: "Hydromancer", element: .water,
                  maxHP: 24, maxMana: 9, manaRegen: 3,
                  spellIDs: ["hydro_waterjet", "hydro_flood", "hydro_quench", "hydro_riptide"],
                  unlockStars: 0,
                  lore: "Nerith reads the tide of battle literally. She floods the field to set up devastating lightning chains for her allies."),
        MageClass(id: "stormcaller", name: "Vael", title: "Stormcaller", element: .charge,
                  maxHP: 20, maxMana: 9, manaRegen: 3,
                  spellIDs: ["storm_shock", "storm_chainlight", "storm_chargefield", "storm_overload"],
                  unlockStars: 6,
                  lore: "Vael hears the storm before it breaks. On wetted ground his lightning leaps from foe to foe, stunning all it touches."),
        MageClass(id: "frostweaver", name: "Sylwen", title: "Frostweaver", element: .ice,
                  maxHP: 23, maxMana: 8, manaRegen: 3,
                  spellIDs: ["frost_iceshard", "frost_wall", "frost_glacialburst", "frost_chillbolt"],
                  unlockStars: 12,
                  lore: "Sylwen shapes the battlefield itself, freezing water into walls that funnel enemies into killing grounds."),
        MageClass(id: "toxicologist", name: "Morr", title: "Toxicologist", element: .poison,
                  maxHP: 21, maxMana: 8, manaRegen: 3,
                  spellIDs: ["tox_poisonbolt", "tox_miasma", "tox_corrode", "tox_creepingspore"],
                  unlockStars: 20,
                  lore: "Morr brews ruin in glass. His poison clouds corrode armor and detonate spectacularly when a Pyromancer is near."),
        MageClass(id: "geomancer", name: "Brann", title: "Geomancer", element: .vines,
                  maxHP: 26, maxMana: 7, manaRegen: 3,
                  spellIDs: ["geo_thornlash", "geo_entangle", "geo_overgrowth", "geo_rootspike"],
                  unlockStars: 30,
                  lore: "Brann commands the living earth. His vine walls cage the enemy — and make perfect fuel for a burn-path."),
        MageClass(id: "voidbinder", name: "Khale", title: "Voidbinder", element: .voidd,
                  maxHP: 22, maxMana: 9, manaRegen: 3,
                  spellIDs: ["void_nullbolt", "void_rift", "void_collapse", "void_drain"],
                  unlockStars: 42,
                  lore: "Khale walks the space between elements. Where she casts, the field goes silent — a counter to enemies who weaponize terrain."),
        MageClass(id: "runesmith", name: "Dura", title: "Runesmith", element: .fire,
                  maxHP: 25, maxMana: 8, manaRegen: 3,
                  spellIDs: ["rune_emberrune", "rune_tiderune", "rune_stormrune", "rune_wardrune"],
                  unlockStars: 56,
                  lore: "Dura inscribes persistent runes that pre-seed the field with elements, letting her conduct multi-element reactions single-handed."),
    ]

    static func byId(_ id: String) -> MageClass? { all.first { $0.id == id } }
}
