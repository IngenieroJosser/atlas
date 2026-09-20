import SwiftUI

struct WorldScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    @ObservedObject private var connectivity = AtlasConnectivityMonitor.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 34) {
                AppHeader(
                    greeting: "Buenos días · 3 señales requieren atención",
                    openSearch: { open(.search) },
                    openNotifications: { open(.notifications) }
                )
                .atlasStagger(0, distance: 6)

                if !connectivity.isConnected {
                    offlineBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                worldHero.atlasStagger(1)
                attention.atlasStagger(2)
                recentStates.atlasStagger(3)
                importantChanges.atlasStagger(4)
                upcoming.atlasStagger(5)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .animation(AtlasMotion.standardAnimation, value: connectivity.isConnected)
    }

    private var worldHero: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                AtlasColor.navy

                WorldGrid()
                    .opacity(0.18)

                Circle()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    .frame(width: 170, height: 170)
                    .offset(x: 205, y: 90)

                Circle()
                    .fill(AtlasColor.blue)
                    .frame(width: 10, height: 10)
                    .offset(x: 276, y: 168)

                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(connectivity.isConnected ? AtlasColor.healthy : AtlasColor.attention)
                                .frame(width: 7, height: 7)
                            Text(connectivity.isConnected ? "WORLD / LIVE" : "WORLD / LOCAL")
                                .font(AtlasType.label(.caption2, weight: .semibold))
                                .tracking(1.0)
                        }
                        .foregroundStyle(Color.white.opacity(0.72))

                        Spacer()

                        Text("20 SEP · 16:39")
                            .font(AtlasType.mono(.caption2, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.5))
                    }

                    Text("Tu mundo físico,\nleído con contexto.")
                        .font(AtlasType.display(.largeTitle, weight: .semibold))
                        .tracking(-1.35)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("ATLAS conecta estados, evidencia y cambios para que veas qué importa antes de entrar al detalle.")
                        .font(AtlasType.body(.body, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .lineSpacing(4)
                        .frame(maxWidth: 330, alignment: .leading)

                    HStack(spacing: 10) {
                        Button(action: startScan) {
                            HStack(spacing: 9) {
                                Image(systemName: "viewfinder")
                                Text("Escanear ahora")
                            }
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasColor.navy)
                            .padding(.horizontal, 15)
                            .frame(height: 46)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                        }
                        .buttonStyle(AtlasPressButtonStyle())

                        Button { open(.askAtlas) } label: {
                            HStack(spacing: 9) {
                                Image(systemName: "sparkles")
                                Text("Preguntar")
                            }
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                            .frame(height: 46)
                            .overlay {
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            }
                        }
                        .buttonStyle(AtlasPressButtonStyle())
                    }
                }
                .padding(20)
            }
            .frame(minHeight: 330)

            HStack(spacing: 0) {
                heroMetric("12", "ACTIVOS")
                heroRule
                heroMetric("03", "ATENCIÓN")
                heroRule
                heroMetric("41", "CAMBIOS")
                heroRule
                heroMetric("98%", "SYNC")
            }
            .padding(.horizontal, 16)
            .frame(height: 86)
            .background(AtlasColor.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AtlasColor.line, lineWidth: 1)
        }
    }

    private func heroMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(AtlasType.heading(.title3, weight: .semibold))
                .tracking(-0.6)
                .foregroundStyle(AtlasColor.ink)
            Text(label)
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.75)
                .foregroundStyle(AtlasColor.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroRule: some View {
        Rectangle()
            .fill(AtlasColor.line)
            .frame(width: 1, height: 44)
            .padding(.horizontal, 8)
    }

    private var attention: some View {
        VStack(alignment: .leading, spacing: 12) {
            AtlasSectionLabel(index: "02", title: "REQUIERE ATENCIÓN", trailing: "03 activos")

            Text("Lo que necesita una decisión.")
                .font(AtlasType.heading(.title2, weight: .semibold))
                .tracking(-0.55)
                .foregroundStyle(AtlasColor.ink)

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

            Button("Ver todas las alertas →") { open(.alerts) }
                .font(AtlasType.body(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
                .padding(.top, 3)
        }
    }

    private var recentStates: some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: "03", title: "ESTADOS RECIENTES", trailing: "5 capturas")

            Text("La memoria más reciente de tus activos.")
                .font(AtlasType.heading(.title2, weight: .semibold))
                .tracking(-0.55)
                .foregroundStyle(AtlasColor.ink)
                .padding(.bottom, 2)

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

            Text("Qué cambió desde la última vez.")
                .font(AtlasType.heading(.title2, weight: .semibold))
                .tracking(-0.55)
                .foregroundStyle(AtlasColor.ink)
                .padding(.bottom, 2)

            ForEach(AtlasSampleData.changes.prefix(2)) { change in
                ChangeRow(change: change) { open(.changeDetail) }
            }

            Button("Abrir memoria completa →") { open(.compare) }
                .font(AtlasType.body(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
                .padding(.top, 2)
        }
    }

    private var upcoming: some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: "05", title: "PRÓXIMAMENTE", trailing: "2 acciones")

            Text("Lo siguiente, sin ruido.")
                .font(AtlasType.heading(.title2, weight: .semibold))
                .tracking(-0.55)
                .foregroundStyle(AtlasColor.ink)
                .padding(.bottom, 2)

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
            Rectangle()
                .fill(AtlasColor.attention)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Trabajando en local")
                    .font(AtlasType.heading(.subheadline, weight: .semibold))
                    .foregroundStyle(AtlasColor.ink)
                Text("Puedes seguir capturando evidencia. ATLAS sincronizará cuando vuelva la conexión.")
                    .font(AtlasType.body(.caption, weight: .medium))
                    .foregroundStyle(AtlasColor.inkSecondary)
            }
            Spacer()
            SyncBadge(state: .local)
        }
        .padding(.vertical, 12)
    }
}

private struct WorldGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let step: CGFloat = 34
                var x: CGFloat = 0
                while x <= proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += step
                }
                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += step
                }
            }
            .stroke(Color.white.opacity(0.22), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}
