import CoreText
import SwiftUI
import UIKit

enum AtlasFontRegistry {
    private static let bundledFonts = [
        "Manrope-VariableFont_wght",
        "Geist-VariableFont_wght"
    ]

    static func registerBundledFonts() {
        for fileName in bundledFonts {
            let urls = [
                Bundle.main.url(forResource: fileName, withExtension: "ttf", subdirectory: "Resources/Fonts"),
                Bundle.main.url(forResource: fileName, withExtension: "ttf")
            ]

            guard let url = urls.compactMap({ $0 }).first else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func hasFamily(_ family: String) -> Bool {
        UIFont.familyNames.contains { $0.caseInsensitiveCompare(family) == .orderedSame }
    }
}

enum AtlasType {
    static func display(_ style: Font.TextStyle = .largeTitle, weight: Font.Weight = .semibold) -> Font {
        custom(
            family: "Manrope",
            style: style,
            weight: weight,
            fallbackDesign: .rounded
        )
    }

    static func heading(_ style: Font.TextStyle = .title2, weight: Font.Weight = .semibold) -> Font {
        custom(
            family: "Manrope",
            style: style,
            weight: weight,
            fallbackDesign: .rounded
        )
    }

    static func body(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        custom(
            family: "Geist",
            style: style,
            weight: weight,
            fallbackDesign: .default
        )
    }

    static func label(_ style: Font.TextStyle = .caption, weight: Font.Weight = .medium) -> Font {
        custom(
            family: "Geist",
            style: style,
            weight: weight,
            fallbackDesign: .default
        )
    }

    static func mono(_ style: Font.TextStyle = .caption2, weight: Font.Weight = .medium) -> Font {
        .system(style, design: .monospaced, weight: weight)
    }

    private static func custom(
        family: String,
        style: Font.TextStyle,
        weight: Font.Weight,
        fallbackDesign: Font.Design
    ) -> Font {
        guard AtlasFontRegistry.hasFamily(family) else {
            return .system(style, design: fallbackDesign, weight: weight)
        }

        return .custom(
            family,
            size: baseSize(for: style),
            relativeTo: style
        )
        .weight(weight)
    }

    private static func baseSize(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: return 40
        case .title: return 32
        case .title2: return 25
        case .title3: return 21
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 17
        }
    }
}
