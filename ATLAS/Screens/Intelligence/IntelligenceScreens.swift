import SwiftUI

struct AskAtlasScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore
    @State private var question = ""

    private let suggestions = [
        "¿Qué activos requieren atención?",
        "¿Qué cambió recientemente?",
        "¿Qué mantenimiento debería revisar?",
        "Resume las últimas inspecciones."
    ]

    var body: some View {
        AtlasPage {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        AtlasBackHeader(title: "Ask Atlas", eyebrow: "INTELLIGENCE / CONTEXT")
                        Text("Pregunta sobre el mundo físico que ya registraste.")
                            .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)

                        if let assetID = store.selectedAssetID, let asset = store.assets.first(where: { $0.id == assetID }) {
                            HStack(spacing: 10) {
                                Image(systemName: asset.category.atlasSymbol).foregroundStyle(AtlasColor.blue)
                                Text("Contexto: \(asset.name)").font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                            }
                        }

                        FlowLayout(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(suggestion) { question = suggestion; submit() }
                                    .font(AtlasType.body(.caption, weight: .semibold))
                                    .foregroundStyle(AtlasColor.inkSecondary)
                                    .padding(.horizontal, 12).padding(.vertical, 9)
                                    .background(AtlasColor.surfaceSecondary)
                                    .clipShape(Capsule())
                            }
                        }

                        HStack(alignment: .bottom, spacing: 10) {
                            TextField("Pregunta a Atlas…", text: $question, axis: .vertical)
                                .font(AtlasType.body(.body))
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .background(AtlasColor.surface)
                                .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
                            Button(action: submit) {
                                Image(systemName: "arrow.up").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                                    .frame(width: 44, height: 44).background(AtlasColor.navy).clipShape(Circle())
                            }.disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || store.isLoading)
                        }

                        if store.isLoading {
                            AtlasLoadingState(title: "Atlas está consultando…", detail: "Buscando evidencia dentro de tus activos y estados.")
                        }

                        if let response = store.askResponse {
                            VStack(alignment: .leading, spacing: 18) {
                                AIInsight(title: "Respuesta", text: response.answer, confidence: response.confidence.uppercased())
                                if !response.recommendedAction.isEmpty {
                                    MetadataLabel(title: "Recommended action", value: response.recommendedAction)
                                }
                                AtlasSectionLabel(index: "SRC", title: "SOURCES", trailing: String(format: "%02d", response.sources.count))
                                ForEach(response.sources) { source in
                                    Button {
                                        Task { await navigate(source) }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(source.type.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                                                Text(source.label).font(AtlasType.heading(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                            }
                                            Spacer(); Image(systemName: "arrow.up.right").foregroundStyle(AtlasColor.inkMuted)
                                        }.padding(.vertical, 10)
                                    }.buttonStyle(AtlasPressButtonStyle())
                                }
                            }
                            .id("answer")
                            .onAppear { withAnimation(AtlasMotion.standardAnimation) { proxy.scrollTo("answer", anchor: .top) } }
                        }
                    }.padding(20)
                }
            }
        }
    }

    private func submit() {
        let value = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        Task { await store.askAtlas(value, assetId: store.selectedAssetID) }
    }

    private func navigate(_ source: APISourceRef) async {
        switch source.type.lowercased() {
        case "asset": await store.selectAsset(source.id); open(.assetDetail)
        case "change": await store.selectChange(source.id); open(.changeDetail)
        case "anomaly": await store.selectAnomaly(source.id); open(.anomalyDetail)
        case "inspection": await store.selectInspection(source.id); open(.inspectionResult)
        case "work_order": await store.selectWorkOrder(source.id); open(.workOrderDetail)
        case "report": await store.selectReport(source.id); open(.reportDetail)
        default: break
        }
    }
}

struct AtlasInsightScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Atlas Insight", eyebrow: "INTELLIGENCE / TRACE")
                    if let insight = store.selectedInsight ?? store.insights.first {
                        AIInsight(title: insight.title, text: insight.statement, confidence: insight.confidenceText.ifEmpty("TRACEABLE"))
                        MetadataLabel(title: "Basis", value: insight.basis.ifEmpty("Información registrada en Atlas"))
                        MetadataLabel(title: "Evidence refs", value: String(insight.evidenceRefs.count))
                        MetadataLabel(title: "Recommended action", value: insight.recommendation.ifEmpty("Sin recomendación adicional"))
                        Text("Creado · \(insight.createdAt.atlasFull)").font(AtlasType.mono(.caption)).foregroundStyle(AtlasColor.inkMuted)
                        if let assetId = insight.assetId {
                            AtlasPrimaryButton(title: "Abrir activo", symbol: "shippingbox") {
                                Task { await store.selectAsset(assetId); open(.assetDetail) }
                            }
                        }
                    } else {
                        AtlasEmptyState(title: "Sin insights", detail: "Los insights trazables aparecerán aquí cuando exista contexto suficiente.", symbol: "sparkles")
                    }
                }.padding(20)
            }
        }
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    init(spacing: CGFloat, @ViewBuilder content: () -> Content) { self.spacing = spacing; self.content = content() }
    var body: some View { LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: spacing)], alignment: .leading, spacing: spacing) { content } }
}
