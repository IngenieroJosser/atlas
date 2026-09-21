import SwiftUI

struct NotificationsScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    HStack {
                        AtlasBackHeader(title: "Notificaciones", eyebrow: "YOU / INBOX")
                        Spacer()
                    }
                    if store.notifications.isEmpty {
                        AtlasEmptyState(title: "Sin notificaciones", detail: "ATLAS te avisará cuando haya cambios relevantes o tareas pendientes.", symbol: "bell")
                    } else {
                        Button("Marcar todas como leídas") { Task { await store.markAllNotificationsRead() } }
                            .font(AtlasType.body(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                        ForEach(store.notifications) { item in
                            Button {
                                Task {
                                    if item.readAt == nil { await store.markNotificationRead(item.id) }
                                    navigate(item)
                                }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Circle().fill(item.readAt == nil ? AtlasColor.blue : AtlasColor.lineStrong).frame(width: 8, height: 8).padding(.top, 6)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.level.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(item.level.atlasHealth.color)
                                        Text(item.title).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                        Text(item.message).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                                        Text(item.createdAt.atlasRelative).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted)
                                    }
                                    Spacer()
                                }.padding(.vertical, 12)
                            }.buttonStyle(AtlasPressButtonStyle())
                            AtlasDivider()
                        }
                    }
                }.padding(20)
            }
        }
    }

    private func navigate(_ item: APINotification) {
        guard let id = item.entityId, let type = item.entityType?.lowercased() else { return }
        Task {
            switch type {
            case "asset": await store.selectAsset(id); open(.assetDetail)
            case "change": await store.selectChange(id); open(.changeDetail)
            case "anomaly": await store.selectAnomaly(id); open(.anomalyDetail)
            case "inspection": await store.selectInspection(id); open(.inspectionResult)
            case "work_order": await store.selectWorkOrder(id); open(.workOrderDetail)
            case "report": await store.selectReport(id); open(.reportDetail)
            default: break
            }
        }
    }
}

struct AlertsScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    AtlasBackHeader(title: "Alerts", eyebrow: "WORLD / SIGNALS")
                    if store.alerts.isEmpty {
                        AtlasEmptyState(title: "Sin alertas", detail: "No hay señales críticas o de atención activas.", symbol: "checkmark.seal")
                    } else {
                        ForEach(store.alerts) { alert in
                            AlertRow(level: alert.level, title: alert.title, detail: "\(alert.detail) · \(alert.occurredAt.atlasRelative)", color: alert.level.atlasHealth.color) {
                                Task { await navigate(alert) }
                            }
                        }
                    }
                }.padding(20)
            }
        }
    }

    private func navigate(_ alert: APIAlert) async {
        switch alert.entityType.lowercased() {
        case "anomaly": await store.selectAnomaly(alert.entityId); open(.anomalyDetail)
        case "asset": await store.selectAsset(alert.entityId); open(.assetDetail)
        case "maintenance": await store.selectMaintenance(alert.entityId); open(.maintenanceDetail)
        case "work_order": await store.selectWorkOrder(alert.entityId); open(.workOrderDetail)
        default: break
        }
    }
}
