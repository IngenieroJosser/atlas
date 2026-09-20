import SwiftUI

struct ChangesScreen: View {
    let open: (AtlasRoute) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                AtlasEditorialHeader(
                    eyebrow: "CHANGES",
                    title: "La memoria cronológica de tu mundo físico.",
                    subtitle: "Cada evento conserva qué cambió, cuándo ocurrió y qué evidencia lo respalda."
                )

                VStack(spacing: 0) {
                    ForEach(AtlasSampleData.changes) { change in
                        ChangeRow(change: change) { open(.changeDetail) }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
    }
}

struct ChangeDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "CHANGE / GEOMETRY",
                        title: "+4,2 cm detectados.",
                        subtitle: "Estudio 04 · Sala · 18 sep 2026 · 14:22",
                        backAction: { dismiss() }
                    )

                    ComparisonView()

                    VStack(alignment: .leading, spacing: 14) {
                        AtlasSectionLabel(index: "01", title: "DETECTED CHANGE")
                        detail("Tipo", "Geometría")
                        detail("Confianza", "92%")
                        detail("Origen", "Captura iPhone")
                        detail("Estado anterior", "017")
                        detail("Estado actual", "018")
                    }

                    AIInsight(
                        title: "La pared occidental presenta una diferencia medible.",
                        text: "El cambio excede el margen observado entre capturas previas. ATLAS recomienda verificar si corresponde a obra, movimiento temporal u otra modificación física.",
                        confidence: "92%"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "EVIDENCE", trailing: "2 estados")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                EvidenceCard(evidence: .init(title: "Estado 017", detail: "12 sep · captura base", symbol: "photo"))
                                EvidenceCard(evidence: .init(title: "Estado 018", detail: "20 sep · captura actual", symbol: "photo"))
                            }
                        }
                    }

                    AtlasPrimaryButton(title: "Comparar estados", symbol: "rectangle.split.2x1") { open(.compare) }
                }
                .padding(20)
            }
        }
    }

    private func detail(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key).font(AtlasType.body(.subheadline)).foregroundStyle(AtlasColor.inkSecondary)
            Spacer()
            Text(value).font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
        }
        .padding(.vertical, 7)
    }
}

struct CompareScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stateA = "12 SEP"
    @State private var stateB = "20 SEP"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "COMPARE",
                        title: "Entiende qué cambió, no solo que cambió.",
                        subtitle: "Compara estados visuales, geometría, objetos, condición y medidas.",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 12) {
                        statePicker("ESTADO A", selection: $stateA)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(AtlasColor.inkMuted)
                        statePicker("ESTADO B", selection: $stateB)
                    }

                    ComparisonView()
                        .id("\(stateA)-\(stateB)")
                        .transition(.opacity.combined(with: .scale(scale: 0.985)))
                        .animation(reduceMotion ? nil : AtlasMotion.standardAnimation, value: "\(stateA)-\(stateB)")

                    VStack(alignment: .leading, spacing: 0) {
                        AtlasSectionLabel(index: "01", title: "DIFFERENCES", trailing: "4 cambios")
                            .padding(.bottom, 8)
                        comparisonRow("Geometría", "Pared oeste", "+4,2 cm", AtlasColor.attention)
                        AtlasDivider()
                        comparisonRow("Superficie", "Acabado", "Modificado", AtlasColor.warning)
                        AtlasDivider()
                        comparisonRow("Objetos", "Mesa auxiliar", "Añadido", AtlasColor.blue)
                        AtlasDivider()
                        comparisonRow("Condición", "General", "Sin cambios", AtlasColor.healthy)
                    }

                    AIInsight(
                        title: "El cambio principal está concentrado en una zona.",
                        text: "La mayor diferencia aparece en la pared occidental. El resto del espacio conserva una condición consistente con el estado del 12 de septiembre.",
                        confidence: "90%"
                    )
                }
                .padding(20)
            }
        }
    }

    private func statePicker(_ label: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasType.label(.caption2, weight: .semibold))
                .foregroundStyle(AtlasColor.inkMuted)
            Menu {
                ForEach(["03 SEP", "12 SEP", "18 SEP", "20 SEP"], id: \.self) { date in
                    Button(date) {
                        AtlasHaptics.selection()
                        if reduceMotion { selection.wrappedValue = date }
                        else { withAnimation(AtlasMotion.standardAnimation) { selection.wrappedValue = date } }
                    }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue)
                        .font(AtlasType.body(.subheadline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(AtlasColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func comparisonRow(_ category: String, _ item: String, _ delta: String, _ color: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.uppercased())
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
                Text(item)
                    .font(AtlasType.body(.body, weight: .medium))
                    .foregroundStyle(AtlasColor.ink)
            }
            Spacer()
            Text(delta)
                .font(AtlasType.mono(.caption, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.vertical, 13)
    }
}

struct AnomalyDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "ANOMALY / SURFACE",
                        title: "Posible humedad recurrente.",
                        subtitle: "Apartamento Norte · Cocina",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 10) {
                        StatusBadge(health: .warning)
                        Text("CONFIANZA 94%")
                            .font(AtlasType.mono(.caption2, weight: .semibold))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "01", title: "EVOLUTION")
                        detail("Primera detección", "14 sep · 08:41")
                        detail("Última observación", "20 sep · 09:42")
                        detail("Severidad potencial", "Media")
                        detail("Ubicación", "Pared norte · cocina")
                    }

                    AIInsight(
                        title: "La señal visual aparece en tres estados consecutivos.",
                        text: "La evolución de la zona es consistente con una condición que merece inspección. ATLAS no determina la causa física sin verificación adicional.",
                        confidence: "94%"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "EVIDENCE", trailing: "3 estados")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["14 sep", "18 sep", "20 sep"], id: \.self) { date in
                                    EvidenceCard(evidence: .init(title: date, detail: "Pared norte · cocina", symbol: "photo"))
                                }
                            }
                        }
                    }

                    VStack(spacing: 10) {
                        AtlasPrimaryButton(title: "Crear orden de trabajo", symbol: "doc.badge.plus") { open(.createWorkOrder) }
                        AtlasSecondaryButton(title: "Solicitar inspección", symbol: "checklist") { open(.newInspection) }
                        Button("Descartar hallazgo") {}
                            .font(AtlasType.body(.body, weight: .semibold))
                            .foregroundStyle(AtlasColor.critical)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .padding(20)
            }
        }
    }

    private func detail(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key).font(AtlasType.body(.subheadline)).foregroundStyle(AtlasColor.inkSecondary)
            Spacer()
            Text(value).font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
        }
        .padding(.vertical, 7)
    }
}
