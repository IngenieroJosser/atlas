import SwiftUI

struct MaintenanceScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "MAINTENANCE",
                        title: "Lo importante, antes de que sea urgente.",
                        subtitle: "Próximos, vencidos, completados y sugeridos por ATLAS.",
                        backAction: { dismiss() }
                    )

                    maintenanceGroup("01", "UPCOMING", items: [
                        ("Unidad M-028", "Revisión preventiva", "Mañana · MEDIA"),
                        ("Panel eléctrico", "Verificación térmica", "23 sep · BAJA")
                    ])

                    maintenanceGroup("02", "OVERDUE", items: [
                        ("Estudio 04", "Revisión de cambio geométrico", "2 días · ALTA")
                    ])

                    VStack(alignment: .leading, spacing: 10) {
                        AtlasSectionLabel(index: "03", title: "SUGGESTED BY ATLAS")
                        AIInsight(
                            title: "Revisa el sistema de montaje de M-028.",
                            text: "La recomendación está respaldada por dos inspecciones y una variación visual recurrente.",
                            confidence: "89%"
                        )
                    }

                    AtlasPrimaryButton(title: "Ver órdenes de trabajo", symbol: "doc.text") { open(.workOrders) }
                }
                .padding(20)
            }
        }
    }

    private func maintenanceGroup(_ index: String, _ title: String, items: [(String, String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: index, title: title)
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                Button { open(.maintenanceDetail) } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.0)
                                .font(AtlasType.label(.caption2, weight: .semibold))
                                .foregroundStyle(AtlasColor.inkMuted)
                            Text(item.1)
                                .font(AtlasType.heading(.headline, weight: .semibold))
                                .foregroundStyle(AtlasColor.ink)
                            Text(item.2)
                                .font(AtlasType.mono(.caption2))
                                .foregroundStyle(title == "OVERDUE" ? AtlasColor.critical : AtlasColor.inkSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }
                    .padding(.vertical, 13)
                }
                .buttonStyle(AtlasPressButtonStyle())
                if idx < items.count - 1 { AtlasDivider() }
            }
        }
    }
}

struct MaintenanceDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "MAINTENANCE / M-028",
                        title: "Revisión preventiva.",
                        subtitle: "Unidad de enfriamiento M-028",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 12) {
                        badge("MEDIA", color: AtlasColor.attention)
                        badge("MAÑANA", color: AtlasColor.blue)
                    }

                    detailSection

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "HISTORY")
                        history("03 AGO", "Revisión completada", "Sin hallazgos")
                        AtlasDivider()
                        history("14 JUN", "Mantenimiento preventivo", "Filtro reemplazado")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "03", title: "EVIDENCE")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AtlasSampleData.evidence.prefix(2)) { EvidenceCard(evidence: $0) }
                            }
                        }
                    }

                    AtlasPrimaryButton(title: "Crear orden de trabajo", symbol: "doc.badge.plus") { open(.createWorkOrder) }
                }
                .padding(20)
            }
        }
    }

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AtlasSectionLabel(index: "01", title: "DETAIL")
            detail("Fecha prevista", "21 sep 2026")
            detail("Prioridad", "Media")
            detail("Responsable", "Equipo técnico")
            detail("Fuente", "Plan preventivo")
        }
    }

    private func detail(_ key: String, _ value: String) -> some View {
        HStack { Text(key).foregroundStyle(AtlasColor.inkSecondary); Spacer(); Text(value).fontWeight(.semibold).foregroundStyle(AtlasColor.ink) }
            .font(AtlasType.body(.subheadline))
            .padding(.vertical, 7)
    }

    private func history(_ date: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(date).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted).frame(width: 50, alignment: .leading)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                Text(detail).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
            }
        }.padding(.vertical, 9)
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text).font(AtlasType.mono(.caption2, weight: .semibold)).foregroundStyle(color)
            .padding(.horizontal, 9).padding(.vertical, 6).background(color.opacity(0.08)).clipShape(Capsule())
    }
}

struct WorkOrdersScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var filter = "Abiertas"

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "WORK ORDERS",
                        title: "Acciones conectadas con evidencia.",
                        subtitle: "Abiertas, asignadas, en progreso y completadas.",
                        backAction: { dismiss() },
                        trailingSymbol: "plus",
                        trailingAction: { open(.createWorkOrder) }
                    )

                    HStack(spacing: 8) {
                        ForEach(["Abiertas", "Asignadas", "En progreso", "Completadas"], id: \.self) { item in
                            Button { filter = item } label: {
                                Text(item)
                                    .font(AtlasType.body(.caption, weight: .semibold))
                                    .foregroundStyle(filter == item ? .white : AtlasColor.inkSecondary)
                                    .padding(.horizontal, 10)
                                    .frame(height: 34)
                                    .background(filter == item ? AtlasColor.blue : AtlasColor.surfaceSecondary)
                                    .clipShape(Capsule())
                            }.buttonStyle(AtlasPressButtonStyle())
                        }
                    }
                    .horizontalScrollIfNeeded()

                    VStack(spacing: 0) {
                        ForEach(AtlasSampleData.workOrders) { order in
                            Button { open(.workOrderDetail) } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(order.code)
                                            .font(AtlasType.mono(.caption2, weight: .semibold))
                                            .foregroundStyle(AtlasColor.blue)
                                        Spacer()
                                        Text(order.status.uppercased())
                                            .font(AtlasType.label(.caption2, weight: .semibold))
                                            .foregroundStyle(AtlasColor.inkMuted)
                                    }
                                    Text(order.title)
                                        .font(AtlasType.heading(.headline, weight: .semibold))
                                        .foregroundStyle(AtlasColor.ink)
                                    Text("\(order.asset) · \(order.priority) · \(order.assignee)")
                                        .font(AtlasType.body(.caption))
                                        .foregroundStyle(AtlasColor.inkSecondary)
                                }
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(AtlasPressButtonStyle())
                            AtlasDivider()
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func horizontalScrollIfNeeded() -> some View {
        ScrollView(.horizontal, showsIndicators: false) { self }
    }
}

struct CreateWorkOrderScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Revisar sistema de montaje"
    @State private var priority = "Alta"
    @State private var assignee = "Equipo técnico"
    @State private var detail = ""

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "NEW WORK ORDER",
                        title: "De hallazgo a acción.",
                        subtitle: "Origen · Anomalía superficial · Unidad M-028",
                        backAction: { dismiss() }
                    )

                    formField("TÍTULO", text: $title)
                    formField("PRIORIDAD", text: $priority)
                    formField("RESPONSABLE", text: $assignee)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPCIÓN")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(AtlasColor.inkMuted)
                        TextEditor(text: $detail)
                            .font(AtlasType.body(.body))
                            .frame(height: 120)
                            .padding(10)
                            .scrollContentBackground(.hidden)
                            .background(AtlasColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
                    }

                    AtlasPrimaryButton(title: "Crear orden", symbol: "checkmark") { dismiss() }
                }
                .padding(20)
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AtlasType.label(.caption2, weight: .semibold)).tracking(0.8).foregroundStyle(AtlasColor.inkMuted)
            TextField("", text: text)
                .font(AtlasType.body(.body))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(AtlasColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
        }
    }
}

struct WorkOrderDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "WO-2048 / HIGH",
                        title: "Revisar sistema de montaje.",
                        subtitle: "Unidad de enfriamiento M-028 · Asignada",
                        backAction: { dismiss() }
                    )

                    detail("Responsable", "Equipo técnico")
                    detail("Estado", "Asignada")
                    detail("Prioridad", "Alta")
                    detail("Creada", "20 sep · 10:04")

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "01", title: "DESCRIPTION")
                        Text("Inspeccionar fijaciones y sistema de montaje. La recomendación se origina en una variación visual detectada en dos inspecciones consecutivas.")
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.inkSecondary)
                            .lineSpacing(4)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "02", title: "RELATED")
                        PrimaryActionRow(title: "Unidad M-028", subtitle: "Activo relacionado", symbol: "fan") { open(.assetDetail) }
                        AtlasDivider()
                        PrimaryActionRow(title: "Variación de montaje", subtitle: "Hallazgo relacionado", symbol: "exclamationmark.triangle") { open(.anomalyDetail) }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "03", title: "TIMELINE")
                        Text("10:04 · Orden creada desde recomendación ATLAS")
                        Text("10:06 · Asignada a Equipo técnico")
                    }
                    .font(AtlasType.body(.subheadline))
                    .foregroundStyle(AtlasColor.inkSecondary)
                }
                .padding(20)
            }
        }
    }

    private func detail(_ key: String, _ value: String) -> some View {
        HStack { Text(key).foregroundStyle(AtlasColor.inkSecondary); Spacer(); Text(value).fontWeight(.semibold).foregroundStyle(AtlasColor.ink) }
            .font(AtlasType.body(.subheadline))
            .padding(.vertical, 4)
    }
}
