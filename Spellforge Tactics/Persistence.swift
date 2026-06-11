import Foundation

// Single Codable game-state blob persisted under spt.* namespace.
struct SaveData: Codable {
    var version: Int = 1
    var essence: Int = 0
    var totalStars: Int = 0
    var missionStars: [String: Int] = [:]          // missionId -> best stars (0..3)
    var spellTiers: [String: Int] = [:]            // spellId -> tier (0..3)
    var unlockedAchievements: [String] = []
    var seenElements: [String] = []
    var seenReactions: [String] = []               // "applied|existing"
    var seenEnemies: [String] = []
    var seenSpells: [String] = []
    var lastParty: [String] = []                   // mage class ids

    // Statistics
    var missionsWon: Int = 0
    var reactionsTriggered: Int = 0
    var enemiesDefeated: Int = 0
    var spellsCast: Int = 0
    var bossesDefeated: Int = 0
    var totalTurnsPlayed: Int = 0

    // Settings
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var onboardingDone: Bool = false
}

enum SaveStore {
    static let key = "spt.gamestate.v1"

    static func load() -> SaveData {
        guard let data = UserDefaults.standard.data(forKey: key) else { return SaveData() }
        do {
            return try JSONDecoder().decode(SaveData.self, from: data)
        } catch {
            // Decode failure -> safe defaults.
            return SaveData()
        }
    }

    static func save(_ s: SaveData) {
        do {
            let data = try JSONEncoder().encode(s)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // ignore encode failure
        }
    }

    static func wipe() {
        let dict = UserDefaults.standard.dictionaryRepresentation()
        for k in dict.keys where k.hasPrefix("spt.") {
            UserDefaults.standard.removeObject(forKey: k)
        }
    }
}
