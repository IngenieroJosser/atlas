import SwiftUI

enum AtlasColor {
    // Base
    static let void = Color(hex: "05070A")
    static let voidSoft = Color(hex: "090D12")
    static let graphite = Color(hex: "0F151D")
    static let graphite2 = Color(hex: "151D27")
    static let graphite3 = Color(hex: "1C2734")

    // Typography
    static let porcelain = Color(hex: "F7F3EA")
    static let porcelainSoft = Color(hex: "D8D5CF")
    static let smoke = Color(hex: "8E99A7")
    static let smokeDark = Color(hex: "5E6875")

    // Signals
    static let electric = Color(hex: "5C8DFF")
    static let electricBright = Color(hex: "91B7FF")
    static let aqua = Color(hex: "9DEBD9")
    static let amber = Color(hex: "FFB66E")
    static let coral = Color(hex: "FF7F8E")
    static let lime = Color(hex: "C9F79F")
    static let violet = Color(hex: "AF9BFF")

    static let border = Color.white.opacity(0.085)
    static let borderStrong = Color.white.opacity(0.15)
    static let shadow = Color.black.opacity(0.34)
}

enum AtlasType {
    /// Editorial display face. On iOS this uses the native system serif family.
    static func display(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// SF Pro system face for product/UI copy.
    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Rounded system face for compact controls and numbers.
    static func rounded(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// SF Mono-like native design for telemetry and metadata.
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct AtlasBackdrop: View {
    var body: some View {
        ZStack {
            AtlasColor.void

            LinearGradient(
                colors: [
                    AtlasColor.graphite.opacity(0.82),
                    AtlasColor.void,
                    AtlasColor.voidSoft
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [AtlasColor.electric.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 380
            )
            .offset(x: 110, y: -120)

            RadialGradient(
                colors: [AtlasColor.aqua.opacity(0.055), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 360
            )
            .offset(x: -80, y: 120)
        }
        .ignoresSafeArea()
    }
}

struct AtlasPage<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AtlasBackdrop()
            content
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AtlasHairline: View {
    var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(AtlasColor.border.opacity(opacity))
            .frame(height: 1)
    }
}

struct AtlasGlass<Content: View>: View {
    let radius: CGFloat
    let padding: CGFloat
    private let content: Content

    init(radius: CGFloat = 26, padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.065), Color.white.opacity(0.022)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AtlasColor.border, lineWidth: 1)
            )
    }
}

struct AtlasTag: View {
    let text: String
    var tint: Color = AtlasColor.electric
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text.uppercased())
                .font(AtlasType.mono(9, weight: .semibold))
                .tracking(0.8)
        }
        .foregroundStyle(AtlasColor.porcelain)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tint.opacity(0.11))
        .overlay(Capsule().stroke(tint.opacity(0.32), lineWidth: 1))
        .clipShape(Capsule())
    }
}

struct AtlasKicker: View {
    let index: String
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Text(index)
                .font(AtlasType.mono(9, weight: .bold))
                .foregroundStyle(AtlasColor.electricBright)

            Text(title.uppercased())
                .font(AtlasType.mono(9, weight: .semibold))
                .tracking(1.3)
                .foregroundStyle(AtlasColor.smoke)

            Spacer()

            if let trailing {
                Text(trailing.uppercased())
                    .font(AtlasType.mono(8.5, weight: .medium))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.smokeDark)
            }
        }
    }
}

struct AtlasScreenHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil
    var backAction: (() -> Void)? = nil
    var trailingSymbol: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                if let backAction {
                    Button(action: backAction) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasColor.porcelain)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.white.opacity(0.055)))
                            .overlay(Circle().stroke(AtlasColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Text(eyebrow.uppercased())
                    .font(AtlasType.mono(9, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasColor.smoke)

                Spacer()

                if let trailingSymbol, let trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: trailingSymbol)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AtlasColor.porcelain)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.white.opacity(0.055)))
                            .overlay(Circle().stroke(AtlasColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(title)
                .font(AtlasType.display(42, weight: .medium))
                .tracking(-1.35)
                .foregroundStyle(AtlasColor.porcelain)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(AtlasType.ui(14.5, weight: .regular))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(4)
            }
        }
    }
}

struct AtlasPrimaryButton: View {
    let title: String
    var symbol: String = "arrow.right"
    var tint: Color = AtlasColor.porcelain
    var foreground: Color = AtlasColor.void
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(AtlasType.ui(15, weight: .semibold))
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, 18)
            .frame(height: 54)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(tint))
        }
        .buttonStyle(.plain)
    }
}

struct AtlasSecondaryButton: View {
    let title: String
    var symbol: String = "arrow.right"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(AtlasType.ui(14.5, weight: .semibold))
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(AtlasColor.porcelain)
            .padding(.horizontal, 17)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Color.white.opacity(0.045)))
            .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct AtlasIconButton: View {
    let symbol: String
    var tint: Color = AtlasColor.porcelain
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white.opacity(0.05)))
                .overlay(Circle().stroke(AtlasColor.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
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

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
