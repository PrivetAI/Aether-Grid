import SwiftUI

// Bosses are special enemies with two phases. Phase 2 begins at <= half HP,
// changing their behavior/affinities. Implemented as EnemyDef pairs.
struct BossDef: Identifiable {
    let id: String
    let name: String
    let title: String
    let phase1HP: Int
    let phase2HP: Int          // HP threshold at which phase 2 starts (== phase1HP/2 typically)
    let damage: Int
    let moveRange: Int
    let attackRange: Int
    let phase1Behavior: EnemyBehavior
    let phase2Behavior: EnemyBehavior
    let phase1Immunities: [ElementKind]
    let phase2Immunities: [ElementKind]
    let weaknesses: [ElementKind]
    let regionIndex: Int       // which region finale (0-based)
    let lore: String
    let phase2Lore: String
}

enum BossCatalog {
    static let all: [BossDef] = [
        BossDef(id: "boss_emberlord", name: "Vulcaron", title: "The Ember Lord",
                phase1HP: 36, phase2HP: 18, damage: 5, moveRange: 2, attackRange: 2,
                phase1Behavior: .igniter, phase2Behavior: .charger,
                phase1Immunities: [.fire], phase2Immunities: [.fire],
                weaknesses: [.water, .ice], regionIndex: 0,
                lore: "A colossus of living magma who floods the arena with fire. Drown his flames to wound him.",
                phase2Lore: "Enraged, Vulcaron abandons his throne and charges. His molten core is now exposed to frost."),
        BossDef(id: "boss_tidequeen", name: "Maerwyn", title: "The Tide Queen",
                phase1HP: 40, phase2HP: 20, damage: 4, moveRange: 2, attackRange: 3,
                phase1Behavior: .flooder, phase2Behavior: .ranged,
                phase1Immunities: [.water], phase2Immunities: [.water, .ice],
                weaknesses: [.charge], regionIndex: 1,
                lore: "She drowns the field tile by tile, building lethal conductive pools. Turn her own water against her with lightning.",
                phase2Lore: "Half-drowned herself, Maerwyn freezes her flood into armor — only lightning still bites."),
        BossDef(id: "boss_stormtyrant", name: "Zekarrh", title: "The Storm Tyrant",
                phase1HP: 42, phase2HP: 21, damage: 5, moveRange: 3, attackRange: 4,
                phase1Behavior: .randomizer, phase2Behavior: .ranged,
                phase1Immunities: [.charge], phase2Immunities: [.charge],
                weaknesses: [.ice, .voidd], regionIndex: 2,
                lore: "A being of pure static that scrambles the battlefield each turn. Ground him with frost.",
                phase2Lore: "Cornered, Zekarrh hurls focused bolts. Void his charge to break the storm."),
        BossDef(id: "boss_blightmother", name: "Sythrra", title: "The Blight Mother",
                phase1HP: 44, phase2HP: 22, damage: 4, moveRange: 1, attackRange: 3,
                phase1Behavior: .summoner, phase2Behavior: .splitter,
                phase1Immunities: [.poison], phase2Immunities: [.poison],
                weaknesses: [.fire], regionIndex: 3,
                lore: "She births sludges and miasma without end. Burn her brood and detonate her clouds.",
                phase2Lore: "Wounded, the Blight Mother ruptures — strike her down and she splits. Fire ends the cycle."),
        BossDef(id: "boss_thornking", name: "Oakthar", title: "The Thorn King",
                phase1HP: 46, phase2HP: 23, damage: 5, moveRange: 1, attackRange: 2,
                phase1Behavior: .guardian, phase2Behavior: .advance,
                phase1Immunities: [.vines], phase2Immunities: [.vines],
                weaknesses: [.fire], regionIndex: 4,
                lore: "A throne of living bramble that walls off the field. Set his thicket ablaze with a burn-path.",
                phase2Lore: "His bark splits and he wades forward, dripping sap — even more flammable now."),
        BossDef(id: "boss_voidherald", name: "Nyxalor", title: "The Void Herald",
                phase1HP: 50, phase2HP: 25, damage: 6, moveRange: 3, attackRange: 2,
                phase1Behavior: .phaser, phase2Behavior: .charger,
                phase1Immunities: [.voidd], phase2Immunities: [.voidd],
                weaknesses: [.fire, .charge, .ice], regionIndex: 5,
                lore: "The final unmaker. It phases through every wall and devours the field's elements. Overwhelm it with raw elemental force.",
                phase2Lore: "Stripped of half its essence, Nyxalor lashes out in a frenzy. Every element now wounds it — end this."),
    ]

    static func boss(forRegion idx: Int) -> BossDef? { all.first { $0.regionIndex == idx } }
    static func byId(_ id: String) -> BossDef? { all.first { $0.id == id } }
}
