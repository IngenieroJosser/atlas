import SwiftUI

struct InspectionsScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            AtlasSectionLabel(index: "04", title: "INSPECTIONS")
                            Text("Inspecciones").font(AtlasType.display(.largeTitle, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        }
                        Spacer()
                        Button("Nueva") { open(.newInspection) }.font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                    }

                    if store.inspections.isEmpty {
                        AtlasEmptyState(title: "Sin inspecciones", detail: "Crea una inspección guiada para verificar el estado de un activo.", symbol: "checklist")
                    } else {
                        ForEach(store.inspections) { inspection in
                            InspectionRow(inspection: inspection.presentation(assetName: assetName(inspection.assetId))) {
                                Task { await store.selectInspection(inspection.id); open(.inspectionResult) }
                            }
                            AtlasDivider()
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}

struct NewInspectionScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore
    @State private var selectedAssetID = ""
    @State private var title = "Inspección visual"
    @State private var scheduled = Date()
    @State private var scheduling = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Nueva inspección", eyebrow: "INSPECTION / GUIDED")
                    Text("Atlas crea el flujo de inspección y lo asocia al activo seleccionado.")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ACTIVO").font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
                        Picker("Activo", selection: $selectedAssetID) {
                            Text("Selecciona un activo").tag("")
                            ForEach(store.assets) { asset in Text(asset.name).tag(asset.id) }
                        }.pickerStyle(.menu)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TÍTULO").font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
                        TextField("Inspección visual", text: $title).frame(height: 46)
                            .overlay(alignment: .bottom) { Rectangle().fill(AtlasColor.lineStrong).frame(height: 1) }
                    }
                    Toggle("Programar fecha", isOn: $scheduling)
                    if scheduling { DatePicker("Fecha", selection: $scheduled, displayedComponents: [.date, .hourAndMinute]) }

                    VStack(alignment: .leading, spacing: 10) {
                        AtlasSectionLabel(index: "01", title: "VISUAL")
                        Text("Captura condición exterior y evidencia relevante.").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                        AtlasSectionLabel(index: "02", title: "COMPONENTS")
                        Text("Verifica los componentes clave del activo.").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                        AtlasSectionLabel(index: "03", title: "EVIDENCE")
                        Text("Añade evidencia adicional cuando sea necesario.").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                        AtlasSectionLabel(index: "04", title: "REVIEW")
                        Text("Atlas consolida findings, anomalías y resultado.").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                    }

                    AtlasPrimaryButton(title: "Crear inspección", symbol: "checklist") {
                        Task {
                            if let inspection = await store.createInspection(assetId: selectedAssetID, title: title, scheduledFor: scheduling ? scheduled : nil) {
                                await store.selectInspection(inspection.id)
                                open(.inspectionResult)
                            }
                        }
                    }
                    .disabled(selectedAssetID.isEmpty || title.isEmpty)
                }
                .padding(20)
            }
        }
        .onAppear { if selectedAssetID.isEmpty { selectedAssetID = store.selectedAssetID ?? store.assets.first?.id ?? "" } }
    }
}

struct InspectionResultScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Inspección", eyebrow: "INSPECTION / RESULT")
                    if let result = store.selectedInspection {
                        HStack { Text(result.inspection.status.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.blue); Spacer(); Text(result.inspection.updatedAt.atlasRelative).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted) }
                        Text(result.inspection.title).font(AtlasType.display(.title, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        Text(result.inspection.summary.ifEmpty("Inspection workflow connected to Atlas API."))
                            .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)

                        HStack(spacing: 8) {
                            Metric(value: String(result.findings.count), label: "Findings")
                            Metric(value: String(result.anomaliesCount), label: "Anomalías")
                            Metric(value: String(result.evidenceCount), label: "Evidencias")
                        }

                        AtlasSectionLabel(index: "01", title: "STEPS")
                        ForEach(result.steps) { step in
                            HStack(spacing: 12) {
                                Image(systemName: step.status.lowercased() == "completed" ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(step.status.lowercased() == "completed" ? AtlasColor.healthy : AtlasColor.lineStrong)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(step.stepKey.uppercased()).font(AtlasType.heading(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                    if !step.notes.isEmpty { Text(step.notes).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted) }
                                }
                                Spacer()
                                if step.status.lowercased() != "completed" {
                                    Button("Completar") { Task { await store.completeInspectionStep(stepKey: step.stepKey) } }
                                        .font(AtlasType.body(.caption, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                                }
                            }
                            .padding(.vertical, 8)
                        }

                        AtlasSectionLabel(index: "02", title: "FINDINGS")
                        if result.findings.isEmpty {
                            Text("Sin hallazgos registrados.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted)
                        } else {
                            ForEach(result.findings) { finding in
                                AlertRow(level: finding.severity, title: finding.title, detail: finding.description, color: finding.severity.atlasHealth.color) { }
                            }
                        }

                        AtlasPrimaryButton(title: "Crear orden de trabajo", symbol: "wrench.and.screwdriver") {
                            guard let asset = store.assets.first(where: { $0.id == result.inspection.assetId }) else { return }
                            Task {
                                if let order = await store.createWorkOrder(assetId: asset.id, title: "Acción de inspección: \(result.inspection.title)", description: result.inspection.summary, priority: "medium") {
                                    await store.selectWorkOrder(order.id)
                                    open(.workOrderDetail)
                                }
                            }
                        }
                    } else {
                        AtlasLoadingState(title: "Cargando inspección…", detail: "Recuperando pasos, hallazgos y evidencia.")
                    }
                }
                .padding(20)
            }
        }
    }
}
