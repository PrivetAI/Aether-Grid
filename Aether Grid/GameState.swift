import SwiftUI

final class GameStore: ObservableObject {
    @Published var save: SaveData

    init() {
        self.save = SaveStore.load()
    }

    func persist() { SaveStore.save(save) }

    // MARK: - Progression queries

    func stars(for missionId: String) -> Int { save.missionStars[missionId] ?? 0 }

    func isMissionUnlocked(_ m: MissionDef) -> Bool {
        // First mission of region requires the region itself unlocked.
        // Within a region, mission N requires mission N-1 completed (>=1 star).
        guard isRegionUnlocked(m.regionIndex) else { return false }
        if m.indexInRegion == 0 { return true }
        let prevId = "\(missionIdPrefix(m.regionIndex))m\(m.indexInRegion)"
        return stars(for: prevId) >= 1
    }

    private func missionIdPrefix(_ region: Int) -> String { "r\(region+1)" }

    func isRegionUnlocked(_ region: Int) -> Bool {
        save.totalStars >= Regions.region(region).starsToUnlock
    }

    func isClassUnlocked(_ cls: MageClass) -> Bool {
        save.totalStars >= cls.unlockStars
    }

    func spellTier(_ spellId: String) -> Int { save.spellTiers[spellId] ?? 0 }

    func upgradedSpell(_ base: SpellDef) -> ResolvedSpell {
        let tier = spellTier(base.id)
        var range = base.baseRange
        var aoe = base.baseAoE
        var dmg = base.baseDamage
        var addedReaction = false
        if tier >= 1 { range += base.tier1.rangeBonus; aoe += base.tier1.aoeBonus; dmg += base.tier1.damageBonus; addedReaction = addedReaction || base.tier1.addsReaction }
        if tier >= 2 { range += base.tier2.rangeBonus; aoe += base.tier2.aoeBonus; dmg += base.tier2.damageBonus; addedReaction = addedReaction || base.tier2.addsReaction }
        if tier >= 3 { range += base.tier3.rangeBonus; aoe += base.tier3.aoeBonus; dmg += base.tier3.damageBonus; addedReaction = addedReaction || base.tier3.addsReaction }
        return ResolvedSpell(def: base, range: range, aoe: min(aoe, 2), damage: dmg, addedReaction: addedReaction, tier: tier)
    }

    func upgradeCost(_ spellId: String) -> Int {
        let tier = spellTier(spellId)
        switch tier {
        case 0: return 30
        case 1: return 60
        case 2: return 110
        default: return 0
        }
    }

    func canUpgrade(_ spellId: String) -> Bool {
        spellTier(spellId) < 3 && save.essence >= upgradeCost(spellId)
    }

    func upgrade(_ spellId: String) {
        guard canUpgrade(spellId) else { return }
        save.essence -= upgradeCost(spellId)
        save.spellTiers[spellId] = spellTier(spellId) + 1
        if spellTier(spellId) >= 3 { unlockAchievement("ach_upgrade") }
        persist()
    }

    // MARK: - Mission completion

    /// Record mission result. Stars awarded exactly once at the best level.
    func recordResult(mission: MissionDef, stars newStars: Int, essenceReward: Int,
                      bossDefeated: String?) {
        let previousBest = stars(for: mission.id)
        let firstTime = previousBest == 0
        if newStars > previousBest {
            // award the *difference* in total stars
            let oldTotal = save.totalStars
            save.missionStars[mission.id] = newStars
            recomputeTotalStars()
            _ = oldTotal
        }
        // Essence: full reward on first clear, small repeat reward otherwise.
        if firstTime {
            save.essence += essenceReward
            save.missionsWon += 1
            unlockAchievement("ach_first_blood")
        } else {
            save.essence += max(5, essenceReward / 4)
        }
        if newStars >= 3 { unlockAchievement("ach_threestar") }

        if let bid = bossDefeated {
            save.bossesDefeated = min(save.bossesDefeated + (firstTime ? 1 : 0), BossCatalog.all.count)
            switch bid {
            case "boss_emberlord": unlockAchievement("ach_boss1")
            case "boss_tidequeen": unlockAchievement("ach_boss2")
            case "boss_stormtyrant": unlockAchievement("ach_boss3")
            case "boss_blightmother": unlockAchievement("ach_boss4")
            case "boss_thornking": unlockAchievement("ach_boss5")
            case "boss_voidherald": unlockAchievement("ach_boss6")
            default: break
            }
        }
        checkRegionCompletionAchievements()
        checkStarAchievements()
        checkClassUnlockAchievement()
        persist()
    }

    private func recomputeTotalStars() {
        save.totalStars = save.missionStars.values.reduce(0, +)
    }

    private func checkRegionCompletionAchievements() {
        for r in 0..<6 {
            let ms = MissionCatalog.missions(region: r)
            let done = ms.allSatisfy { stars(for: $0.id) >= 1 }
            if done {
                unlockAchievement("ach_region\(r+1)")
            }
        }
    }

    private func checkStarAchievements() {
        if save.totalStars >= 50 { unlockAchievement("ach_stars50") }
        if save.totalStars >= 150 { unlockAchievement("ach_stars150") }
    }

    private func checkClassUnlockAchievement() {
        if MageRoster.all.allSatisfy({ isClassUnlocked($0) }) {
            unlockAchievement("ach_unlockall")
        }
    }

    // MARK: - Achievements / Grimoire tracking

    func unlockAchievement(_ id: String) {
        guard AchievementCatalog.byId(id) != nil else { return }
        if !save.unlockedAchievements.contains(id) {
            save.unlockedAchievements.append(id)
        }
    }
    func isAchievementUnlocked(_ id: String) -> Bool { save.unlockedAchievements.contains(id) }

    func markElementSeen(_ k: ElementKind) {
        if !save.seenElements.contains(k.rawValue) { save.seenElements.append(k.rawValue) }
    }
    func markReactionSeen(applied: ElementKind, existing: ElementKind) {
        let key = "\(applied.rawValue)|\(existing.rawValue)"
        if !save.seenReactions.contains(key) { save.seenReactions.append(key) }
    }
    func markEnemySeen(_ id: String) {
        if !save.seenEnemies.contains(id) { save.seenEnemies.append(id) }
    }
    func markSpellSeen(_ id: String) {
        if !save.seenSpells.contains(id) { save.seenSpells.append(id) }
    }

    // MARK: - Statistics commits from a finished battle

    func commitBattleStats(reactions: Int, enemiesDefeated: Int, spellsCast: Int, turns: Int) {
        save.reactionsTriggered += reactions
        save.enemiesDefeated += enemiesDefeated
        save.spellsCast += spellsCast
        save.totalTurnsPlayed += turns
        if save.reactionsTriggered >= 10 { unlockAchievement("ach_reaction10") }
        if save.reactionsTriggered >= 100 { unlockAchievement("ach_reaction100") }
        persist()
    }

    // MARK: - Reset

    func resetProgress() {
        SaveStore.wipe()
        save = SaveData()
        persist()
    }
}

struct ResolvedSpell {
    let def: SpellDef
    let range: Int
    let aoe: Int
    let damage: Int
    let addedReaction: Bool
    let tier: Int

    var element: ElementKind { def.element }
    var name: String { def.name }
    var manaCost: Int { def.manaCost }
}
