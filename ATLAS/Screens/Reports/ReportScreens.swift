import SwiftUI

struct ReportsScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Reports", eyebrow: "ATLAS / REPORTS")
                    Text("Informes construidos a partir de estados, inspecciones, cambios y evidencia.")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)

                    if store.reports.isEmpty {
                        AtlasEmptyState(title: "Sin reportes", detail: "Genera un reporte cuando necesites consolidar evidencia y hallazgos.", symbol: "doc.text")
                    } else {
                        ForEach(store.reports) { report in
                            Button {
                                Task { await store.selectReport(report.id); open(.reportDetail) }
                            } label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack {
                                        Text(report.reportType.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                                        Spacer()
                                        Text(report.createdAt.atlasCompact).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted)
                                    }
                                    Text(report.title).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                    Text(report.periodLabel.ifEmpty(report.status.atlasDisplay)).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                                }.padding(.vertical, 14)
                            }.buttonStyle(AtlasPressButtonStyle())
                            AtlasDivider()
                        }
                    }

                    if let asset = store.assets.first {
                        AtlasPrimaryButton(title: "Generar reporte de condición", symbol: "doc.badge.plus") {
                            Task {
                                if let report = await store.createReport(type: "condition", title: "Condition Report · \(asset.name)", assetId: asset.id, period: "Current state") {
                                    await store.selectReport(report.id); open(.reportDetail)
                                }
                            }
                        }
                    }
                }.padding(20)
            }
        }
    }
}

struct ReportDetailScreen: View {
    @EnvironmentObject private var store: AtlasAppStore
    @State private var shareMessage: String?
    @State private var exportURL: URL?

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Report", eyebrow: "EDITORIAL / TRACEABLE")
                    if let report = store.selectedReport {
                        Text(report.reportType.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                        Text(report.title).font(AtlasType.display(.largeTitle, weight: .semibold)).tracking(-1).foregroundStyle(AtlasColor.ink)
                        Text([report.periodLabel, report.createdAt.atlasFull].filter { !$0.isEmpty }.joined(separator: " · "))
                            .font(AtlasType.mono(.caption)).foregroundStyle(AtlasColor.inkMuted)

                        AtlasSectionLabel(index: "01", title: "SUMMARY")
                        Text(report.summary.ifEmpty("Reporte generado por ATLAS a partir de información trazable del sistema."))
                            .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary).lineSpacing(4)

                        reportBlock("02", "FINDINGS", report.findingsJson.count)
                        reportBlock("03", "CHANGES", report.changesJson.count)
                        reportBlock("04", "EVIDENCE", report.evidenceJson.count)
                        reportBlock("05", "RECOMMENDATIONS", report.recommendationsJson.count)

                        if let shareMessage { Text(shareMessage).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.healthy) }

                        AtlasPrimaryButton(title: "Generar PDF", symbol: "doc.richtext") {
                            Task {
                                do {
                                    let data = try await AtlasAPIClient.shared.exportReport(report.id)
                                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("ATLAS-\(report.id).pdf")
                                    try data.write(to: url, options: .atomic)
                                    await MainActor.run {
                                        exportURL = url
                                        shareMessage = "PDF listo · \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))"
                                    }
                                } catch { await MainActor.run { shareMessage = error.localizedDescription } }
                            }
                        }
                        if let exportURL {
                            ShareLink(item: exportURL) {
                                Label("Compartir PDF", systemImage: "square.and.arrow.up")
                                    .font(AtlasType.body(.body, weight: .semibold))
                                    .foregroundStyle(AtlasColor.blue)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                        }
                        AtlasSecondaryButton(title: "Crear enlace compartido", symbol: "link") {
                            Task {
                                do {
                                    let shared = try await AtlasAPIClient.shared.shareReport(report.id)
                                    await MainActor.run { shareMessage = "Token válido hasta \(shared.expiresAt.atlasFull): \(shared.token)" }
                                } catch { await MainActor.run { shareMessage = error.localizedDescription } }
                            }
                        }
                    } else { AtlasLoadingState(title: "Cargando reporte…", detail: "Recuperando resumen, hallazgos y evidencia.") }
                }.padding(20)
            }
        }
    }

    private func reportBlock(_ index: String, _ title: String, _ count: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: index, title: title, trailing: String(format: "%02d", count))
            Text(count == 0 ? "Sin elementos en esta sección." : "\(count) elementos trazables incluidos por el backend.")
                .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
        }
    }
}
