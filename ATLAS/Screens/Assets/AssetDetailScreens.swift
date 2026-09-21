import SwiftUI

struct AssetDetailScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    AtlasBackHeader(title: detail?.asset.name ?? "Activo", eyebrow: "ASSET / \((detail?.asset.category ?? "—").uppercased())")

                    if let detail {
                        hero(detail)
                        currentState(detail)
                        intelligence(detail)
                        changes(detail)
                        evidence(detail)
                        maintenance(detail)
                        activity(detail)
                        actions
                    } else if let error = store.errorMessage {
                        AtlasErrorState(title: "No pudimos abrir el activo", detail: error) {
                            if let id = store.selectedAssetID { Task { await store.selectAsset(id) } }
                        }
                    } else {
                        AtlasLoadingState(title: "Cargando activo…", detail: "Recuperando estado, evidencia y actividad.")
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .task {
            if let id = store.selectedAssetID, store.selectedAssetDetail?.asset.id != id {
                await store.selectAsset(id)
            }
        }
    }

    private var detail: APIAssetDetail? { store.selectedAssetDetail }

    private func hero(_ detail: APIAssetDetail) -> some View {
        ZStack(alignment: .bottomLeading) {
            AtlasColor.navy
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    StatusBadge(health: detail.asset.status.atlasHealth)
                    Spacer()
                    Text(detail.asset.identifier.ifEmpty("NO ID"))
                        .font(AtlasType.mono(.caption2, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.54))
                }
                Spacer()
                Text(detail.asset.name)
                    .font(AtlasType.display(.largeTitle, weight: .semibold))
                    .tracking(-1.2)
                    .foregroundStyle(.white)
                Text([detail.asset.category, detail.asset.location].filter { !$0.isEmpty }.joined(separator: " / "))
                    .font(AtlasType.label(.caption, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(Color.white.opacity(0.62))
            }
            .padding(20)
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func currentState(_ detail: APIAssetDetail) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            AtlasSectionLabel(index: "01", title: "CURRENT STATE")
            HStack(alignment: .top, spacing: 8) {
                Metric(value: detail.latestState.map { String(format: "%.0f%%", $0.confidence * 100) } ?? "—", label: "Confianza")
                Metric(value: String(detail.asset.worldStatesCount), label: "Estados")
                Metric(value: String(detail.asset.openAnomaliesCount), label: "Anomalías")
            }
            MetadataLabel(title: "Condición", value: detail.latestState?.conditionLabel.atlasDisplay ?? detail.asset.status.atlasDisplay)
            MetadataLabel(title: "Última captura", value: detail.latestState?.capturedAt.atlasFull ?? "Sin estado")
            if let summary = detail.latestState?.summary, !summary.isEmpty {
                Text(summary).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
            }
        }
    }

    private func intelligence(_ detail: APIAssetDetail) -> some View {
        let text = detail.latestState?.summary.ifEmpty("Atlas conserva este activo listo para comparar contra futuros estados.") ?? "Todavía no existe un estado físico suficiente para generar una interpretación."
        return AIInsight(title: "Lectura actual", text: text, confidence: detail.latestState.map { String(format: "%.0f%%", $0.confidence * 100) } ?? "N/A")
    }

    private func changes(_ detail: APIAssetDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "02", title: "CHANGES", trailing: String(format: "%02d", detail.asset.changesCount))
            if detail.recentChanges.isEmpty {
                Text("Sin cambios recientes registrados.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted)
            } else {
                ForEach(Array(detail.recentChanges.prefix(4).enumerated()), id: \.offset) { _, item in
                    let title = item["title"]?.stringValue ?? "Cambio detectado"
                    let description = item["description"]?.stringValue ?? ""
                    PrimaryActionRow(title: title, subtitle: description, symbol: "clock.arrow.circlepath") { Task { await store.loadComparison(); open(.compare) } }
                }
            }
        }
    }

    private func evidence(_ detail: APIAssetDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AtlasSectionLabel(index: "03", title: "EVIDENCE", trailing: String(format: "%02d", detail.recentEvidence.count))
            if detail.recentEvidence.isEmpty {
                Text("No hay evidencia asociada todavía.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) { ForEach(detail.recentEvidence) { EvidenceCard(evidence: $0.presentation) } }
                }
            }
        }
    }

    private func maintenance(_ detail: APIAssetDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "04", title: "MAINTENANCE", trailing: String(format: "%02d", detail.asset.pendingMaintenanceCount))
            if detail.maintenance.isEmpty {
                Text("Sin tareas pendientes para este activo.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted)
            } else {
                ForEach(Array(detail.maintenance.prefix(3).enumerated()), id: \.offset) { _, item in
                    PrimaryActionRow(title: item["title"]?.stringValue ?? "Mantenimiento", subtitle: item["status"]?.stringValue?.atlasDisplay ?? "Pendiente", symbol: "wrench.and.screwdriver") { open(.maintenance) }
                }
            }
        }
    }

    private func activity(_ detail: APIAssetDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "05", title: "ACTIVITY")
            if detail.activity.isEmpty {
                Text("Sin actividad registrada.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted)
            } else {
                ForEach(detail.activity.prefix(5)) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle().fill(AtlasColor.blue).frame(width: 7, height: 7).padding(.top, 6)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(AtlasType.heading(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                            Text("\(item.detail) · \(item.occurredAt.atlasRelative)").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                        }
                    }
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 8) {
            AtlasPrimaryButton(title: "Scan again", symbol: "viewfinder", action: startScan)
            PrimaryActionRow(title: "Digital Twin", subtitle: "Representación y geometría disponible", symbol: "cube.transparent") {
                Task { await store.loadDigitalTwin(); open(.digitalTwin) }
            }
            PrimaryActionRow(title: "Inspect", subtitle: "Crear una inspección guiada", symbol: "checklist") { open(.newInspection) }
            PrimaryActionRow(title: "Compare", subtitle: "Comparar estados históricos", symbol: "rectangle.split.2x1") {
                Task { await store.loadComparison(); open(.compare) }
            }
            PrimaryActionRow(title: "Ask Atlas", subtitle: "Consultar con contexto de este activo", symbol: "sparkles") { open(.askAtlas) }
        }
    }
}

struct CreateAssetScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AtlasAppStore
    @State private var name = ""
    @State private var category = "equipment"
    @State private var location = ""
    @State private var identifier = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var tags = ""
    @State private var saving = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Crear activo", eyebrow: "ASSET / NEW")
                    Text("Solo los datos necesarios. Podrás enriquecer el activo con sus estados y evidencia.")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                    field("NOMBRE", $name)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CATEGORÍA").font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
                        Picker("Categoría", selection: $category) {
                            ForEach(["property", "vehicle", "equipment", "infrastructure", "document", "other"], id: \.self) { Text($0.atlasDisplay).tag($0) }
                        }.pickerStyle(.menu)
                    }
                    field("UBICACIÓN", $location)
                    field("IDENTIFICADOR", $identifier)
                    field("DESCRIPCIÓN", $description)
                    field("TAGS · SEPARADOS POR COMAS", $tags)
                    field("NOTAS", $notes)
                    AtlasPrimaryButton(title: saving ? "Guardando…" : "Guardar activo", symbol: "checkmark") {
                        Task {
                            saving = true
                            let created = await store.createAsset(name: name, category: category, location: location, description: description, identifier: identifier, tags: tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }, notes: notes)
                            saving = false
                            if created != nil { dismiss() }
                        }
                    }
                    .disabled(saving || name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(20)
            }
        }
    }

    private func field(_ label: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
            TextField(label, text: text, axis: label == "DESCRIPCIÓN" || label == "NOTAS" ? .vertical : .horizontal)
                .font(AtlasType.body(.body)).frame(minHeight: 46)
                .overlay(alignment: .bottom) { Rectangle().fill(AtlasColor.lineStrong).frame(height: 1) }
        }
    }
}

struct DigitalTwinScreen: View {
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Digital Twin", eyebrow: "ASSET / REPRESENTATION")
                    if let twin = store.selectedDigitalTwin {
                        ZStack {
                            AtlasColor.navy
                            VStack(spacing: 18) {
                                Image(systemName: twin.geometryAvailable ? "cube.transparent" : "photo.on.rectangle")
                                    .font(.system(size: 74, weight: .ultraLight)).foregroundStyle(.white)
                                Text(twin.representation.uppercased())
                                    .font(AtlasType.label(.caption, weight: .semibold)).tracking(1).foregroundStyle(Color.white.opacity(0.6))
                            }
                        }
                        .frame(height: 270).clipShape(RoundedRectangle(cornerRadius: 18))

                        AtlasSectionLabel(index: "01", title: "GEOMETRY")
                        MetadataLabel(title: "Disponible", value: twin.geometryAvailable ? "Sí" : "No")
                        MetadataLabel(title: "Evidencia", value: String(twin.evidenceCount))
                        MetadataLabel(title: "Componentes", value: String(twin.components.count))

                        AtlasSectionLabel(index: "02", title: "STATE")
                        if let state = twin.latestState {
                            MetadataLabel(title: "Estado", value: state.conditionLabel.atlasDisplay)
                            MetadataLabel(title: "Confianza", value: String(format: "%.0f%%", state.confidence * 100))
                            MetadataLabel(title: "Capturado", value: state.capturedAt.atlasFull)
                            if !state.measurementsJson.isEmpty { MetadataLabel(title: "Mediciones", value: "\(state.measurementsJson.count) registradas") }
                        } else {
                            Text("No existe un estado espacial todavía.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted)
                        }
                    } else {
                        AtlasLoadingState(title: "Construyendo vista…", detail: "Recuperando geometría y propiedades disponibles.")
                    }
                }
                .padding(20)
            }
        }
        .task { if store.selectedDigitalTwin == nil { await store.loadDigitalTwin() } }
    }
}
