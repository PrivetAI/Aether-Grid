import Foundation

// The element reaction matrix, implemented as real data + a deterministic resolver.
// Given an element being APPLIED to a tile that already holds `existing`, returns the result.
// All propagation is bounded by the engine (cap per tick) so it always terminates.

struct ReactionEntry {
    let applied: ElementKind
    let existing: ElementKind
    let result: ReactionResult
}

enum ReactionMatrix {

    // Documented reaction table. Order: applied + existing.
    static let entries: [ReactionEntry] = [
        // FIRE
        ReactionEntry(applied: .fire, existing: .oil,
            result: ReactionResult(producedElement: .fire, effect: .spreadFire, damage: 3,
                propagates: true, propagateElement: .oil, stuns: false,
                lore: "Fire on oil ignites and races across every connected oil tile.")),
        ReactionEntry(applied: .fire, existing: .vines,
            result: ReactionResult(producedElement: .fire, effect: .burnPath, damage: 3,
                propagates: true, propagateElement: .vines, stuns: false,
                lore: "Fire turns a vine bed into a burn-path, spreading along the growth.")),
        ReactionEntry(applied: .fire, existing: .water,
            result: ReactionResult(producedElement: .steam, effect: .steamClear, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Fire meets water and is quenched into harmless steam.")),
        ReactionEntry(applied: .fire, existing: .ice,
            result: ReactionResult(producedElement: .steam, effect: .steamClear, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Fire shatters an ice wall into a burst of steam, clearing the tile.")),
        ReactionEntry(applied: .fire, existing: .poison,
            result: ReactionResult(producedElement: nil, effect: .detonate, damage: 5,
                propagates: true, propagateElement: .poison, stuns: false,
                lore: "Flame ignites the poison cloud — it detonates, blasting all adjacent clouds.")),
        ReactionEntry(applied: .fire, existing: .charge,
            result: ReactionResult(producedElement: .fire, effect: .ignite, damage: 2,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Charge arcs through the flame, scorching the tile.")),
        ReactionEntry(applied: .fire, existing: .steam,
            result: ReactionResult(producedElement: .fire, effect: .ignite, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Fire burns through thin steam and settles on the tile.")),

        // WATER
        ReactionEntry(applied: .water, existing: .fire,
            result: ReactionResult(producedElement: .steam, effect: .steamClear, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Water douses fire, leaving a curtain of steam.")),
        ReactionEntry(applied: .water, existing: .charge,
            result: ReactionResult(producedElement: .water, effect: .chainStun, damage: 2,
                propagates: true, propagateElement: .water, stuns: true,
                lore: "Charge already clinging to the tile bursts when wetted, chaining a stun.")),
        ReactionEntry(applied: .water, existing: .oil,
            result: ReactionResult(producedElement: .oil, effect: .none, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Oil floats on water; the slick remains a fire hazard.")),

        // ICE
        ReactionEntry(applied: .ice, existing: .water,
            result: ReactionResult(producedElement: .ice, effect: .freezeWall, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Ice freezes water into a solid, walkable-blocking wall.")),
        ReactionEntry(applied: .ice, existing: .fire,
            result: ReactionResult(producedElement: .steam, effect: .steamClear, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Ice smothers the flame into steam.")),
        ReactionEntry(applied: .ice, existing: .charge,
            result: ReactionResult(producedElement: .ice, effect: .freezeWall, damage: 1,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Frost locks the charge in place as a brittle, crackling wall.")),

        // LIGHTNING CHARGE
        ReactionEntry(applied: .charge, existing: .water,
            result: ReactionResult(producedElement: .water, effect: .chainStun, damage: 3,
                propagates: true, propagateElement: .water, stuns: true,
                lore: "Lightning on water chains across every connected wet tile and stuns occupants.")),
        ReactionEntry(applied: .charge, existing: .ice,
            result: ReactionResult(producedElement: nil, effect: .shatter, damage: 2,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Lightning shatters the ice wall back into a splash of water.")),
        ReactionEntry(applied: .charge, existing: .oil,
            result: ReactionResult(producedElement: .charge, effect: .ignite, damage: 1,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Sparks dance on the oil but need true flame to ignite it.")),

        // POISON
        ReactionEntry(applied: .poison, existing: .fire,
            result: ReactionResult(producedElement: nil, effect: .detonate, damage: 5,
                propagates: true, propagateElement: .poison, stuns: false,
                lore: "Poison spread onto fire detonates instantly.")),
        ReactionEntry(applied: .poison, existing: .water,
            result: ReactionResult(producedElement: .poison, effect: .none, damage: 1,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Poison taints the water, lingering as a corrosive film.")),

        // VINES
        ReactionEntry(applied: .vines, existing: .water,
            result: ReactionResult(producedElement: .vines, effect: .none, damage: 0,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Vines drink the water and grow into a snaring wall.")),
        ReactionEntry(applied: .vines, existing: .fire,
            result: ReactionResult(producedElement: .fire, effect: .burnPath, damage: 2,
                propagates: false, propagateElement: nil, stuns: false,
                lore: "Vines grown into fire simply burn away.")),

        // VOID — consumes everything
        ReactionEntry(applied: .voidd, existing: .fire,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void devours the flame and leaves the tile barren.")),
        ReactionEntry(applied: .voidd, existing: .water,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void swallows the water without a ripple.")),
        ReactionEntry(applied: .voidd, existing: .oil,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void consumes the oil slick.")),
        ReactionEntry(applied: .voidd, existing: .ice,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void unmakes the ice wall.")),
        ReactionEntry(applied: .voidd, existing: .charge,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void grounds the charge into silence.")),
        ReactionEntry(applied: .voidd, existing: .poison,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void absorbs the toxic cloud.")),
        ReactionEntry(applied: .voidd, existing: .vines,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void withers the vines to nothing.")),
        ReactionEntry(applied: .voidd, existing: .steam,
            result: ReactionResult(producedElement: .voidd, effect: .consume, damage: 0, propagates: false, propagateElement: nil, stuns: false, lore: "Void disperses the steam.")),
    ]

    private static let lookup: [String: ReactionResult] = {
        var d: [String: ReactionResult] = [:]
        for e in entries {
            d[key(e.applied, e.existing)] = e.result
        }
        return d
    }()

    private static func key(_ a: ElementKind, _ b: ElementKind) -> String {
        "\(a.rawValue)|\(b.rawValue)"
    }

    /// Resolve applying `applied` onto a tile that holds `existing` (may be nil).
    /// Returns the reaction. If no reaction exists, the applied element simply replaces.
    static func resolve(applying applied: ElementKind, onto existing: ElementKind?) -> ReactionResult {
        guard let existing = existing else {
            // No existing element: applied element just settles, no reaction.
            return ReactionResult(producedElement: applied, effect: .none, damage: 0,
                                  propagates: false, propagateElement: nil, stuns: false, lore: "")
        }
        if let r = lookup[key(applied, existing)] {
            return r
        }
        // Default: applied element overwrites the tile, no special reaction.
        return ReactionResult(producedElement: applied, effect: .none, damage: 0,
                              propagates: false, propagateElement: nil, stuns: false, lore: "")
    }

    /// Returns true if applying `applied` onto `existing` causes any documented reaction.
    static func hasReaction(applying applied: ElementKind, onto existing: ElementKind?) -> Bool {
        guard let existing = existing else { return false }
        return lookup[key(applied, existing)] != nil
    }

    /// All documented reactions, for the Grimoire.
    static var documented: [(applied: ElementKind, existing: ElementKind, lore: String, effect: ReactionEffect)] {
        entries.map { ($0.applied, $0.existing, $0.result.lore, $0.result.effect) }
    }
}
