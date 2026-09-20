import SwiftUI

struct ReportExportScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var include3D = true
    @State private var includeEvidence = true
    @State private var includeAI = true

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Informe", title: "Exportar y compartir", subtitle: "Configura el documento antes de generar una copia verificable.", backAction: { dismiss() })
                    AtlasGlass { VStack(spacing: 18) { toggle("Resumen y métricas", value: .constant(true)); AtlasHairline(); toggle("Modelo / contexto 3D", value: $include3D); AtlasHairline(); toggle("Evidencia fotográfica", value: $includeEvidence); AtlasHairline(); toggle("Interpretación de ATLAS", value: $includeAI) } }
                    AtlasKicker(index: "01", title: "Formato")
                    HStack(spacing: 10) { format("PDF", "doc.richtext"); format("Enlace", "link"); format("Datos", "square.and.arrow.down") }
                    AtlasPrimaryButton(title: "Generar exportación", symbol: "square.and.arrow.up") { dismiss() }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func toggle(_ title: String, value: Binding<Bool>) -> some View { HStack { Text(title).font(AtlasType.ui(14, weight: .medium)).foregroundStyle(AtlasColor.porcelain); Spacer(); Toggle("", isOn: value).labelsHidden().tint(AtlasColor.electric) } }
    private func format(_ title: String, _ symbol: String) -> some View { VStack(spacing: 9) { Image(systemName: symbol).font(.system(size: 20, weight: .light)); Text(title).font(AtlasType.ui(11.5, weight: .semibold)) }.foregroundStyle(AtlasColor.porcelainSoft).frame(maxWidth: .infinity).frame(height: 90).background(RoundedRectangle(cornerRadius: 18).fill(AtlasColor.graphite)).overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasColor.border, lineWidth: 1)) }
}

struct AIHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Inteligencia", title: "Historial de consultas", subtitle: "Conserva las preguntas y conclusiones generadas sobre tus activos.", backAction: { dismiss() })
                    ForEach([("HOY · 13:12", "¿Qué activos requieren atención?"), ("HOY · 10:04", "Resume los cambios del Apartamento Norte"), ("AYER", "¿Qué mantenimiento recomiendas para M-028?")], id: \.0) { item in VStack(alignment: .leading, spacing: 6) { Text(item.0).font(AtlasType.mono(8.5, weight: .bold)).foregroundStyle(AtlasColor.smokeDark); Text(item.1).font(AtlasType.ui(15, weight: .semibold)).foregroundStyle(AtlasColor.porcelain); Text("ATLAS respondió usando evidencia, historial y contexto del activo.").font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke) }.padding(.vertical, 8); AtlasHairline() }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}
