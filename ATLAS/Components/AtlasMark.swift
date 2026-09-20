import SwiftUI

struct AtlasMark: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
                .fill(AtlasColor.electric)

            Path { path in
                let c = size * 0.5
                let top = CGPoint(x: c, y: size * 0.22)
                let left = CGPoint(x: size * 0.28, y: size * 0.68)
                let right = CGPoint(x: size * 0.72, y: size * 0.68)
                let mid = CGPoint(x: c, y: size * 0.53)

                path.move(to: top)
                path.addLine(to: left)
                path.move(to: top)
                path.addLine(to: right)
                path.move(to: left)
                path.addLine(to: mid)
                path.addLine(to: right)
            }
            .stroke(
                Color.white,
                style: StrokeStyle(
                    lineWidth: max(1.5, size * 0.05),
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            Circle()
                .fill(AtlasColor.aqua)
                .frame(width: max(3.2, size * 0.095), height: max(3.2, size * 0.095))
                .offset(y: size * 0.22)
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
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AtlasColor.graphite)

                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Text("ATLAS / WORLD OS")
                            .font(AtlasType.mono(8.2, weight: .bold))
                            .tracking(0.7)
                            .foregroundStyle(AtlasColor.porcelain)

                        Spacer()

                        Circle()
                            .fill(AtlasColor.aqua)
                            .frame(width: 6, height: 6)
                        Text("LIVE PREVIEW")
                            .font(AtlasType.mono(7.7, weight: .semibold))
                            .tracking(0.45)
                            .foregroundStyle(AtlasColor.smoke)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)

                    AtlasHairline()

                    ZStack {
                        LinearGradient(
                            colors: [AtlasColor.graphite2, AtlasColor.cobaltWash.opacity(0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        WorldGrid()
                            .opacity(0.45)
                            .padding(14)

                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("ESTADO ACTUAL")
                                    .font(AtlasType.mono(7.8, weight: .bold))
                                    .tracking(0.55)
                                    .foregroundStyle(AtlasColor.smoke)
                                Text("92")
                                    .font(AtlasType.display(48, weight: .bold))
                                    .tracking(-2)
                                    .foregroundStyle(AtlasColor.porcelain)
                                Text("SALUD / 100")
                                    .font(AtlasType.mono(7.8, weight: .semibold))
                                    .foregroundStyle(AtlasColor.aqua)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.72))
                                    .frame(width: minSide * 0.50, height: minSide * 0.50)
                                AtlasWireframeObject()
                                    .frame(width: minSide * 0.36, height: minSide * 0.36)
                                    .scaleEffect(breathe ? 1.02 : 0.97)
                            }
                        }
                        .padding(18)
                    }

                    AtlasHairline()

                    HStack(spacing: 0) {
                        LensMetric(value: "84,2", label: "M²")
                        LensDivider()
                        LensMetric(value: "07", label: "ESPACIOS")
                        LensDivider()
                        LensMetric(value: "02", label: "ATENCIÓN", tint: AtlasColor.amber)
                    }
                    .frame(height: 58)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AtlasColor.border, lineWidth: 1)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                    breathe = true
                }
            }
        }
    }
}

private struct LensMetric: View {
    let value: String
    let label: String
    var tint: Color = AtlasColor.electric

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(AtlasType.ui(14, weight: .bold))
                .foregroundStyle(AtlasColor.porcelain)
            Text(label)
                .font(AtlasType.mono(7.2, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }
}

private struct LensDivider: View {
    var body: some View {
        Rectangle()
            .fill(AtlasColor.border)
            .frame(width: 1, height: 28)
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
            .stroke(AtlasColor.electric.opacity(0.075), lineWidth: 0.7)
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
                    LinearGradient(colors: [AtlasColor.aqua, AtlasColor.electric], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round)
                )

                Circle().fill(AtlasColor.electric).frame(width: 6, height: 6).position(b)
                Circle().fill(AtlasColor.aqua).frame(width: 5, height: 5).position(a2)
            }
        }
    }
}
