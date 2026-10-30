import Observation
import TileEngine

/// Local solo game state. Rules live in TileEngine; this only coordinates rack, board, and selection.
@Observable
final class Game {
    private(set) var bag = TileBag()
    private(set) var rack: [Tile] = []
    private(set) var board = Board()
    private(set) var selectedTileID: Tile.ID?

    init() {
        newGame()
    }

    func newGame() {
        bag = TileBag()
        board = Board()
        selectedTileID = nil
        rack = (try? bag.draw(StartingHand.size(forPlayers: 1))) ?? []
    }

    func toggleSelection(_ tile: Tile) {
        selectedTileID = selectedTileID == tile.id ? nil : tile.id
    }

    /// Tapping a cell places the selected rack tile there, or sends an existing board tile back to the rack.
    func tapCell(_ cell: GridPosition) {
        if let selectedTileID, let index = rack.firstIndex(where: { $0.id == selectedTileID }) {
            guard (try? board.place(rack[index], at: cell)) != nil else { return }
            rack.remove(at: index)
            self.selectedTileID = nil
        } else if let tile = board.remove(at: cell) {
            rack.append(tile)
        }
    }
}
