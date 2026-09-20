import SwiftUI

struct AssetsScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    @State private var query = ""

    private var filtered: [AtlasAsset] {
        guard !query.isEmpty else { return AtlasSampleData.assets }
        return AtlasSampleData.assets.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.kind.localizedCaseInsensitiveContains(query) ||
            $0.subtitle.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                AtlasEditorialHeader(
                    eyebrow: "ASSETS / ACTIVOS",
                    title: "Tu inventario físico, sin ruido.",
                    subtitle: "Busca, filtra y entra al estado actual de cada activo.",
                    trailingSymbol: "plus",
                    trailingAction: { open(.addAsset) }
                )

                HStack(spacing: 10) {
                    AtlasSearchField(text: $query, placeholder: "Buscar activos")
                    Button { open(.filters) } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                            .frame(width: 48, height: 48)
                            .background(AtlasColor.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(AtlasPressButtonStyle())
                    .accessibilityLabel("Filtros")
                }

                if filtered.isEmpty {
                    AtlasEmptyState(
                        eyebrow: "ASSETS / EMPTY",
                        title: "Tu mundo físico empieza aquí.",
                        detail: "Escanea tu primer activo para crear su primer estado del mundo.",
                        actionTitle: "Escanear activo",
                        action: startScan
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(filtered) { asset in
                            AssetRow(asset: asset) { open(.assetDetail) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
    }
}

struct SearchScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasEditorialHeader(eyebrow: "SEARCH", title: "Busca en tu mundo.", backAction: { dismiss() })
                    AtlasSearchField(text: $query, placeholder: "Activos, lugares, eventos, texto…")

                    if query.isEmpty {
                        recentQueries
                    } else if query.lowercased().contains("xyz") {
                        AtlasEmptyState(
                            eyebrow: "SEARCH / NO RESULTS",
                            title: "No encontramos coincidencias.",
                            detail: "Prueba con el nombre de un activo, una ubicación, un identificador o texto reconocido.",
                            actionTitle: nil,
                            action: nil
                        )
                    } else {
                        groupedResults
                    }
                }
                .padding(20)
            }
        }
    }

    private var recentQueries: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "01", title: "BÚSQUEDAS RECIENTES")
            ForEach(["M-028", "Apartamento Norte", "humedad cocina"], id: \.self) { item in
                Button { query = item } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(AtlasColor.inkMuted)
                        Text(item)
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.ink)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(AtlasPressButtonStyle())
                AtlasDivider()
            }
        }
    }

    private var groupedResults: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 0) {
                AtlasSectionLabel(index: "01", title: "ACTIVOS", trailing: "3")
                ForEach(AtlasSampleData.assets.prefix(3)) { asset in
                    AssetRow(asset: asset) { open(.assetDetail) }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                AtlasSectionLabel(index: "02", title: "EVENTOS", trailing: "2")
                ForEach(AtlasSampleData.changes.prefix(2)) { change in
                    ChangeRow(change: change) { open(.changeDetail) }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                AtlasSectionLabel(index: "03", title: "TEXTO RECONOCIDO", trailing: "OCR")
                Text("SERIAL M-028 · MODEL XR-42 · MAINTENANCE 2026")
                    .font(AtlasType.mono(.caption))
                    .foregroundStyle(AtlasColor.inkSecondary)
                    .padding(.vertical, 12)
            }
        }
    }
}

struct FiltersScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var onlyAnomalies = false
    @State private var pendingMaintenance = false
    @State private var selectedType = "Todos"
    @State private var selectedStatus = "Todos"

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(eyebrow: "FILTERS", title: "Reduce el mundo a lo relevante.", backAction: { dismiss() })

                    filterGroup(title: "TIPO", values: ["Todos", "Propiedad", "Vehículo", "Equipo", "Infraestructura"], selection: $selectedType)
                    filterGroup(title: "ESTADO", values: ["Todos", "Saludable", "Atención", "Advertencia", "Crítico"], selection: $selectedStatus)

                    VStack(spacing: 0) {
                        Toggle("Con anomalías", isOn: $onlyAnomalies)
                            .font(AtlasType.body(.body, weight: .medium))
                            .tint(AtlasColor.blue)
                            .padding(.vertical, 14)
                        AtlasDivider()
                        Toggle("Mantenimiento pendiente", isOn: $pendingMaintenance)
                            .font(AtlasType.body(.body, weight: .medium))
                            .tint(AtlasColor.blue)
                            .padding(.vertical, 14)
                    }

                    AtlasPrimaryButton(title: "Aplicar filtros", symbol: "checkmark") { dismiss() }
                }
                .padding(20)
            }
        }
    }

    private func filterGroup(title: String, values: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.inkMuted)
            FlowLayout(spacing: 8) {
                ForEach(values, id: \.self) { value in
                    Button { selection.wrappedValue = value } label: {
                        Text(value)
                            .font(AtlasType.body(.subheadline, weight: .medium))
                            .foregroundStyle(selection.wrappedValue == value ? .white : AtlasColor.ink)
                            .padding(.horizontal, 12)
                            .frame(minHeight: 38)
                            .background(selection.wrappedValue == value ? AtlasColor.blue : AtlasColor.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(AtlasPressButtonStyle())
                }
            }
        }
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: spacing)], spacing: spacing) {
            content
        }
    }
}
