import SwiftUI

// Region 2 — The Howling Spires (Frost and Lightning). Teaches ice walls + metal conduction.
enum MissionsR3 {
    static let R = 2

    static let missions: [MissionDef] = [
        MissionDef(id: "r3m1", regionIndex: R, indexInRegion: 0, name: "Frozen Ground",
            gridW: 8, gridH: 7,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(4,3), GridPos(4,4)]),
                MissionTerrainPatch(.iceSheet, [GridPos(2,3)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("frostbound", 5, 3), EnemySpawn("husk", 6, 2), EnemySpawn("husk", 6, 4) ],
            waves: [],
            exitTile: nil,
            lore: "A Frostbound Revenant leads. Fire melts its icy armor — and itself."),

        MissionDef(id: "r3m2", regionIndex: R, indexInRegion: 1, name: "The Ice Maze",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .underTurns(7),
            terrain: [
                MissionTerrainPatch(.iceSheet, [GridPos(4,1), GridPos(4,2), GridPos(4,5), GridPos(4,6)]),
                MissionTerrainPatch(.waterPool, [GridPos(4,3), GridPos(4,4)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("charger", 7, 3), EnemySpawn("charger", 7, 4),
                EnemySpawn("husk", 6, 1), EnemySpawn("husk", 6, 6)
            ],
            waves: [],
            exitTile: nil,
            lore: "Freeze the central water to seal the maze and funnel the chargers into a kill-box."),

        MissionDef(id: "r3m3", regionIndex: R, indexInRegion: 2, name: "Conductive Ruins",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [
                MissionTerrainPatch(.metal, [GridPos(3,3), GridPos(4,3), GridPos(5,3), GridPos(4,2), GridPos(4,4)]),
                MissionTerrainPatch(.waterPool, [GridPos(4,3)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("husk", 4, 2), EnemySpawn("husk", 4, 4),
                EnemySpawn("husk", 3, 3), EnemySpawn("husk", 5, 3), EnemySpawn("stormcrow", 7, 3)
            ],
            waves: [],
            exitTile: nil,
            lore: "Conductive metal carries lightning across its whole span. One bolt, many kills."),

        MissionDef(id: "r3m4", regionIndex: R, indexInRegion: 3, name: "Hold the Spire",
            gridW: 9, gridH: 9,
            objective: .survive(turns: 7), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.chasm, [GridPos(0,0), GridPos(8,0), GridPos(0,8), GridPos(8,8)])
            ],
            mageSpawns: [GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)],
            enemySpawns: [ EnemySpawn("husk", 1, 4), EnemySpawn("husk", 7, 4) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("charger", 4, 1), EnemySpawn("charger", 4, 7)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("frostbound", 1, 1), EnemySpawn("frostbound", 7, 7)]),
                EnemyWave(onTurn: 6, spawns: [EnemySpawn("stormcrow", 1, 7)])
            ],
            exitTile: nil,
            lore: "Wall yourself in with ice and survive the storm. Freeze the water around you into a fortress."),

        MissionDef(id: "r3m5", regionIndex: R, indexInRegion: 4, name: "Bone Turrets",
            gridW: 10, gridH: 8,
            objective: .annihilate, bonus: .underTurns(8),
            terrain: [
                MissionTerrainPatch(.iceSheet, [GridPos(5,2), GridPos(5,5)]),
                MissionTerrainPatch(.waterPool, [GridPos(5,3), GridPos(5,4)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("boneturret", 8, 2), EnemySpawn("boneturret", 8, 5),
                EnemySpawn("frostbound", 6, 3), EnemySpawn("husk", 4, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Immobile turrets pound you from afar. Wall their line of fire with ice, then advance."),

        MissionDef(id: "r3m6", regionIndex: R, indexInRegion: 5, name: "Extinguish the Pyres",
            gridW: 9, gridH: 9,
            objective: .extinguishTiles([GridPos(2,2), GridPos(6,2), GridPos(4,6)]),
            bonus: .underTurns(6),
            terrain: [
                MissionTerrainPatch(.lava, [GridPos(2,2), GridPos(6,2), GridPos(4,6)]),
                MissionTerrainPatch(.waterPool, [GridPos(2,3), GridPos(6,3), GridPos(4,5)])
            ],
            mageSpawns: [GridPos(4,8), GridPos(3,8), GridPos(5,8), GridPos(4,7)],
            enemySpawns: [ EnemySpawn("pyretotem", 2, 2), EnemySpawn("pyretotem", 6, 2), EnemySpawn("husk", 4, 4) ],
            waves: [],
            exitTile: nil,
            lore: "Snuff out the three pyres with water or ice before the Tyrant's fires spread."),

        MissionDef(id: "r3m7", regionIndex: R, indexInRegion: 6, name: "Phase Wraiths",
            gridW: 9, gridH: 9,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [
                MissionTerrainPatch(.iceSheet, [GridPos(3,4), GridPos(5,4)]),
                MissionTerrainPatch(.waterPool, [GridPos(4,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("phasewraith", 6, 3), EnemySpawn("phasewraith", 6, 5),
                EnemySpawn("frostbound", 7, 4)
            ],
            waves: [],
            exitTile: nil,
            lore: "Phase Wraiths drift through walls. Only frost and void can truly stop them."),

        MissionDef(id: "r3m8", regionIndex: R, indexInRegion: 7, name: "The Tyrant's Vanguard",
            gridW: 10, gridH: 9,
            objective: .annihilate, bonus: .underTurns(10),
            terrain: [
                MissionTerrainPatch(.metal, [GridPos(4,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.waterPool, [GridPos(4,4)]),
                MissionTerrainPatch(.iceSheet, [GridPos(6,2), GridPos(6,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("stormcrow", 7, 3), EnemySpawn("stormcrow", 7, 5),
                EnemySpawn("boneturret", 9, 4), EnemySpawn("frostbound", 6, 4), EnemySpawn("charger", 8, 2)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("phasewraith", 9, 7)]) ],
            exitTile: nil,
            lore: "The full storm-host. Conduct lightning through the metal, then mop up with frost."),

        MissionDef(id: "r3m9", regionIndex: R, indexInRegion: 8, name: "Zekarrh, The Storm Tyrant",
            gridW: 10, gridH: 9,
            objective: .defeatBoss(bossId: "boss_stormtyrant"), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.metal, [GridPos(4,4), GridPos(5,4), GridPos(4,3), GridPos(4,5), GridPos(5,3), GridPos(5,5)]),
                MissionTerrainPatch(.waterPool, [GridPos(2,2), GridPos(7,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boss_stormtyrant", 7, 4, isBoss: true),
                EnemySpawn("stormcrow", 6, 2), EnemySpawn("stormcrow", 6, 6)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("boneturret", 9, 4)]) ],
            exitTile: nil,
            lore: "The Storm Tyrant scrambles the field each turn. Ground him with frost, then void his charge to break the storm."),
    ]
}
