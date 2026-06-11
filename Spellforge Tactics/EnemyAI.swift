import SwiftUI

extension BattleEngine {

    // MARK: - Player: movement

    func reachableTiles(for mage: BattleUnit) -> Set<GridPos> {
        guard !mage.hasMoved, !mage.stunned else { return [] }
        var result: Set<GridPos> = []
        var frontier: [(GridPos, Int)] = [(mage.pos, 0)]
        var visited: Set<GridPos> = [mage.pos]
        while let (p, d) = frontier.first {
            frontier.removeFirst()
            if d >= mage.moveRange { continue }
            for n in p.neighbors where inBounds(n) && !visited.contains(n) {
                visited.insert(n)
                if isPassable(n, for: .mage) {
                    result.insert(n)
                    frontier.append((n, d+1))
                }
            }
        }
        return result
    }

    func moveSelectedMage(to dest: GridPos) {
        guard let mage = selectedMage, !mage.hasMoved else { return }
        guard reachableTiles(for: mage).contains(dest) else { return }
        mage.pos = dest
        mage.hasMoved = true
        applyTerrainStanding(mage)
        checkObjectiveAfterAction()
        objectWillChange.send()
    }

    private func applyTerrainStanding(_ unit: BattleUnit) {
        let t = tiles[unit.pos.y][unit.pos.x]
        if t.terrain == .leyNode && unit.side == .mage {
            unit.mana = min(unit.maxMana, unit.mana + 2)
        }
        if t.terrain.burnsOccupant > 0 {
            damageUnit(unit, amount: t.terrain.burnsOccupant, fromReaction: false, source: "lava")
        }
    }

    // MARK: - Player: casting

    func castableTiles(for mage: BattleUnit, spell: ResolvedSpell) -> Set<GridPos> {
        guard !mage.hasActed, !mage.stunned, mage.mana >= spell.manaCost else { return [] }
        var result: Set<GridPos> = []
        for dy in -spell.range...spell.range {
            for dx in -spell.range...spell.range {
                let p = GridPos(mage.pos.x+dx, mage.pos.y+dy)
                if inBounds(p) && mage.pos.manhattan(to: p) <= spell.range && mage.pos.manhattan(to: p) > 0 {
                    if !tiles[p.y][p.x].terrain.impassable {
                        result.insert(p)
                    }
                }
            }
        }
        return result
    }

    func previewTiles(center: GridPos, spell: ResolvedSpell) -> [GridPos] {
        SpellAoEPattern.tiles(center: center, aoe: spell.aoe).filter { inBounds($0) && !tiles[$0.y][$0.x].terrain.impassable }
    }

    /// Cast the selected spell from the selected mage at center tile.
    func castSelected(at center: GridPos) {
        guard let mage = selectedMage, let sid = selectedSpellId, let spell = spells[sid] else { return }
        guard !mage.hasActed, mage.mana >= spell.manaCost else { return }
        guard castableTiles(for: mage, spell: spell).contains(center) else { return }

        mage.mana -= spell.manaCost
        mage.hasActed = true
        spellCastCount += 1
        store.markSpellSeen(sid)
        store.markElementSeen(spell.element)

        let targets = previewTiles(center: center, spell: spell)
        var chainStunThisCast = 0

        for t in targets {
            // direct damage to occupant
            if spell.damage > 0, let occ = unit(at: t) {
                let dmg = effectiveDamage(spell.damage, element: spell.element, on: occ)
                damageUnit(occ, amount: dmg, fromReaction: false, source: spell.name)
            }
            // apply element + resolve reaction
            chainStunThisCast += applyElement(spell.element, at: t)
        }
        maxChainStunInOneCast = max(maxChainStunInOneCast, chainStunThisCast)
        if chainStunThisCast >= 3 { store.unlockAchievement("ach_chainstun") }

        selectedSpellId = nil
        checkObjectiveAfterAction()
        objectWillChange.send()
    }

    func effectiveDamage(_ base: Int, element: ElementKind, on unit: BattleUnit) -> Int {
        if unit.immunities.contains(element) { return 0 }
        if unit.weaknesses.contains(element) { return base * 2 }
        return base
    }

    // MARK: - Element application + reaction resolution (bounded, terminates)

    /// Applies `applied` element to tile p, resolving any reaction there and bounded propagation.
    /// Returns the number of enemies stunned by the result (origin tile + chain).
    @discardableResult
    func applyElement(_ applied: ElementKind, at p: GridPos) -> Int {
        guard inBounds(p) else { return 0 }
        let existing = tiles[p.y][p.x].element
        if let ex = existing {
            store.markReactionSeen(applied: applied, existing: ex)
        }
        let result = ReactionMatrix.resolve(applying: applied, onto: existing)

        var didStun = false
        let isReaction = ReactionMatrix.hasReaction(applying: applied, onto: existing)
        if isReaction {
            reactionCount += 1
            store.markElementSeen(applied)
        }

        // set produced element
        tiles[p.y][p.x].element = result.producedElement

        // apply damage to occupant
        if result.damage > 0, let occ = unit(at: p) {
            let elementForAffinity = result.producedElement ?? applied
            let dmg = effectiveDamage(result.damage, element: elementForAffinity, on: occ)
            damageUnit(occ, amount: dmg, fromReaction: true, source: result.effect.rawValue)
        }
        if result.stuns, let occ = unit(at: p), occ.side == .enemy {
            occ.stunned = true
            didStun = true
        }
        if result.effect == .detonate { didDetonate = true; store.unlockAchievement("ach_detonate") }

        // bounded propagation (BFS with hard cap on visited tiles to guarantee termination)
        var chainStuns = 0
        if result.propagates, let propEl = result.propagateElement {
            chainStuns = propagate(result: result, sourceElement: applied, matching: propEl, from: p)
        }
        return (didStun ? 1 : 0) + chainStuns
    }

    /// Spreads the ORIGIN reaction's outcome across every connected tile whose element
    /// matches `matching` (fire+oil race, charge+water chain-stun, poison detonation chain).
    /// BFS with a hard step cap -> deterministic and always terminates.
    /// Returns the number of enemies stunned along the chain.
    @discardableResult
    private func propagate(result: ReactionResult, sourceElement: ElementKind, matching: ElementKind, from origin: GridPos) -> Int {
        let cap = 60   // hard cap on propagation steps -> guaranteed termination
        var steps = 0
        var stunCount = 0
        var frontier: [GridPos] = [origin]
        var visited: Set<GridPos> = [origin]
        while !frontier.isEmpty && steps < cap {
            let cur = frontier.removeFirst()
            for n in cur.neighbors where inBounds(n) && !visited.contains(n) {
                steps += 1
                if steps >= cap { break }
                let tEl = tiles[n.y][n.x].element
                guard tEl == matching else { continue }
                visited.insert(n)
                // Apply the origin reaction's outcome to this connected tile.
                tiles[n.y][n.x].element = result.producedElement
                reactionCount += 1
                if result.damage > 0, let occ = unit(at: n) {
                    let el = result.producedElement ?? sourceElement
                    let dmg = effectiveDamage(result.damage, element: el, on: occ)
                    damageUnit(occ, amount: dmg, fromReaction: true, source: result.effect.rawValue)
                }
                if result.stuns, let occ = unit(at: n), occ.side == .enemy {
                    occ.stunned = true
                    stunCount += 1
                }
                frontier.append(n)
            }
        }
        return stunCount
    }

    // MARK: - Damage / death

    func damageUnit(_ unit: BattleUnit, amount: Int, fromReaction: Bool, source: String) {
        guard amount > 0, unit.alive else { return }
        unit.hp -= amount
        addFloatProxy("-\(amount)", at: unit.pos, color: unit.side == .mage ? Theme.danger : Theme.gold)
        if unit.side == .mage {
            anyMageDamaged = true
            healLeechesIfAny()
        }
        if unit.hp <= 0 {
            handleDeath(unit, fromReaction: fromReaction)
        }
    }

    private func healLeechesIfAny() {
        for e in enemies where e.behavior == .leech {
            e.hp = min(e.maxHP, e.hp + 2)
        }
    }

    private func handleDeath(_ unit: BattleUnit, fromReaction: Bool) {
        if unit.side == .enemy {
            // Boss phase transition
            if let bid = unit.bossDefId, let bdef = BossCatalog.byId(bid), unit.bossPhase == 1 {
                // begin phase 2 instead of dying
                unit.bossPhase = 2
                unit.hp = bdef.phase2HP
                unit.maxHP = bdef.phase2HP
                unit.behavior = bdef.phase2Behavior
                unit.immunities = bdef.phase2Immunities
                addFloatProxy("PHASE II", at: unit.pos, color: Theme.danger)
                statusMessage = bdef.phase2Lore
                return
            }
            enemiesKilled += 1
            if fromReaction { } else { anyDirectKill = true }
            // splitter
            if let childId = unit.splitsInto, let cdef = EnemyCatalog.byId(childId) {
                let spots = unit.pos.neighbors.filter { inBounds($0) && self.unit(at: $0) == nil && !tiles[$0.y][$0.x].terrain.impassable }
                for spot in spots.prefix(2) {
                    let child = BattleUnit.makeEnemy(cdef, at: spot)
                    units.append(child)
                }
            }
            if unit.bossDefId != nil { bossDefeatedId = unit.bossDefId }
        } else {
            mageLost = true
        }
    }

    func addFloatProxy(_ text: String, at pos: GridPos, color: Color) {
        let ft = FloatingText(pos: pos, text: text, color: color)
        floatingTexts.append(ft)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
            self?.floatingTexts.removeAll { $0.id == ft.id }
        }
    }

    // MARK: - End player turn -> enemy turn -> terrain tick -> next round

    func endPlayerTurn() {
        guard phase == .playerTurn else { return }
        phase = .enemyTurn
        objectWillChange.send()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.runEnemyTurn()
        }
    }

    private func runEnemyTurn() {
        for e in enemies where e.alive {
            if e.stunned {
                e.stunned = false   // recover from stun, skip turn
                continue
            }
            takeEnemyAction(e)
            if lost { break }
        }
        terrainTick()
        spawnWavesForUpcomingRound()
        // reset mage flags + regen
        for m in mages {
            m.hasMoved = false
            m.hasActed = false
            if !m.stunned {
                m.mana = min(m.maxMana, m.mana + m.manaRegen)
            }
            m.stunned = false
            // ley node regen
            if tiles[m.pos.y][m.pos.x].terrain == .leyNode {
                m.mana = min(m.maxMana, m.mana + 1)
            }
        }
        roundNumber += 1
        checkObjectiveAfterEnemyTurn()
        if !won && !lost {
            phase = .playerTurn
            if selectedMage == nil, let idx = units.firstIndex(where: { $0.side == .mage && $0.alive }) {
                selectedMageIndex = idx
            }
        }
        objectWillChange.send()
    }

    // MARK: - Terrain ticks

    private func terrainTick() {
        for y in 0..<height {
            for x in 0..<width {
                let p = GridPos(x, y)
                let terr = tiles[y][x].terrain
                if terr.reseedsEachTurn {
                    // lava reignites fire
                    if tiles[y][x].element == nil || tiles[y][x].element == .steam {
                        tiles[y][x].element = .fire
                    }
                    if let occ = unit(at: p) {
                        damageUnit(occ, amount: terr.burnsOccupant, fromReaction: false, source: "lava")
                    }
                }
            }
        }
        // flooders / igniters / randomizers act as terrain-affecting enemies (already moved in their AI),
        // but immobile totems with behavior do their tile effect here.
        for e in enemies where e.alive {
            switch e.behavior {
            case .flooder:
                if let target = nearestEmptyElementTile(to: e.pos) {
                    applyElement(.water, at: target)
                }
            case .igniter:
                if let target = nearestEmptyElementTile(to: e.pos) {
                    applyElement(.fire, at: target)
                }
            case .randomizer:
                randomizeATile(near: e.pos)
            default: break
            }
        }
    }

    private func nearestEmptyElementTile(to p: GridPos) -> GridPos? {
        for r in 1...3 {
            for dx in -r...r { for dy in -r...r {
                let q = GridPos(p.x+dx, p.y+dy)
                if inBounds(q) && !tiles[q.y][q.x].terrain.impassable && q.manhattan(to: p) <= r {
                    return q
                }
            }}
        }
        return nil
    }

    private func randomizeATile(near p: GridPos) {
        // Deterministic-ish: pick a tile based on round number to keep reproducible.
        let candidates = (0..<3).compactMap { _ -> GridPos? in nil }
        _ = candidates
        let opts: [GridPos] = p.neighbors.filter { inBounds($0) && !tiles[$0.y][$0.x].terrain.impassable }
        guard !opts.isEmpty else { return }
        let pick = opts[(roundNumber + p.x + p.y) % opts.count]
        let allEls = ElementKind.allCases
        let el = allEls[(roundNumber * 3 + pick.x + pick.y) % allEls.count]
        tiles[pick.y][pick.x].element = el
    }

    // MARK: - Waves

    private func spawnWavesForUpcomingRound() {
        for wave in mission.waves where wave.onTurn == roundNumber {
            for s in wave.spawns { spawnFromDescriptor(s) }
        }
    }

    // MARK: - Enemy single-unit action

    func takeEnemyAction(_ e: BattleUnit) {
        // Summoner: spawn a minion on cooldown.
        if e.behavior == .summoner {
            if e.summonCooldown <= 0, let mid = e.summons, let mdef = EnemyCatalog.byId(mid) {
                if let spot = e.pos.neighbors.first(where: { inBounds($0) && unit(at: $0) == nil && !tiles[$0.y][$0.x].terrain.impassable }) {
                    units.append(BattleUnit.makeEnemy(mdef, at: spot))
                    e.summonCooldown = 3
                }
            } else {
                e.summonCooldown -= 1
            }
        }
        // Totems with tile effects act in terrainTick; they don't move/attack here unless guardian.
        if e.behavior == .flooder || e.behavior == .igniter || e.behavior == .randomizer {
            // still attack if a mage is adjacent (randomizer/stormcrow can peck)
            if e.attackRange > 0, let target = nearestMage(to: e), e.pos.manhattan(to: target.pos) <= e.attackRange {
                attack(e, target)
            }
            return
        }

        guard let target = nearestMage(to: e) else { return }

        // If already in attack range, attack.
        if e.pos.manhattan(to: target.pos) <= e.attackRange && hasLineToAttack(e, target) {
            attack(e, target)
            return
        }

        // Move toward target (up to moveRange), respecting walls unless phaser.
        let phaser = e.behavior == .phaser
        if e.moveRange > 0 {
            let path = stepToward(from: e.pos, to: target.pos, maxSteps: e.moveRange, phaser: phaser)
            if let dest = path {
                e.pos = dest
                // lava burn while moving
                let terr = tiles[dest.y][dest.x].terrain
                if terr.burnsOccupant > 0 {
                    damageUnit(e, amount: terr.burnsOccupant, fromReaction: false, source: "lava")
                }
            }
        }
        // Attack after moving if now in range.
        if e.alive, e.pos.manhattan(to: target.pos) <= e.attackRange && hasLineToAttack(e, target) {
            attack(e, target)
        }
    }

    private func hasLineToAttack(_ e: BattleUnit, _ target: BattleUnit) -> Bool {
        // Melee (range 1) and ranged both allowed; ranged ignores element walls for simplicity.
        return true
    }

    private func attack(_ e: BattleUnit, _ target: BattleUnit) {
        guard e.damage > 0 else { return }
        damageUnit(target, amount: e.damage, fromReaction: false, source: e.name)
    }

    func nearestMage(to e: BattleUnit) -> BattleUnit? {
        mages.min { e.pos.manhattan(to: $0.pos) < e.pos.manhattan(to: $1.pos) }
    }

    /// Greedy BFS step toward target, returning the best reachable tile within maxSteps.
    private func stepToward(from: GridPos, to: GridPos, maxSteps: Int, phaser: Bool) -> GridPos? {
        struct Node { let p: GridPos; let dist: Int }
        var frontier: [Node] = [Node(p: from, dist: 0)]
        var visited: Set<GridPos> = [from]
        var best: GridPos? = nil
        var bestDistToTarget = from.manhattan(to: to)
        var head = 0
        while head < frontier.count {
            let node = frontier[head]; head += 1
            if node.dist >= maxSteps { continue }
            for n in node.p.neighbors where inBounds(n) && !visited.contains(n) {
                visited.insert(n)
                // can't move onto another unit; can't enter impassable; walls block unless phaser
                let t = tiles[n.y][n.x]
                if t.terrain.impassable { continue }
                if unit(at: n) != nil {
                    // occupied; can't stand here, but could be the target's tile (don't move into it)
                    continue
                }
                if !phaser, let el = t.element, el.blocksMovement { continue }
                let d = n.manhattan(to: to)
                if d < bestDistToTarget {
                    bestDistToTarget = d
                    best = n
                }
                frontier.append(Node(p: n, dist: node.dist + 1))
            }
        }
        return best
    }

    // MARK: - Objective evaluation

    func checkObjectiveAfterAction() {
        // Some objectives can be met immediately on a player action.
        switch mission.objective {
        case .annihilate, .defeatBoss:
            if enemies.isEmpty { winBattle() }
            if case .defeatBoss(let bid) = mission.objective {
                if !enemies.contains(where: { $0.bossDefId == bid }) && bossDefeatedId == bid {
                    winBattle()
                }
            }
        case .igniteTiles(let targets):
            if targets.allSatisfy({ inBounds($0) && tiles[$0.y][$0.x].element == .fire }) {
                winBattle()
            }
        case .extinguishTiles(let targets):
            if targets.allSatisfy({ inBounds($0) && tiles[$0.y][$0.x].element != .fire }) {
                winBattle()
            }
        case .escort(let exit):
            if mages.contains(where: { $0.pos == exit }) { winBattle() }
        case .survive, .protectLeyNode:
            break
        }
        evaluateLoss()
    }

    func checkObjectiveAfterEnemyTurn() {
        switch mission.objective {
        case .annihilate:
            if enemies.isEmpty { winBattle() }
        case .defeatBoss(let bid):
            if enemies.isEmpty || bossDefeatedId == bid { winBattle() }
        case .survive(let turns):
            objectiveProgress = min(roundNumber - 1, turns)
            if roundNumber - 1 >= turns { winBattle() }
        case .protectLeyNode(let node, let turns):
            // failed if an enemy is standing on the node
            if let occ = unit(at: node), occ.side == .enemy {
                loseBattle()
            } else {
                objectiveProgress = min(roundNumber - 1, turns)
                if roundNumber - 1 >= turns { winBattle() }
            }
        case .igniteTiles(let targets):
            // terrain/totem fire can complete this during the enemy phase too
            if targets.allSatisfy({ inBounds($0) && tiles[$0.y][$0.x].element == .fire }) {
                winBattle()
            }
        case .extinguishTiles(let targets):
            if targets.allSatisfy({ inBounds($0) && tiles[$0.y][$0.x].element != .fire }) {
                winBattle()
            }
        case .escort(let exit):
            if mages.contains(where: { $0.pos == exit }) { winBattle() }
        }
        evaluateLoss()
    }

    private func evaluateLoss() {
        if mages.isEmpty { loseBattle() }
    }

    private func winBattle() {
        guard !won && !lost else { return }
        won = true
        phase = .won
    }

    private func loseBattle() {
        guard !won && !lost else { return }
        lost = true
        phase = .lost
    }

    // MARK: - Results

    func computeStars() -> Int {
        guard won else { return 0 }
        var stars = 1
        // Star 2: bonus objective satisfied
        if bonusSatisfied() { stars += 1 }
        // Star 3: no mage lost
        if !mageLost { stars += 1 }
        return min(stars, 3)
    }

    func bonusSatisfied() -> Bool {
        switch mission.bonus {
        case .reactionKillsOnly: return !anyDirectKill
        case .noMageDamage: return !anyMageDamaged
        case .underTurns(let n): return roundNumber <= n
        case .noMageLost: return !mageLost
        }
    }

    func essenceReward() -> Int {
        let base = 20 + mission.indexInRegion * 4 + mission.regionIndex * 10
        let bossBonus = (mission.indexInRegion == 8) ? 40 : 0
        return base + bossBonus
    }

    func finalize() {
        if mission.bonus == .reactionKillsOnly && bonusSatisfied() && won {
            store.unlockAchievement("ach_reactiononly")
        }
        if mission.bonus == .noMageDamage && bonusSatisfied() && won {
            store.unlockAchievement("ach_flawless")
        }
        store.commitBattleStats(reactions: reactionCount, enemiesDefeated: enemiesKilled,
                                spellsCast: spellCastCount, turns: roundNumber)
        if won {
            store.recordResult(mission: mission, stars: computeStars(),
                               essenceReward: essenceReward(), bossDefeated: bossDefeatedId)
        }
    }
}
