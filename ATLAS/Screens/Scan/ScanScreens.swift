import SwiftUI
import UIKit

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: ScanStep = .intro
    @State private var mode: ScanMode = .space
    @State private var progress: Double = 0.12

    var body: some View {
        ZStack {
            switch step {
            case .intro:
                AtlasBackdrop()
                ScanIntroView(
                    mode: $mode,
                    start: { withAnimation(.easeInOut(duration: 0.22)) { step = .capture } },
                    close: { dismiss() }
                )
            case .capture:
                ScanCaptureView(
                    mode: mode,
                    progress: $progress,
                    finish: { withAnimation(.easeInOut(duration: 0.22)) { step = .processing } },
                    close: { dismiss() }
                )
            case .processing:
                AtlasBackdrop()
                ScanProcessingView(continueAction: { withAnimation(.easeInOut(duration: 0.22)) { step = .result } })
            case .result:
                AtlasBackdrop()
                ScanResultView(close: { dismiss() })
            }
        }
        .preferredColorScheme(step == .capture ? .dark : .light)
    }
}

private struct ScanIntroView: View {
    @Binding var mode: ScanMode
    let start: () -> Void
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                AtlasTag(text: "Nuevo escaneo", tint: AtlasColor.electric, symbol: "camera.viewfinder")
                Spacer()
                AtlasIconButton(symbol: "xmark", action: close)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text("Apunta. Captura. Entiende.")
                    .font(AtlasType.display(43, weight: .bold))
                    .tracking(-1.3)
                    .foregroundStyle(AtlasColor.porcelain)

                Text("ATLAS usará la cámara del iPhone para capturar evidencia real. Elige el tipo de elemento que vas a analizar.")
                    .font(AtlasType.ui(15))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(3)
            }

            VStack(spacing: 10) {
                ForEach(ScanMode.allCases) { item in
                    Button { mode = item } label: {
                        HStack(spacing: 14) {
                            Image(systemName: item.symbol)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(mode == item ? .white : AtlasColor.electric)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(mode == item ? AtlasColor.electric : AtlasColor.cobaltWash)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.rawValue)
                                    .font(AtlasType.ui(15, weight: .semibold))
                                    .foregroundStyle(AtlasColor.porcelain)
                                Text(modeDescription(item))
                                    .font(AtlasType.ui(12.5))
                                    .foregroundStyle(AtlasColor.smoke)
                            }
                            Spacer()
                            Image(systemName: mode == item ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(mode == item ? AtlasColor.electric : AtlasColor.smokeDark)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 20).fill(AtlasColor.graphite))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(mode == item ? AtlasColor.electric.opacity(0.30) : AtlasColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            AtlasPrimaryButton(title: "Abrir cámara", symbol: "camera.fill", action: start)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 24)
    }

    private func modeDescription(_ mode: ScanMode) -> String {
        switch mode {
        case .space: return "Habitaciones, propiedades y geometría espacial."
        case .object: return "Equipos, productos y activos individuales."
        case .vehicle: return "Exterior, componentes y cambios visibles."
        }
    }
}

private struct ScanCaptureView: View {
    let mode: ScanMode
    @Binding var progress: Double
    let finish: () -> Void
    let close: () -> Void

    @StateObject private var camera = AtlasCameraController()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            cameraLayer

            LinearGradient(
                colors: [Color.black.opacity(0.38), .clear, Color.black.opacity(0.60)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            scanFrame
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack {
                    capsule(text: mode.rawValue, symbol: mode.symbol)
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.black.opacity(0.30)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)

                Spacer()

                if camera.state == .ready {
                    Text(camera.captureCount == 0 ? "Mantén el activo dentro del marco" : "Captura guardada · sigue recorriendo el activo")
                        .font(AtlasType.ui(13.5, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.black.opacity(0.34)))
                        .padding(.bottom, 14)
                }

                controls
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: camera.captureCount) { _, newValue in
            if newValue > 0 {
                withAnimation(.easeOut(duration: 0.2)) {
                    progress = min(1, max(progress, Double(newValue) * 0.24))
                }
            }
        }
    }

    @ViewBuilder
    private var cameraLayer: some View {
        switch camera.state {
        case .ready:
            AtlasCameraPreview(session: camera.session)
                .ignoresSafeArea()
        case .requesting, .idle:
            cameraMessage(symbol: "camera", title: "Preparando cámara", detail: "iOS puede pedirte permiso para usar la cámara.")
        case .denied:
            cameraMessage(
                symbol: "camera.fill",
                title: "Activa el acceso a la cámara",
                detail: "Ve a Ajustes → ATLAS → Cámara y activa el permiso.",
                showSettings: true
            )
        case .unavailable:
            cameraMessage(symbol: "iphone.slash", title: "Cámara no disponible", detail: "Prueba este flujo en un iPhone físico con cámara disponible.")
        case .failed:
            cameraMessage(symbol: "exclamationmark.triangle", title: "No pudimos iniciar la cámara", detail: "Cierra este flujo e inténtalo nuevamente.")
        }
    }

    private var scanFrame: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - 44
            let height = min(proxy.size.height * 0.55, 500)
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    .frame(width: width, height: height)
                CornerReticle()
                    .frame(width: width, height: height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -18)
        }
    }

    private var controls: some View {
        VStack(spacing: 14) {
            HStack {
                Text("CAPTURA")
                    .font(AtlasType.mono(8.5, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color.white.opacity(0.68))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(AtlasType.rounded(16, weight: .bold))
                    .foregroundStyle(.white)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.20))
                    Capsule().fill(Color.white)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 5)

            HStack(spacing: 14) {
                Button {
                    camera.capturePhoto()
                } label: {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 70, height: 70)
                        Circle().stroke(Color.black.opacity(0.15), lineWidth: 1).frame(width: 58, height: 58)
                    }
                }
                .buttonStyle(.plain)
                .disabled(camera.state != .ready)
                .opacity(camera.state == .ready ? 1 : 0.45)

                Button(action: finish) {
                    HStack(spacing: 8) {
                        Text("Finalizar")
                        Image(systemName: "checkmark")
                    }
                    .font(AtlasType.ui(14.5, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(height: 52)
                    .background(Capsule().fill(Color.white.opacity(0.18)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func capsule(text: String, symbol: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
            Text(text.uppercased())
        }
        .font(AtlasType.ui(10, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.black.opacity(0.30)))
    }

    @ViewBuilder
    private func cameraMessage(symbol: String, title: String, detail: String, showSettings: Bool = false) -> some View {
        VStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white)
            Text(title)
                .font(AtlasType.display(25, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(detail)
                .font(AtlasType.ui(13.5))
                .foregroundStyle(Color.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            if showSettings {
                Button("Abrir Ajustes") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                .font(AtlasType.ui(14, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Capsule().fill(Color.white))
            }
        }
        .padding(.horizontal, 34)
    }
}

private struct CornerReticle: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                corner.rotationEffect(.degrees(0)).position(x: 20, y: 20)
                corner.rotationEffect(.degrees(90)).position(x: w - 20, y: 20)
                corner.rotationEffect(.degrees(270)).position(x: 20, y: h - 20)
                corner.rotationEffect(.degrees(180)).position(x: w - 20, y: h - 20)
            }
        }
    }

    private var corner: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 22))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 22, y: 0))
        }
        .stroke(Color.white, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        .frame(width: 22, height: 22)
    }
}

private struct ScanProcessingView: View {
    @State private var spin = false
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AtlasColor.cobaltWash)
                    .frame(width: 156, height: 156)
                Circle()
                    .trim(from: 0.08, to: 0.74)
                    .stroke(AtlasColor.electric, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 132, height: 132)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                AtlasMark(size: 48)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) { spin = true }
            }

            VStack(spacing: 10) {
                Text("Organizando lo que capturaste")
                    .font(AtlasType.display(31, weight: .bold))
                    .foregroundStyle(AtlasColor.porcelain)
                    .multilineTextAlignment(.center)
                Text("ATLAS está consolidando evidencia, contexto y cambios visibles.")
                    .font(AtlasType.ui(14))
                    .foregroundStyle(AtlasColor.smoke)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 30)

            AtlasGlass {
                VStack(spacing: 14) {
                    processingRow("Evidencia visual", state: "Listo", tint: AtlasColor.aqua)
                    AtlasHairline()
                    processingRow("Contexto del activo", state: "Listo", tint: AtlasColor.aqua)
                    AtlasHairline()
                    processingRow("Cambios y anomalías", state: "Analizando", tint: AtlasColor.electric)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            AtlasPrimaryButton(title: "Ver resultado", symbol: "arrow.right", action: continueAction)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
    }

    private func processingRow(_ title: String, state: String, tint: Color) -> some View {
        HStack {
            Text(title).font(AtlasType.ui(13.5, weight: .medium)).foregroundStyle(AtlasColor.porcelainSoft)
            Spacer()
            Text(state).font(AtlasType.ui(11.5, weight: .semibold)).foregroundStyle(tint)
        }
    }
}

private struct ScanResultView: View {
    let close: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    AtlasTag(text: "Escaneo completado", tint: AtlasColor.aqua, symbol: "checkmark")
                    Spacer()
                    AtlasIconButton(symbol: "xmark", action: close)
                }

                Text("Listo. Ya tienes una nueva referencia.")
                    .font(AtlasType.display(39, weight: .bold))
                    .tracking(-1.2)
                    .foregroundStyle(AtlasColor.porcelain)

                AtlasGlass {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("APARTAMENTO NORTE")
                                    .font(AtlasType.ui(10, weight: .semibold))
                                    .tracking(0.7)
                                    .foregroundStyle(AtlasColor.smoke)
                                Text("Estado #14")
                                    .font(AtlasType.display(26, weight: .bold))
                                    .foregroundStyle(AtlasColor.porcelain)
                            }
                            Spacer()
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundStyle(AtlasColor.electric)
                        }

                        HStack(spacing: 0) {
                            AtlasMetric(value: "32", label: "Evidencias").frame(maxWidth: .infinity, alignment: .leading)
                            AtlasMetric(value: "02", label: "Hallazgos", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                            AtlasMetric(value: "92", label: "Salud", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Text("Hallazgos")
                    .font(AtlasType.display(24, weight: .bold))
                    .foregroundStyle(AtlasColor.porcelain)
                resultFinding("Posible humedad", detail: "Cocina · pared norte", tint: AtlasColor.amber)
                resultFinding("Cambio de acabado", detail: "Sala · muro oeste", tint: AtlasColor.violet)

                AtlasPrimaryButton(title: "Guardar y cerrar", symbol: "checkmark", action: close)
                AtlasSecondaryButton(title: "Generar informe", symbol: "doc.text") {}
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
    }

    private func resultFinding(_ title: String, detail: String, tint: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 13).fill(tint.opacity(0.10)))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.ui(14.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke)
            }
            Spacer()
            Text("REVISAR").font(AtlasType.ui(10, weight: .semibold)).foregroundStyle(tint)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(AtlasColor.graphite))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasColor.border, lineWidth: 1))
    }
}
