import SwiftUI

// Aggregates codex entries from the catalogs. Discovery state lives in GameStore.save.
enum GrimoireSection: String, CaseIterable, Identifiable {
    case elements = "Elements"
    case reactions = "Reactions"
    case enemies = "Enemies"
    case spells = "Spells"
    var id: String { rawValue }
}

struct GrimoireElementEntry: Identifiable {
    let id: String
    let kind: ElementKind
    var seen: Bool
}

struct GrimoireReactionEntry: Identifiable {
    let id: String
    let applied: ElementKind
    let existing: ElementKind
    let lore: String
    var seen: Bool
}

struct GrimoireEnemyEntry: Identifiable {
    let id: String
    let def: EnemyDef
    var seen: Bool
}

struct GrimoireSpellEntry: Identifiable {
    let id: String
    let def: SpellDef
    var seen: Bool
}

enum GrimoireBuilder {
    static func elements(_ save: SaveData) -> [GrimoireElementEntry] {
        ElementKind.allCases.map { GrimoireElementEntry(id: $0.rawValue, kind: $0, seen: save.seenElements.contains($0.rawValue)) }
    }
    static func reactions(_ save: SaveData) -> [GrimoireReactionEntry] {
        ReactionMatrix.documented.map { d in
            let key = "\(d.applied.rawValue)|\(d.existing.rawValue)"
            return GrimoireReactionEntry(id: key, applied: d.applied, existing: d.existing, lore: d.lore, seen: save.seenReactions.contains(key))
        }
    }
    static func enemies(_ save: SaveData) -> [GrimoireEnemyEntry] {
        EnemyCatalog.all.map { GrimoireEnemyEntry(id: $0.id, def: $0, seen: save.seenEnemies.contains($0.id)) }
    }
    static func spells(_ save: SaveData) -> [GrimoireSpellEntry] {
        SpellCatalog.all.map { GrimoireSpellEntry(id: $0.id, def: $0, seen: save.seenSpells.contains($0.id)) }
    }
}
