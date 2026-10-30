import SwiftUI
import TileEngine

/// Placeholder screen: deals a starting hand from the engine so the app/engine wiring is visible.
/// The board, rack interactions, and Split/Peel/Dump come next.
struct ContentView: View {
    @State private var bag = TileBag()
    @State private var rack: [Tile] = []

    var body: some View {
        VStack(spacing: 24) {
            Text("Tilestorm")
                .font(.largeTitle.bold())

            Text("\(bag.count) tiles in the bag")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 8)], spacing: 8) {
                ForEach(rack) { tile in
                    TileView(tile: tile)
                }
            }
            .padding(.horizontal)

            Button("New Hand", action: deal)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear(perform: deal)
    }

    private func deal() {
        bag = TileBag()
        rack = (try? bag.draw(StartingHand.size(forPlayers: 1))) ?? []
    }
}

struct TileView: View {
    let tile: Tile

    var body: some View {
        Text(String(tile.letter))
            .font(.title2.weight(.semibold))
            .frame(width: 44, height: 44)
            .background(.yellow.opacity(0.85), in: .rect(cornerRadius: 8))
            .foregroundStyle(.black)
            .accessibilityLabel("Tile \(String(tile.letter))")
    }
}

#Preview {
    ContentView()
}
