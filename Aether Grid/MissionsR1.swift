import SwiftUI

// Region 0 — The Cinder Reach (Ash and Oil). Teaches fire + oil + water.
enum MissionsR1 {
    static let R = 0

    static let missions: [MissionDef] = [
        // 1
        MissionDef(id: "r1m1", regionIndex: R, indexInRegion: 0, name: "First Spark",
            gridW: 7, gridH: 7,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [ MissionTerrainPatch(.oilPool, [GridPos(3,3), GridPos(4,3), GridPos(2,3)]) ],
            mageSpawns: [GridPos(0,5), GridPos(1,5), GridPos(0,6), GridPos(1,6)],
            enemySpawns: [ EnemySpawn("husk", 5, 1), EnemySpawn("husk", 4, 1), EnemySpawn("husk", 3, 1) ],
            waves: [],
            exitTile: nil,
            lore: "A scouting band of husks shambles across an oil slick. Light it and watch them burn."),
        // 2
        MissionDef(id: "r1m2", regionIndex: R, indexInRegion: 1, name: "Oil and Ash",
            gridW: 7, gridH: 7,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [ MissionTerrainPatch(.oilPool, [GridPos(2,2), GridPos(3,2), GridPos(4,2), GridPos(3,3), GridPos(3,4)]) ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [ EnemySpawn("husk", 2, 1), EnemySpawn("husk", 4, 1), EnemySpawn("fireelem", 5, 2) ],
            waves: [],
            exitTile: nil,
            lore: "A Cinder Elemental marches with husks. You cannot burn the elemental — drown and freeze it, or let reactions clear the rest."),
        // 3
        MissionDef(id: "r1m3", regionIndex: R, indexInRegion: 2, name: "The Lava Run",
            gridW: 8, gridH: 7,
            objective: .annihilate, bonus: .underTurns(6),
            terrain: [
                MissionTerrainPatch(.lava, [GridPos(4,3), GridPos(4,4)]),
                MissionTerrainPatch(.oilPool, [GridPos(3,3), GridPos(5,3)])
            ],
            mageSpawns: [GridPos(0,5), GridPos(1,5), GridPos(0,6), GridPos(1,6)],
            enemySpawns: [ EnemySpawn("husk", 6, 2), EnemySpawn("husk", 6, 4), EnemySpawn("charger", 7, 3) ],
            waves: [],
            exitTile: nil,
            lore: "A charger barrels toward you across lava-veined ground. Use the terrain to your advantage."),
        // 4
        MissionDef(id: "r1m4", regionIndex: R, indexInRegion: 3, name: "Ember Channel",
            gridW: 8, gridH: 8,
            objective: .igniteTiles([GridPos(6,1), GridPos(6,6)]),
            bonus: .underTurns(5),
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(6,1), GridPos(6,6), GridPos(5,1), GridPos(5,6)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(0,4), GridPos(1,3), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("husk", 4, 0), EnemySpawn("husk", 4, 7) ],
            waves: [],
            exitTile: nil,
            lore: "Ignite the two ritual braziers to collapse the gate. Mind the husks guarding them."),
        // 5
        MissionDef(id: "r1m5", regionIndex: R, indexInRegion: 4, name: "Pyre Totem",
            gridW: 8, gridH: 8,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(2,4), GridPos(3,4)]) ],
            mageSpawns: [GridPos(0,5), GridPos(1,5), GridPos(0,6), GridPos(1,6)],
            enemySpawns: [ EnemySpawn("pyretotem", 6, 3), EnemySpawn("husk", 5, 5), EnemySpawn("husk", 5, 2) ],
            waves: [],
            exitTile: nil,
            lore: "A Pyre Totem spits fire each turn. Douse it with water — it is immune to flame."),
        // 6
        MissionDef(id: "r1m6", regionIndex: R, indexInRegion: 5, name: "Hold the Vent",
            gridW: 8, gridH: 8,
            objective: .survive(turns: 6), bonus: .noMageLost,
            terrain: [ MissionTerrainPatch(.oilPool, [GridPos(3,3), GridPos(4,3), GridPos(3,4), GridPos(4,4)]) ],
            mageSpawns: [GridPos(3,3), GridPos(4,3), GridPos(3,4), GridPos(4,4)],
            enemySpawns: [ EnemySpawn("husk", 0, 0), EnemySpawn("husk", 7, 0) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("husk", 0, 7), EnemySpawn("husk", 7, 7)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("charger", 0, 4), EnemySpawn("fireelem", 7, 4)])
            ],
            exitTile: nil,
            lore: "Hold your ground on the oil while waves of cinder-kin close in."),
        // 7
        MissionDef(id: "r1m7", regionIndex: R, indexInRegion: 6, name: "The Splitting Sludge",
            gridW: 8, gridH: 8,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [ MissionTerrainPatch(.oilPool, [GridPos(4,3), GridPos(4,4), GridPos(4,5)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("sludge", 5, 4), EnemySpawn("sludge", 6, 2), EnemySpawn("husk", 6, 6) ],
            waves: [],
            exitTile: nil,
            lore: "Sludges split when struck down. Burn them to ash before they multiply."),
        // 8
        MissionDef(id: "r1m8", regionIndex: R, indexInRegion: 7, name: "Inferno Gauntlet",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .underTurns(8),
            terrain: [
                MissionTerrainPatch(.lava, [GridPos(4,2), GridPos(4,5)]),
                MissionTerrainPatch(.oilPool, [GridPos(3,3), GridPos(5,3), GridPos(3,4), GridPos(5,4)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("fireelem", 7, 2), EnemySpawn("fireelem", 7, 5),
                EnemySpawn("charger", 8, 3), EnemySpawn("husk", 6, 4)
            ],
            waves: [ EnemyWave(onTurn: 3, spawns: [EnemySpawn("husk", 8, 6), EnemySpawn("husk", 8, 1)]) ],
            exitTile: nil,
            lore: "The Ember Lord's vanguard. Two Cinder Elementals lead the charge — bring water and frost."),
        // 9 — BOSS
        MissionDef(id: "r1m9", regionIndex: R, indexInRegion: 8, name: "Vulcaron, The Ember Lord",
            gridW: 9, gridH: 9,
            objective: .defeatBoss(bossId: "boss_emberlord"),
            bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.lava, [GridPos(4,4)]),
                MissionTerrainPatch(.oilPool, [GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.waterPool, [GridPos(1,1), GridPos(7,7)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boss_emberlord", 7, 4, isBoss: true),
                EnemySpawn("husk", 6, 2), EnemySpawn("husk", 6, 6)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("fireelem", 8, 4)]) ],
            exitTile: nil,
            lore: "Vulcaron floods the arena with fire and immolates all who approach. Drown his flames, then freeze his exposed core in phase two."),
    ]
}
