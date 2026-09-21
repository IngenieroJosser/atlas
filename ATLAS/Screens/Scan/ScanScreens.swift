import PhotosUI
import SwiftUI
import UIKit

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: ScanStep = .mode
    @State private var mode: ScanMode = .auto
    @State private var capturedImage: UIImage?
    @State private var visionResult = AtlasVisionResult(recognizedText: [], textConfidence: 0)
    @State private var captureSession: APICapture?
    @EnvironmentObject private var store: AtlasAppStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch step {
            case .mode:
                ScanModeScreen(mode: $mode, close: { dismiss() }) {
                    move(to: .capture)
                }
            case .capture:
                ScanCaptureScreen(
                    mode: $mode,
                    close: { dismiss() },
                    back: { move(to: .mode) }
                ) { image in
                    capturedImage = image
                    move(to: .processing)
                }
            case .processing:
                ScanProcessingScreen(mode: mode, image: capturedImage, store: store) { result, capture in
                    visionResult = result
                    captureSession = capture
                    move(to: .result)
                }
            case .result:
                ScanResultScreen(
                    mode: mode,
                    image: capturedImage,
                    visionResult: visionResult,
                    captureSession: captureSession,
                    close: { dismiss() },
                    captureAgain: { move(to: .capture) }
                )
            }
        }
        .id(step.rawValue)
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
        )
    }

    private func move(to next: ScanStep) {
        AtlasHaptics.selection()
        if reduceMotion {
            step = next
        } else {
            withAnimation(AtlasMotion.standardAnimation) {
                step = next
            }
        }
    }
}

private struct ScanModeScreen: View {
    @Binding var mode: ScanMode
    let close: () -> Void
    let continueAction: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                        .buttonStyle(AtlasCompactPressButtonStyle())
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
                        Text("Puedes elegir una categoría o dejar que Atlas organice la captura automáticamente.")
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.inkSecondary)
                            .lineSpacing(4)
                    }

                    VStack(spacing: 0) {
                        ForEach(ScanMode.allCases) { option in
                            Button {
                                AtlasHaptics.selection()
                                if reduceMotion {
                                    mode = option
                                } else {
                                    withAnimation(AtlasMotion.fastAnimation) { mode = option }
                                }
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
                                            Text("Atlas decidirá el flujo de captura según la escena.")
                                                .font(AtlasType.body(.caption))
                                                .foregroundStyle(AtlasColor.inkMuted)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: mode == option ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(mode == option ? AtlasColor.blue : AtlasColor.lineStrong)
                                        .scaleEffect(mode == option ? 1 : 0.92)
                                        .animation(reduceMotion ? nil : AtlasMotion.firmSpring, value: mode.rawValue)
                                }
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(AtlasCompactPressButtonStyle())
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
        return "Cámara + Vision + ARKit disponibles. Atlas no requiere LiDAR para capturar evidencia y crear estados."
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
    @State private var shutterFlash = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            cameraContent

            if camera.state == .ready {
                CameraOverlay(
                    mode: mode,
                    camera: camera,
                    close: close,
                    back: back,
                    galleryItem: $galleryItem,
                    capture: capturePhoto
                )
            }

            Color.white
                .opacity(shutterFlash ? 0.78 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(false)
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

    private func capturePhoto() {
        AtlasHaptics.impact(.medium)
        withAnimation(.easeOut(duration: 0.08)) { shutterFlash = true }
        camera.capturePhoto()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(110))
            withAnimation(.easeOut(duration: 0.14)) { shutterFlash = false }
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
            cameraMessage(title: "No pudimos iniciar la cámara", detail: "Cierra el escaneo e inténtalo nuevamente. Si continúa, revisa los permisos de Atlas.")
        }
    }

    private var permissionDenied: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.fill")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(.white)
            Text("Atlas necesita acceso a la cámara")
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
    let capture: () -> Void

    var body: some View {
        ZStack {
            CameraReticle()
                .padding(.horizontal, 34)
                .padding(.vertical, 150)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                topControls
                Spacer()
                context
                    .atlasStagger(1, distance: 8)
                bottomControls
                    .atlasStagger(2, distance: 8)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 22)
        }
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

            Button(action: capture) {
                ZStack {
                    Circle().stroke(.white, lineWidth: 3).frame(width: 74, height: 74)
                    Circle().fill(.white).frame(width: 60, height: 60)
                }
            }
            .buttonStyle(AtlasCompactPressButtonStyle())
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
            .buttonStyle(AtlasCompactPressButtonStyle())
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
        .buttonStyle(AtlasCompactPressButtonStyle())
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

private struct CameraReticle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        CameraCornerShape()
            .trim(from: 0, to: reduceMotion || revealed ? 1 : 0)
            .stroke(Color.white.opacity(0.72), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
            .onAppear {
                if reduceMotion {
                    revealed = true
                } else {
                    withAnimation(.easeOut(duration: 0.55)) { revealed = true }
                }
            }
            .accessibilityHidden(true)
    }
}

private struct CameraCornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length = min(rect.width, rect.height) * 0.13

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))

        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        return path
    }
}

private struct ScanProcessingScreen: View {
    let mode: ScanMode
    let image: UIImage?
    let store: AtlasAppStore
    let completed: (AtlasVisionResult, APICapture?) -> Void
    @State private var progress = 0
    @State private var failure: String?

    private let steps = ["Evidencia visual", "Registro de captura", "Texto / OCR", "Upload evidence", "Análisis Atlas", "Preparar world state"]

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 28) {
                Spacer()
                AtlasSectionLabel(index: "AI", title: "ANALYSING WORLD STATE")
                Text("Atlas está construyendo un estado trazable.")
                    .font(AtlasType.display(.largeTitle, weight: .semibold)).tracking(-1).foregroundStyle(AtlasColor.ink)
                Text("La captura se procesa localmente con Vision y se registra en el backend con su evidencia original.")
                    .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary).lineSpacing(4)

                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 14) {
                            Group {
                                if index < progress { AtlasAnimatedCheckmark(color: AtlasColor.healthy, size: 19) }
                                else if index == progress { AtlasProcessingIndicator(color: AtlasColor.blue, size: 18) }
                                else { Image(systemName: "circle").foregroundStyle(AtlasColor.lineStrong) }
                            }.frame(width: 24)
                            Text(step).font(AtlasType.body(.body, weight: index == progress ? .semibold : .regular)).foregroundStyle(index <= progress ? AtlasColor.ink : AtlasColor.inkMuted)
                            Spacer()
                        }.padding(.vertical, 13)
                        if index < steps.count - 1 { AtlasDivider() }
                    }
                }
                if let failure {
                    Text(failure).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.critical)
                }
                Spacer()
            }
            .padding(22)
            .task { await runPipeline() }
        }
    }

    private func runPipeline() async {
        guard let image else {
            completed(.init(recognizedText: [], textConfidence: 0), nil)
            return
        }
        do {
            progress = 0
            let vision = await AtlasVisionAnalyzer.analyze(image: image)
            withAnimation(AtlasMotion.fastAnimation) { progress = 1 }
            let capture = try await store.createCapture(mode: mode)
            withAnimation(AtlasMotion.fastAnimation) { progress = 2 }
            AtlasHaptics.selection()
            withAnimation(AtlasMotion.fastAnimation) { progress = 3 }
            _ = try await store.uploadCaptureEvidence(captureId: capture.id, image: image)
            withAnimation(AtlasMotion.fastAnimation) { progress = 4 }
            _ = try await store.analyzeCapture(captureId: capture.id, mode: mode, vision: vision, suggestedName: suggestedName)
            withAnimation(AtlasMotion.fastAnimation) { progress = 5 }
            try? await Task.sleep(for: .milliseconds(220))
            completed(vision, capture)
        } catch {
            failure = error.localizedDescription
            AtlasHaptics.warning()
            try? await Task.sleep(for: .milliseconds(650))
            let vision = await AtlasVisionAnalyzer.analyze(image: image)
            completed(vision, nil)
        }
    }

    private var suggestedName: String {
        switch mode {
        case .property: "Espacio capturado"
        case .vehicle: "Vehículo detectado"
        case .equipment: "Equipo detectado"
        case .infrastructure: "Infraestructura detectada"
        case .document: "Documento capturado"
        case .other: "Nuevo activo"
        case .auto: "Activo por confirmar"
        }
    }
}

private struct ScanResultScreen: View {
    let mode: ScanMode
    let image: UIImage?
    let visionResult: AtlasVisionResult
    let captureSession: APICapture?
    let close: () -> Void
    let captureAgain: () -> Void

    @EnvironmentObject private var store: AtlasAppStore
    @State private var name = ""
    @State private var selectedAssetID = ""
    @State private var committed: APICaptureCommitResult?
    @State private var saving = false
    @State private var error: String?

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Button(action: close) { Image(systemName: "xmark").foregroundStyle(AtlasColor.ink).frame(width: 44, height: 44) }
                        Spacer()
                        Text(captureSession == nil ? "RESULTADO LOCAL" : "RESULTADO / API")
                            .font(AtlasType.label(.caption2, weight: .semibold)).tracking(1).foregroundStyle(AtlasColor.inkMuted)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("ASSET DETECTED").font(AtlasType.label(.caption2, weight: .semibold)).tracking(1).foregroundStyle(AtlasColor.blue)
                        Text(committed?.asset.name ?? suggestedName)
                            .font(AtlasType.display(.largeTitle, weight: .semibold)).tracking(-1).foregroundStyle(AtlasColor.ink)
                        HStack(spacing: 10) {
                            StatusBadge(health: .stable)
                            Text("CONFIANZA \(Int(max(visionResult.textConfidence, 0.72) * 100))%")
                                .font(AtlasType.mono(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
                        }
                    }

                    if let image {
                        Image(uiImage: image).resizable().scaledToFill().frame(height: 230).frame(maxWidth: .infinity).clipped().clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if committed == nil {
                        VStack(alignment: .leading, spacing: 10) {
                            AtlasSectionLabel(index: "01", title: "CREATE / ATTACH")
                            TextField("Nombre del activo", text: $name)
                                .font(AtlasType.body(.body)).frame(height: 48)
                                .overlay(alignment: .bottom) { Rectangle().fill(AtlasColor.lineStrong).frame(height: 1) }
                            Picker("Activo existente", selection: $selectedAssetID) {
                                Text("Selecciona para adjuntar").tag("")
                                ForEach(store.assets) { Text($0.name).tag($0.id) }
                            }.pickerStyle(.menu)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "TEXTO DETECTADO", trailing: visionResult.recognizedText.isEmpty ? "Sin OCR" : "Vision")
                        if visionResult.recognizedText.isEmpty {
                            Text("No se detectó texto suficientemente legible.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                        } else {
                            ForEach(visionResult.recognizedText.prefix(5), id: \.self) { text in Text(text).font(AtlasType.mono(.caption)).foregroundStyle(AtlasColor.inkSecondary).padding(.vertical, 4) }
                        }
                    }

                    if let committed {
                        VStack(alignment: .leading, spacing: 12) {
                            AtlasSectionLabel(index: "03", title: "WORLD STATE SAVED")
                            MetadataLabel(title: "Activo", value: committed.asset.name)
                            MetadataLabel(title: "Estado #", value: String(committed.worldState.sequenceNumber))
                            MetadataLabel(title: "Sync", value: committed.worldState.syncStatus.uppercased())
                            MetadataLabel(title: "Cambios", value: String(committed.detectedChanges.count))
                        }
                        HStack(spacing: 10) { Image(systemName: "checkmark.circle.fill").foregroundStyle(AtlasColor.healthy); Text("Activo y estado sincronizados con Atlas API.").font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.ink) }
                    } else if captureSession == nil {
                        Text("El backend no estaba disponible durante el procesamiento. Puedes capturar de nuevo o guardar la operación localmente para sincronizarla después.")
                            .font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.warning)
                    }

                    if let error { Text(error).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.critical) }

                    if committed == nil, let captureSession {
                        AtlasPrimaryButton(title: saving ? "Guardando…" : "Crear activo", symbol: "plus") {
                            Task { await commitNew(captureSession.id) }
                        }.disabled(saving)
                        AtlasSecondaryButton(title: "Adjuntar a activo existente", symbol: "link") {
                            Task { await attach(captureSession.id) }
                        }.disabled(saving || selectedAssetID.isEmpty)
                    }

                    if captureSession == nil && committed == nil {
                        AtlasPrimaryButton(title: "Guardar para sincronizar", symbol: "internaldrive") {
                            let localID = UUID().uuidString
                            store.enqueueOfflineOperation(entityType: "capture", localId: localID, payload: ["capture_mode": .string(modeAPIValue), "recognized_text": .string(visionResult.recognizedText.joined(separator: "\n"))])
                            AtlasHaptics.success()
                        }
                    }

                    Button("Capturar de nuevo", action: captureAgain)
                        .font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.blue).frame(maxWidth: .infinity, minHeight: 44)
                }.padding(20)
            }
        }
        .onAppear { if name.isEmpty { name = suggestedName } }
    }

    private func commitNew(_ captureId: String) async {
        saving = true; defer { saving = false }
        do {
            committed = try await store.commitNewAsset(captureId: captureId, name: name.ifEmpty(suggestedName), mode: mode)
            AtlasHaptics.success()
        } catch { self.error = error.localizedDescription; AtlasHaptics.warning() }
    }

    private func attach(_ captureId: String) async {
        saving = true; defer { saving = false }
        do {
            committed = try await store.commitToExistingAsset(captureId: captureId, assetId: selectedAssetID)
            AtlasHaptics.success()
        } catch { self.error = error.localizedDescription; AtlasHaptics.warning() }
    }

    private var suggestedName: String {
        switch mode {
        case .property: "Espacio capturado"
        case .vehicle: "Vehículo detectado"
        case .equipment: "Equipo detectado"
        case .infrastructure: "Infraestructura detectada"
        case .document: "Documento capturado"
        case .other: "Nuevo activo"
        case .auto: "Activo por confirmar"
        }
    }

    private var modeAPIValue: String {
        switch mode {
        case .auto: "auto"; case .property: "property"; case .vehicle: "vehicle"; case .equipment: "equipment"; case .infrastructure: "infrastructure"; case .document: "document"; case .other: "other"
        }
    }
}
