import SwiftUI

// Region 4 — The Thornwild (Vine and Earth). Teaches vine walls + burn-paths.
enum MissionsR5 {
    static let R = 4

    static let missions: [MissionDef] = [
        MissionDef(id: "r5m1", regionIndex: R, indexInRegion: 0, name: "Bramble Path",
            gridW: 8, gridH: 7,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [ MissionTerrainPatch(.vineBed, [GridPos(3,3), GridPos(4,3), GridPos(5,3)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("thornhulk", 6, 3), EnemySpawn("husk", 6, 2), EnemySpawn("husk", 6, 4) ],
            waves: [],
            exitTile: nil,
            lore: "Set the vine bed ablaze for a racing burn-path that scorches everything along it."),

        MissionDef(id: "r5m2", regionIndex: R, indexInRegion: 1, name: "Thorn Hulks",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .underTurns(8),
            terrain: [ MissionTerrainPatch(.vineBed, [GridPos(4,3), GridPos(4,4), GridPos(4,5)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("thornhulk", 6, 3), EnemySpawn("thornhulk", 6, 5),
                EnemySpawn("charger", 7, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Thorn Hulks are slow, tough, and very flammable. Light them up."),

        MissionDef(id: "r5m3", regionIndex: R, indexInRegion: 2, name: "Caged In",
            gridW: 9, gridH: 9,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(4,2), GridPos(4,6), GridPos(2,4), GridPos(6,4)]),
                MissionTerrainPatch(.oilPool, [GridPos(4,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("phasewraith", 6, 3), EnemySpawn("thornhulk", 7, 5),
                EnemySpawn("husk", 5, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Wall the field with vines to cage your foes — but beware the Phase Wraith that ignores them."),

        MissionDef(id: "r5m4", regionIndex: R, indexInRegion: 3, name: "Escort Through the Wild",
            gridW: 11, gridH: 7,
            objective: .escort(to: GridPos(10,3)), bonus: .underTurns(9),
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(5,2), GridPos(5,4), GridPos(7,2), GridPos(7,4)]),
                MissionTerrainPatch(.leyNode, [GridPos(10,3)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(0,2), GridPos(0,4), GridPos(1,3)],
            enemySpawns: [
                EnemySpawn("thornhulk", 6, 3), EnemySpawn("charger", 8, 1), EnemySpawn("charger", 8, 5)
            ],
            waves: [ EnemyWave(onTurn: 3, spawns: [EnemySpawn("phasewraith", 10, 0)]) ],
            exitTile: GridPos(10,3),
            lore: "Carve a burn-path through the thicket to escort your channeler to the far node."),

        MissionDef(id: "r5m5", regionIndex: R, indexInRegion: 4, name: "The Choking Grove",
            gridW: 9, gridH: 9,
            objective: .annihilate, bonus: .underTurns(8),
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(3,3), GridPos(4,3), GridPos(5,3), GridPos(3,5), GridPos(4,5), GridPos(5,5)]),
                MissionTerrainPatch(.oilPool, [GridPos(4,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("thornhulk", 6, 3), EnemySpawn("thornhulk", 6, 5),
                EnemySpawn("soulleech", 7, 4), EnemySpawn("husk", 5, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Twin vine rows flank an oil core. A single spark could chain the whole grove."),

        MissionDef(id: "r5m6", regionIndex: R, indexInRegion: 5, name: "Hold the Heartwood",
            gridW: 9, gridH: 9,
            objective: .survive(turns: 7), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.leyNode, [GridPos(4,4)])
            ],
            mageSpawns: [GridPos(4,4), GridPos(3,4), GridPos(5,4), GridPos(4,3)],
            enemySpawns: [ EnemySpawn("thornhulk", 0, 4), EnemySpawn("thornhulk", 8, 4) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("charger", 4, 0), EnemySpawn("charger", 4, 8)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("phasewraith", 0, 0), EnemySpawn("phasewraith", 8, 8)]),
                EnemyWave(onTurn: 6, spawns: [EnemySpawn("soulleech", 0, 8)])
            ],
            exitTile: nil,
            lore: "Defend the heartwood node. Wall yourself in vines and burn any who breach."),

        MissionDef(id: "r5m7", regionIndex: R, indexInRegion: 6, name: "Wraith Thicket",
            gridW: 10, gridH: 9,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(4,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.iceSheet, [GridPos(6,2), GridPos(6,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("phasewraith", 6, 3), EnemySpawn("phasewraith", 6, 5),
                EnemySpawn("thornhulk", 8, 4), EnemySpawn("soulleech", 7, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Phase Wraiths drift through your vine walls. Bind them with frost or void."),

        MissionDef(id: "r5m8", regionIndex: R, indexInRegion: 7, name: "The Thorn Vanguard",
            gridW: 11, gridH: 9,
            objective: .annihilate, bonus: .underTurns(11),
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(5,4), GridPos(6,4), GridPos(5,3), GridPos(5,5)]),
                MissionTerrainPatch(.oilPool, [GridPos(5,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("thornhulk", 7, 3), EnemySpawn("thornhulk", 7, 5),
                EnemySpawn("phasewraith", 9, 4), EnemySpawn("charger", 8, 2), EnemySpawn("soulleech", 8, 6)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("thornhulk", 10, 4)]) ],
            exitTile: nil,
            lore: "The Thorn King's vanguard. Carve burn-paths through the thicket and overwhelm them."),

        MissionDef(id: "r5m9", regionIndex: R, indexInRegion: 8, name: "Oakthar, The Thorn King",
            gridW: 11, gridH: 9,
            objective: .defeatBoss(bossId: "boss_thornking"), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.vineBed, [GridPos(5,4), GridPos(6,4), GridPos(5,3), GridPos(5,5), GridPos(6,3), GridPos(6,5)]),
                MissionTerrainPatch(.oilPool, [GridPos(5,4), GridPos(6,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boss_thornking", 8, 4, isBoss: true),
                EnemySpawn("thornhulk", 7, 2), EnemySpawn("thornhulk", 7, 6)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("phasewraith", 10, 4)]) ],
            exitTile: nil,
            lore: "Oakthar walls the field in living bramble. Set his thicket ablaze with a burn-path — and when his bark splits in phase two, finish the burning."),
    ]
}
