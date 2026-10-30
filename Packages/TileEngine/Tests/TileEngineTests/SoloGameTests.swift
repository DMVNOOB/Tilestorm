import Testing
@testable import TileEngine

private func makeGame(distribution: [Character: Int] = TileDistribution.standard) -> SoloGame {
    var rng = SplitMix64(state: 7)
    return SoloGame(distribution: distribution, using: &rng)
}

/// Places every rack tile on the board in a row, emptying the rack.
private func placeWholeRack(_ game: inout SoloGame) throws {
    for tile in game.player.rack {
        try game.put(tile.id, at: GridPosition(row: 0, column: game.player.board.tiles.count))
    }
}

@Test func newGameDealsStartingHand() {
    let game = makeGame()
    #expect(game.player.rack.count == 21)
    #expect(game.bag.count == 123)
}

@Test func drawRequiresEmptyRack() throws {
    var game = makeGame()
    #expect(!game.canDraw)
    #expect(throws: SoloGameError.tilesStillOnRack) { try game.draw() }
    #expect(game.bag.count == 123)
}

@Test func drawTakesOneTileFromBag() throws {
    var game = makeGame()
    try placeWholeRack(&game)
    #expect(game.canDraw)
    let drawn = try game.draw()
    #expect(game.player.rack == [drawn])
    #expect(game.bag.count == 122)
}

@Test func drawFromEmptyBagThrows() throws {
    var game = makeGame(distribution: ["A": 21])
    try placeWholeRack(&game)
    #expect(!game.canDraw)
    #expect(throws: SoloGameError.bagEmpty) { try game.draw() }
}

@Test func swapReturnsOneAndDrawsThree() throws {
    var game = makeGame()
    var rng = SplitMix64(state: 3)
    let returned = game.player.rack[0]
    let drawn = try game.swap(returned.id, using: &rng)
    #expect(drawn.count == 3)
    #expect(game.player.rack.count == 23)
    #expect(game.bag.count == 121)
    #expect(game.player.rack.suffix(3) == drawn[...])
}

@Test func swapCanTakeTileFromBoard() throws {
    var game = makeGame()
    let tile = game.player.rack[0]
    try game.put(tile.id, at: GridPosition(row: 0, column: 0))
    try game.swap(tile.id)
    #expect(game.player.board.isEmpty)
    #expect(game.player.rack.count == 23)
}

@Test func swapNeedsThreeTilesInBag() throws {
    var game = makeGame(distribution: ["A": 23])
    #expect(game.bag.count == 2)
    #expect(!game.canSwap)
    let tile = game.player.rack[0]
    #expect(throws: SoloGameError.notEnoughTilesToSwap) { try game.swap(tile.id) }
    #expect(game.player.rack.count == 21)
    #expect(game.bag.count == 2)
}

@Test func swapUnknownTileThrows() {
    var game = makeGame()
    #expect(throws: SoloGameError.unknownTile(9999)) { try game.swap(9999) }
    #expect(game.bag.count == 123)
}
