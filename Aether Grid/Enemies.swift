import SwiftUI

enum EnemyBehavior: String, Codable {
    case advance         // move toward nearest mage, attack if adjacent
    case ranged          // attack from distance, kite
    case charger         // rush long distance, heavy hit
    case splitter        // splits into two on death (sludge)
    case flooder         // floods a nearby tile with water each turn (totem, immobile)
    case igniter         // seeds fire on a nearby tile each turn
    case randomizer      // randomizes an element on a tile each turn (stormcrow)
    case guardian        // immobile, high HP, must be destroyed for objectives
    case summoner        // periodically spawns a weak minion
    case leech           // heals when adjacent mage takes damage
    case phaser          // ignores vines/ice walls
    case turret          // immobile ranged
}

struct EnemyDef: Identifiable {
    let id: String
    let name: String
    let maxHP: Int
    let damage: Int
    let moveRange: Int
    let attackRange: Int
    let behavior: EnemyBehavior
    let immunities: [ElementKind]    // takes no damage / no reaction from these
    let weaknesses: [ElementKind]    // takes double damage from these
    let splitsInto: String?          // enemy id spawned on death (splitter)
    let summons: String?             // enemy id spawned by summoner
    let lore: String
}

enum EnemyCatalog {
    static let all: [EnemyDef] = [
        EnemyDef(id: "husk", name: "Ashen Husk", maxHP: 6, damage: 2, moveRange: 2, attackRange: 1,
                 behavior: .advance, immunities: [], weaknesses: [.water],
                 splitsInto: nil, summons: nil,
                 lore: "A shambling, brittle corpse animated by stray mana. Weak, but they come in numbers."),
        EnemyDef(id: "fireelem", name: "Cinder Elemental", maxHP: 10, damage: 3, moveRange: 2, attackRange: 1,
                 behavior: .advance, immunities: [.fire], weaknesses: [.water, .ice],
                 splitsInto: nil, summons: nil,
                 lore: "A creature of living flame. Immune to fire — but wet it and freeze it and it shatters instantly."),
        EnemyDef(id: "waterelem", name: "Tide Elemental", maxHP: 11, damage: 3, moveRange: 2, attackRange: 1,
                 behavior: .advance, immunities: [.water], weaknesses: [.charge],
                 splitsInto: nil, summons: nil,
                 lore: "A churning column of water. Lightning is its undoing."),
        EnemyDef(id: "sludge", name: "Caustic Sludge", maxHP: 8, damage: 2, moveRange: 1, attackRange: 1,
                 behavior: .splitter, immunities: [.poison], weaknesses: [.fire],
                 splitsInto: "sludgelet", summons: nil,
                 lore: "A toxic ooze that splits into two lesser sludges when struck down. Burn it to stop the spread."),
        EnemyDef(id: "sludgelet", name: "Sludgelet", maxHP: 3, damage: 1, moveRange: 1, attackRange: 1,
                 behavior: .advance, immunities: [.poison], weaknesses: [.fire],
                 splitsInto: nil, summons: nil,
                 lore: "A small fragment of a larger sludge. Fragile, but acidic."),
        EnemyDef(id: "charger", name: "Bonewrack Charger", maxHP: 12, damage: 5, moveRange: 4, attackRange: 1,
                 behavior: .charger, immunities: [], weaknesses: [.vines],
                 splitsInto: nil, summons: nil,
                 lore: "A galloping horror that closes distance fast. Vine walls stop it cold."),
        EnemyDef(id: "floodtotem", name: "Flood Totem", maxHP: 14, damage: 0, moveRange: 0, attackRange: 0,
                 behavior: .flooder, immunities: [.water], weaknesses: [.fire],
                 splitsInto: nil, summons: nil,
                 lore: "An immobile idol that drowns a nearby tile in water each turn — fuel for an enemy Stormcaller, or for you."),
        EnemyDef(id: "pyretotem", name: "Pyre Totem", maxHP: 14, damage: 0, moveRange: 0, attackRange: 0,
                 behavior: .igniter, immunities: [.fire], weaknesses: [.water],
                 splitsInto: nil, summons: nil,
                 lore: "A burning idol that spits fire onto a nearby tile each turn."),
        EnemyDef(id: "stormcrow", name: "Stormcrow", maxHP: 7, damage: 2, moveRange: 3, attackRange: 2,
                 behavior: .randomizer, immunities: [.charge], weaknesses: [.ice],
                 splitsInto: nil, summons: nil,
                 lore: "An erratic bird of static that scrambles the element on a random tile each turn. Freeze it."),
        EnemyDef(id: "hexarcher", name: "Hex Archer", maxHP: 8, damage: 4, moveRange: 2, attackRange: 4,
                 behavior: .ranged, immunities: [], weaknesses: [.poison],
                 splitsInto: nil, summons: nil,
                 lore: "A skeletal archer that strikes from afar and retreats. Close the gap or chain it."),
        EnemyDef(id: "boneturret", name: "Bone Turret", maxHP: 16, damage: 4, moveRange: 0, attackRange: 5,
                 behavior: .turret, immunities: [], weaknesses: [.voidd],
                 splitsInto: nil, summons: nil,
                 lore: "An immobile siege construct of fused bone. Long reach, no mobility."),
        EnemyDef(id: "graveguard", name: "Grave Guardian", maxHP: 22, damage: 4, moveRange: 0, attackRange: 1,
                 behavior: .guardian, immunities: [], weaknesses: [.charge],
                 splitsInto: nil, summons: nil,
                 lore: "A towering sentinel that never moves but punishes any who approach. Often guards a ley-node."),
        EnemyDef(id: "necromancer", name: "Pale Necromancer", maxHP: 13, damage: 2, moveRange: 1, attackRange: 3,
                 behavior: .summoner, immunities: [], weaknesses: [.fire],
                 splitsInto: nil, summons: "husk",
                 lore: "Raises a fresh husk every few turns. Cut off the source quickly."),
        EnemyDef(id: "soulleech", name: "Soul Leech", maxHP: 9, damage: 3, moveRange: 3, attackRange: 1,
                 behavior: .leech, immunities: [], weaknesses: [.voidd],
                 splitsInto: nil, summons: nil,
                 lore: "A parasite that mends itself whenever a mage is wounded. Void severs its feeding."),
        EnemyDef(id: "phasewraith", name: "Phase Wraith", maxHP: 10, damage: 4, moveRange: 3, attackRange: 1,
                 behavior: .phaser, immunities: [], weaknesses: [.voidd, .ice],
                 splitsInto: nil, summons: nil,
                 lore: "A spectre that drifts through vine and ice walls. Only void and frost truly bind it."),
        EnemyDef(id: "venomspitter", name: "Venom Spitter", maxHP: 9, damage: 3, moveRange: 2, attackRange: 3,
                 behavior: .ranged, immunities: [.poison], weaknesses: [.ice],
                 splitsInto: nil, summons: nil,
                 lore: "Hurls acid from range. Immune to its own poison."),
        EnemyDef(id: "frostbound", name: "Frostbound Revenant", maxHP: 12, damage: 3, moveRange: 2, attackRange: 1,
                 behavior: .advance, immunities: [.ice], weaknesses: [.fire],
                 splitsInto: nil, summons: nil,
                 lore: "A corpse encased in eternal ice. Fire melts its armor and itself."),
        EnemyDef(id: "thornhulk", name: "Thorn Hulk", maxHP: 18, damage: 4, moveRange: 1, attackRange: 1,
                 behavior: .advance, immunities: [.vines], weaknesses: [.fire],
                 splitsInto: nil, summons: nil,
                 lore: "A lumbering mass of bramble and bark. Slow but tough — and very flammable."),
        EnemyDef(id: "voidspawn", name: "Void Spawn", maxHP: 11, damage: 4, moveRange: 3, attackRange: 1,
                 behavior: .advance, immunities: [.voidd], weaknesses: [.fire, .charge],
                 splitsInto: nil, summons: nil,
                 lore: "A shard of living nothing. It resists void but burns and shocks like anything else."),
    ]

    static func byId(_ id: String) -> EnemyDef? { all.first { $0.id == id } }
}
