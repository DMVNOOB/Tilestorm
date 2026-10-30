import Testing
@testable import TileEngine

private let a = Tile(id: 0, letter: "A")
private let b = Tile(id: 1, letter: "B")
private let origin = GridPosition(row: 0, column: 0)
private let right = GridPosition(row: 0, column: 1)

@Test func placeAndLookUpTile() throws {
    var board = Board()
    try board.place(a, at: origin)
    #expect(board.tile(at: origin) == a)
    #expect(board.position(of: a.id) == origin)
    #expect(board.tile(at: right) == nil)
}

@Test func negativePositionsAreAllowed() throws {
    var board = Board()
    let upLeft = GridPosition(row: -3, column: -7)
    try board.place(a, at: upLeft)
    #expect(board.tile(at: upLeft) == a)
}

@Test func placingOnOccupiedCellThrows() throws {
    var board = Board()
    try board.place(a, at: origin)
    #expect(throws: BoardError.cellOccupied(origin)) { try board.place(b, at: origin) }
    #expect(board.tile(at: origin) == a)
}

@Test func placingSameTileTwiceThrows() throws {
    var board = Board()
    try board.place(a, at: origin)
    #expect(throws: BoardError.tileAlreadyOnBoard(a.id)) { try board.place(a, at: right) }
}

@Test func removeReturnsTile() throws {
    var board = Board()
    try board.place(a, at: origin)
    #expect(board.remove(at: origin) == a)
    #expect(board.isEmpty)
    #expect(board.remove(at: origin) == nil)
}

@Test func moveTile() throws {
    var board = Board()
    try board.place(a, at: origin)
    try board.move(from: origin, to: right)
    #expect(board.tile(at: origin) == nil)
    #expect(board.tile(at: right) == a)
}

@Test func moveOntoOccupiedCellThrowsAndLeavesBoardUnchanged() throws {
    var board = Board()
    try board.place(a, at: origin)
    try board.place(b, at: right)
    #expect(throws: BoardError.cellOccupied(right)) { try board.move(from: origin, to: right) }
    #expect(board.tile(at: origin) == a)
    #expect(board.tile(at: right) == b)
}

@Test func moveFromEmptyCellThrows() {
    var board = Board()
    #expect(throws: BoardError.cellEmpty(origin)) { try board.move(from: origin, to: right) }
}
