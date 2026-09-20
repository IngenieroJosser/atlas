import SwiftUI

struct InspectionsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var segment = "Todas"

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "INSPECTIONS",
                        title: "Inspecciones guiadas, evidencia primero.",
                        subtitle: "Programadas, en progreso, completadas y archivadas.",
                        backAction: { dismiss() },
                        trailingSymbol: "plus",
                        trailingAction: { open(.newInspection) }
                    )

                    segmentPicker

                    VStack(spacing: 0) {
                        ForEach(AtlasSampleData.inspections) { inspection in
                            InspectionRow(inspection: inspection) { open(.inspectionResult) }
                            AtlasDivider()
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Todas", "Programadas", "En progreso", "Completadas", "Archivadas"], id: \.self) { item in
                    Button { segment = item } label: {
                        Text(item)
                            .font(AtlasType.body(.caption, weight: .semibold))
                            .foregroundStyle(segment == item ? .white : AtlasColor.inkSecondary)
                            .padding(.horizontal, 12)
                            .frame(height: 36)
                            .background(segment == item ? AtlasColor.blue : AtlasColor.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct NewInspectionScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    private let steps = [
        ("01", "VISUAL", "Captura la condición exterior.", "camera.viewfinder"),
        ("02", "COMPONENTES", "Verifica los componentes relevantes.", "square.grid.2x2"),
        ("03", "EVIDENCIA", "Añade evidencia cuando sea necesaria.", "photo.on.rectangle"),
        ("04", "REVISIÓN", "ATLAS organiza hallazgos y contexto.", "sparkles")
    ]

    var body: some View {
        AtlasPage {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        AtlasEditorialHeader(
                            eyebrow: "NEW INSPECTION",
                            title: "Una inspección, en pequeños pasos.",
                            subtitle: "Unidad de enfriamiento M-028",
                            backAction: { dismiss() }
                        )

                        VStack(spacing: 0) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 16) {
                                    VStack(spacing: 7) {
                                        Circle()
                                            .fill(index <= currentStep ? AtlasColor.blue : AtlasColor.lineStrong)
                                            .frame(width: 9, height: 9)
                                        if index < steps.count - 1 {
                                            Rectangle()
                                                .fill(AtlasColor.line)
                                                .frame(width: 1, height: 64)
                                        }
                                    }
                                    .padding(.top, 7)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(step.0) / \(step.1)")
                                            .font(AtlasType.label(.caption2, weight: .semibold))
                                            .tracking(0.8)
                                            .foregroundStyle(index <= currentStep ? AtlasColor.blue : AtlasColor.inkMuted)
                                        Text(step.2)
                                            .font(AtlasType.heading(.headline, weight: .semibold))
                                            .foregroundStyle(AtlasColor.ink)
                                        if index == currentStep {
                                            Text(stepDetail(index))
                                                .font(AtlasType.body(.caption))
                                                .foregroundStyle(AtlasColor.inkSecondary)
                                                .lineSpacing(3)
                                                .padding(.top, 3)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: step.3)
                                        .foregroundStyle(index <= currentStep ? AtlasColor.blue : AtlasColor.inkMuted)
                                }
                                .padding(.vertical, 7)
                            }
                        }
                    }
                    .padding(20)
                }

                VStack(spacing: 10) {
                    AtlasPrimaryButton(
                        title: currentStep == steps.count - 1 ? "Finalizar inspección" : "Completar paso",
                        symbol: currentStep == steps.count - 1 ? "checkmark" : "arrow.right"
                    ) {
                        if currentStep == steps.count - 1 {
                            open(.inspectionResult)
                        } else {
                            currentStep += 1
                        }
                    }
                    if currentStep > 0 {
                        Button("Paso anterior") { currentStep -= 1 }
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasColor.inkSecondary)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .overlay(alignment: .top) { AtlasDivider() }
            }
        }
    }

    private func stepDetail(_ index: Int) -> String {
        switch index {
        case 0: return "Registra la vista general y cualquier condición visible que deba quedar documentada."
        case 1: return "Confirma ventilador, montaje, panel frontal y componentes definidos para este activo."
        case 2: return "Fotografías, notas o lecturas adicionales solo cuando aporten contexto."
        default: return "ATLAS resume hallazgos, cambios, evidencia y recomendaciones antes de cerrar."
        }
    }
}

struct InspectionResultScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "INSPECTION / RESULT",
                        title: "Condición verificada.",
                        subtitle: "Unidad M-028 · 20 sep 2026 · 15:42",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 10) {
                        StatusBadge(health: .verified)
                        Text("CONFIANZA 93%")
                            .font(AtlasType.mono(.caption2, weight: .semibold))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }

                    resultSection("01", "FINDINGS", rows: [
                        ("01", "Ligera variación en montaje", "Seguimiento"),
                        ("02", "Panel frontal", "Sin cambios"),
                        ("03", "Ventilador", "Verificado")
                    ])

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "EVIDENCE", trailing: "7 piezas")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AtlasSampleData.evidence) { EvidenceCard(evidence: $0) }
                            }
                        }
                    }

                    AIInsight(
                        title: "No se observa degradación significativa.",
                        text: "La variación en el sistema de montaje es pequeña, pero aparece en dos inspecciones consecutivas. Conviene mantenerla bajo observación.",
                        confidence: "91%"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "03", title: "RECOMMENDATIONS")
                        PrimaryActionRow(title: "Inspeccionar sistema de montaje", subtitle: "Recomendado en los próximos 7 días", symbol: "wrench.adjustable") { open(.createWorkOrder) }
                        AtlasDivider()
                        PrimaryActionRow(title: "Comparar con inspección anterior", subtitle: "18 sep → 20 sep", symbol: "rectangle.split.2x1") { open(.compare) }
                    }
                }
                .padding(20)
            }
        }
    }

    private func resultSection(_ index: String, _ title: String, rows: [(String, String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: index, title: title)
            ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                HStack(alignment: .top, spacing: 12) {
                    Text(row.0)
                        .font(AtlasType.mono(.caption2, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(row.1)
                            .font(AtlasType.body(.body, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                        Text(row.2)
                            .font(AtlasType.body(.caption))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }
                    Spacer()
                }
                .padding(.vertical, 11)
                if idx < rows.count - 1 { AtlasDivider() }
            }
        }
    }
}
