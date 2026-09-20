import SwiftUI

struct AtlasMark: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .stroke(AtlasColor.borderStrong, lineWidth: 1)
                )

            Path { path in
                let c = size * 0.5
                let top = CGPoint(x: c, y: size * 0.22)
                let left = CGPoint(x: size * 0.26, y: size * 0.69)
                let right = CGPoint(x: size * 0.74, y: size * 0.69)
                let mid = CGPoint(x: c, y: size * 0.54)

                path.move(to: top)
                path.addLine(to: left)
                path.move(to: top)
                path.addLine(to: right)
                path.move(to: left)
                path.addLine(to: mid)
                path.addLine(to: right)
            }
            .stroke(
                LinearGradient(
                    colors: [AtlasColor.aqua, AtlasColor.electricBright],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(
                    lineWidth: max(1.4, size * 0.047),
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            Circle()
                .fill(AtlasColor.porcelain)
                .frame(width: max(3.5, size * 0.10), height: max(3.5, size * 0.10))
                .offset(y: size * 0.24)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("ATLAS")
    }
}

struct AtlasWorldLens: View {
    @State private var breathe = false

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let minSide = min(w, h)

            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AtlasColor.graphite2, AtlasColor.voidSoft],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RadialGradient(
                    colors: [AtlasColor.electric.opacity(0.20), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: minSide * 0.52
                )
                .scaleEffect(breathe ? 1.05 : 0.95)

                WorldGrid()
                    .opacity(0.30)
                    .padding(18)

                Circle()
                    .stroke(AtlasColor.electric.opacity(0.22), lineWidth: 1)
                    .frame(width: minSide * 0.62, height: minSide * 0.62)
                    .scaleEffect(breathe ? 1.03 : 0.96)

                Circle()
                    .stroke(AtlasColor.aqua.opacity(0.20), lineWidth: 1)
                    .frame(width: minSide * 0.44, height: minSide * 0.44)
                    .scaleEffect(breathe ? 0.96 : 1.03)

                AtlasWireframeObject()
                    .frame(width: minSide * 0.46, height: minSide * 0.46)
                    .shadow(color: AtlasColor.electric.opacity(0.18), radius: 28)

                scanReticle(width: w, height: h)

                VStack {
                    HStack {
                        AtlasTag(text: "MUNDO 01", tint: AtlasColor.electric, symbol: "viewfinder")
                        Spacer()
                        AtlasTag(text: "EN VIVO", tint: AtlasColor.aqua, symbol: "dot.radiowaves.left.and.right")
                    }
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("APARTAMENTO NORTE")
                                .font(AtlasType.mono(9, weight: .bold))
                                .tracking(1.1)
                                .foregroundStyle(AtlasColor.smoke)
                            Text("84,2 m²")
                                .font(AtlasType.rounded(24, weight: .bold))
                                .foregroundStyle(AtlasColor.porcelain)
                        }

                        Spacer()

                        Image(systemName: "cube.transparent")
                            .font(.system(size: 19, weight: .medium))
                            .foregroundStyle(AtlasColor.porcelainSoft)
                    }
                }
                .padding(18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(AtlasColor.border, lineWidth: 1)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
        }
    }

    private func scanReticle(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ReticleCorner().position(x: 30, y: 30)
            ReticleCorner().rotationEffect(.degrees(90)).position(x: width - 30, y: 30)
            ReticleCorner().rotationEffect(.degrees(270)).position(x: 30, y: height - 30)
            ReticleCorner().rotationEffect(.degrees(180)).position(x: width - 30, y: height - 30)
        }
    }
}

private struct ReticleCorner: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 18))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 18, y: 0))
        }
        .stroke(AtlasColor.electricBright, style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
        .frame(width: 18, height: 18)
    }
}

private struct WorldGrid: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            Path { path in
                for i in 0...6 {
                    let y = h * CGFloat(i) / 6
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: w, y: y))
                }
                for i in 0...6 {
                    let x = w * CGFloat(i) / 6
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: h))
                }
            }
            .stroke(Color.white.opacity(0.08), lineWidth: 0.7)
        }
    }
}

private struct AtlasWireframeObject: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let a = CGPoint(x: w * 0.23, y: h * 0.35)
            let b = CGPoint(x: w * 0.55, y: h * 0.18)
            let c = CGPoint(x: w * 0.78, y: h * 0.34)
            let d = CGPoint(x: w * 0.47, y: h * 0.52)
            let a2 = CGPoint(x: w * 0.23, y: h * 0.64)
            let c2 = CGPoint(x: w * 0.78, y: h * 0.63)
            let d2 = CGPoint(x: w * 0.47, y: h * 0.82)

            ZStack {
                Path { path in
                    path.move(to: a); path.addLine(to: b); path.addLine(to: c); path.addLine(to: d); path.closeSubpath()
                    path.move(to: a); path.addLine(to: a2); path.addLine(to: d2); path.addLine(to: d)
                    path.move(to: c); path.addLine(to: c2); path.addLine(to: d2)
                    path.move(to: a2); path.addLine(to: d2); path.addLine(to: c2)
                }
                .stroke(
                    LinearGradient(colors: [AtlasColor.aqua, AtlasColor.electricBright], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round)
                )

                Circle().fill(AtlasColor.porcelain).frame(width: 7, height: 7).position(b)
                Circle().fill(AtlasColor.aqua).frame(width: 6, height: 6).position(a2)
            }
        }
    }
}
