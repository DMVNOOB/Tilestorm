import SwiftUI
import TileEngine

struct TitleView: View {
    let onPlay: () -> Void

    @State private var showHowToPlay = false

    var body: some View {
        ZStack {
            Color.parchment
            RadialGradient(colors: [.butter.opacity(0.9), .butter.opacity(0)], center: .center, startRadius: 0, endRadius: 380)
            ScatteredTiles()

            VStack(spacing: 0) {
                Spacer()
                Logo()
                Text("Build words. Beat the bag.")
                    .font(GameFont.ui(19, relativeTo: .title3))
                    .foregroundStyle(Color.cocoa.opacity(0.75))
                    .padding(.top, 32)

                VStack(spacing: 18) {
                    Button(action: onPlay) { Text("Play").frame(width: 200) }
                        .buttonStyle(GameButtonStyle(kind: .primary))
                    Button { showHowToPlay = true } label: { Text("How to Play").frame(width: 200) }
                        .buttonStyle(GameButtonStyle(kind: .secondary))
                }
                .padding(.top, 44)

                Spacer()
                Text("Solo practice · v\(Bundle.main.shortVersion) alpha")
                    .font(GameFont.ui(13, .medium, relativeTo: .footnote))
                    .foregroundStyle(Color.cocoa.opacity(0.45))
                    .padding(.bottom, 8)
            }
        }
        .background(Color.parchment.ignoresSafeArea())
        .sheet(isPresented: $showHowToPlay) { HowToPlayView() }
    }
}

/// TILE / STORM spelled in tilted tiles that bob gently.
private struct Logo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var bobbing = false

    private static let tilts: [Double] = [-6, 4, -3, 7, -5, 3, -4, 6, -2]

    var body: some View {
        VStack(spacing: 14) {
            row("TILE", startIndex: 0)
            row("STORM", startIndex: 4)
        }
        .onAppear { if !reduceMotion { bobbing = true } }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tilestorm")
        .accessibilityAddTraits(.isHeader)
    }

    private func row(_ word: String, startIndex: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(word.enumerated()), id: \.offset) { offset, letter in
                let index = startIndex + offset
                TileView(tile: Tile(id: index, letter: letter), size: 60, isSelected: index == 6)
                    .rotationEffect(.degrees(Self.tilts[index]))
                    .offset(y: (offset.isMultiple(of: 2) ? 0 : 6) + (bobbing ? -4 : 0))
                    .animation(
                        .easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(Double(index) * 0.12),
                        value: bobbing
                    )
            }
        }
    }
}

/// Faded tiles drifting around the edges: the "storm".
private struct ScatteredTiles: View {
    private static let tiles: [(letter: Character, x: CGFloat, y: CGFloat, tilt: Double)] = [
        ("Q", 0.1, 0.12, -18), ("W", 0.88, 0.11, 14), ("Z", 0.74, 0.21, -8), ("K", 0.24, 0.22, 22),
        ("J", 0.1, 0.72, 12), ("X", 0.88, 0.75, -16), ("V", 0.22, 0.88, -6), ("H", 0.8, 0.89, 20),
    ]

    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(Self.tiles.enumerated()), id: \.offset) { index, item in
                TileView(tile: Tile(id: index, letter: item.letter), size: 42)
                    .rotationEffect(.degrees(item.tilt))
                    .opacity(0.35)
                    .position(x: item.x * geometry.size.width, y: item.y * geometry.size.height)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss

    private static let rules: [(title: String, detail: String)] = [
        ("Build", "Drag tiles from your rack onto the board to make words that read across or down."),
        ("Connect", "Every word has to link up into one grid. Tiles that only touch at a corner don't count."),
        ("Draw", "Once every tile is placed in real words, draw another from the bag."),
        ("Swap", "Stuck with a tricky letter? Select it and swap it for three from the bag."),
        ("Finish", "Use every tile in the bag in one valid grid to clear the storm."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How to Play")
                .font(GameFont.display(32, relativeTo: .largeTitle))
                .accessibilityAddTraits(.isHeader)
            ForEach(Self.rules, id: \.title) { rule in
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.title).font(GameFont.display(20, relativeTo: .headline))
                    Text(rule.detail).font(GameFont.ui(16, .medium)).opacity(0.8)
                }
            }
            Spacer(minLength: 0)
            Button { dismiss() } label: { Text("Got It").frame(maxWidth: .infinity) }
                .buttonStyle(GameButtonStyle(kind: .primary))
        }
        .foregroundStyle(Color.cocoa)
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.parchment.ignoresSafeArea())
        .presentationDetents([.large])
    }
}

private extension Bundle {
    var shortVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }
}
