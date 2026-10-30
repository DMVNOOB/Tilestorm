/// A word on the board: a run of two or more tiles reading left to right or top to bottom.
public struct PlacedWord: Hashable, Sendable {
    public let text: String
    public let cells: [GridPosition]
}

public enum BoardProblem: Equatable, Sendable {
    /// The board has no words yet (it's empty or holds a single tile).
    case noWords
    /// The tiles form more than one separate group.
    case notConnected
    case invalidWords([PlacedWord])
}

extension Board {
    /// Every maximal horizontal and vertical run of two or more tiles, across words first.
    public var words: [PlacedWord] {
        runs(step: GridPosition(row: 0, column: 1)) + runs(step: GridPosition(row: 1, column: 0))
    }

    /// True when every tile can reach every other through up/down/left/right neighbours.
    public var isConnected: Bool {
        guard let start = tiles.keys.first else { return true }
        var seen: Set<GridPosition> = [start]
        var frontier = [start]
        while let cell = frontier.popLast() {
            for neighbour in cell.neighbours where tiles[neighbour] != nil && !seen.contains(neighbour) {
                seen.insert(neighbour)
                frontier.append(neighbour)
            }
        }
        return seen.count == tiles.count
    }

    /// Everything stopping this board from being a valid grid. Empty means valid.
    public func problems(using wordList: WordList) -> [BoardProblem] {
        let words = words
        guard !words.isEmpty else { return [.noWords] }
        var problems: [BoardProblem] = []
        if !isConnected {
            problems.append(.notConnected)
        }
        let invalid = words.filter { !wordList.contains($0.text) }
        if !invalid.isEmpty {
            problems.append(.invalidWords(invalid))
        }
        return problems
    }

    private func runs(step: GridPosition) -> [PlacedWord] {
        // A run starts at a tile with no tile before it in the step direction.
        let starts = tiles.keys
            .filter { tiles[$0 - step] == nil }
            .sorted { ($0.row, $0.column) < ($1.row, $1.column) }
        return starts.compactMap { start in
            var cells: [GridPosition] = []
            var cell = start
            while tiles[cell] != nil {
                cells.append(cell)
                cell = cell + step
            }
            guard cells.count >= 2 else { return nil }
            return PlacedWord(text: String(cells.map { tiles[$0]!.letter }), cells: cells)
        }
    }
}

extension GridPosition {
    var neighbours: [GridPosition] {
        [
            GridPosition(row: row - 1, column: column),
            GridPosition(row: row + 1, column: column),
            GridPosition(row: row, column: column - 1),
            GridPosition(row: row, column: column + 1),
        ]
    }

    static func + (lhs: GridPosition, rhs: GridPosition) -> GridPosition {
        GridPosition(row: lhs.row + rhs.row, column: lhs.column + rhs.column)
    }

    static func - (lhs: GridPosition, rhs: GridPosition) -> GridPosition {
        GridPosition(row: lhs.row - rhs.row, column: lhs.column - rhs.column)
    }
}
