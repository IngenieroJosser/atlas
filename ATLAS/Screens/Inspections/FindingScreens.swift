import SwiftUI

struct FindingsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Análisis", title: "Hallazgos", subtitle: "Anomalías observadas, clasificadas y vinculadas a evidencia verificable.", backAction: { dismiss() })
                    HStack { AtlasMetric(value: "08", label: "Total"); Spacer(); AtlasMetric(value: "02", label: "Alta", tint: AtlasColor.coral); Spacer(); AtlasMetric(value: "03", label: "Media", tint: AtlasColor.amber) }
                    AtlasKicker(index: "01", title: "Requieren atención")
                    ForEach(AtlasSampleData.alerts) { alert in
                        Button { open(.findingDetail) } label: {
                            HStack(spacing: 13) {
                                ZStack { Circle().fill(alert.tint.opacity(0.11)); Image(systemName: alert.symbol).foregroundStyle(alert.tint) }.frame(width: 42, height: 42)
                                VStack(alignment: .leading, spacing: 4) { Text(alert.title).font(AtlasType.ui(14.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain); Text(alert.detail).font(AtlasType.ui(12)).foregroundStyle(AtlasColor.smoke) }
                                Spacer(); Text(alert.level).font(AtlasType.mono(8.5, weight: .bold)).foregroundStyle(alert.tint)
                            }.padding(.vertical, 8)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}

struct FindingDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Hallazgo / F-028", title: "Posible humedad recurrente", subtitle: "Pared norte de cocina · Apartamento Norte", backAction: { dismiss() })
                    AtlasGlass {
                        VStack(spacing: 16) {
                            AtlasValueRow(label: "Severidad", value: "Alta", tint: AtlasColor.coral)
                            AtlasHairline(); AtlasValueRow(label: "Confianza visual", value: "92%", tint: AtlasColor.aqua)
                            AtlasHairline(); AtlasValueRow(label: "Primera detección", value: "18 SEP 2026")
                            AtlasHairline(); AtlasValueRow(label: "Estado", value: "Pendiente de revisión", tint: AtlasColor.amber)
                        }
                    }
                    AtlasKicker(index: "01", title: "Interpretación")
                    Text("Se observa una alteración cromática y pérdida de uniformidad superficial compatible con exposición recurrente a humedad. ATLAS recomienda validar la causa antes de intervenir el acabado.")
                        .font(AtlasType.ui(14.5)).foregroundStyle(AtlasColor.porcelainSoft).lineSpacing(5)
                    AtlasKicker(index: "02", title: "Evidencia")
                    HStack(spacing: 10) { evidenceTile("photo", "IMG 2041"); evidenceTile("ruler", "Medición"); evidenceTile("waveform", "Nota de voz") }
                    AtlasPrimaryButton(title: "Crear orden de revisión", symbol: "wrench.and.screwdriver") {}
                    AtlasSecondaryButton(title: "Marcar como resuelto", symbol: "checkmark.circle") {}
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func evidenceTile(_ symbol: String, _ title: String) -> some View {
        VStack(spacing: 9) { Image(systemName: symbol).font(.system(size: 20, weight: .light)).foregroundStyle(AtlasColor.electricBright); Text(title).font(AtlasType.ui(10.5, weight: .medium)).foregroundStyle(AtlasColor.smoke) }
            .frame(maxWidth: .infinity).frame(height: 92).background(RoundedRectangle(cornerRadius: 18).fill(AtlasColor.graphite)).overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasColor.border, lineWidth: 1))
    }
}

struct EvidenceScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var filter = "Todo"
    private let filters = ["Todo", "Fotos", "Mediciones", "Documentos"]

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasScreenHeader(eyebrow: "Evidencia", title: "Registro verificable", subtitle: "Todo lo capturado permanece asociado al activo, momento y contexto espacial.", backAction: { dismiss() })
                    ScrollView(.horizontal, showsIndicators: false) { HStack(spacing: 8) { ForEach(filters, id: \.self) { item in Button { filter = item } label: { Text(item).font(AtlasType.ui(12, weight: .semibold)).foregroundStyle(filter == item ? AtlasColor.void : AtlasColor.porcelainSoft).padding(.horizontal, 14).frame(height: 38).background(Capsule().fill(filter == item ? AtlasColor.porcelain : AtlasColor.graphite)) }.buttonStyle(.plain) } } }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(0..<8, id: \.self) { index in
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 22).fill(index % 3 == 0 ? AtlasColor.graphite2 : AtlasColor.graphite)
                                Image(systemName: index % 3 == 0 ? "photo" : (index % 3 == 1 ? "ruler" : "doc.text")).font(.system(size: 30, weight: .ultraLight)).foregroundStyle(AtlasColor.electricBright.opacity(0.72)).frame(maxWidth: .infinity, maxHeight: .infinity)
                                VStack(alignment: .leading, spacing: 2) { Text("EVIDENCIA").font(AtlasType.mono(7.5, weight: .bold)).foregroundStyle(AtlasColor.smoke); Text("#\(2041 + index)").font(AtlasType.ui(12.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain) }.padding(12)
                            }.frame(height: 150).overlay(RoundedRectangle(cornerRadius: 22).stroke(AtlasColor.border, lineWidth: 1))
                        }
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}
