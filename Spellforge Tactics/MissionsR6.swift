import SwiftUI

// Region 5 — The Hollow Between (Void and Ruin). The endgame: all elements + void.
enum MissionsR6 {
    static let R = 5

    static let missions: [MissionDef] = [
        MissionDef(id: "r6m1", regionIndex: R, indexInRegion: 0, name: "Edge of Nothing",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [
                MissionTerrainPatch(.chasm, [GridPos(4,0), GridPos(4,7)]),
                MissionTerrainPatch(.oilPool, [GridPos(4,3), GridPos(4,4)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("voidspawn", 6, 3), EnemySpawn("voidspawn", 6, 5), EnemySpawn("husk", 5, 4) ],
            waves: [],
            exitTile: nil,
            lore: "Void Spawn resist void itself — but they burn and shock like anything else."),

        MissionDef(id: "r6m2", regionIndex: R, indexInRegion: 1, name: "Unmaking Ground",
            gridW: 9, gridH: 9,
            objective: .annihilate, bonus: .underTurns(9),
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(4,4), GridPos(3,4), GridPos(5,4)]),
                MissionTerrainPatch(.metal, [GridPos(4,3), GridPos(4,5)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("voidspawn", 6, 3), EnemySpawn("voidspawn", 6, 5),
                EnemySpawn("phasewraith", 7, 4), EnemySpawn("soulleech", 6, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "A mixed host of unmade things. Chain lightning through the wet metal to thin them."),

        MissionDef(id: "r6m3", regionIndex: R, indexInRegion: 2, name: "The Silent Vault",
            gridW: 10, gridH: 9,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(5,3), GridPos(5,5)]),
                MissionTerrainPatch(.waterPool, [GridPos(5,4)]),
                MissionTerrainPatch(.iceSheet, [GridPos(7,2), GridPos(7,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boneturret", 9, 3), EnemySpawn("boneturret", 9, 5),
                EnemySpawn("voidspawn", 6, 4), EnemySpawn("phasewraith", 8, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Turrets guard the vault. Wall their fire, then unleash every element you have."),

        MissionDef(id: "r6m4", regionIndex: R, indexInRegion: 3, name: "Protect the Last Node",
            gridW: 10, gridH: 9,
            objective: .protectLeyNode(GridPos(5,4), turns: 7), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.leyNode, [GridPos(5,4)]),
                MissionTerrainPatch(.oilPool, [GridPos(4,4), GridPos(6,4), GridPos(5,3), GridPos(5,5)])
            ],
            mageSpawns: [GridPos(4,3), GridPos(6,3), GridPos(4,5), GridPos(6,5)],
            enemySpawns: [ EnemySpawn("voidspawn", 0, 4), EnemySpawn("voidspawn", 9, 4) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("charger", 5, 0), EnemySpawn("charger", 5, 8)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("phasewraith", 0, 0), EnemySpawn("phasewraith", 9, 8)]),
                EnemyWave(onTurn: 6, spawns: [EnemySpawn("boneturret", 0, 8)])
            ],
            exitTile: nil,
            lore: "The last ley-node in the world. Hold it at all costs — detonate the oil ring on anything that nears."),

        MissionDef(id: "r6m5", regionIndex: R, indexInRegion: 4, name: "All Elements",
            gridW: 11, gridH: 9,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(4,2)]),
                MissionTerrainPatch(.waterPool, [GridPos(6,2)]),
                MissionTerrainPatch(.vineBed, [GridPos(4,6)]),
                MissionTerrainPatch(.lava, [GridPos(6,6)]),
                MissionTerrainPatch(.metal, [GridPos(5,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("voidspawn", 7, 3), EnemySpawn("frostbound", 8, 4),
                EnemySpawn("thornhulk", 7, 5), EnemySpawn("waterelem", 9, 4), EnemySpawn("stormcrow", 8, 2)
            ],
            waves: [],
            exitTile: nil,
            lore: "Every terrain, every foe. A true test of elemental mastery — win on reactions alone."),

        MissionDef(id: "r6m6", regionIndex: R, indexInRegion: 5, name: "Sever the Leeches",
            gridW: 10, gridH: 9,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(4,4), GridPos(5,4)]),
                MissionTerrainPatch(.metal, [GridPos(3,4), GridPos(6,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("soulleech", 6, 3), EnemySpawn("soulleech", 6, 5),
                EnemySpawn("soulleech", 7, 4), EnemySpawn("voidspawn", 8, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "A nest of Soul Leeches. Void severs their feeding — or stun them all in one chain."),

        MissionDef(id: "r6m7", regionIndex: R, indexInRegion: 6, name: "The Hollow Vanguard",
            gridW: 11, gridH: 9,
            objective: .annihilate, bonus: .underTurns(12),
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(5,4), GridPos(4,4), GridPos(6,4)]),
                MissionTerrainPatch(.iceSheet, [GridPos(7,2), GridPos(7,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("voidspawn", 8, 3), EnemySpawn("voidspawn", 8, 5),
                EnemySpawn("phasewraith", 9, 4), EnemySpawn("boneturret", 10, 4), EnemySpawn("frostbound", 7, 4)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("voidspawn", 10, 7)]) ],
            exitTile: nil,
            lore: "The Void Herald's vanguard masses. This is the last gate before the end."),

        MissionDef(id: "r6m8", regionIndex: R, indexInRegion: 7, name: "Threshold of Ruin",
            gridW: 11, gridH: 9,
            objective: .survive(turns: 8), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(5,4), GridPos(4,4), GridPos(6,4), GridPos(5,3), GridPos(5,5)]),
                MissionTerrainPatch(.chasm, [GridPos(0,0), GridPos(10,0), GridPos(0,8), GridPos(10,8)])
            ],
            mageSpawns: [GridPos(5,4), GridPos(4,4), GridPos(6,4), GridPos(5,5)],
            enemySpawns: [ EnemySpawn("voidspawn", 0, 4), EnemySpawn("voidspawn", 10, 4) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("phasewraith", 5, 0), EnemySpawn("phasewraith", 5, 8)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("frostbound", 1, 1), EnemySpawn("frostbound", 9, 7)]),
                EnemyWave(onTurn: 6, spawns: [EnemySpawn("boneturret", 1, 7), EnemySpawn("boneturret", 9, 1)])
            ],
            exitTile: nil,
            lore: "Survive the unmaking. Detonate the oil core to clear each wave before it overwhelms you."),

        MissionDef(id: "r6m9", regionIndex: R, indexInRegion: 8, name: "Nyxalor, The Void Herald",
            gridW: 11, gridH: 9,
            objective: .defeatBoss(bossId: "boss_voidherald"), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.oilPool, [GridPos(4,4)]),
                MissionTerrainPatch(.waterPool, [GridPos(6,4)]),
                MissionTerrainPatch(.vineBed, [GridPos(5,2)]),
                MissionTerrainPatch(.metal, [GridPos(5,6)]),
                MissionTerrainPatch(.leyNode, [GridPos(5,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boss_voidherald", 8, 4, isBoss: true),
                EnemySpawn("voidspawn", 7, 2), EnemySpawn("voidspawn", 7, 6)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("phasewraith", 10, 4)]) ],
            exitTile: nil,
            lore: "The final unmaker phases through every wall and devours the field's elements. Overwhelm it with raw elemental force — and when it frenzies in phase two, every element bites. End this."),
    ]
}
