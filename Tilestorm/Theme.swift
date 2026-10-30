import CoreText
import SwiftUI

// Colours and type from the Figma design ("Tilestorm — Game Design").

extension Color {
    static let parchment = Color(hex: 0xF6EBD3)
    static let sand = Color(hex: 0xEAD7B0)
    static let tan = Color(hex: 0xC9A06B)
    static let toffee = Color(hex: 0x9C6B3C)
    static let cocoa = Color(hex: 0x4A2F1B)
    static let cream = Color(hex: 0xFFF6E0)
    static let butter = Color(hex: 0xFFE48A)
    static let honey = Color(hex: 0xF4C542)
    static let mustard = Color(hex: 0xE0A526)
    static let terracotta = Color(hex: 0xD2553A)
    static let sage = Color(hex: 0x7A9A45)

    // Raised edges and outlines
    static let tileEdge = Color(hex: 0xD9B77E)
    static let tileOutline = Color(hex: 0xE8D3A8)
    static let honeyEdge = Color(hex: 0xC98E1C)
    static let disabledEdge = Color(hex: 0xD6C7A6)

    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum GameFont {
    /// Fredoka weights, by PostScript name.
    enum Weight: String {
        case medium = "FredokaLight-Medium"
        case semibold = "FredokaLight-SemiBold"
        case bold = "FredokaLight-Bold"
    }

    /// Lilita One: chunky display type for the logo, headings, and buttons.
    static func display(_ size: CGFloat, relativeTo style: Font.TextStyle = .title) -> Font {
        .custom("LilitaOne", size: size, relativeTo: style)
    }

    /// Fredoka: rounded type for tiles and body text.
    static func ui(_ size: CGFloat, _ weight: Weight = .semibold, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(weight.rawValue, size: size, relativeTo: style)
    }

    /// Tile letters scale with the tile, not with Dynamic Type.
    static func tile(_ size: CGFloat) -> Font {
        .custom(Weight.bold.rawValue, fixedSize: size)
    }

    /// Registers the bundled .ttf files for this process. Call once at launch.
    static func registerBundledFonts() {
        for url in Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [] {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

/// The chunky "physical piece" look: a face sitting on a darker edge, with a soft shadow below.
struct RaisedBackground: View {
    var face: Color
    var edge: Color
    var lift: CGFloat
    var cornerRadius: CGFloat
    var outline: Color? = nil
    var outlineWidth: CGFloat = 0
    var castsShadow = true

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        ZStack {
            shape.fill(edge).offset(y: lift)
            shape.fill(face.shadow(.inner(color: .white.opacity(0.6), radius: 0, y: 2)))
            if let outline {
                shape.strokeBorder(outline, lineWidth: outlineWidth)
            }
        }
        .compositingGroup()
        .shadow(color: .cocoa.opacity(castsShadow ? 0.18 : 0), radius: 5, y: lift + 3)
    }
}
