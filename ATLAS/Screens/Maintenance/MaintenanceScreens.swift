import SwiftUI

struct MaintenanceScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Maintenance", eyebrow: "OPERATIONS / MAINTENANCE")
                    HStack(spacing: 8) {
                        Metric(value: String(store.maintenance.filter { $0.status.lowercased() == "upcoming" }.count), label: "Upcoming")
                        Metric(value: String(store.maintenance.filter { $0.status.lowercased() == "overdue" }.count), label: "Overdue")
                        Metric(value: String(store.maintenance.filter { $0.suggestedByAtlas }.count), label: "ATLAS")
                    }
                    if store.maintenance.isEmpty {
                        AtlasEmptyState(title: "Sin mantenimiento", detail: "Las tareas planificadas o sugeridas por ATLAS aparecerán aquí.", symbol: "wrench.and.screwdriver")
                    } else {
                        ForEach(store.maintenance) { task in
                            Button {
                                Task { await store.selectMaintenance(task.id); open(.maintenanceDetail) }
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(task.status.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(task.priority.atlasHealth.color)
                                        Spacer()
                                        Text(task.dueAt?.atlasRelative ?? "Sin fecha").font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted)
                                    }
                                    Text(task.title).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                    Text("\(assetName(task.assetId)) · \(task.priority.atlasDisplay)").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                                    if task.suggestedByAtlas { Text("SUGGESTED BY ATLAS").font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.blue) }
                                }
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(AtlasPressButtonStyle())
                            AtlasDivider()
                        }
                    }
                }.padding(20)
            }
        }
    }

    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}

struct MaintenanceDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Maintenance detail", eyebrow: "TASK / DETAIL")
                    if let task = store.selectedMaintenance {
                        HStack { StatusBadge(health: task.priority.atlasHealth); Spacer(); Text(task.status.uppercased()).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted) }
                        Text(task.title).font(AtlasType.display(.title, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        Text(task.description.ifEmpty("Sin descripción adicional.")).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                        MetadataLabel(title: "Activo", value: assetName(task.assetId))
                        MetadataLabel(title: "Prioridad", value: task.priority.atlasDisplay)
                        MetadataLabel(title: "Fecha prevista", value: task.dueAt?.atlasFull ?? "Sin fecha")
                        MetadataLabel(title: "Responsable", value: task.assigneeUserId == nil ? "Sin asignar" : "Usuario asignado")
                        MetadataLabel(title: "Origen", value: task.suggestedByAtlas ? "Sugerido por ATLAS" : (task.sourceType?.atlasDisplay ?? "Manual"))

                        if task.status.lowercased() != "completed" {
                            AtlasPrimaryButton(title: "Marcar completado", symbol: "checkmark") { Task { await store.completeMaintenance(task.id) } }
                        }
                        AtlasSecondaryButton(title: "Crear Work Order", symbol: "wrench.and.screwdriver") {
                            Task {
                                if let order = await store.createWorkOrder(assetId: task.assetId, title: task.title, description: task.description, priority: task.priority) {
                                    await store.selectWorkOrder(order.id); open(.workOrderDetail)
                                }
                            }
                        }
                    } else { AtlasLoadingState(title: "Cargando tarea…", detail: "Recuperando mantenimiento y relaciones.") }
                }.padding(20)
            }
        }
    }
    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}

struct WorkOrdersScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .bottom) {
                        AtlasBackHeader(title: "Work Orders", eyebrow: "OPERATIONS / WORK")
                        Spacer()
                    }
                    if store.workOrders.isEmpty {
                        AtlasEmptyState(title: "Sin órdenes", detail: "Crea una orden desde un activo, anomalía, inspección o mantenimiento.", symbol: "wrench.and.screwdriver")
                    } else {
                        ForEach(store.workOrders) { order in
                            Button {
                                Task { await store.selectWorkOrder(order.id); open(.workOrderDetail) }
                            } label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack {
                                        Text(order.code).font(AtlasType.mono(.caption, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                                        Spacer()
                                        Text(order.priority.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(order.priority.atlasHealth.color)
                                    }
                                    Text(order.title).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                    Text("\(assetName(order.assetId)) · \(order.status.atlasDisplay)").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                                }.padding(.vertical, 14)
                            }.buttonStyle(AtlasPressButtonStyle())
                            AtlasDivider()
                        }
                    }
                    AtlasPrimaryButton(title: "Crear Work Order", symbol: "plus") { open(.createWorkOrder) }
                }.padding(20)
            }
        }
    }
    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}

struct CreateWorkOrderScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AtlasAppStore
    @State private var assetId = ""
    @State private var title = ""
    @State private var description = ""
    @State private var priority = "medium"

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Nueva orden", eyebrow: "WORK ORDER / NEW")
                    Picker("Activo", selection: $assetId) {
                        Text("Selecciona activo").tag("")
                        ForEach(store.assets) { Text($0.name).tag($0.id) }
                    }.pickerStyle(.menu)
                    field("TÍTULO", $title)
                    field("DESCRIPCIÓN", $description)
                    Picker("Prioridad", selection: $priority) {
                        ForEach(["low", "medium", "high", "critical"], id: \.self) { Text($0.atlasDisplay).tag($0) }
                    }.pickerStyle(.segmented)
                    AtlasPrimaryButton(title: "Crear orden", symbol: "checkmark") {
                        Task {
                            if await store.createWorkOrder(assetId: assetId, title: title, description: description, priority: priority) != nil { dismiss() }
                        }
                    }.disabled(assetId.isEmpty || title.isEmpty)
                }.padding(20)
            }
        }
        .onAppear { assetId = store.selectedAssetID ?? store.assets.first?.id ?? "" }
    }
    private func field(_ label: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
            TextField(label, text: text, axis: .vertical).font(AtlasType.body(.body)).frame(minHeight: 46)
                .overlay(alignment: .bottom) { Rectangle().fill(AtlasColor.lineStrong).frame(height: 1) }
        }
    }
}

struct WorkOrderDetailScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Work Order", eyebrow: "OPERATIONS / DETAIL")
                    if let detail = store.selectedWorkOrder {
                        Text(detail.workOrder.code).font(AtlasType.mono(.headline, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                        Text(detail.workOrder.title).font(AtlasType.display(.title, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        Text(detail.workOrder.description.ifEmpty("Sin descripción adicional.")).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                        MetadataLabel(title: "Activo", value: assetName(detail.workOrder.assetId))
                        MetadataLabel(title: "Prioridad", value: detail.workOrder.priority.atlasDisplay)
                        MetadataLabel(title: "Estado", value: detail.workOrder.status.atlasDisplay)
                        MetadataLabel(title: "Responsable", value: detail.workOrder.assigneeUserId == nil ? "Sin asignar" : "Usuario asignado")
                        AtlasSectionLabel(index: "01", title: "TIMELINE")
                        if detail.events.isEmpty { Text("Sin eventos todavía.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkMuted) }
                        ForEach(detail.events) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.eventType.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.blue)
                                Text(event.detail).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.ink)
                                Text(event.createdAt.atlasFull).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.inkMuted)
                            }.padding(.vertical, 8)
                        }
                    } else { AtlasLoadingState(title: "Cargando orden…", detail: "Recuperando estado y timeline.") }
                }.padding(20)
            }
        }
    }
    private func assetName(_ id: String) -> String { store.assets.first(where: { $0.id == id })?.name ?? "Activo" }
}
