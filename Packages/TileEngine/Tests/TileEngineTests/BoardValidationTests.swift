import Testing
@testable import TileEngine

/// Builds a board from rows of text; spaces are empty cells. Row 0 is the first string.
private func board(_ rows: String...) throws -> Board {
    var board = Board()
    var id = 0
    for (row, line) in rows.enumerated() {
        for (column, letter) in line.enumerated() where letter != " " {
            try board.place(Tile(id: id, letter: letter), at: GridPosition(row: row, column: column))
            id += 1
        }
    }
    return board
}

private let words = WordList(["CAT", "CAR", "AT", "TO", "ART"])

@Test func findsAcrossAndDownWords() throws {
    let b = try board(
        "CAT",
        "A  ",
        "R  "
    )
    #expect(b.words.map(\.text) == ["CAT", "CAR"])
    #expect(b.words[1].cells == [
        GridPosition(row: 0, column: 0), GridPosition(row: 1, column: 0), GridPosition(row: 2, column: 0),
    ])
}

@Test func singleLettersAreNotWords() throws {
    #expect(try board("A").words.isEmpty)
    #expect(try board("A A").words.isEmpty)
}

@Test func validGridHasNoProblems() throws {
    let b = try board(
        "CAT",
        "A O",
        "R  "
    )
    #expect(b.problems(using: words).isEmpty)
}

@Test func emptyOrSingleTileBoardHasNoWords() throws {
    #expect(Board().problems(using: words) == [.noWords])
    #expect(try board("A").problems(using: words) == [.noWords])
}

@Test func reportsInvalidWords() throws {
    let b = try board(
        "CAT",
        "X  "
    )
    let invalid = try #require(b.words.first { $0.text == "CX" })
    #expect(b.problems(using: words) == [.invalidWords([invalid])])
}

@Test func reportsDisconnectedGroups() throws {
    let b = try board(
        "CAT",
        "   ",
        "AT "
    )
    #expect(!b.isConnected)
    #expect(b.problems(using: words) == [.notConnected])
}

@Test func diagonalTouchDoesNotConnect() throws {
    let b = try board(
        "AT ",
        "  AT"
    )
    #expect(!b.isConnected)
}

@Test func reportsBothProblemsTogether() throws {
    let b = try board(
        "CAT",
        "   ",
        "ZZ "
    )
    let zz = try #require(b.words.first { $0.text == "ZZ" })
    #expect(b.problems(using: words) == [.notConnected, .invalidWords([zz])])
}

@Test func bundledWordListLoads() {
    let list = WordList.enable
    #expect(list.count == 172_823)
    #expect(list.contains("cat"))
    #expect(list.contains("CATS"))
    #expect(!list.contains("XQZ"))
}
