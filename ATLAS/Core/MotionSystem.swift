import SwiftUI
import UIKit

// MARK: - Motion language

enum AtlasMotion {
    static let micro: Double = 0.14
    static let fast: Double = 0.20
    static let standard: Double = 0.34
    static let deliberate: Double = 0.48

    static let standardAnimation = Animation.easeOut(duration: standard)
    static let fastAnimation = Animation.easeOut(duration: fast)
    static let softSpring = Animation.spring(response: 0.34, dampingFraction: 0.86, blendDuration: 0.08)
    static let firmSpring = Animation.spring(response: 0.28, dampingFraction: 0.78, blendDuration: 0.06)
}

@MainActor
enum AtlasHaptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

// MARK: - Screen entrance

private struct AtlasScreenEntranceModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let distance: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion || isVisible ? 1 : 0)
            .offset(y: reduceMotion || isVisible ? 0 : distance)
            .onAppear {
                guard !isVisible else { return }
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(AtlasMotion.standardAnimation) {
                        isVisible = true
                    }
                }
            }
    }
}

private struct AtlasStaggerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    let index: Int
    let distance: CGFloat
    let baseDelay: Double

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion || isVisible ? 1 : 0)
            .offset(y: reduceMotion || isVisible ? 0 : distance)
            .onAppear {
                guard !isVisible else { return }
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(
                        .easeOut(duration: AtlasMotion.standard)
                            .delay(Double(index) * baseDelay)
                    ) {
                        isVisible = true
                    }
                }
            }
    }
}

private struct AtlasScaleRevealModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion || isVisible ? 1 : 0)
            .scaleEffect(reduceMotion || isVisible ? 1 : 0.965)
            .onAppear {
                guard !isVisible else { return }
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(AtlasMotion.softSpring) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func atlasScreenEntrance(distance: CGFloat = 12) -> some View {
        modifier(AtlasScreenEntranceModifier(distance: distance))
    }

    func atlasStagger(_ index: Int, distance: CGFloat = 10, baseDelay: Double = 0.045) -> some View {
        modifier(AtlasStaggerModifier(index: index, distance: distance, baseDelay: baseDelay))
    }

    func atlasScaleReveal() -> some View {
        modifier(AtlasScaleRevealModifier())
    }
}

// MARK: - Interaction styles

struct AtlasPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(reduceMotion ? nil : AtlasMotion.fastAnimation, value: configuration.isPressed)
    }
}

struct AtlasCompactPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
            .animation(reduceMotion ? nil : AtlasMotion.firmSpring, value: configuration.isPressed)
    }
}

// MARK: - Loading-only shimmer

private struct AtlasShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    GeometryReader { proxy in
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.34), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: max(proxy.size.width * 0.45, 80))
                        .rotationEffect(.degrees(18))
                        .offset(x: phase * proxy.size.width * 1.7)
                    }
                    .allowsHitTesting(false)
                    .mask(content)
                }
            }
            .onAppear {
                guard !reduceMotion else { return }
                phase = -1
                withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func atlasShimmer() -> some View {
        modifier(AtlasShimmerModifier())
    }
}

// MARK: - Reusable motion primitives

struct AtlasAnimatedCheckmark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false

    var color: Color = AtlasColor.healthy
    var size: CGFloat = 22

    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(color)
            .scaleEffect(reduceMotion || visible ? 1 : 0.55)
            .opacity(reduceMotion || visible ? 1 : 0)
            .onAppear {
                if reduceMotion {
                    visible = true
                } else {
                    withAnimation(AtlasMotion.firmSpring) { visible = true }
                }
            }
    }
}

struct AtlasProcessingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double = 0

    var color: Color = AtlasColor.blue
    var size: CGFloat = 20

    var body: some View {
        Circle()
            .trim(from: 0.08, to: 0.78)
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            .accessibilityHidden(true)
    }
}
