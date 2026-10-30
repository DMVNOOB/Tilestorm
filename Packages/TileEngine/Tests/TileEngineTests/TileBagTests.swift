import Testing
@testable import TileEngine

/// Deterministic generator so shuffles are reproducible in tests.
struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Test func standardDistributionHas144Tiles() {
    #expect(TileDistribution.standard.values.reduce(0, +) == 144)
    #expect(TileDistribution.standard.count == 26)
    #expect(TileBag().count == 144)
}

@Test func tileIdsAreUnique() {
    let bag = TileBag()
    #expect(Set(bag.tiles.map(\.id)).count == 144)
}

@Test(arguments: [(1, 21), (4, 21), (5, 15), (6, 15), (7, 11), (8, 11)])
func startingHandSize(players: Int, expected: Int) {
    #expect(StartingHand.size(forPlayers: players) == expected)
}

@Test func drawRemovesTilesFromBag() throws {
    var bag = TileBag()
    let hand = try bag.draw(21)
    #expect(hand.count == 21)
    #expect(bag.count == 123)
    #expect(Set(hand).isDisjoint(with: Set(bag.tiles)))
}

@Test func drawingMoreThanAvailableThrowsAndLeavesBagIntact() {
    var bag = TileBag(distribution: ["A": 2])
    #expect(throws: TileBagError.notEnoughTiles(requested: 3, available: 2)) {
        try bag.draw(3)
    }
    #expect(bag.count == 2)
}

@Test func putBackReturnsTilesToBag() throws {
    var rng = SplitMix64(state: 1)
    var bag = TileBag(using: &rng)
    let drawn = try bag.draw(1)
    bag.putBack(drawn, using: &rng)
    #expect(bag.count == 144)
    #expect(bag.tiles.contains(drawn[0]))
}

@Test func seededBagsShuffleIdentically() {
    var a = SplitMix64(state: 42)
    var b = SplitMix64(state: 42)
    #expect(TileBag(using: &a).tiles == TileBag(using: &b).tiles)
}
