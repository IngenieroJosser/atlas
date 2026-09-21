import SwiftUI

struct WorldScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    @EnvironmentObject private var store: AtlasAppStore
    @StateObject private var connectivity = AtlasConnectivityMonitor.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 30) {
                AppHeader(
                    greeting: greeting,
                    openSearch: { open(.search) },
                    openNotifications: { open(.notifications) }
                )

                worldHero
                metrics
                attentionSection
                recentStatesSection
                changesSection
                upcomingSection

                if let error = store.errorMessage {
                    AtlasErrorState(title: "No pudimos actualizar Mundo", detail: error) {
                        Task { await store.refreshWorld() }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 26)
        }
        .refreshable { await store.refreshWorld() }
        .task {
            if store.worldOverview == nil { await store.refreshWorld() }
            if connectivity.isConnected { await store.flushOfflineQueueIfPossible() }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let firstName = store.profile?.user.fullName.split(separator: " ").first.map(String.init) ?? ""
        let base: String
        switch hour {
        case 5..<12: base = "Buenos días"
        case 12..<19: base = "Buenas tardes"
        default: base = "Buenas noches"
        }
        return firstName.isEmpty ? base : "\(base), \(firstName)"
    }

    private var worldHero: some View {
        ZStack(alignment: .bottomLeading) {
            AtlasColor.navy
            AtlasGridPattern(spacing: 26)
                .opacity(0.14)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("(01) / WORLD / OVERVIEW").font(AtlasType.label(.caption, weight: .semibold)).tracking(0.8).foregroundStyle(Color.white.opacity(0.68))
                    Spacer()
                    HStack(spacing: 7) {
                        Circle()
                            .fill(connectivity.isConnected ? AtlasColor.healthy : AtlasColor.warning)
                            .frame(width: 7, height: 7)
                        Text(connectivity.isConnected ? "LIVE" : "LOCAL")
                            .font(AtlasType.mono(.caption2, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.78))
                    }
                }

                Text("¿Qué está pasando\nen tu mundo físico?")
                    .font(AtlasType.display(.largeTitle, weight: .semibold))
                    .tracking(-1.35)
                    .foregroundStyle(.white)

                Text(connectivity.isConnected
                     ? "ATLAS conecta estados, cambios y acciones en una sola memoria operativa."
                     : "Sin conexión. Las capturas pueden permanecer locales y se sincronizarán cuando vuelva la red.")
                    .font(AtlasType.body(.body))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .lineSpacing(4)

                HStack(spacing: 10) {
                    Button(action: startScan) {
                        Label("Escanear", systemImage: "viewfinder")
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasColor.navy)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(AtlasCompactPressButtonStyle())

                    Button { open(.askAtlas) } label: {
                        Label("Ask ATLAS", systemImage: "sparkles")
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .overlay { RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.24)) }
                    }
                    .buttonStyle(AtlasCompactPressButtonStyle())
                }

                if store.pendingOfflineOperations > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("\(store.pendingOfflineOperations) operaciones pendientes de sincronizar")
                    }
                    .font(AtlasType.body(.caption, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.72))
                }
            }
            .padding(22)
        }
        .frame(minHeight: 330)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .atlasScreenEntrance(distance: 9)
    }

    private var metrics: some View {
        let overview = store.worldOverview
        return VStack(alignment: .leading, spacing: 16) {
            AtlasSectionLabel(index: "02", title: "SEÑALES")
            HStack(alignment: .top, spacing: 8) {
                Metric(value: String(overview?.assetsTotal ?? store.assets.count), label: "Activos")
                Metric(value: String(overview?.monitoredAssets ?? store.assets.filter { $0.latestStateAt != nil }.count), label: "Monitoreados")
                Metric(value: String(overview?.recentChanges ?? store.changes.count), label: "Cambios")
                Metric(value: String(overview?.requiresAttention ?? store.anomalies.filter { $0.status != "dismissed" }.count), label: "Atención")
            }
            if let last = overview?.lastSyncAt ?? store.lastSuccessfulRefresh {
                Text("Última sincronización · \(last.atlasRelative)")
                    .font(AtlasType.body(.caption, weight: .medium))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
    }

    private var attentionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "03", title: "REQUIERE ATENCIÓN", trailing: String(format: "%02d", activeAnomalies.count))
            if activeAnomalies.isEmpty {
                AtlasEmptyState(title: "Sin alertas abiertas", detail: "ATLAS no registra anomalías pendientes en este momento.", symbol: "checkmark.seal")
            } else {
                ForEach(activeAnomalies.prefix(3)) { anomaly in
                    AlertRow(
                        level: anomaly.severity,
                        title: anomaly.title,
                        detail: [assetName(anomaly.assetId), anomaly.locationText].filter { !$0.isEmpty }.joined(separator: " · "),
                        color: anomaly.severity.atlasHealth.color
                    ) {
                        Task { await store.selectAnomaly(anomaly.id); open(.anomalyDetail) }
                    }
                }
                if activeAnomalies.count > 3 {
                    Button("Ver todas las alertas →") { open(.alerts) }
                        .font(AtlasType.body(.subheadline, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                }
            }
        }
    }

    private var recentStatesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: "04", title: "RECENT WORLD STATES")
            let recent = store.assets.filter { $0.latestStateAt != nil }.sorted { ($0.latestStateAt ?? .distantPast) > ($1.latestStateAt ?? .distantPast) }
            if recent.isEmpty {
                AtlasEmptyState(title: "Todavía no hay estados", detail: "Escanea tu primer activo para construir su memoria física.", symbol: "square.stack.3d.up")
            } else {
                ForEach(Array(recent.prefix(4).enumerated()), id: \.element.id) { index, asset in
                    WorldStateRow(index: String(format: "%02d", index + 1), asset: asset.presentation) {
                        Task { await store.selectAsset(asset.id); open(.assetDetail) }
                    }
                    if index < min(recent.count, 4) - 1 { AtlasDivider() }
                }
            }
        }
    }

    private var changesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AtlasSectionLabel(index: "05", title: "CHANGES", trailing: String(format: "%02d", store.changes.count))
            if store.changes.isEmpty {
                AtlasEmptyState(title: "Sin cambios detectados", detail: "Cuando existan dos estados comparables aparecerán aquí.", symbol: "clock.arrow.circlepath")
            } else {
                ForEach(store.changes.prefix(4)) { change in
                    ChangeRow(change: change.presentation(assetName: assetName(change.assetId))) {
                        Task { await store.selectChange(change.id); open(.changeDetail) }
                    }
                }
            }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "06", title: "UPCOMING")
            let nextInspections = store.inspections.filter { $0.status.lowercased() != "completed" }.prefix(2)
            let nextMaintenance = store.maintenance.filter { $0.status.lowercased() != "completed" }.prefix(2)

            if nextInspections.isEmpty && nextMaintenance.isEmpty {
                AtlasEmptyState(title: "Nada pendiente", detail: "No hay inspecciones ni mantenimiento próximos.", symbol: "calendar.badge.checkmark")
            } else {
                ForEach(Array(nextInspections)) { inspection in
                    PrimaryActionRow(
                        title: inspection.title,
                        subtitle: "Inspección · \(assetName(inspection.assetId)) · \((inspection.scheduledFor ?? inspection.createdAt).atlasRelative)",
                        symbol: "checklist"
                    ) {
                        Task { await store.selectInspection(inspection.id); open(.inspectionResult) }
                    }
                }
                ForEach(Array(nextMaintenance)) { task in
                    PrimaryActionRow(
                        title: task.title,
                        subtitle: "Mantenimiento · \(assetName(task.assetId)) · \((task.dueAt ?? task.createdAt).atlasRelative)",
                        symbol: "wrench.and.screwdriver"
                    ) {
                        Task { await store.selectMaintenance(task.id); open(.maintenanceDetail) }
                    }
                }
            }
        }
    }

    private var activeAnomalies: [APIAnomaly] {
        store.anomalies.filter { !["dismissed", "resolved", "closed"].contains($0.status.lowercased()) }
    }

    private func assetName(_ id: String) -> String {
        store.assets.first(where: { $0.id == id })?.name ?? "Activo"
    }
}

private struct AtlasGridPattern: View {
    let spacing: CGFloat
    var body: some View {
        Canvas { context, size in
            var path = Path()
            stride(from: CGFloat.zero, through: size.width, by: spacing).forEach { x in
                path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height))
            }
            stride(from: CGFloat.zero, through: size.height, by: spacing).forEach { y in
                path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(.white), lineWidth: 0.5)
        }
    }
}
