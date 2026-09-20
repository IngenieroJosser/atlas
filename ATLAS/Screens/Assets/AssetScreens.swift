import SwiftUI

struct AssetsScreen: View {
    let open: (AtlasRoute) -> Void
    @State private var query = ""
    @State private var selectedFilter = "Todos"

    private let filters = ["Todos", "Propiedades", "Vehículos", "Equipos"]

    var filtered: [AtlasAsset] {
        AtlasSampleData.assets.filter { asset in
            let matchesSearch = query.isEmpty || asset.name.localizedCaseInsensitiveContains(query) || asset.type.localizedCaseInsensitiveContains(query)
            let matchesFilter: Bool
            switch selectedFilter {
            case "Propiedades": matchesFilter = asset.type == "PROPIEDAD"
            case "Vehículos": matchesFilter = asset.type == "VEHÍCULO"
            case "Equipos": matchesFilter = asset.type == "EQUIPO" || asset.type == "INFRAESTRUCTURA"
            default: matchesFilter = true
            }
            return matchesSearch && matchesFilter
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                AtlasScreenHeader(
                    eyebrow: "ATLAS / ASSETS",
                    title: "Todo tu mundo, en un índice.",
                    subtitle: "Identidad, evidencia, versiones y contexto físico organizados alrededor de cada activo.",
                    trailingSymbol: "plus",
                    trailingAction: { open(.addAsset) }
                )

                HStack(spacing: 0) {
                    AtlasMetric(value: "12", label: "Activos", tint: AtlasColor.electric).frame(maxWidth: .infinity, alignment: .leading)
                    AtlasMetric(value: "05", label: "Clases", tint: AtlasColor.violet).frame(maxWidth: .infinity, alignment: .leading)
                    AtlasMetric(value: "03", label: "Atención", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 12) {
                    AtlasKicker(index: "01 / 03", title: "Buscar", trailing: "Biblioteca física")
                    AtlasSearchField(text: $query, placeholder: "Buscar activo, tipo o ubicación")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Text(filter)
                                        .font(AtlasType.ui(11.5, weight: .semibold))
                                        .foregroundStyle(selectedFilter == filter ? .white : AtlasColor.porcelainSoft)
                                        .padding(.horizontal, 13)
                                        .frame(height: 36)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(selectedFilter == filter ? AtlasColor.porcelain : AtlasColor.graphite)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(selectedFilter == filter ? Color.clear : AtlasColor.border, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    AtlasKicker(index: "02 / 03", title: "Selección", trailing: "\(filtered.count) visibles")
                    AtlasEditorialHeading(
                        kicker: "Índice activo",
                        title: "Menos lista. Más lectura.",
                        detail: "Cada fila concentra estado, tipo y contexto para llegar al detalle sin pasos innecesarios."
                    )

                    VStack(spacing: 0) {
                        ForEach(Array(filtered.enumerated()), id: \.element.id) { index, asset in
                            Button { open(.assetDetail) } label: {
                                HStack(spacing: 10) {
                                    Text(String(format: "%02d", index + 1))
                                        .font(AtlasType.mono(8, weight: .bold))
                                        .foregroundStyle(AtlasColor.smokeDark)
                                        .frame(width: 24, alignment: .leading)
                                    AtlasAssetRow(asset: asset)
                                }
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            if index < filtered.count - 1 { AtlasHairline() }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    AtlasKicker(index: "03 / 03", title: "Acción", trailing: "Nuevo activo")
                    AtlasSecondaryButton(title: "Registrar un activo", symbol: "plus") {
                        open(.addAsset)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 34)
        }
    }
}

struct AssetDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasScreenHeader(
                        eyebrow: "Activo / Propiedad",
                        title: "Apartamento Norte",
                        subtitle: "Un gemelo digital vivo del activo, con contexto espacial, historial y evidencia verificable.",
                        backAction: { dismiss() },
                        trailingSymbol: "pencil",
                        trailingAction: { open(.editAsset) }
                    )

                    assetHero
                    statusGrid

                    AtlasKicker(index: "01", title: "Explorar activo")
                    VStack(spacing: 0) {
                        Button { open(.digitalTwin) } label: {
                            AtlasActionRow(index: "A", symbol: "cube.transparent", title: "Gemelo digital", detail: "Geometría, espacios y relaciones físicas.", tint: AtlasColor.electricBright)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.inspections) } label: {
                            AtlasActionRow(index: "B", symbol: "viewfinder", title: "Inspecciones", detail: "Capturas, hallazgos, evidencia y estados.", tint: AtlasColor.aqua)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.compare) } label: {
                            AtlasActionRow(index: "C", symbol: "square.split.2x1", title: "Comparar versiones", detail: "Detecta cambios físicos entre dos momentos.", tint: AtlasColor.violet)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.reports) } label: {
                            AtlasActionRow(index: "D", symbol: "doc.text", title: "Informes", detail: "Documentación y evidencia exportable.", tint: AtlasColor.amber)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.findings) } label: {
                            AtlasActionRow(index: "E", symbol: "exclamationmark.magnifyingglass", title: "Hallazgos", detail: "Anomalías, severidad, confianza y seguimiento.", tint: AtlasColor.coral)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.evidence) } label: {
                            AtlasActionRow(index: "F", symbol: "photo.on.rectangle.angled", title: "Evidencia", detail: "Fotos, mediciones y documentos del activo.", tint: AtlasColor.electricBright)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.maintenance) } label: {
                            AtlasActionRow(index: "G", symbol: "wrench.and.screwdriver", title: "Mantenimiento", detail: "Órdenes, tareas y recomendaciones preventivas.", tint: AtlasColor.aqua)
                        }.buttonStyle(.plain)
                        AtlasHairline()
                        Button { open(.spatialMap) } label: {
                            AtlasActionRow(index: "H", symbol: "map", title: "Mapa espacial", detail: "Ubica espacios, activos y hallazgos en contexto.", tint: AtlasColor.violet)
                        }.buttonStyle(.plain)
                    }

                    AtlasKicker(index: "02", title: "Actividad reciente", trailing: "Últimos 7 días")
                    VStack(spacing: 16) {
                        ForEach(AtlasSampleData.changes.prefix(3)) { change in
                            AtlasChangeRow(change: change)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private var assetHero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [AtlasColor.graphite2, AtlasColor.voidSoft], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 250)

            RadialGradient(colors: [AtlasColor.electric.opacity(0.22), .clear], center: .center, startRadius: 10, endRadius: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Image(systemName: "building.2")
                .font(.system(size: 84, weight: .ultraLight))
                .foregroundStyle(AtlasColor.electricBright.opacity(0.65))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ASSET-0012")
                        .font(AtlasType.mono(8.5, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AtlasColor.smoke)
                    Text("84,2 m² · 7 espacios")
                        .font(AtlasType.ui(15, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                }
                Spacer()
                AtlasTag(text: "Saludable", tint: AtlasColor.aqua, symbol: "checkmark")
            }
            .padding(18)
        }
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
    }

    private var statusGrid: some View {
        HStack(spacing: 0) {
            AtlasMetric(value: "92", label: "Salud", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
            AtlasMetric(value: "14", label: "Versiones", tint: AtlasColor.electricBright).frame(maxWidth: .infinity, alignment: .leading)
            AtlasMetric(value: "02", label: "Alertas", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct DigitalTwinScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Apartamento Norte",
                        title: "Gemelo digital",
                        subtitle: "Representación espacial del activo y sus componentes relacionados.",
                        backAction: { dismiss() }
                    )

                    AtlasWorldLens().frame(height: 340)

                    HStack(spacing: 0) {
                        AtlasMetric(value: "7", label: "Espacios").frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "14", label: "Ventanas", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "9", label: "Puertas", tint: AtlasColor.violet).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Estructura")
                    VStack(spacing: 0) {
                        twinRow("Sala", detail: "24,1 m² · 3 objetos", symbol: "sofa")
                        AtlasHairline()
                        twinRow("Cocina", detail: "13,8 m² · 1 alerta", symbol: "fork.knife")
                        AtlasHairline()
                        twinRow("Habitación principal", detail: "17,4 m² · estable", symbol: "bed.double")
                        AtlasHairline()
                        twinRow("Baño", detail: "6,2 m² · estable", symbol: "shower")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func twinRow(_ title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AtlasColor.electricBright)
                .frame(width: 38, height: 38)
                .background(RoundedRectangle(cornerRadius: 12).fill(AtlasColor.electric.opacity(0.10)))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.ui(14.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(12)).foregroundStyle(AtlasColor.smoke)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(AtlasColor.smokeDark)
        }
        .padding(.vertical, 10)
    }
}

struct InspectionsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Apartamento Norte",
                        title: "Inspecciones",
                        subtitle: "Cada inspección crea una versión verificable del estado físico del activo.",
                        backAction: { dismiss() }
                    )

                    inspectionCard("20 SEP 2026", status: "Actual", findings: "2 hallazgos", tint: AtlasColor.aqua)
                        .onTapGesture { open(.inspectionDetail) }
                    inspectionCard("03 SEP 2026", status: "Archivada", findings: "0 críticos", tint: AtlasColor.electricBright)
                        .onTapGesture { open(.inspectionDetail) }
                    inspectionCard("12 AGO 2026", status: "Línea base", findings: "Captura inicial", tint: AtlasColor.violet)
                        .onTapGesture { open(.inspectionDetail) }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func inspectionCard(_ date: String, status: String, findings: String, tint: Color) -> some View {
        AtlasGlass {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(date)
                        .font(AtlasType.mono(9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AtlasColor.smoke)
                    Text(status)
                        .font(AtlasType.display(25, weight: .medium))
                        .foregroundStyle(AtlasColor.porcelain)
                    Text(findings)
                        .font(AtlasType.ui(12.5))
                        .foregroundStyle(tint)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AtlasColor.smoke)
            }
        }
    }
}

struct InspectionDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Inspección / 20 Sep",
                        title: "Estado actual",
                        subtitle: "Inspección finalizada con 2 hallazgos moderados y evidencia completa.",
                        backAction: { dismiss() },
                        trailingSymbol: "square.and.arrow.up",
                        trailingAction: { open(.reportExport) }
                    )

                    HStack(spacing: 0) {
                        AtlasMetric(value: "92", label: "Salud", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "32", label: "Evidencias").frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "02", label: "Hallazgos", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Hallazgos")
                    findingCard(title: "Posible humedad", detail: "Pared norte · Cocina", confidence: "87%", tint: AtlasColor.amber)
                    findingCard(title: "Cambio de acabado", detail: "Sala · Muro oeste", confidence: "94%", tint: AtlasColor.violet)

                    AtlasPrimaryButton(title: "Abrir informe completo", symbol: "doc.text") { open(.reportDetail) }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func findingCard(title: String, detail: String, confidence: String, tint: Color) -> some View {
        AtlasGlass {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    AtlasTag(text: "Moderado", tint: tint, symbol: "exclamationmark.triangle")
                    Spacer()
                    Text(confidence)
                        .font(AtlasType.rounded(16, weight: .bold))
                        .foregroundStyle(AtlasColor.porcelain)
                }
                Text(title)
                    .font(AtlasType.display(25, weight: .medium))
                    .foregroundStyle(AtlasColor.porcelain)
                Text(detail)
                    .font(AtlasType.ui(12.5))
                    .foregroundStyle(AtlasColor.smoke)
                Text("La evidencia visual muestra una alteración respecto a la línea base. Se recomienda validación humana antes de ejecutar una intervención.")
                    .font(AtlasType.ui(13))
                    .foregroundStyle(AtlasColor.porcelainSoft)
                    .lineSpacing(4)
            }
        }
    }
}
