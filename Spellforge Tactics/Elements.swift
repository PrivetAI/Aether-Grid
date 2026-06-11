import SwiftUI

// MARK: - Elements

enum ElementKind: String, Codable, CaseIterable, Identifiable {
    case fire, oil, water, ice, charge, poison, vines, steam, voidd
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fire: return "Fire"
        case .oil: return "Oil"
        case .water: return "Water"
        case .ice: return "Ice"
        case .charge: return "Lightning Charge"
        case .poison: return "Poison Cloud"
        case .vines: return "Vines"
        case .steam: return "Steam"
        case .voidd: return "Void"
        }
    }

    var color: Color {
        switch self {
        case .fire: return Theme.ember
        case .oil: return Color(red: 0.18, green: 0.15, blue: 0.10)
        case .water: return Theme.aqua
        case .ice: return Theme.frost
        case .charge: return Theme.storm
        case .poison: return Theme.poison
        case .vines: return Theme.vine
        case .steam: return Theme.steam
        case .voidd: return Theme.voidc
        }
    }

    // Whether this element blocks movement when present on a tile.
    var blocksMovement: Bool {
        switch self {
        case .ice, .vines: return true   // frozen wall / vine wall
        default: return false
        }
    }

    var lore: String {
        switch self {
        case .fire: return "The hungriest element. It feeds on oil and vines, evaporates water into steam, and shatters into nothing against the cold."
        case .oil: return "Inert until kindled. A slick of oil is a fuse waiting for a spark; ignite one pool and the whole slick goes up."
        case .water: return "A conductor and a quencher. Lightning loves it; frost binds it into walls; fire flees it as steam."
        case .ice: return "Frozen water raised as a wall. It blocks passage and shatters when struck by fire, releasing a quenching mist."
        case .charge: return "Stored lightning clinging to a tile. Touch water and it leaps across every connected pool, stunning what stands within."
        case .poison: return "A violet miasma that corrodes the unprotected. Bring flame near it and the cloud detonates."
        case .vines: return "Living growth that snares and walls. Fire turns a vine bed into a racing burn-path."
        case .steam: return "The ghost of quenched fire. Harmless on its own, it clears a tile and obscures intent for a turn."
        case .voidd: return "Anti-element. It devours whatever it touches and refuses to react, leaving a tile barren and silent."
        }
    }
}

// MARK: - Reaction results

enum ReactionEffect: String, Codable {
    case ignite          // start fire here
    case spreadFire      // fire jumps to adjacent oil/vine
    case steamClear      // produce steam, remove both
    case chainStun       // lightning chains across water, stun occupants
    case freezeWall      // produce ice wall
    case detonate        // poison + fire AoE damage
    case burnPath        // vines + fire -> directional fire spread
    case consume         // void removes element
    case shatter         // ice shattered -> water + minor dmg
    case none
}

struct ReactionResult {
    var producedElement: ElementKind?    // element left on the tile (nil = cleared)
    var effect: ReactionEffect
    var damage: Int                      // damage to occupant of this tile
    var propagates: Bool                 // does it spread to neighbors?
    var propagateElement: ElementKind?   // element matched on neighbors to propagate into
    var stuns: Bool
    var lore: String

    static let inert = ReactionResult(producedElement: nil, effect: .none, damage: 0,
                                      propagates: false, propagateElement: nil, stuns: false, lore: "")
}
