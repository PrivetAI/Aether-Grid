import SwiftUI

// Region 3 — The Rot Marsh (Poison and Decay). Teaches poison + fire detonations + splitters.
enum MissionsR4 {
    static let R = 3

    static let missions: [MissionDef] = [
        MissionDef(id: "r4m1", regionIndex: R, indexInRegion: 0, name: "Toxic Bloom",
            gridW: 8, gridH: 7,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [ MissionTerrainPatch(.vineBed, [GridPos(4,3)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("sludge", 5, 3), EnemySpawn("husk", 6, 2), EnemySpawn("husk", 6, 4) ],
            waves: [],
            exitTile: nil,
            lore: "Lay a poison cloud, then ignite it. The detonation clears clustered foes."),

        MissionDef(id: "r4m2", regionIndex: R, indexInRegion: 1, name: "The Spitter Line",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .underTurns(7),
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(4,4)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("venomspitter", 7, 2), EnemySpawn("venomspitter", 7, 5),
                EnemySpawn("sludge", 5, 3), EnemySpawn("sludge", 5, 5)
            ],
            waves: [],
            exitTile: nil,
            lore: "Venom Spitters strike from range and resist poison. Freeze them — they hate the cold."),

        MissionDef(id: "r4m3", regionIndex: R, indexInRegion: 2, name: "Necromancer's Pit",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [ MissionTerrainPatch(.oilPool, [GridPos(5,3), GridPos(5,4), GridPos(5,5)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("necromancer", 7, 4), EnemySpawn("husk", 5, 3), EnemySpawn("husk", 5, 5)
            ],
            waves: [],
            exitTile: nil,
            lore: "The Necromancer raises a fresh husk every few turns. Burn the brood and cut off the source fast."),

        MissionDef(id: "r4m4", regionIndex: R, indexInRegion: 3, name: "Protect the Well",
            gridW: 9, gridH: 9,
            objective: .protectLeyNode(GridPos(4,4), turns: 6), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.leyNode, [GridPos(4,4)]),
                MissionTerrainPatch(.oilPool, [GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)])
            ],
            mageSpawns: [GridPos(3,3), GridPos(5,3), GridPos(3,5), GridPos(5,5)],
            enemySpawns: [ EnemySpawn("sludge", 0, 4), EnemySpawn("sludge", 8, 4) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("husk", 4, 0), EnemySpawn("husk", 4, 8)]),
                EnemyWave(onTurn: 3, spawns: [EnemySpawn("necromancer", 0, 0)]),
                EnemyWave(onTurn: 5, spawns: [EnemySpawn("venomspitter", 8, 8)])
            ],
            exitTile: nil,
            lore: "Keep the brood off the well. The oil ring is a detonation waiting to happen."),

        MissionDef(id: "r4m5", regionIndex: R, indexInRegion: 4, name: "Soul Leeches",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [ MissionTerrainPatch(.vineBed, [GridPos(4,3), GridPos(4,4), GridPos(4,5)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("soulleech", 6, 3), EnemySpawn("soulleech", 6, 5),
                EnemySpawn("sludge", 5, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Soul Leeches heal when your mages bleed. Void severs their feeding, or burn them down fast."),

        MissionDef(id: "r4m6", regionIndex: R, indexInRegion: 5, name: "Ignite the Bog",
            gridW: 10, gridH: 8,
            objective: .igniteTiles([GridPos(7,2), GridPos(7,5)]),
            bonus: .underTurns(7),
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(7,2), GridPos(7,5), GridPos(6,2), GridPos(6,5)]),
                MissionTerrainPatch(.vineBed, [GridPos(4,3), GridPos(4,4)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("sludge", 5, 2), EnemySpawn("sludge", 5, 5), EnemySpawn("venomspitter", 8, 3)
            ],
            waves: [],
            exitTile: nil,
            lore: "Ignite the two oil-soaked nests to collapse the Blight Mother's hatchery."),

        MissionDef(id: "r4m7", regionIndex: R, indexInRegion: 6, name: "The Endless Brood",
            gridW: 9, gridH: 9,
            objective: .survive(turns: 6), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(4,4), GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)])
            ],
            mageSpawns: [GridPos(4,4), GridPos(3,4), GridPos(5,4), GridPos(4,5)],
            enemySpawns: [ EnemySpawn("necromancer", 0, 0), EnemySpawn("necromancer", 8, 8) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("sludge", 8, 0), EnemySpawn("sludge", 0, 8)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("venomspitter", 4, 0), EnemySpawn("venomspitter", 4, 8)])
            ],
            exitTile: nil,
            lore: "Two Necromancers flood the marsh with husks. Hold the oil ring and detonate the swarm."),

        MissionDef(id: "r4m8", regionIndex: R, indexInRegion: 7, name: "Plague Vanguard",
            gridW: 10, gridH: 9,
            objective: .annihilate, bonus: .underTurns(10),
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(5,4), GridPos(4,4), GridPos(6,4)]),
                MissionTerrainPatch(.vineBed, [GridPos(5,2), GridPos(5,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("necromancer", 8, 4), EnemySpawn("venomspitter", 7, 2),
                EnemySpawn("venomspitter", 7, 6), EnemySpawn("sludge", 5, 3), EnemySpawn("soulleech", 6, 4)
            ],
            waves: [ EnemyWave(onTurn: 3, spawns: [EnemySpawn("sludge", 9, 4)]) ],
            exitTile: nil,
            lore: "The Blight Mother's full court. Poison, fire, and patience will see you through."),

        MissionDef(id: "r4m9", regionIndex: R, indexInRegion: 8, name: "Sythrra, The Blight Mother",
            gridW: 10, gridH: 9,
            objective: .defeatBoss(bossId: "boss_blightmother"), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(5,4), GridPos(4,4), GridPos(6,4), GridPos(5,3), GridPos(5,5)]),
                MissionTerrainPatch(.vineBed, [GridPos(3,2), GridPos(7,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boss_blightmother", 7, 4, isBoss: true),
                EnemySpawn("sludge", 6, 2), EnemySpawn("sludge", 6, 6)
            ],
            waves: [ EnemyWave(onTurn: 3, spawns: [EnemySpawn("venomspitter", 9, 4)]) ],
            exitTile: nil,
            lore: "Sythrra births sludges without end and splits when wounded. Only fire ends the cycle — burn her brood, detonate her clouds, and finish her."),
    ]
}
