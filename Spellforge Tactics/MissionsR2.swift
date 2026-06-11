import SwiftUI

// Region 1 — The Drowned Fen (Water and Storm). Teaches water + lightning chains.
enum MissionsR2 {
    static let R = 1

    static let missions: [MissionDef] = [
        MissionDef(id: "r2m1", regionIndex: R, indexInRegion: 0, name: "Conductor",
            gridW: 7, gridH: 7,
            objective: .annihilate, bonus: .reactionKillsOnly,
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(3,2), GridPos(3,3), GridPos(3,4)]) ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [ EnemySpawn("husk", 3, 2), EnemySpawn("husk", 3, 4), EnemySpawn("husk", 5, 3) ],
            waves: [],
            exitTile: nil,
            lore: "Husks wade through a flooded channel. Wet them, then loose a single bolt to chain them all."),

        MissionDef(id: "r2m2", regionIndex: R, indexInRegion: 1, name: "Tide Elemental",
            gridW: 8, gridH: 7,
            objective: .annihilate, bonus: .underTurns(6),
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(4,3), GridPos(5,3), GridPos(4,4)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [ EnemySpawn("waterelem", 5, 3), EnemySpawn("husk", 6, 2), EnemySpawn("husk", 6, 5) ],
            waves: [],
            exitTile: nil,
            lore: "A Tide Elemental cannot be drowned — but lightning unmakes it."),

        MissionDef(id: "r2m3", regionIndex: R, indexInRegion: 2, name: "Flood Totem",
            gridW: 8, gridH: 8,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(3,4), GridPos(4,4)]) ],
            mageSpawns: [GridPos(0,5), GridPos(1,5), GridPos(0,6), GridPos(1,6)],
            enemySpawns: [ EnemySpawn("floodtotem", 6, 4), EnemySpawn("husk", 5, 2), EnemySpawn("husk", 5, 6) ],
            waves: [],
            exitTile: nil,
            lore: "The Flood Totem drowns a tile each turn — turn its growing pools into a conductive trap."),

        MissionDef(id: "r2m4", regionIndex: R, indexInRegion: 3, name: "Protect the Ley-Node",
            gridW: 8, gridH: 8,
            objective: .protectLeyNode(GridPos(4,4), turns: 5), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.leyNode, [GridPos(4,4)]),
                MissionTerrainPatch(.waterPool, [GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)])
            ],
            mageSpawns: [GridPos(3,3), GridPos(5,3), GridPos(3,5), GridPos(5,5)],
            enemySpawns: [ EnemySpawn("husk", 0, 4), EnemySpawn("husk", 7, 4) ],
            waves: [
                EnemyWave(onTurn: 2, spawns: [EnemySpawn("charger", 4, 0), EnemySpawn("charger", 4, 7)]),
                EnemyWave(onTurn: 4, spawns: [EnemySpawn("waterelem", 0, 0)])
            ],
            exitTile: nil,
            lore: "Keep all enemies off the ley-node. The surrounding water is your best weapon."),

        MissionDef(id: "r2m5", regionIndex: R, indexInRegion: 4, name: "Hex Archers",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .underTurns(7),
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(5,3), GridPos(5,4), GridPos(5,5)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("hexarcher", 7, 2), EnemySpawn("hexarcher", 7, 5),
                EnemySpawn("husk", 5, 3), EnemySpawn("husk", 5, 5)
            ],
            waves: [],
            exitTile: nil,
            lore: "Hex Archers strike from afar. Use the water channel to chain-stun and close in."),

        MissionDef(id: "r2m6", regionIndex: R, indexInRegion: 5, name: "Escort the Channeler",
            gridW: 10, gridH: 7,
            objective: .escort(to: GridPos(9,3)), bonus: .underTurns(8),
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(4,3), GridPos(5,3), GridPos(6,3)]),
                MissionTerrainPatch(.leyNode, [GridPos(9,3)])
            ],
            mageSpawns: [GridPos(0,3), GridPos(0,2), GridPos(0,4), GridPos(1,3)],
            enemySpawns: [
                EnemySpawn("husk", 5, 1), EnemySpawn("husk", 5, 5),
                EnemySpawn("waterelem", 7, 3)
            ],
            waves: [ EnemyWave(onTurn: 3, spawns: [EnemySpawn("charger", 9, 0)]) ],
            exitTile: GridPos(9,3),
            lore: "Lead your first mage to the far ley-node. Clear the path with chained lightning."),

        MissionDef(id: "r2m7", regionIndex: R, indexInRegion: 6, name: "Stormcrow Roost",
            gridW: 9, gridH: 8,
            objective: .annihilate, bonus: .noMageDamage,
            terrain: [ MissionTerrainPatch(.waterPool, [GridPos(4,3), GridPos(4,4)]) ],
            mageSpawns: [GridPos(0,3), GridPos(1,3), GridPos(0,4), GridPos(1,4)],
            enemySpawns: [
                EnemySpawn("stormcrow", 6, 2), EnemySpawn("stormcrow", 6, 5),
                EnemySpawn("waterelem", 7, 3)
            ],
            waves: [],
            exitTile: nil,
            lore: "Stormcrows scramble the field each turn. Freeze them before they ruin your setup."),

        MissionDef(id: "r2m8", regionIndex: R, indexInRegion: 7, name: "The Drowned Host",
            gridW: 9, gridH: 9,
            objective: .annihilate, bonus: .underTurns(9),
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(4,4), GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.metal, [GridPos(2,4), GridPos(6,4)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("waterelem", 6, 3), EnemySpawn("waterelem", 6, 5),
                EnemySpawn("hexarcher", 8, 4), EnemySpawn("husk", 5, 2), EnemySpawn("husk", 5, 6)
            ],
            waves: [ EnemyWave(onTurn: 3, spawns: [EnemySpawn("floodtotem", 8, 1)]) ],
            exitTile: nil,
            lore: "The Tide Queen's host masses on conductive metal. One great chain could end them all."),

        MissionDef(id: "r2m9", regionIndex: R, indexInRegion: 8, name: "Maerwyn, The Tide Queen",
            gridW: 9, gridH: 9,
            objective: .defeatBoss(bossId: "boss_tidequeen"), bonus: .noMageLost,
            terrain: [
                MissionTerrainPatch(.waterPool, [GridPos(4,4), GridPos(3,4), GridPos(5,4), GridPos(4,3), GridPos(4,5)]),
                MissionTerrainPatch(.metal, [GridPos(2,2), GridPos(6,6)])
            ],
            mageSpawns: [GridPos(0,4), GridPos(1,4), GridPos(0,5), GridPos(1,5)],
            enemySpawns: [
                EnemySpawn("boss_tidequeen", 7, 4, isBoss: true),
                EnemySpawn("waterelem", 6, 2), EnemySpawn("waterelem", 6, 6)
            ],
            waves: [ EnemyWave(onTurn: 4, spawns: [EnemySpawn("floodtotem", 8, 4)]) ],
            exitTile: nil,
            lore: "Maerwyn drowns the field to build a lethal grid. Use her own pools — strike them with lightning to shatter her court, then her."),
    ]
}
