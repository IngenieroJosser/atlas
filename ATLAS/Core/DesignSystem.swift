import SwiftUI

enum AtlasColor {
    // Palette preserved from ATLAS v9.
    static let void = Color(hex: "F5F7FB")
    static let voidSoft = Color(hex: "EDF1F7")
    static let graphite = Color(hex: "FFFFFF")
    static let graphite2 = Color(hex: "F7F9FC")
    static let graphite3 = Color(hex: "E8EEF7")

    static let porcelain = Color(hex: "101828")
    static let porcelainSoft = Color(hex: "344054")
    static let smoke = Color(hex: "667085")
    static let smokeDark = Color(hex: "98A2B3")

    static let electric = Color(hex: "315CF6")
    static let electricBright = Color(hex: "4F6BFF")
    static let aqua = Color(hex: "16A085")
    static let amber = Color(hex: "E89A20")
    static let coral = Color(hex: "E5484D")
    static let lime = Color(hex: "2FB171")
    static let violet = Color(hex: "7A5AF8")

    static let border = Color.black.opacity(0.07)
    static let borderStrong = Color.black.opacity(0.14)
    static let shadow = Color(hex: "182230").opacity(0.07)

    static let cobaltWash = Color(hex: "EAF0FF")
    static let mintWash = Color(hex: "EAF8F5")
    static let amberWash = Color(hex: "FFF6E8")
    static let violetWash = Color(hex: "F1EEFF")
}

enum AtlasType {
    // SF Pro Display-like hierarchy: deliberately not rounded.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func rounded(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch sanitized.count {
        case 8:
            red = (value >> 24) & 0xFF
            green = (value >> 16) & 0xFF
            blue = (value >> 8) & 0xFF
            alpha = value & 0xFF
        default:
            red = (value >> 16) & 0xFF
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 0xFF
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

struct AtlasBackdrop: View {
    var body: some View {
        ZStack(alignment: .top) {
            AtlasColor.void

            LinearGradient(
                colors: [AtlasColor.cobaltWash.opacity(0.70), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)
            .ignoresSafeArea(edges: .top)
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
        .preferredColorScheme(.light)
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

    init(radius: CGFloat = 18, padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AtlasColor.graphite)
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
                    .font(.system(size: 9.5, weight: .semibold))
            }
            Text(text.uppercased())
                .font(AtlasType.mono(8, weight: .semibold))
                .tracking(0.55)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct AtlasKicker: View {
    let index: String
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 7) {
            Text("(\(index))")
                .font(AtlasType.mono(8.5, weight: .bold))
                .foregroundStyle(AtlasColor.electric)

            Text("/")
                .font(AtlasType.mono(8.5, weight: .medium))
                .foregroundStyle(AtlasColor.smokeDark)

            Text(title.uppercased())
                .font(AtlasType.ui(9.5, weight: .semibold))
                .tracking(1.0)
                .foregroundStyle(AtlasColor.smoke)

            Spacer()

            if let trailing {
                Text(trailing.uppercased())
                    .font(AtlasType.mono(8, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(AtlasColor.smokeDark)
            }
        }
    }
}

struct AtlasEditorialHeading: View {
    let kicker: String
    let title: String
    var detail: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(kicker.uppercased())
                .font(AtlasType.mono(8.5, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.electric)

            Text(title)
                .font(AtlasType.display(30, weight: .bold))
                .tracking(-0.9)
                .foregroundStyle(AtlasColor.porcelain)
                .fixedSize(horizontal: false, vertical: true)

            if let detail {
                Text(detail)
                    .font(AtlasType.ui(13.5))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(3)
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
            HStack(spacing: 10) {
                if let backAction {
                    Button(action: backAction) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AtlasColor.porcelain)
                            .frame(width: 38, height: 38)
                            .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(AtlasColor.graphite))
                            .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Text(eyebrow.uppercased())
                    .font(AtlasType.mono(8.5, weight: .bold))
                    .tracking(0.9)
                    .foregroundStyle(AtlasColor.smoke)

                Spacer()

                if let trailingSymbol, let trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: trailingSymbol)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AtlasColor.porcelain)
                            .frame(width: 38, height: 38)
                            .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(AtlasColor.graphite))
                            .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(title)
                .font(AtlasType.display(36, weight: .bold))
                .tracking(-1.25)
                .foregroundStyle(AtlasColor.porcelain)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(AtlasType.ui(14, weight: .regular))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(3)
            }
        }
    }
}

struct AtlasPrimaryButton: View {
    let title: String
    var symbol: String = "arrow.right"
    var tint: Color = AtlasColor.electric
    var foreground: Color = .white
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
            .foregroundStyle(foreground)
            .padding(.horizontal, 17)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(tint))
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
                    .font(AtlasType.ui(14, weight: .semibold))
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 12.5, weight: .semibold))
            }
            .foregroundStyle(AtlasColor.porcelain)
            .padding(.horizontal, 17)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AtlasColor.graphite))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AtlasColor.borderStrong, lineWidth: 1))
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(AtlasColor.graphite))
                .overlay(RoundedRectangle(cornerRadius: 11, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
