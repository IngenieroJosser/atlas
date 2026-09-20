import SwiftUI
import UIKit

enum AtlasColor {
    static let background = adaptive(light: "F6F8FB", dark: "07111F")
    static let surface = adaptive(light: "FFFFFF", dark: "0B1728")
    static let surfaceSecondary = adaptive(light: "EEF3F8", dark: "0F2035")
    static let surfaceStrong = adaptive(light: "E2E9F1", dark: "152A44")

    static let ink = adaptive(light: "0C1728", dark: "F5F8FC")
    static let inkSecondary = adaptive(light: "405064", dark: "BBC7D6")
    static let inkMuted = adaptive(light: "728195", dark: "7F91A8")
    static let line = adaptive(light: "DDE4EC", dark: "20344B")
    static let lineStrong = adaptive(light: "C7D1DD", dark: "304A65")

    static let navy = Color(hex: "0B1F36")
    static let blue = Color(hex: "2F6BFF")
    static let blueStrong = Color(hex: "1951D9")
    static let blueSoft = adaptive(light: "EAF0FF", dark: "13274C")
    static let blueGray = Color(hex: "6E819B")

    static let healthy = Color(hex: "2E9D69")
    static let attention = Color(hex: "D49A24")
    static let warning = Color(hex: "D97706")
    static let critical = Color(hex: "CC3A48")
    static let info = Color(hex: "2F6BFF")

    static let local = Color(hex: "5E6E82")
    static let syncing = Color(hex: "6F59D9")

    private static func adaptive(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

enum AtlasType {
    // Manrope-like role: strong, geometric, editorial headings using system rounded.
    static func display(_ style: Font.TextStyle = .largeTitle, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

    static func heading(_ style: Font.TextStyle = .title2, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

    // Geist-like role: neutral system UI face.
    static func body(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .default, weight: weight)
    }

    static func label(_ style: Font.TextStyle = .caption, weight: Font.Weight = .semibold) -> Font {
        .system(style, design: .default, weight: weight)
    }

    static func mono(_ style: Font.TextStyle = .caption2, weight: Font.Weight = .medium) -> Font {
        .system(style, design: .monospaced, weight: weight)
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let r: UInt64
        let g: UInt64
        let b: UInt64
        let a: UInt64
        switch sanitized.count {
        case 8:
            r = (value >> 24) & 0xFF
            g = (value >> 16) & 0xFF
            b = (value >> 8) & 0xFF
            a = value & 0xFF
        default:
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            a = 0xFF
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8) & 0xFF) / 255
        let b = CGFloat(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

struct AtlasPage<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            AtlasColor.background.ignoresSafeArea()
            content
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AtlasDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasColor.line)
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

struct AtlasSurface<Content: View>: View {
    var inset: CGFloat = 18
    var radius: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(inset)
            .background(AtlasColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AtlasColor.line, lineWidth: 1)
            }
    }
}

struct AtlasSectionLabel: View {
    let index: String
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("(\(index))")
                .font(AtlasType.mono(.caption2, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)

            Text("/ \(title.uppercased())")
                .font(AtlasType.label(.caption, weight: .semibold))
                .tracking(0.9)
                .foregroundStyle(AtlasColor.inkMuted)

            Spacer(minLength: 12)

            if let trailing {
                Text(trailing.uppercased())
                    .font(AtlasType.mono(.caption2))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct AtlasEditorialHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil
    var backAction: (() -> Void)? = nil
    var trailingSymbol: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                if let backAction {
                    Button(action: backAction) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Volver")
                }

                Text(eyebrow.uppercased())
                    .font(AtlasType.label(.caption, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(AtlasColor.inkMuted)

                Spacer()

                if let trailingSymbol, let trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: trailingSymbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(title)
                .font(AtlasType.display(.largeTitle, weight: .semibold))
                .tracking(-1.0)
                .foregroundStyle(AtlasColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            if let subtitle {
                Text(subtitle)
                    .font(AtlasType.body(.body))
                    .foregroundStyle(AtlasColor.inkSecondary)
                    .lineSpacing(4)
            }
        }
    }
}

struct AtlasPrimaryButton: View {
    let title: String
    var symbol: String = "arrow.right"
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(AtlasType.body(.body, weight: .semibold))
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(minHeight: 52)
            .background(isDisabled ? AtlasColor.blueGray : AtlasColor.blue)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct AtlasSecondaryButton: View {
    let title: String
    var symbol: String = "arrow.right"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(AtlasType.body(.body, weight: .semibold))
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(AtlasColor.ink)
            .padding(.horizontal, 18)
            .frame(minHeight: 52)
            .background(AtlasColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(AtlasColor.lineStrong, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
