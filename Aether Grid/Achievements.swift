import SwiftUI

struct AchievementDef: Identifiable {
    let id: String
    let name: String
    let desc: String
}

enum AchievementCatalog {
    static let all: [AchievementDef] = [
        AchievementDef(id: "ach_first_blood", name: "First Spark", desc: "Win your first mission."),
        AchievementDef(id: "ach_region1", name: "Cinder Conqueror", desc: "Complete The Cinder Reach."),
        AchievementDef(id: "ach_region2", name: "Fen Walker", desc: "Complete The Drowned Fen."),
        AchievementDef(id: "ach_region3", name: "Spire Climber", desc: "Complete The Howling Spires."),
        AchievementDef(id: "ach_region4", name: "Marsh Cleanser", desc: "Complete The Rot Marsh."),
        AchievementDef(id: "ach_region5", name: "Wild Tamer", desc: "Complete The Thornwild."),
        AchievementDef(id: "ach_region6", name: "Void Ender", desc: "Complete The Hollow Between."),
        AchievementDef(id: "ach_boss1", name: "Ember Lord Slain", desc: "Defeat Vulcaron."),
        AchievementDef(id: "ach_boss2", name: "Tide Queen Slain", desc: "Defeat Maerwyn."),
        AchievementDef(id: "ach_boss3", name: "Storm Tyrant Slain", desc: "Defeat Zekarrh."),
        AchievementDef(id: "ach_boss4", name: "Blight Mother Slain", desc: "Defeat Sythrra."),
        AchievementDef(id: "ach_boss5", name: "Thorn King Slain", desc: "Defeat Oakthar."),
        AchievementDef(id: "ach_boss6", name: "World Saved", desc: "Defeat the Void Herald."),
        AchievementDef(id: "ach_reaction10", name: "Alchemist", desc: "Trigger 10 elemental reactions."),
        AchievementDef(id: "ach_reaction100", name: "Grand Alchemist", desc: "Trigger 100 elemental reactions."),
        AchievementDef(id: "ach_chainstun", name: "Conductor", desc: "Chain-stun 3 enemies in one cast."),
        AchievementDef(id: "ach_detonate", name: "Demolitionist", desc: "Detonate a poison cloud."),
        AchievementDef(id: "ach_flawless", name: "Untouchable", desc: "Win a mission without any mage taking damage."),
        AchievementDef(id: "ach_reactiononly", name: "Pure Chemistry", desc: "Win a mission using only reaction kills."),
        AchievementDef(id: "ach_threestar", name: "Perfectionist", desc: "Earn 3 stars on a mission."),
        AchievementDef(id: "ach_unlockall", name: "Full Coven", desc: "Unlock all 8 mage classes."),
        AchievementDef(id: "ach_upgrade", name: "Scholar", desc: "Upgrade a spell to tier 3."),
        AchievementDef(id: "ach_stars50", name: "Star-Forged", desc: "Earn 50 total stars."),
        AchievementDef(id: "ach_stars150", name: "Archmage", desc: "Earn 150 total stars."),
    ]

    static func byId(_ id: String) -> AchievementDef? { all.first { $0.id == id } }
}
