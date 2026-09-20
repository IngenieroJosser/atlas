import SwiftUI

struct NotificationsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "NOTIFICATIONS",
                        title: "Solo lo que merece interrumpirte.",
                        subtitle: "Crítico, atención e información se muestran con significado.",
                        backAction: { dismiss() }
                    )

                    notificationGroup("01", "CRITICAL") {
                        AlertRow(level: "CRÍTICO", title: "M-028 requiere revisión", detail: "Hallazgo recurrente · hace 18 min", color: AtlasColor.critical) { open(.anomalyDetail) }
                    }

                    notificationGroup("02", "ATTENTION") {
                        AlertRow(level: "ATENCIÓN", title: "Cambio geométrico en Estudio 04", detail: "+4,2 cm detectados · hace 2 h", color: AtlasColor.attention) { open(.changeDetail) }
                        AtlasDivider()
                        AlertRow(level: "ATENCIÓN", title: "Mantenimiento vence mañana", detail: "Unidad M-028 · revisión preventiva", color: AtlasColor.attention) { open(.maintenanceDetail) }
                    }

                    notificationGroup("03", "INFORMATION") {
                        AlertRow(level: "INFO", title: "Inspección completada", detail: "Apartamento Norte · condición verificada", color: AtlasColor.info) { open(.inspections) }
                    }
                }
                .padding(20)
            }
        }
    }

    private func notificationGroup<Content: View>(_ index: String, _ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: index, title: title)
            content()
        }
    }
}

struct AlertsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "ALERTS",
                        title: "Atención priorizada por contexto.",
                        subtitle: "ATLAS diferencia severidad, evidencia y siguiente acción.",
                        backAction: { dismiss() }
                    )

                    AlertRow(level: "ALTA", title: "Posible humedad recurrente", detail: "Apartamento Norte · 3 estados consecutivos", color: AtlasColor.critical) { open(.anomalyDetail) }
                    AtlasDivider()
                    AlertRow(level: "MEDIA", title: "Cambio visual sin clasificar", detail: "Vehículo diario · puerta izquierda", color: AtlasColor.attention) { open(.changeDetail) }
                    AtlasDivider()
                    AlertRow(level: "BAJA", title: "Revisión preventiva recomendada", detail: "Unidad M-028 · 38 días", color: AtlasColor.info) { open(.maintenanceDetail) }
                }
                .padding(20)
            }
        }
    }
}
