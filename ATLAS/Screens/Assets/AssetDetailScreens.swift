import SwiftUI

struct AssetDetailScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    AtlasEditorialHeader(
                        eyebrow: "ASSET / EQUIPMENT",
                        title: "Unidad de enfriamiento M-028",
                        subtitle: "Actualizado hace 18 min",
                        backAction: { dismiss() },
                        trailingSymbol: "ellipsis",
                        trailingAction: {}
                    )

                    HStack(spacing: 10) {
                        StatusBadge(health: .stable)
                        SyncBadge(state: .synced)
                    }

                    assetVisual
                    currentState

                    AIInsight(
                        title: "Condición estable frente al estado anterior.",
                        text: "No se detecta degradación visual significativa. La ligera variación observada en el sistema de montaje debe seguirse en la próxima inspección.",
                        confidence: "89%"
                    )

                    changes
                    evidence
                    maintenance
                    activity
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
            .safeAreaInset(edge: .bottom) {
                assetActions
            }
        }
    }

    private var assetVisual: some View {
        ZStack {
            AtlasColor.navy
            VStack(spacing: 18) {
                Image(systemName: "fan")
                    .font(.system(size: 76, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.88))
                HStack(spacing: 20) {
                    Label("M-028", systemImage: "number")
                    Label("PLANTA 01", systemImage: "mappin")
                }
                .font(AtlasType.mono(.caption2, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.62))
            }
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityLabel("Representación visual de Unidad de enfriamiento M-028")
    }

    private var currentState: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasSectionLabel(index: "01", title: "CURRENT STATE")
            HStack(alignment: .top, spacing: 20) {
                MetadataLabel(title: "Condición", value: "Estable")
                MetadataLabel(title: "Confianza", value: "94%")
                MetadataLabel(title: "Última inspección", value: "Hoy")
            }
            AtlasDivider()
            HStack(alignment: .top, spacing: 20) {
                MetadataLabel(title: "Categoría", value: "HVAC")
                MetadataLabel(title: "Ubicación", value: "Planta 01")
                MetadataLabel(title: "Estados", value: "18")
            }
        }
    }

    private var changes: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "02", title: "CHANGES", trailing: "2 recientes")
            ForEach(AtlasSampleData.changes.prefix(2)) { change in
                ChangeRow(change: change) { open(.changeDetail) }
            }
        }
    }

    private var evidence: some View {
        VStack(alignment: .leading, spacing: 14) {
            AtlasSectionLabel(index: "03", title: "EVIDENCE", trailing: "12 piezas")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AtlasSampleData.evidence) { evidence in
                        EvidenceCard(evidence: evidence)
                    }
                }
            }
        }
    }

    private var maintenance: some View {
        VStack(alignment: .leading, spacing: 6) {
            AtlasSectionLabel(index: "04", title: "MAINTENANCE", trailing: "Próximo · 21 sep")
            PrimaryActionRow(title: "Revisión preventiva", subtitle: "Prioridad media · Equipo técnico", symbol: "wrench.and.screwdriver") {
                open(.maintenanceDetail)
            }
            AtlasDivider()
            PrimaryActionRow(title: "Órdenes de trabajo", subtitle: "1 abierta · WO-2048", symbol: "doc.text") {
                open(.workOrders)
            }
        }
    }

    private var activity: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "05", title: "ACTIVITY", trailing: "Últimos 7 días")
            Text("20 SEP · Estado 018 capturado")
            Text("19 SEP · Inspección visual completada")
            Text("18 SEP · Recomendación de seguimiento creada")
        }
        .font(AtlasType.body(.subheadline))
        .foregroundStyle(AtlasColor.inkSecondary)
    }

    private var assetActions: some View {
        HStack(spacing: 8) {
            compactAction("Escanear", "viewfinder", startScan)
            compactAction("Inspeccionar", "checklist", { open(.newInspection) })
            compactAction("Comparar", "rectangle.split.2x1", { open(.compare) })
            compactAction("ATLAS", "sparkles", { open(.askAtlas) })
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { AtlasDivider() }
    }

    private func compactAction(_ title: String, _ symbol: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 16, weight: .semibold))
                Text(title).font(AtlasType.label(.caption2, weight: .semibold))
            }
            .foregroundStyle(AtlasColor.ink)
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.plain)
    }
}

struct CreateAssetScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category = "Equipo"
    @State private var location = ""
    @State private var identifier = ""
    @State private var notes = ""

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "NEW ASSET",
                        title: "Crea un activo sin convertirlo en un formulario eterno.",
                        subtitle: "Completa lo esencial. Puedes enriquecer el activo después.",
                        backAction: { dismiss() }
                    )

                    simpleField("NOMBRE", placeholder: "Unidad de enfriamiento M-028", text: $name)
                    simpleField("CATEGORÍA", placeholder: "Equipo", text: $category)
                    simpleField("UBICACIÓN", placeholder: "Planta 01", text: $location)
                    simpleField("IDENTIFICADOR", placeholder: "M-028", text: $identifier)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTAS")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(AtlasColor.inkMuted)
                        TextEditor(text: $notes)
                            .font(AtlasType.body(.body))
                            .frame(minHeight: 110)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(AtlasColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
                    }

                    AtlasPrimaryButton(title: "Guardar activo", symbol: "checkmark") { dismiss() }
                }
                .padding(20)
            }
        }
    }

    private func simpleField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.inkMuted)
            TextField(placeholder, text: text)
                .font(AtlasType.body(.body))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(AtlasColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
        }
    }
}

struct DigitalTwinScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "DIGITAL TWIN",
                        title: "Representación útil, no 3D decorativo.",
                        subtitle: "ATLAS utiliza la información espacial disponible y degrada de forma segura cuando el dispositivo no dispone de LiDAR.",
                        backAction: { dismiss() }
                    )

                    twinCanvas

                    capabilityRow

                    detailSection("01", "GEOMETRY", rows: [("Dimensiones", "84 × 62 × 48 cm"), ("Volumen estimado", "0,25 m³"), ("Captura", "Estado 018")])
                    detailSection("02", "PROPERTIES", rows: [("Fabricante", "ATX Systems"), ("Modelo", "XR-42"), ("Serial", "M028-62291")])
                    detailSection("03", "COMPONENTS", rows: [("Ventilador", "Verificado"), ("Montaje", "Seguimiento"), ("Panel frontal", "Verificado")])
                    detailSection("04", "MEASUREMENTS", rows: [("Ancho", "84,0 cm"), ("Alto", "62,1 cm"), ("Profundidad", "48,2 cm")])
                }
                .padding(20)
            }
        }
    }

    private var twinCanvas: some View {
        ZStack {
            AtlasColor.surfaceSecondary
            VStack(spacing: 18) {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 92, weight: .ultraLight))
                    .foregroundStyle(AtlasColor.blue)
                Text("M-028 / ESTADO 018")
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var capabilityRow: some View {
        HStack(spacing: 8) {
            capability("ARKit", available: AtlasDeviceCapabilities.worldTrackingSupported)
            capability("LiDAR", available: AtlasDeviceCapabilities.lidarSceneReconstructionSupported)
            capability("RoomPlan", available: AtlasDeviceCapabilities.roomPlanSupported)
        }
    }

    private func capability(_ name: String, available: Bool) -> some View {
        HStack(spacing: 5) {
            Circle().fill(available ? AtlasColor.healthy : AtlasColor.inkMuted).frame(width: 6, height: 6)
            Text(name)
                .font(AtlasType.label(.caption2, weight: .semibold))
        }
        .foregroundStyle(available ? AtlasColor.healthy : AtlasColor.inkMuted)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(AtlasColor.surfaceSecondary)
        .clipShape(Capsule())
    }

    private func detailSection(_ index: String, _ title: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AtlasSectionLabel(index: index, title: title)
            ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                HStack {
                    Text(row.0)
                        .font(AtlasType.body(.subheadline))
                        .foregroundStyle(AtlasColor.inkSecondary)
                    Spacer()
                    Text(row.1)
                        .font(AtlasType.body(.subheadline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                }
                .padding(.vertical, 8)
                if idx < rows.count - 1 { AtlasDivider() }
            }
        }
    }
}
