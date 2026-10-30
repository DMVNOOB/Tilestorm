import Observation
import TileEngine

/// Local solo game state. Rules live in TileEngine; this only coordinates the bag, the player's tiles, and selection.
@Observable
final class Game {
    private(set) var bag = TileBag()
    private(set) var player = PlayerTiles()
    private(set) var selectedTileID: Tile.ID?

    var rack: [Tile] { player.rack }
    var board: Board { player.board }

    init() {
        newGame()
    }

    func newGame() {
        bag = TileBag()
        selectedTileID = nil
        player = PlayerTiles(rack: (try? bag.draw(StartingHand.size(forPlayers: 1))) ?? [])
    }

    func toggleSelection(_ tile: Tile) {
        selectedTileID = selectedTileID == tile.id ? nil : tile.id
    }

    /// Tapping a cell places the selected rack tile there, or sends an existing board tile back to the rack.
    func tapCell(_ cell: GridPosition) {
        if let selectedTileID {
            try? player.put(selectedTileID, at: cell)
            self.selectedTileID = nil
        } else if let tile = board.tile(at: cell) {
            try? player.returnToRack(tile.id)
        }
    }

    func put(_ tile: Tile, at cell: GridPosition) {
        try? player.put(tile.id, at: cell)
        selectedTileID = nil
    }

    func returnToRack(_ tile: Tile) {
        try? player.returnToRack(tile.id)
    }
}
