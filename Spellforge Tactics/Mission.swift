import SwiftUI

enum ObjectiveKind: Equatable {
    case annihilate                  // defeat all enemies
    case survive(turns: Int)         // survive N enemy turns
    case protectLeyNode(GridPos, turns: Int)  // keep node tile free of enemies for N turns
    case escort(to: GridPos)         // move a channeler mage to exit
    case defeatBoss(bossId: String)  // kill the boss
    case igniteTiles([GridPos])      // set fire on specific tiles
    case extinguishTiles([GridPos])  // clear element from specific tiles

    var label: String {
        switch self {
        case .annihilate: return "Annihilate all enemies"
        case .survive(let t): return "Survive \(t) turns"
        case .protectLeyNode(_, let t): return "Protect the ley-node for \(t) turns"
        case .escort: return "Escort the channeler to the exit"
        case .defeatBoss: return "Defeat the boss"
        case .igniteTiles(let t): return "Ignite \(t.count) marked tile(s)"
        case .extinguishTiles(let t): return "Extinguish \(t.count) marked tile(s)"
        }
    }
}

enum BonusKind: Equatable {
    case reactionKillsOnly       // every enemy killed by a reaction (not direct damage)
    case noMageDamage            // no mage takes any damage
    case underTurns(Int)         // win within N rounds
    case noMageLost              // (used for 3rd star generally; included for variety)

    var label: String {
        switch self {
        case .reactionKillsOnly: return "Bonus: win using only reaction kills"
        case .noMageDamage: return "Bonus: no mage takes damage"
        case .underTurns(let n): return "Bonus: win within \(n) rounds"
        case .noMageLost: return "Bonus: lose no mage"
        }
    }
}

struct MissionTerrainPatch {
    let kind: TerrainKind
    let tiles: [GridPos]
    init(_ kind: TerrainKind, _ tiles: [GridPos]) { self.kind = kind; self.tiles = tiles }
}

struct MissionDef: Identifiable {
    let id: String
    let regionIndex: Int
    let indexInRegion: Int    // 0-based (0..8)
    let name: String
    let gridW: Int
    let gridH: Int
    let objective: ObjectiveKind
    let bonus: BonusKind
    let terrain: [MissionTerrainPatch]
    let mageSpawns: [GridPos]         // up to 4 starting tiles for the party
    let enemySpawns: [EnemySpawn]
    let waves: [EnemyWave]
    let exitTile: GridPos?           // for escort
    let lore: String

    var displayNumber: Int { indexInRegion + 1 }
}

struct Region: Identifiable {
    let id: Int
    let name: String
    let subtitle: String
    let starsToUnlock: Int
    let accent: Color
    let lore: String
}

enum Regions {
    static let all: [Region] = [
        Region(id: 0, name: "The Cinder Reach", subtitle: "Ash and Oil", starsToUnlock: 0, accent: Theme.ember,
               lore: "A scorched waste of oil vents and lava flows where the Ember Lord rules."),
        Region(id: 1, name: "The Drowned Fen", subtitle: "Water and Storm", starsToUnlock: 10, accent: Theme.aqua,
               lore: "A flooded marsh of conductive pools, domain of the Tide Queen."),
        Region(id: 2, name: "The Howling Spires", subtitle: "Frost and Lightning", starsToUnlock: 24, accent: Theme.storm,
               lore: "Storm-wracked peaks of ice sheets and metal ruins ruled by the Storm Tyrant."),
        Region(id: 3, name: "The Rot Marsh", subtitle: "Poison and Decay", starsToUnlock: 40, accent: Theme.poison,
               lore: "A festering bog where the Blight Mother breeds her endless brood."),
        Region(id: 4, name: "The Thornwild", subtitle: "Vine and Earth", starsToUnlock: 58, accent: Theme.vine,
               lore: "A living jungle of bramble walls and vine beds, throne of the Thorn King."),
        Region(id: 5, name: "The Hollow Between", subtitle: "Void and Ruin", starsToUnlock: 78, accent: Theme.voidc,
               lore: "The unraveling edge of the world, where the Void Herald devours all elements."),
    ]

    static func region(_ i: Int) -> Region { all[i] }
}

enum MissionCatalog {
    static var all: [MissionDef] = {
        MissionsR1.missions + MissionsR2.missions + MissionsR3.missions +
        MissionsR4.missions + MissionsR5.missions + MissionsR6.missions
    }()

    static func missions(region: Int) -> [MissionDef] {
        all.filter { $0.regionIndex == region }.sorted { $0.indexInRegion < $1.indexInRegion }
    }

    static func byId(_ id: String) -> MissionDef? { all.first { $0.id == id } }
    static var count: Int { all.count }
}
