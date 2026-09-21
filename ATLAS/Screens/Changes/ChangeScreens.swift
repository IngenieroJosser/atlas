import SwiftUI

struct ChangesScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 7) {
                    AtlasSectionLabel(index: "03", title: "CHANGES")
                    Text("Cambios")
                        .font(AtlasType.display(.largeTitle, weight: .semibold))
                        .tracking(-1.1)
                        .foregroundStyle(AtlasColor.ink)
                    Text("Una memoria cronológica de tu mundo físico.")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                }

                if store.changes.isEmpty {
                    AtlasEmptyState(title: "Sin cambios todavía", detail: "Atlas necesita estados comparables para detectar diferencias.", symbol: "clock.arrow.circlepath")
                } else {
                    ForEach(store.changes) { change in
                        ChangeRow(change: change.presentation(assetName: assetName(change.assetId))) {
                            Task { await store.selectChange(change.id); open(.changeDetail) }
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .refreshable { await store.bootstrap() }
    }

    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}

struct ChangeDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Detalle de cambio", eyebrow: "CHANGE / EVIDENCE")
                    if let change = store.selectedChange {
                        AtlasSectionLabel(index: "01", title: change.changeType.uppercased())
                        Text(change.title)
                            .font(AtlasType.display(.title, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        Text(change.description)
                            .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary).lineSpacing(4)

                        HStack(spacing: 8) {
                            Metric(value: change.confidence.map { String(format: "%.0f%%", $0 * 100) } ?? "—", label: "Confianza")
                            Metric(value: change.severity.atlasDisplay, label: "Severidad")
                        }

                        MetadataLabel(title: "Activo", value: assetName(change.assetId))
                        MetadataLabel(title: "Timestamp", value: change.createdAt.atlasFull)
                        MetadataLabel(title: "Source", value: [change.fromStateId, change.toStateId].compactMap { $0 }.isEmpty ? "Estado registrado" : "Comparación de estados")

                        AtlasSectionLabel(index: "02", title: "BEFORE / AFTER")
                        ComparisonView()

                        AIInsight(title: "Interpretación", text: change.description.ifEmpty("Atlas registró una diferencia entre estados. Revisa la evidencia antes de tomar una acción."), confidence: change.confidence.map { String(format: "%.0f%%", $0 * 100) } ?? "N/A")

                        AtlasPrimaryButton(title: "Comparar estados", symbol: "rectangle.split.2x1") {
                            Task { await store.loadComparison(assetId: change.assetId); open(.compare) }
                        }
                    } else {
                        AtlasLoadingState(title: "Cargando cambio…", detail: "Recuperando evidencia y estados relacionados.")
                    }
                }
                .padding(20)
            }
        }
    }

    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}

struct CompareScreen: View {
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Compare", eyebrow: "WORLD STATE / DIFF")
                    if let comparison = store.selectedComparison {
                        ComparisonView()
                        AtlasSectionLabel(index: "01", title: "DETECTED CHANGES", trailing: String(format: "%02d", comparison.changes.count))
                        if comparison.changes.isEmpty {
                            AtlasEmptyState(title: "Sin diferencias", detail: "Los estados comparados no contienen diferencias estructuradas registradas.", symbol: "equal")
                        } else {
                            ForEach(Array(comparison.changes.enumerated()), id: \.offset) { index, change in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(String(format: "%02d", index + 1)).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.blue)
                                    Text(change["field"]?.stringValue ?? change["type"]?.stringValue ?? "Cambio")
                                        .font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                    Text(change["detail"]?.stringValue ?? change["description"]?.stringValue ?? "Diferencia registrada por el motor de comparación.")
                                        .font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                                }
                                .padding(.vertical, 10)
                                AtlasDivider()
                            }
                        }
                        AIInsight(title: "Atlas / COMPARISON", text: comparison.interpretation.ifEmpty("La comparación se basa únicamente en los estados registrados."), confidence: "TRACEABLE")
                    } else {
                        AtlasLoadingState(title: "Comparando estados…", detail: "Recuperando la última comparación disponible.")
                    }
                }
                .padding(20)
            }
        }
        .task { if store.selectedComparison == nil { await store.loadComparison() } }
    }
}

struct AnomalyDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Anomalía", eyebrow: "ANOMALY / TRACE")
                    if let anomaly = store.selectedAnomaly {
                        HStack { StatusBadge(health: anomaly.severity.atlasHealth); Spacer(); Text(anomaly.status.uppercased()).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted) }
                        Text(anomaly.title).font(AtlasType.display(.title, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        Text(anomaly.description).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)

                        HStack(spacing: 8) {
                            Metric(value: anomaly.confidence.map { String(format: "%.0f%%", $0 * 100) } ?? "—", label: "Confianza")
                            Metric(value: anomaly.severity.atlasDisplay, label: "Severidad")
                        }
                        MetadataLabel(title: "Activo", value: assetName(anomaly.assetId))
                        MetadataLabel(title: "Ubicación", value: anomaly.locationText.ifEmpty("No registrada"))
                        MetadataLabel(title: "Primera detección", value: anomaly.firstDetected.atlasFull)
                        MetadataLabel(title: "Última observación", value: anomaly.lastObserved.atlasFull)
                        AIInsight(title: "Atlas interpretation", text: anomaly.description.ifEmpty("Anomalía registrada. La severidad y confianza provienen de la evidencia disponible."), confidence: anomaly.confidence.map { String(format: "%.0f%%", $0 * 100) } ?? "N/A")

                        AtlasPrimaryButton(title: "Crear orden de trabajo", symbol: "wrench.and.screwdriver") {
                            Task { await store.createWorkOrderFromSelectedAnomaly(); open(.workOrders) }
                        }
                        AtlasSecondaryButton(title: "Solicitar inspección", symbol: "checklist") {
                            Task { await store.requestInspectionForSelectedAnomaly(); open(.inspections) }
                        }
                        Button("Descartar anomalía") { Task { await store.markSelectedAnomalyDismissed() } }
                            .font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.critical)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    } else {
                        AtlasLoadingState(title: "Cargando anomalía…", detail: "Recuperando evolución y evidencia.")
                    }
                }.padding(20)
            }
        }
    }

    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}
