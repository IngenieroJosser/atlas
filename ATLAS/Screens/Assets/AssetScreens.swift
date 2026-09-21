import SwiftUI

struct AssetsScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    @EnvironmentObject private var store: AtlasAppStore
    @State private var query = ""
    @State private var selectedStatus = "Todos"

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        AtlasSectionLabel(index: "02", title: "ASSETS")
                        Text("Activos")
                            .font(AtlasType.display(.largeTitle, weight: .semibold))
                            .tracking(-1.1)
                            .foregroundStyle(AtlasColor.ink)
                    }
                    Spacer()
                    HeaderIcon(symbol: "slider.horizontal.3", label: "Filtros") { open(.filters) }
                }

                AtlasSearchField(text: $query, placeholder: "Buscar activos")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Todos", "Estable", "Atención", "Crítico"], id: \.self) { item in
                            Button(item) { selectedStatus = item }
                                .font(AtlasType.label(.caption, weight: .semibold))
                                .foregroundStyle(selectedStatus == item ? .white : AtlasColor.inkSecondary)
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .background(selectedStatus == item ? AtlasColor.navy : AtlasColor.surfaceSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }

                HStack {
                    Text("\(filteredAssets.count) activos")
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)
                    Spacer()
                    Button("Nuevo activo") { open(.addAsset) }
                        .font(AtlasType.body(.subheadline, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                }

                if store.assets.isEmpty && store.isRefreshing {
                    AtlasLoadingState(title: "Cargando activos…", detail: "Sincronizando con ATLAS API.")
                } else if filteredAssets.isEmpty {
                    AtlasEmptyState(title: query.isEmpty ? "Tu mundo físico empieza aquí" : "Sin resultados", detail: query.isEmpty ? "Escanea tu primer activo para crear su primer estado." : "Prueba otro nombre, categoría o ubicación.", symbol: "shippingbox")
                    if query.isEmpty { AtlasPrimaryButton(title: "Escanear activo", symbol: "viewfinder", action: startScan) }
                } else {
                    VStack(spacing: 0) {
                        ForEach(filteredAssets) { asset in
                            AssetRow(asset: asset.presentation) {
                                Task {
                                    await store.selectAsset(asset.id)
                                    open(.assetDetail)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .refreshable { await store.refreshWorld() }
    }

    private var filteredAssets: [APIAssetSummary] {
        store.assets.filter { asset in
            let matchesText = query.isEmpty || [asset.name, asset.category, asset.location, asset.identifier].joined(separator: " ").localizedCaseInsensitiveContains(query)
            let matchesStatus: Bool
            switch selectedStatus {
            case "Estable": matchesStatus = ["stable", "healthy", "verified"].contains(asset.status.lowercased())
            case "Atención": matchesStatus = ["attention", "warning", "review"].contains(asset.status.lowercased())
            case "Crítico": matchesStatus = asset.status.lowercased() == "critical"
            default: matchesStatus = true
            }
            return matchesText && matchesStatus
        }
    }
}

struct SearchScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore
    @State private var query = ""
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Buscar", eyebrow: "GLOBAL / SEARCH")
                    AtlasSearchField(text: $query, placeholder: "Activos, inspecciones, reportes, texto…")

                    if query.count < 2 {
                        AtlasEmptyState(title: "Busca en tu mundo", detail: "ATLAS busca activos, eventos, inspecciones, órdenes, reportes y texto reconocido.", symbol: "magnifyingglass")
                    } else if store.searchResults.isEmpty && store.isLoading {
                        AtlasLoadingState(title: "Buscando…", detail: "Consultando la memoria física de ATLAS.")
                    } else if store.searchResults.isEmpty {
                        AtlasEmptyState(title: "Sin resultados", detail: "No encontramos coincidencias para “\(query)”.", symbol: "magnifyingglass")
                    } else {
                        VStack(spacing: 0) {
                            ForEach(store.searchResults) { result in
                                Button {
                                    navigate(result)
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: icon(for: result.type))
                                            .foregroundStyle(AtlasColor.blue)
                                            .frame(width: 34)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.type.uppercased())
                                                .font(AtlasType.label(.caption2, weight: .semibold))
                                                .foregroundStyle(AtlasColor.inkMuted)
                                            Text(result.title)
                                                .font(AtlasType.heading(.headline, weight: .semibold))
                                                .foregroundStyle(AtlasColor.ink)
                                            if !result.subtitle.isEmpty {
                                                Text(result.subtitle)
                                                    .font(AtlasType.body(.caption))
                                                    .foregroundStyle(AtlasColor.inkMuted)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.right").foregroundStyle(AtlasColor.inkMuted)
                                    }
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(AtlasPressButtonStyle())
                                AtlasDivider()
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .onChange(of: query) { _, value in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(280))
                if !Task.isCancelled { await store.search(value) }
            }
        }
        .onDisappear { searchTask?.cancel() }
    }

    private func navigate(_ result: APISearchResult) {
        Task {
            switch result.type.lowercased() {
            case "asset": await store.selectAsset(result.id); open(.assetDetail)
            case "change": await store.selectChange(result.id); open(.changeDetail)
            case "inspection": await store.selectInspection(result.id); open(.inspectionResult)
            case "work_order", "work-order": await store.selectWorkOrder(result.id); open(.workOrderDetail)
            case "report": await store.selectReport(result.id); open(.reportDetail)
            case "anomaly": await store.selectAnomaly(result.id); open(.anomalyDetail)
            default: break
            }
        }
    }

    private func icon(for type: String) -> String {
        switch type.lowercased() {
        case "asset": "shippingbox"
        case "inspection": "checklist"
        case "work_order", "work-order": "wrench.and.screwdriver"
        case "report": "doc.text"
        case "change": "clock.arrow.circlepath"
        default: "magnifyingglass"
        }
    }
}

struct FiltersScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var status = "Todos"
    @State private var type = "Todos"
    @State private var anomalies = false
    @State private var changes = false
    @State private var maintenance = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Filtros", eyebrow: "ASSETS / FILTER")
                    filterPicker("TIPO", selection: $type, values: ["Todos", "Property", "Vehicle", "Equipment", "Infrastructure", "Document"])
                    filterPicker("ESTADO", selection: $status, values: ["Todos", "Stable", "Attention", "Warning", "Critical"])
                    Toggle("Con anomalías", isOn: $anomalies)
                    Toggle("Con cambios", isOn: $changes)
                    Toggle("Mantenimiento pendiente", isOn: $maintenance)
                    Text("Estos filtros visuales están preparados para los parámetros equivalentes de GET /assets.")
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .padding(20)
            }
        }
    }

    private func filterPicker(_ title: String, selection: Binding<String>, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
            Picker(title, selection: selection) { ForEach(values, id: \.self) { Text($0).tag($0) } }
                .pickerStyle(.menu)
        }
    }
}

struct AtlasBackHeader: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let eyebrow: String
    var body: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                .foregroundStyle(AtlasColor.ink)
            VStack(alignment: .leading, spacing: 2) {
                Text(eyebrow).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
                Text(title).font(AtlasType.heading(.title2, weight: .semibold)).foregroundStyle(AtlasColor.ink)
            }
            Spacer()
        }
    }
}
