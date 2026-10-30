import Testing
@testable import TileEngine

private let a = Tile(id: 0, letter: "A")
private let b = Tile(id: 1, letter: "B")
private let c = Tile(id: 2, letter: "C")
private let origin = GridPosition(row: 0, column: 0)
private let right = GridPosition(row: 0, column: 1)

@Test func putFromRackOntoEmptyCell() throws {
    var player = PlayerTiles(rack: [a, b])
    try player.put(a.id, at: origin)
    #expect(player.rack == [b])
    #expect(player.board.tile(at: origin) == a)
}

@Test func putFromRackOntoOccupiedCellSendsDisplacedTileToSameRackSlot() throws {
    var player = PlayerTiles(rack: [a, b, c])
    try player.put(a.id, at: origin)
    try player.put(c.id, at: origin)
    #expect(player.rack == [b, a])
    #expect(player.board.tile(at: origin) == c)
}

@Test func putBoardTileOntoEmptyCellMovesIt() throws {
    var player = PlayerTiles(rack: [a])
    try player.put(a.id, at: origin)
    try player.put(a.id, at: right)
    #expect(player.board.tile(at: origin) == nil)
    #expect(player.board.tile(at: right) == a)
}

@Test func putBoardTileOntoOccupiedCellSwapsThem() throws {
    var player = PlayerTiles(rack: [a, b])
    try player.put(a.id, at: origin)
    try player.put(b.id, at: right)
    try player.put(a.id, at: right)
    #expect(player.board.tile(at: origin) == b)
    #expect(player.board.tile(at: right) == a)
}

@Test func putBoardTileOntoItsOwnCellChangesNothing() throws {
    var player = PlayerTiles(rack: [a])
    try player.put(a.id, at: origin)
    try player.put(a.id, at: origin)
    #expect(player.board.tile(at: origin) == a)
    #expect(player.rack.isEmpty)
}

@Test func returnToRackTakesTileOffBoard() throws {
    var player = PlayerTiles(rack: [a, b])
    try player.put(a.id, at: origin)
    try player.returnToRack(a.id)
    #expect(player.board.isEmpty)
    #expect(player.rack == [b, a])
}

@Test func returnToRackForRackTileDoesNothing() throws {
    var player = PlayerTiles(rack: [a])
    try player.returnToRack(a.id)
    #expect(player.rack == [a])
}

@Test func unknownTileThrows() {
    var player = PlayerTiles(rack: [a])
    #expect(throws: PlayerTilesError.unknownTile(c.id)) { try player.put(c.id, at: origin) }
    #expect(throws: PlayerTilesError.unknownTile(c.id)) { try player.returnToRack(c.id) }
}
