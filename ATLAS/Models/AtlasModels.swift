import Foundation
import SwiftUI

enum AtlasTab: String, CaseIterable, Identifiable {
    case world, assets, changes, profile
    var id: String { rawValue }

    var title: String {
        switch self {
        case .world: return "Mundo"
        case .assets: return "Activos"
        case .changes: return "Cambios"
        case .profile: return "Tú"
        }
    }

    var symbol: String {
        switch self {
        case .world: return "globe.americas"
        case .assets: return "shippingbox"
        case .changes: return "clock.arrow.circlepath"
        case .profile: return "person.crop.circle"
        }
    }
}

enum AtlasRoute: Hashable {
    case search
    case filters
    case notifications
    case alerts
    case reports
    case reportDetail
    case assetDetail
    case addAsset
    case digitalTwin
    case inspections
    case newInspection
    case inspectionResult
    case changeDetail
    case compare
    case anomalyDetail
    case maintenance
    case maintenanceDetail
    case workOrders
    case createWorkOrder
    case workOrderDetail
    case askAtlas
    case atlasInsight
    case organization
    case integrations
    case security
    case privacy
    case permissions
    case help
    case settings
    case about
}

enum AtlasSheet: Identifiable {
    case scan
    var id: Int { 0 }
}

enum ScanStep: Int, CaseIterable {
    case mode, capture, processing, result
}

enum ScanMode: String, CaseIterable, Identifiable {
    case auto = "Detección automática"
    case property = "Propiedad"
    case vehicle = "Vehículo"
    case equipment = "Equipo"
    case infrastructure = "Infraestructura"
    case document = "Documento"
    case other = "Otro"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .auto: return "viewfinder"
        case .property: return "building.2"
        case .vehicle: return "car.side"
        case .equipment: return "gearshape.2"
        case .infrastructure: return "bolt.horizontal.circle"
        case .document: return "doc.text.viewfinder"
        case .other: return "square.dashed"
        }
    }

    var shortTitle: String {
        switch self {
        case .auto: return "Auto"
        default: return rawValue
        }
    }
}

enum AtlasHealth: String {
    case healthy = "Saludable"
    case stable = "Estable"
    case attention = "Atención"
    case warning = "Advertencia"
    case critical = "Crítico"
    case verified = "Verificado"

    var color: Color {
        switch self {
        case .healthy, .stable, .verified: return AtlasColor.healthy
        case .attention: return AtlasColor.attention
        case .warning: return AtlasColor.warning
        case .critical: return AtlasColor.critical
        }
    }
}

enum AtlasSyncState: String {
    case local = "LOCAL"
    case syncing = "SYNCING"
    case synced = "SYNCED"
    case failed = "SYNC FAILED"

    var color: Color {
        switch self {
        case .local: return AtlasColor.local
        case .syncing: return AtlasColor.syncing
        case .synced: return AtlasColor.healthy
        case .failed: return AtlasColor.critical
        }
    }
}

struct AtlasAsset: Identifiable, Hashable {
    let id = UUID()
    let kind: String
    let name: String
    let subtitle: String
    let symbol: String
    let health: AtlasHealth
    let updated: String
    let changes: Int
    let syncState: AtlasSyncState
}

struct AtlasChange: Identifiable, Hashable {
    let id = UUID()
    let type: String
    let title: String
    let asset: String
    let detail: String
    let time: String
    let symbol: String
    let health: AtlasHealth
}

struct AtlasInspection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let asset: String
    let date: String
    let status: String
    let progress: Double
}

struct AtlasWorkOrder: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let asset: String
    let title: String
    let priority: String
    let status: String
    let assignee: String
}

struct AtlasEvidence: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
}

enum AtlasSampleData {
    static let assets: [AtlasAsset] = [
        .init(kind: "PROPIEDAD", name: "Apartamento Norte", subtitle: "84,2 m² · 7 espacios", symbol: "building.2", health: .healthy, updated: "Hace 18 min", changes: 0, syncState: .synced),
        .init(kind: "VEHÍCULO", name: "Vehículo diario", subtitle: "Exterior · estado 18", symbol: "car.side", health: .attention, updated: "Hace 2 h", changes: 2, syncState: .synced),
        .init(kind: "EQUIPO", name: "Unidad de enfriamiento M-028", subtitle: "HVAC · Planta 01", symbol: "fan", health: .stable, updated: "Hace 2 h", changes: 2, syncState: .synced),
        .init(kind: "INFRAESTRUCTURA", name: "Panel eléctrico", subtitle: "Línea base · Nivel 2", symbol: "bolt", health: .verified, updated: "Ayer", changes: 0, syncState: .synced),
        .init(kind: "PROPIEDAD", name: "Estudio 04", subtitle: "51,8 m² · 4 espacios", symbol: "house", health: .warning, updated: "18 sep", changes: 4, syncState: .local)
    ]

    static let changes: [AtlasChange] = [
        .init(type: "ANOMALÍA SUPERFICIAL", title: "Posible humedad recurrente", asset: "Apartamento Norte", detail: "Pared de cocina · revisión recomendada", time: "09:42", symbol: "drop.triangle", health: .warning),
        .init(type: "CONDICIÓN VERIFICADA", title: "Sin degradación relevante", asset: "Unidad M-028", detail: "La condición visual permanece estable", time: "08:16", symbol: "checkmark.seal", health: .verified),
        .init(type: "NUEVO ESTADO", title: "Estado del mundo creado", asset: "Vehículo diario", detail: "Exterior · 18 evidencias", time: "AYER", symbol: "square.stack.3d.up", health: .stable),
        .init(type: "GEOMETRÍA MODIFICADA", title: "+4,2 cm detectados", asset: "Estudio 04", detail: "Sala · pared occidental", time: "18 SEP", symbol: "ruler", health: .attention),
        .init(type: "INSPECCIÓN ARCHIVADA", title: "Línea base consolidada", asset: "Panel eléctrico", detail: "Sin hallazgos críticos", time: "17 SEP", symbol: "archivebox", health: .verified)
    ]

    static let inspections: [AtlasInspection] = [
        .init(title: "Inspección visual mensual", asset: "Unidad M-028", date: "Hoy · 15:30", status: "Programada", progress: 0),
        .init(title: "Entrega de inmueble", asset: "Apartamento Norte", date: "19 sep", status: "Completada", progress: 1),
        .init(title: "Revisión exterior", asset: "Vehículo diario", date: "18 sep", status: "En progreso", progress: 0.66)
    ]

    static let workOrders: [AtlasWorkOrder] = [
        .init(code: "WO-2048", asset: "Unidad M-028", title: "Revisar sistema de montaje", priority: "ALTA", status: "Asignada", assignee: "Equipo técnico"),
        .init(code: "WO-2032", asset: "Apartamento Norte", title: "Evaluar origen de humedad", priority: "MEDIA", status: "Abierta", assignee: "Sin asignar"),
        .init(code: "WO-1994", asset: "Panel eléctrico", title: "Verificación preventiva", priority: "BAJA", status: "Completada", assignee: "Mantenimiento")
    ]

    static let evidence: [AtlasEvidence] = [
        .init(title: "Fotografía 01", detail: "Captura principal · 3024 × 4032", symbol: "photo"),
        .init(title: "OCR", detail: "Modelo / serial reconocidos", symbol: "text.viewfinder"),
        .init(title: "Medición", detail: "Distancia estimada · 84 cm", symbol: "ruler")
    ]
}
