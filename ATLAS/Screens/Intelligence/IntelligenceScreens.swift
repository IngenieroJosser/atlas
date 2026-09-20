import SwiftUI

struct AskAtlasScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var prompt = ""
    @State private var asked = false

    private let suggestions = [
        "¿Qué cambió en Estudio 04 este mes?",
        "¿Qué activos requieren atención?",
        "Compara las dos últimas inspecciones.",
        "¿Por qué M-028 está marcado para revisión?",
        "¿Qué mantenimiento debería priorizar?"
    ]

    var body: some View {
        AtlasPage {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        AtlasEditorialHeader(
                            eyebrow: "ASK ATLAS",
                            title: "Pregunta sobre tu mundo físico.",
                            subtitle: "ATLAS responde usando activos, estados, evidencia, inspecciones y órdenes registradas.",
                            backAction: { dismiss() }
                        )

                        if !asked {
                            VStack(alignment: .leading, spacing: 10) {
                                AtlasSectionLabel(index: "01", title: "SUGGESTED")
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button {
                                        AtlasHaptics.selection()
                                        prompt = suggestion
                                        withAnimation(AtlasMotion.standardAnimation) { asked = true }
                                    } label: {
                                        HStack(alignment: .top, spacing: 12) {
                                            Text(suggestion)
                                                .font(AtlasType.body(.body, weight: .medium))
                                                .foregroundStyle(AtlasColor.ink)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(AtlasColor.inkMuted)
                                        }
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(AtlasPressButtonStyle())
                                    AtlasDivider()
                                }
                            }
                        } else {
                            response
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(20)
                }

                HStack(spacing: 10) {
                    TextField("Pregunta a ATLAS…", text: $prompt, axis: .vertical)
                        .font(AtlasType.body(.body))
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 48)
                        .background(AtlasColor.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button {
                        if !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            AtlasHaptics.impact(.light)
                            withAnimation(AtlasMotion.standardAnimation) { asked = true }
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(AtlasColor.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(AtlasCompactPressButtonStyle())
                    .accessibilityLabel("Enviar")
                }
                .padding(14)
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) { AtlasDivider() }
            }
        }
    }

    private var response: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("TU PREGUNTA")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.inkMuted)
                Text(prompt)
                    .font(AtlasType.heading(.headline, weight: .semibold))
                    .foregroundStyle(AtlasColor.ink)
            }

            AIInsight(
                title: "M-028 requiere seguimiento, no una intervención crítica.",
                text: "La marca de revisión proviene de una variación visual del sistema de montaje presente en los estados 017 y 018. La condición general se mantiene estable.",
                confidence: "89%"
            )

            VStack(alignment: .leading, spacing: 10) {
                AtlasSectionLabel(index: "SRC", title: "SOURCES", trailing: "3 referencias")
                source("Estado 018", "20 sep · captura visual", "photo")
                AtlasDivider()
                source("Inspección #IN-284", "20 sep · condición verificada", "checklist")
                AtlasDivider()
                source("Estado 017", "18 sep · captura anterior", "photo")
            }

            Button("Abrir insight completo") { open(.atlasInsight) }
                .font(AtlasType.body(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
        }
    }

    private func source(_ title: String, _ detail: String, _ symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).foregroundStyle(AtlasColor.blue).frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                Text(detail).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct AtlasInsightScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "ATLAS / INSIGHT",
                        title: "La variación del montaje merece seguimiento.",
                        subtitle: "Unidad de enfriamiento M-028",
                        backAction: { dismiss() }
                    )

                    HStack(alignment: .top, spacing: 24) {
                        Metric(value: "03", label: "Estados", footnote: "comparados")
                        Metric(value: "89%", label: "Confianza", footnote: "evidencia")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "01", title: "INTERPRETATION")
                        Text("En los últimos tres estados se observa un desplazamiento visual creciente alrededor del sistema de montaje. La señal no permite concluir por sí sola una falla mecánica, pero sí justifica verificación física.")
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.inkSecondary)
                            .lineSpacing(5)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "EVIDENCE")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                EvidenceCard(evidence: .init(title: "Estado 016", detail: "14 sep · baseline", symbol: "photo"))
                                EvidenceCard(evidence: .init(title: "Estado 017", detail: "18 sep · +1,1 cm", symbol: "photo"))
                                EvidenceCard(evidence: .init(title: "Estado 018", detail: "20 sep · +1,8 cm", symbol: "photo"))
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "03", title: "RECOMMENDED ACTION")
                        Text("Inspeccionar fijaciones y sistema de montaje antes de la próxima operación prolongada.")
                            .font(AtlasType.heading(.title3, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                        Text("Motivo · tendencia observada en 3 estados / evidencia visual consistente.")
                            .font(AtlasType.body(.caption))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }

                    AtlasPrimaryButton(title: "Crear orden de trabajo", symbol: "doc.badge.plus") { open(.createWorkOrder) }
                }
                .padding(20)
            }
        }
    }
}
