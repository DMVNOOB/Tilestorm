import SwiftUI
import TileEngine

/// Switches between the title screen and a game.
struct ContentView: View {
    private enum Screen {
        case title, game
    }

    @State private var game = Game()
    @State private var screen: Screen = Self.initialScreen

    var body: some View {
        ZStack {
            switch screen {
            case .title:
                TitleView(onPlay: { start(SoloGame()) })
                    .transition(.opacity)
            case .game:
                GameView(game: game, onStart: start, onQuit: { show(.title) })
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.light)
    }

    private func start(_ state: SoloGame) {
        game.start(state)
        show(.game)
    }

    private func show(_ next: Screen) {
        withAnimation(.easeInOut(duration: 0.25)) { screen = next }
    }

    /// Debug launches with `-scenario` go straight into the game.
    private static var initialScreen: Screen {
        #if DEBUG
        if Scenario.fromLaunchArguments != nil { return .game }
        #endif
        return .title
    }
}

#Preview {
    ContentView()
}
