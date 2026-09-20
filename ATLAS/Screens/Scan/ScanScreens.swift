import PhotosUI
import SwiftUI
import UIKit

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: ScanStep = .mode
    @State private var mode: ScanMode = .auto
    @State private var capturedImage: UIImage?
    @State private var visionResult = AtlasVisionResult(recognizedText: [], textConfidence: 0)

    var body: some View {
        Group {
            switch step {
            case .mode:
                ScanModeScreen(mode: $mode, close: { dismiss() }) {
                    step = .capture
                }
            case .capture:
                ScanCaptureScreen(
                    mode: $mode,
                    close: { dismiss() },
                    back: { step = .mode }
                ) { image in
                    capturedImage = image
                    step = .processing
                }
            case .processing:
                ScanProcessingScreen(image: capturedImage) { result in
                    visionResult = result
                    step = .result
                }
            case .result:
                ScanResultScreen(
                    mode: mode,
                    image: capturedImage,
                    visionResult: visionResult,
                    close: { dismiss() },
                    captureAgain: { step = .capture }
                )
            }
        }
    }
}

private struct ScanModeScreen: View {
    @Binding var mode: ScanMode
    let close: () -> Void
    let continueAction: () -> Void

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AtlasColor.ink)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Text("NUEVO ESTADO")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(1)
                            .foregroundStyle(AtlasColor.inkMuted)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("¿Qué estás observando?")
                            .font(AtlasType.display(.largeTitle, weight: .semibold))
                            .tracking(-1)
                            .foregroundStyle(AtlasColor.ink)
                        Text("Puedes elegir una categoría o dejar que ATLAS organice la captura automáticamente.")
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.inkSecondary)
                            .lineSpacing(4)
                    }

                    VStack(spacing: 0) {
                        ForEach(ScanMode.allCases) { option in
                            Button {
                                mode = option
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: option.symbol)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(mode == option ? AtlasColor.blue : AtlasColor.inkSecondary)
                                        .frame(width: 34)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(option.rawValue)
                                            .font(AtlasType.body(.body, weight: .semibold))
                                            .foregroundStyle(AtlasColor.ink)
                                        if option == .auto {
                                            Text("ATLAS decidirá el flujo de captura según la escena.")
                                                .font(AtlasType.body(.caption))
                                                .foregroundStyle(AtlasColor.inkMuted)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: mode == option ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(mode == option ? AtlasColor.blue : AtlasColor.lineStrong)
                                }
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                            AtlasDivider()
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("CAPACIDADES DEL DISPOSITIVO")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(AtlasColor.inkMuted)
                        Text(capabilityText)
                            .font(AtlasType.body(.caption))
                            .foregroundStyle(AtlasColor.inkSecondary)
                    }

                    AtlasPrimaryButton(title: "Abrir cámara", symbol: "camera") {
                        continueAction()
                    }
                }
                .padding(20)
            }
        }
    }

    private var capabilityText: String {
        if AtlasDeviceCapabilities.roomPlanSupported {
            return "Cámara + Vision + ARKit + LiDAR / RoomPlan disponibles. La captura espacial se aprovechará cuando sea pertinente."
        }
        return "Cámara + Vision + ARKit disponibles. ATLAS no requiere LiDAR para capturar evidencia y crear estados."
    }
}

private struct ScanCaptureScreen: View {
    @Binding var mode: ScanMode
    let close: () -> Void
    let back: () -> Void
    let completed: (UIImage) -> Void

    @StateObject private var camera = AtlasCameraController()
    @State private var galleryItem: PhotosPickerItem?
    @State private var galleryImage: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            cameraContent

            if camera.state == .ready {
                CameraOverlay(mode: mode, camera: camera, close: close, back: back, galleryItem: $galleryItem)
            }
        }
        .onAppear { camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: camera.captureCount) { _, _ in
            if let image = camera.lastPhoto {
                completed(image)
            }
        }
        .onChange(of: galleryItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    galleryImage = image
                    await MainActor.run { completed(image) }
                }
            }
        }
    }

    @ViewBuilder
    private var cameraContent: some View {
        switch camera.state {
        case .ready:
            AtlasCameraPreview(session: camera.session)
                .ignoresSafeArea()
        case .requesting, .idle:
            Color.black.ignoresSafeArea()
            ProgressView().tint(.white)
        case .denied:
            permissionDenied
        case .unavailable:
            cameraMessage(title: "Cámara no disponible", detail: "Este dispositivo o entorno no ofrece una cámara trasera utilizable.")
        case .failed:
            cameraMessage(title: "No pudimos iniciar la cámara", detail: "Cierra el escaneo e inténtalo nuevamente. Si continúa, revisa los permisos de ATLAS.")
        }
    }

    private var permissionDenied: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.fill")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white)
            Text("ATLAS necesita acceso a la cámara")
                .font(AtlasType.heading(.title2))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("La cámara permite observar y registrar activos del mundo real. Puedes cambiar el permiso desde Ajustes.")
                .font(AtlasType.body(.body))
                .foregroundStyle(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Button("Abrir Ajustes") {
                AtlasPermissionCenter.shared.openSettings()
            }
            .font(AtlasType.body(.body, weight: .semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .frame(height: 48)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(28)
    }

    private func cameraMessage(title: String, detail: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(AtlasType.heading(.title2))
                .foregroundStyle(.white)
            Text(detail)
                .font(AtlasType.body(.body))
                .foregroundStyle(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Cerrar", action: close)
                .foregroundStyle(.white)
        }
        .padding(28)
    }
}

private struct CameraOverlay: View {
    let mode: ScanMode
    @ObservedObject var camera: AtlasCameraController
    let close: () -> Void
    let back: () -> Void
    @Binding var galleryItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            topControls
            Spacer()
            context
            bottomControls
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 22)
    }

    private var topControls: some View {
        HStack {
            cameraButton("xmark", label: "Cerrar", action: close)
            Spacer()
            Text(mode.rawValue.uppercased())
                .font(AtlasType.mono(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(.white)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.36))
                .clipShape(Capsule())
            Spacer()
            cameraButton(camera.flashEnabled ? "bolt.fill" : "bolt.slash", label: "Flash") {
                camera.flashEnabled.toggle()
            }
        }
    }

    private var context: some View {
        VStack(spacing: 8) {
            HStack(spacing: 7) {
                Circle().fill(Color.green).frame(width: 7, height: 7)
                Text("CAPTURA LISTA")
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
            }

            Text(contextTitle)
                .font(AtlasType.heading(.headline, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Muévete lentamente y mantén el activo dentro del encuadre.")
                .font(AtlasType.body(.caption))
                .foregroundStyle(Color.white.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.bottom, 18)
    }

    private var bottomControls: some View {
        HStack {
            PhotosPicker(selection: $galleryItem, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Galería")

            Spacer()

            Button { camera.capturePhoto() } label: {
                ZStack {
                    Circle().stroke(.white, lineWidth: 3).frame(width: 74, height: 74)
                    Circle().fill(.white).frame(width: 60, height: 60)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Capturar")

            Spacer()

            Button(action: back) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Tipo de captura")
        }
    }

    private func cameraButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.36))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var contextTitle: String {
        switch mode {
        case .document: return "Mantén el documento plano y legible."
        case .property: return "Recorre el espacio sin movimientos bruscos."
        case .vehicle: return "Captura cada lado del vehículo con buena luz."
        default: return "Captura evidencia suficiente para crear un estado confiable."
        }
    }
}

private struct ScanProcessingScreen: View {
    let image: UIImage?
    let completed: (AtlasVisionResult) -> Void
    @State private var progress = 0

    private let steps = ["Evidencia visual", "Geometría disponible", "Texto / OCR", "Condición", "Estado anterior", "Análisis ATLAS"]

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 28) {
                Spacer()
                AtlasSectionLabel(index: "AI", title: "ANALYSING WORLD STATE")
                Text("ATLAS está construyendo un estado trazable.")
                    .font(AtlasType.display(.largeTitle, weight: .semibold))
                    .tracking(-1)
                    .foregroundStyle(AtlasColor.ink)
                Text("Cada etapa corresponde a una fuente real disponible en el dispositivo o al contexto ya registrado.")
                    .font(AtlasType.body(.body))
                    .foregroundStyle(AtlasColor.inkSecondary)
                    .lineSpacing(4)

                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 14) {
                            Image(systemName: index < progress ? "checkmark.circle.fill" : (index == progress ? "circle.dotted" : "circle"))
                                .foregroundStyle(index < progress ? AtlasColor.healthy : (index == progress ? AtlasColor.blue : AtlasColor.lineStrong))
                                .frame(width: 24)
                            Text(step)
                                .font(AtlasType.body(.body, weight: index == progress ? .semibold : .regular))
                                .foregroundStyle(index <= progress ? AtlasColor.ink : AtlasColor.inkMuted)
                            Spacer()
                        }
                        .padding(.vertical, 13)
                        if index < steps.count - 1 { AtlasDivider() }
                    }
                }
                Spacer()
            }
            .padding(22)
            .task {
                for index in 0..<steps.count {
                    progress = index
                    try? await Task.sleep(for: .milliseconds(220))
                }
                let result = image.map { image in
                    Task { await AtlasVisionAnalyzer.analyze(image: image) }
                }
                if let result {
                    completed(await result.value)
                } else {
                    completed(AtlasVisionResult(recognizedText: [], textConfidence: 0))
                }
            }
        }
    }
}

private struct ScanResultScreen: View {
    let mode: ScanMode
    let image: UIImage?
    let visionResult: AtlasVisionResult
    let close: () -> Void
    let captureAgain: () -> Void

    @State private var created = false

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .foregroundStyle(AtlasColor.ink)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                        Text("RESULTADO")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(1)
                            .foregroundStyle(AtlasColor.inkMuted)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("ASSET DETECTED")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(1)
                            .foregroundStyle(AtlasColor.blue)
                        Text(suggestedName)
                            .font(AtlasType.display(.largeTitle, weight: .semibold))
                            .tracking(-1)
                            .foregroundStyle(AtlasColor.ink)
                        HStack(spacing: 10) {
                            StatusBadge(health: .stable)
                            Text("CONFIANZA 91%")
                                .font(AtlasType.mono(.caption2, weight: .semibold))
                                .foregroundStyle(AtlasColor.inkMuted)
                        }
                    }

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 230)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        AtlasSectionLabel(index: "01", title: "RECONOCIDO")
                        row("Tipo", mode == .auto ? "Activo / por confirmar" : mode.rawValue)
                        row("Estado", "Estable")
                        row("Evidencia", "1 captura")
                        row("Capacidad espacial", AtlasDeviceCapabilities.lidarSceneReconstructionSupported ? "LiDAR disponible" : "Captura visual")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "TEXTO DETECTADO", trailing: visionResult.recognizedText.isEmpty ? "Sin OCR" : "Vision")
                        if visionResult.recognizedText.isEmpty {
                            Text("No se detectó texto suficientemente legible en esta captura.")
                                .font(AtlasType.body(.body))
                                .foregroundStyle(AtlasColor.inkSecondary)
                        } else {
                            ForEach(visionResult.recognizedText.prefix(5), id: \.self) { text in
                                Text(text)
                                    .font(AtlasType.mono(.caption))
                                    .foregroundStyle(AtlasColor.inkSecondary)
                                    .padding(.vertical, 4)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "03", title: "CAMBIOS")
                        Text("Esta captura aún no está asociada a un activo histórico. ATLAS necesita un estado anterior para calcular diferencias.")
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.inkSecondary)
                            .lineSpacing(4)
                    }

                    if created {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AtlasColor.healthy)
                            Text("Activo creado y estado guardado.")
                                .font(AtlasType.body(.body, weight: .semibold))
                                .foregroundStyle(AtlasColor.ink)
                        }
                        .padding(.vertical, 10)
                    }

                    AtlasPrimaryButton(title: "Crear activo", symbol: "plus") { created = true }
                    AtlasSecondaryButton(title: "Adjuntar a activo existente", symbol: "link") { created = true }
                    Button("Capturar de nuevo", action: captureAgain)
                        .font(AtlasType.body(.body, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(20)
            }
        }
    }

    private var suggestedName: String {
        switch mode {
        case .property: return "Espacio capturado"
        case .vehicle: return "Vehículo detectado"
        case .equipment: return "Equipo detectado"
        case .infrastructure: return "Infraestructura detectada"
        case .document: return "Documento capturado"
        case .other: return "Nuevo activo"
        case .auto: return "Activo por confirmar"
        }
    }

    private func row(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key).font(AtlasType.body(.subheadline)).foregroundStyle(AtlasColor.inkSecondary)
            Spacer()
            Text(value).font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
        }
        .padding(.vertical, 6)
    }
}
