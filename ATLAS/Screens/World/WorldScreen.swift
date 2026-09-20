import SwiftUI

struct WorldScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    @ObservedObject private var connectivity = AtlasConnectivityMonitor.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                AppHeader(
                    greeting: "Buenos días · tu mundo está al día",
                    openSearch: { open(.search) },
                    openNotifications: { open(.notifications) }
                )

                if !connectivity.isConnected {
                    offlineBanner
                }

                hero
                overviewMetrics
                attention
                recentStates
                importantChanges
                upcoming
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            AtlasSectionLabel(index: "01", title: "MUNDO / RESUMEN", trailing: "HOY")

            Text("Una lectura clara de tu mundo físico.")
                .font(AtlasType.display(.largeTitle, weight: .semibold))
                .tracking(-1.1)
                .foregroundStyle(AtlasColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("ATLAS reúne cambios, estados, evidencia y próximas acciones sin convertir tu iPhone en un panel empresarial.")
                .font(AtlasType.body(.body))
                .foregroundStyle(AtlasColor.inkSecondary)
                .lineSpacing(4)

            HStack(spacing: 12) {
                Button(action: startScan) {
                    Label("Escanear", systemImage: "viewfinder")
                        .font(AtlasType.body(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 48)
                        .background(AtlasColor.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { open(.askAtlas) } label: {
                    Label("Preguntar", systemImage: "sparkles")
                        .font(AtlasType.body(.body, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 48)
                        .background(AtlasColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var overviewMetrics: some View {
        VStack(spacing: 14) {
            AtlasDivider()
            HStack(alignment: .top, spacing: 0) {
                Metric(value: "12", label: "Activos", footnote: "11 monitoreados")
                Rectangle().fill(AtlasColor.line).frame(width: 1, height: 68).padding(.horizontal, 10)
                Metric(value: "03", label: "Atención", footnote: "1 alta")
                Rectangle().fill(AtlasColor.line).frame(width: 1, height: 68).padding(.horizontal, 10)
                Metric(value: "41", label: "Cambios", footnote: "7 días")
            }
            AtlasDivider()
            HStack {
                Text("ÚLTIMA SINCRONIZACIÓN")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.inkMuted)
                Spacer()
                SyncBadge(state: connectivity.isConnected ? .synced : .local)
                Text(connectivity.isConnected ? "Hace 2 min" : "Pendiente")
                    .font(AtlasType.mono(.caption2))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
    }

    private var attention: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "02", title: "REQUIERE ATENCIÓN", trailing: "03 activos")
            AlertRow(
                level: "ALTA",
                title: "Posible humedad recurrente",
                detail: "Apartamento Norte · cocina · hace 18 min",
                color: AtlasColor.critical,
                action: { open(.anomalyDetail) }
            )
            AtlasDivider()
            AlertRow(
                level: "MEDIA",
                title: "Cambio visual sin clasificar",
                detail: "Vehículo diario · puerta izquierda · hace 2 h",
                color: AtlasColor.attention,
                action: { open(.changeDetail) }
            )

            Button("Ver todas las alertas") { open(.alerts) }
                .font(AtlasType.body(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
                .padding(.top, 4)
        }
    }

    private var recentStates: some View {
        VStack(alignment: .leading, spacing: 6) {
            AtlasSectionLabel(index: "03", title: "ESTADOS RECIENTES", trailing: "5 capturas")
            ForEach(Array(AtlasSampleData.assets.prefix(3).enumerated()), id: \.element.id) { index, asset in
                WorldStateRow(index: String(format: "%02d", index + 1), asset: asset) {
                    open(.assetDetail)
                }
                if index < 2 { AtlasDivider() }
            }
        }
    }

    private var importantChanges: some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: "04", title: "CAMBIOS", trailing: "Memoria física")
            ForEach(AtlasSampleData.changes.prefix(2)) { change in
                ChangeRow(change: change) { open(.changeDetail) }
            }
            Button("Abrir memoria completa") { open(.compare) }
                .font(AtlasType.body(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
        }
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: "05", title: "PRÓXIMAMENTE", trailing: "2 acciones")
            InspectionRow(inspection: AtlasSampleData.inspections[0]) { open(.inspections) }
            AtlasDivider()
            PrimaryActionRow(
                title: "Mantenimiento preventivo",
                subtitle: "Unidad M-028 · mañana",
                symbol: "wrench.and.screwdriver"
            ) { open(.maintenance) }
        }
    }

    private var offlineBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(AtlasColor.attention)
            VStack(alignment: .leading, spacing: 3) {
                Text("Trabajando en local")
                    .font(AtlasType.body(.subheadline, weight: .semibold))
                    .foregroundStyle(AtlasColor.ink)
                Text("Puedes seguir capturando evidencia. ATLAS sincronizará cuando vuelva la conexión.")
                    .font(AtlasType.body(.caption))
                    .foregroundStyle(AtlasColor.inkSecondary)
            }
            Spacer()
            SyncBadge(state: .local)
        }
        .padding(14)
        .background(AtlasColor.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
