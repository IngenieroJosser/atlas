import SwiftUI
import UIKit

enum AtlasColor {
    // Editorial canvas: calm neutral background + precise high-contrast surfaces.
    static let background = adaptive(light: "F4F6F8", dark: "06101B")
    static let surface = adaptive(light: "FFFFFF", dark: "0A1624")
    static let surfaceSecondary = adaptive(light: "EDF1F5", dark: "0E1D2E")
    static let surfaceStrong = adaptive(light: "E3E8EE", dark: "14283E")

    static let ink = adaptive(light: "0A1420", dark: "F6F8FB")
    static let inkSecondary = adaptive(light: "435365", dark: "C0CAD6")
    static let inkMuted = adaptive(light: "788695", dark: "8090A4")
    static let line = adaptive(light: "DCE2E8", dark: "20344A")
    static let lineStrong = adaptive(light: "C8D0D9", dark: "314A63")

    static let navy = Color(hex: "0A1D33")
    static let navyRaised = Color(hex: "102A47")
    static let blue = Color(hex: "2D63FF")
    static let blueStrong = Color(hex: "1B4FD9")
    static let blueSoft = adaptive(light: "E8EEFF", dark: "142850")
    static let blueWash = adaptive(light: "F1F4FF", dark: "0E2141")
    static let blueGray = Color(hex: "71829A")

    static let healthy = Color(hex: "238B5B")
    static let attention = Color(hex: "C48A1D")
    static let warning = Color(hex: "D66B16")
    static let critical = Color(hex: "C83C4B")
    static let info = blue

    static let local = Color(hex: "68778A")
    static let syncing = Color(hex: "6E5CC8")

    private static func adaptive(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
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
        .atlasScreenEntrance()
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
    var radius: CGFloat = 16
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
        HStack(alignment: .center, spacing: 9) {
            Text(index.count <= 2 ? "(\(index))" : index)
                .font(AtlasType.mono(.caption2, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)

            Text("/ \(title.uppercased())")
                .font(AtlasType.label(.caption, weight: .semibold))
                .tracking(0.75)
                .foregroundStyle(AtlasColor.inkSecondary)

            Rectangle()
                .fill(AtlasColor.line)
                .frame(height: 1)
                .padding(.leading, 2)

            if let trailing {
                Text(trailing.uppercased())
                    .font(AtlasType.mono(.caption2, weight: .medium))
                    .foregroundStyle(AtlasColor.inkMuted)
                    .lineLimit(1)
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
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                if let backAction {
                    Button(action: backAction) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(AtlasCompactPressButtonStyle())
                    .accessibilityLabel("Volver")
                }

                Text(eyebrow.uppercased())
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .tracking(1.15)
                    .foregroundStyle(AtlasColor.blue)

                Spacer()

                if let trailingSymbol, let trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: trailingSymbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(AtlasCompactPressButtonStyle())
                }
            }
            .atlasStagger(0, distance: 5)

            Text(title)
                .font(AtlasType.display(.largeTitle, weight: .semibold))
                .tracking(-1.25)
                .foregroundStyle(AtlasColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .atlasStagger(1, distance: 8)

            if let subtitle {
                Text(subtitle)
                    .font(AtlasType.body(.body, weight: .regular))
                    .foregroundStyle(AtlasColor.inkSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .atlasStagger(2, distance: 7)
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
            .frame(minHeight: 54)
            .background(isDisabled ? AtlasColor.blueGray : AtlasColor.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(AtlasPressButtonStyle())
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
            .frame(minHeight: 54)
            .background(AtlasColor.surface)
            .overlay(alignment: .bottom) {
                Rectangle().fill(AtlasColor.lineStrong).frame(height: 1)
            }
        }
        .buttonStyle(AtlasPressButtonStyle())
    }
}
