import SwiftUI

struct AskAtlasScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var prompt = ""
    @State private var answerVisible = false

    private let suggestions = [
        "¿Qué activos requieren atención?",
        "¿Qué cambió esta semana?",
        "Resume el estado del Apartamento Norte",
        "¿Qué mantenimiento recomiendas?"
    ]

    var body: some View {
        AtlasPage {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        AtlasScreenHeader(
                            eyebrow: "Inteligencia contextual",
                            title: "Pregunta a ATLAS",
                            subtitle: "Consulta el historial, estado, relaciones y evidencia de tu mundo físico.",
                            backAction: { dismiss() }
                        )

                        AtlasGlass {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 9) {
                                    Circle().fill(AtlasColor.aqua).frame(width: 7, height: 7)
                                    Text("CONTEXTO ACTIVO · 12 ACTIVOS")
                                        .font(AtlasType.mono(8.5, weight: .bold))
                                        .tracking(1)
                                        .foregroundStyle(AtlasColor.smoke)
                                }

                                Text("¿Qué quieres entender de tu mundo?")
                                    .font(AtlasType.display(30, weight: .medium))
                                    .tracking(-0.8)
                                    .foregroundStyle(AtlasColor.porcelain)

                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button {
                                        prompt = suggestion
                                    } label: {
                                        HStack {
                                            Text(suggestion)
                                                .font(AtlasType.ui(13))
                                                .foregroundStyle(AtlasColor.porcelainSoft)
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(AtlasColor.smoke)
                                        }
                                        .padding(.vertical, 7)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if answerVisible {
                            AtlasGlass {
                                VStack(alignment: .leading, spacing: 14) {
                                    AtlasTag(text: "Respuesta contextual", tint: AtlasColor.electric, symbol: "sparkles")
                                    Text("Hay 3 elementos que requieren atención prioritaria.")
                                        .font(AtlasType.display(27, weight: .medium))
                                        .foregroundStyle(AtlasColor.porcelain)
                                    Text("La principal señal proviene del Apartamento Norte: una anomalía de humedad apareció en la cocina respecto a la inspección del 3 de septiembre. También hay un cambio visual sin clasificar en el vehículo y una revisión preventiva pendiente en la unidad M-028.")
                                        .font(AtlasType.ui(13.5))
                                        .foregroundStyle(AtlasColor.porcelainSoft)
                                        .lineSpacing(4)
                                    Text("ATLAS no sustituye una inspección profesional; presenta evidencia y contexto para acelerar la decisión.")
                                        .font(AtlasType.ui(11.5))
                                        .foregroundStyle(AtlasColor.smoke)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 120)
                }

                HStack(spacing: 10) {
                    TextField("Pregunta sobre tus activos…", text: $prompt, axis: .vertical)
                        .font(AtlasType.ui(14))
                        .foregroundStyle(AtlasColor.porcelain)
                        .tint(AtlasColor.electricBright)
                        .lineLimit(1...4)

                    Button {
                        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        withAnimation(.easeOut(duration: 0.2)) { answerVisible = true }
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AtlasColor.void)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(AtlasColor.porcelain))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AtlasColor.graphite.opacity(0.96))
                .overlay(Rectangle().fill(AtlasColor.border).frame(height: 1), alignment: .top)
            }
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
                    AtlasScreenHeader(
                        eyebrow: "Señales prioritarias",
                        title: "Alertas",
                        subtitle: "Riesgos, anomalías y mantenimiento que merecen revisión humana.",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 0) {
                        AtlasMetric(value: "03", label: "Abiertas", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "01", label: "Alta", tint: AtlasColor.coral).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "07", label: "Resueltas", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Abiertas", trailing: "Ordenadas por prioridad")

                    ForEach(AtlasSampleData.alerts) { alert in
                        Button { open(.inspectionDetail) } label: {
                            AtlasGlass {
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 13).fill(alert.tint.opacity(0.11))
                                        Image(systemName: alert.symbol)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(alert.tint)
                                    }
                                    .frame(width: 44, height: 44)

                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(alert.level)
                                                .font(AtlasType.mono(8.5, weight: .bold))
                                                .tracking(0.8)
                                                .foregroundStyle(alert.tint)
                                            Spacer()
                                            Text(alert.time)
                                                .font(AtlasType.ui(10.5))
                                                .foregroundStyle(AtlasColor.smokeDark)
                                        }
                                        Text(alert.title)
                                            .font(AtlasType.ui(15, weight: .semibold))
                                            .foregroundStyle(AtlasColor.porcelain)
                                        Text(alert.detail)
                                            .font(AtlasType.ui(12.2))
                                            .foregroundStyle(AtlasColor.smoke)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }
}

struct ReportsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Documentación",
                        title: "Informes",
                        subtitle: "Inspecciones estructuradas con evidencia, hallazgos, métricas y trazabilidad.",
                        backAction: { dismiss() },
                        trailingSymbol: "plus",
                        trailingAction: {}
                    )

                    HStack(spacing: 0) {
                        AtlasMetric(value: "18", label: "Generados").frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "05", label: "Compartidos", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "02", label: "Borradores", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Recientes")
                    reportCard(title: "Inspección · Apartamento Norte", date: "20 SEP 2026", status: "Listo", tint: AtlasColor.aqua)
                        .onTapGesture { open(.reportDetail) }
                    reportCard(title: "Comparación · Vehículo diario", date: "19 SEP 2026", status: "Listo", tint: AtlasColor.electricBright)
                        .onTapGesture { open(.reportDetail) }
                    reportCard(title: "Estado · Unidad M-028", date: "18 SEP 2026", status: "Borrador", tint: AtlasColor.amber)
                        .onTapGesture { open(.reportDetail) }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func reportCard(title: String, date: String, status: String, tint: Color) -> some View {
        AtlasGlass {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(tint)
                    Spacer()
                    AtlasTag(text: status, tint: tint)
                }
                Text(title)
                    .font(AtlasType.display(25, weight: .medium))
                    .foregroundStyle(AtlasColor.porcelain)
                HStack {
                    Text(date)
                        .font(AtlasType.mono(8.5, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AtlasColor.smoke)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasColor.smoke)
                }
            }
        }
    }
}

struct ReportDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Informe / RPT-2041",
                        title: "Apartamento Norte",
                        subtitle: "Inspección del 20 de septiembre de 2026.",
                        backAction: { dismiss() },
                        trailingSymbol: "square.and.arrow.up",
                        trailingAction: {}
                    )

                    AtlasGlass {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("RESUMEN EJECUTIVO")
                                .font(AtlasType.mono(8.5, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(AtlasColor.smoke)
                            Text("Estado general estable con dos hallazgos moderados.")
                                .font(AtlasType.display(29, weight: .medium))
                                .foregroundStyle(AtlasColor.porcelain)
                            Text("La inspección cubrió 84,2 m², 7 espacios y 32 evidencias visuales. No se detectaron hallazgos críticos. La anomalía principal corresponde a una posible humedad en la cocina.")
                                .font(AtlasType.ui(13.5))
                                .foregroundStyle(AtlasColor.porcelainSoft)
                                .lineSpacing(4)
                        }
                    }

                    HStack(spacing: 0) {
                        AtlasMetric(value: "92", label: "Salud", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "32", label: "Evidencias").frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "02", label: "Hallazgos", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Recomendaciones")
                    recommendation("Validar origen de humedad", detail: "Inspeccionar tubería, sellado y unión ventana-pared.")
                    recommendation("Documentar intervención", detail: "Crear un nuevo estado después de cualquier reparación.")

                    AtlasPrimaryButton(title: "Compartir informe", symbol: "square.and.arrow.up") {}
                    AtlasSecondaryButton(title: "Exportar PDF", symbol: "arrow.down.doc") {}
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func recommendation(_ title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AtlasColor.aqua)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke).lineSpacing(3)
            }
        }
    }
}
