import SwiftUI

enum TerrainKind: String, Codable {
    case floor          // plain arcane stone
    case oilPool        // pre-seeds oil
    case waterPool      // pre-seeds water
    case lava           // pre-seeds fire each turn; damages occupants
    case iceSheet       // pre-seeds ice; slippery wall
    case vineBed        // pre-seeds vines
    case metal          // conductive: charge passes through it
    case chasm          // impassable pit
    case leyNode        // mana well; standing mage regenerates extra mana; objective point

    var displayName: String {
        switch self {
        case .floor: return "Arcane Floor"
        case .oilPool: return "Oil Pool"
        case .waterPool: return "Water Pool"
        case .lava: return "Lava"
        case .iceSheet: return "Ice Sheet"
        case .vineBed: return "Vine Bed"
        case .metal: return "Conductive Metal"
        case .chasm: return "Chasm"
        case .leyNode: return "Ley-Node"
        }
    }

    // Element this terrain seeds onto a tile at battle start.
    var seedElement: ElementKind? {
        switch self {
        case .oilPool: return .oil
        case .waterPool: return .water
        case .lava: return .fire
        case .iceSheet: return .ice
        case .vineBed: return .vines
        default: return nil
        }
    }

    var impassable: Bool { self == .chasm }

    // Lava re-seeds fire each terrain tick and burns occupants.
    var reseedsEachTurn: Bool { self == .lava }
    var burnsOccupant: Int { self == .lava ? 2 : 0 }

    var baseColor: Color {
        switch self {
        case .floor: return Color(red: 0.16, green: 0.14, blue: 0.26)
        case .oilPool: return Color(red: 0.12, green: 0.10, blue: 0.09)
        case .waterPool: return Color(red: 0.10, green: 0.26, blue: 0.36)
        case .lava: return Color(red: 0.45, green: 0.16, blue: 0.08)
        case .iceSheet: return Color(red: 0.30, green: 0.44, blue: 0.50)
        case .vineBed: return Color(red: 0.14, green: 0.28, blue: 0.16)
        case .metal: return Color(red: 0.30, green: 0.31, blue: 0.36)
        case .chasm: return Color(red: 0.04, green: 0.03, blue: 0.08)
        case .leyNode: return Color(red: 0.28, green: 0.16, blue: 0.40)
        }
    }

    var lore: String {
        switch self {
        case .floor: return "Rune-etched stone that holds whatever element you cast upon it."
        case .oilPool: return "A slick of black oil — the patient Pyromancer's favourite fuse."
        case .waterPool: return "Standing water. Conducts lightning and freezes into walls."
        case .lava: return "Molten rock that reignites fire each turn and scorches anyone who stands in it."
        case .iceSheet: return "A frozen sheet that blocks movement until shattered."
        case .vineBed: return "Dense living growth — walkable, flammable, and ripe for a burn-path."
        case .metal: return "Conductive plating that carries lightning charge across the board."
        case .chasm: return "A bottomless rift. Nothing crosses it."
        case .leyNode: return "A well of raw mana. A mage standing here draws extra power each turn."
        }
    }
}
