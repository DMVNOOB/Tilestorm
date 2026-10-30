import Testing
@testable import TileEngine

/// A row of the starting hand's 21 "A" tiles, accepted as a word so draw tests control validity.
private let rowOfAs = String(repeating: "A", count: 21)

private func makeGame(
    distribution: [Character: Int] = TileDistribution.standard,
    wordList: WordList = WordList([rowOfAs])
) -> SoloGame {
    var rng = SplitMix64(state: 7)
    return SoloGame(distribution: distribution, wordList: wordList, using: &rng)
}

/// Places every rack tile on the board in one row, emptying the rack.
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
    var game = makeGame(distribution: ["A": 30])
    #expect(!game.canDraw)
    #expect(throws: SoloGameError.tilesStillOnRack) { try game.draw() }
    #expect(game.bag.count == 9)
}

@Test func drawTakesOneTileWhenBoardIsValid() throws {
    var game = makeGame(distribution: ["A": 30])
    try placeWholeRack(&game)
    #expect(game.canDraw)
    let result = try game.draw()
    guard case .drew(let tile) = result else {
        Issue.record("Expected a tile, got \(result)")
        return
    }
    #expect(game.player.rack == [tile])
    #expect(game.bag.count == 8)
}

@Test func drawRefusesInvalidWords() throws {
    var game = makeGame(distribution: ["A": 30], wordList: WordList([]))
    try placeWholeRack(&game)
    #expect(!game.canDraw)
    let word = try #require(game.player.board.words.first)
    #expect(throws: SoloGameError.boardInvalid([.invalidWords([word])])) { try game.draw() }
    #expect(game.bag.count == 9)
}

@Test func drawRefusesDisconnectedBoard() throws {
    var game = makeGame(distribution: ["A": 30], wordList: WordList(["AA", String(repeating: "A", count: 19)]))
    let rack = game.player.rack
    // A 19-letter row, then a separate 2-letter row two lines below.
    for (column, tile) in rack.prefix(19).enumerated() {
        try game.put(tile.id, at: GridPosition(row: 0, column: column))
    }
    for (column, tile) in rack.suffix(2).enumerated() {
        try game.put(tile.id, at: GridPosition(row: 2, column: column))
    }
    #expect(throws: SoloGameError.boardInvalid([.notConnected])) { try game.draw() }
}

@Test func drawWithEmptyBagAndValidBoardFinishesGame() throws {
    var game = makeGame(distribution: ["A": 21])
    try placeWholeRack(&game)
    #expect(game.canDraw)
    #expect(try game.draw() == .finished)
    #expect(game.isFinished)
    #expect(!game.canDraw)
    #expect(!game.canSwap)
    let tile = try #require(game.player.board.tiles.values.first)
    #expect(throws: SoloGameError.gameFinished) { try game.returnToRack(tile.id) }
    #expect(throws: SoloGameError.gameFinished) { try game.draw() }
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

@Test func gameInProgressCanFinish() throws {
    var player = PlayerTiles(rack: [Tile(id: 0, letter: "A"), Tile(id: 1, letter: "T")])
    try player.put(0, at: GridPosition(row: 0, column: 0))
    try player.put(1, at: GridPosition(row: 0, column: 1))
    var game = SoloGame(bag: TileBag(tiles: []), player: player, wordList: WordList(["AT"]))
    #expect(game.canDraw)
    #expect(try game.draw() == .finished)
}
