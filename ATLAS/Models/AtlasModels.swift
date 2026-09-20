import SwiftUI
import Foundation

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
        case .world: return "circle.grid.2x2"
        case .assets: return "cube.transparent"
        case .changes: return "clock.arrow.circlepath"
        case .profile: return "person.crop.circle"
        }
    }
}

enum AtlasRoute: Hashable {
    case search
    case notifications
    case alerts
    case reports
    case reportDetail
    case reportExport
    case assetDetail
    case addAsset
    case editAsset
    case spatialMap
    case digitalTwin
    case inspections
    case inspectionDetail
    case findings
    case findingDetail
    case evidence
    case maintenance
    case workOrderDetail
    case askAtlas
    case aiHistory
    case compare
    case activityLog
    case settings
    case account
    case organization
    case team
    case subscription
    case integrations
    case security
    case syncStorage
    case permissions
    case privacy
    case help
    case about
    case onboarding
    case login
    case forgotPassword
    case verification
    case createAccount
    case screenMap
}

enum AtlasSheet: Identifiable {
    case scan
    var id: Int { 0 }
}

enum ScanStep: Int, CaseIterable {
    case intro, capture, processing, result
}

enum ScanMode: String, CaseIterable, Identifiable {
    case space = "Espacio"
    case object = "Objeto"
    case vehicle = "Vehículo"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .space: return "square.3.layers.3d"
        case .object: return "cube.transparent"
        case .vehicle: return "car.side"
        }
    }
}

struct AtlasAsset: Identifiable, Hashable {
    let id = UUID()
    let type: String
    let name: String
    let detail: String
    let symbol: String
    let state: String
    let tintHex: String

    var tint: Color { Color(hex: tintHex) }
}

struct AtlasChange: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let title: String
    let detail: String
    let symbol: String
    let tintHex: String
    var tint: Color { Color(hex: tintHex) }
}

struct AtlasAlert: Identifiable {
    let id = UUID()
    let level: String
    let title: String
    let detail: String
    let time: String
    let symbol: String
    let tintHex: String
    var tint: Color { Color(hex: tintHex) }
}

enum AtlasSampleData {
    static let assets: [AtlasAsset] = [
        .init(type: "PROPIEDAD", name: "Apartamento Norte", detail: "84,2 m² · 7 espacios", symbol: "building.2", state: "Saludable", tintHex: "91B7FF"),
        .init(type: "VEHÍCULO", name: "Vehículo diario", detail: "Exterior · Actualizado hoy", symbol: "car.side", state: "2 cambios", tintHex: "FFB66E"),
        .init(type: "EQUIPO", name: "Unidad de enfriamiento M-028", detail: "Operativa · 08:16", symbol: "fan", state: "Estable", tintHex: "9DEBD9"),
        .init(type: "INFRAESTRUCTURA", name: "Panel eléctrico", detail: "Línea base · Sin hallazgos", symbol: "bolt", state: "Saludable", tintHex: "AF9BFF"),
        .init(type: "PROPIEDAD", name: "Estudio 04", detail: "51,8 m² · 4 espacios", symbol: "house", state: "Revisar", tintHex: "FF7F8E")
    ]

    static let changes: [AtlasChange] = [
        .init(time: "09:42", title: "Anomalía superficial detectada", detail: "Pared de cocina · Apartamento Norte", symbol: "drop.triangle", tintHex: "FFB66E"),
        .init(time: "08:16", title: "Inspección completada", detail: "Unidad M-028 · Estado estable", symbol: "checkmark.seal", tintHex: "9DEBD9"),
        .init(time: "AYER", title: "Nuevo estado del mundo", detail: "Vehículo diario · Exterior", symbol: "square.stack.3d.up", tintHex: "91B7FF"),
        .init(time: "18 SEP", title: "Geometría modificada", detail: "Estudio 04 · Sala", symbol: "cube.transparent", tintHex: "AF9BFF"),
        .init(time: "17 SEP", title: "Inspección archivada", detail: "Panel eléctrico · Línea base", symbol: "archivebox", tintHex: "8E99A7")
    ]

    static let alerts: [AtlasAlert] = [
        .init(level: "ALTA", title: "Posible humedad recurrente", detail: "Apartamento Norte · Cocina", time: "Hace 18 min", symbol: "drop.triangle", tintHex: "FF7F8E"),
        .init(level: "MEDIA", title: "Cambio visual sin clasificar", detail: "Vehículo diario · Puerta izquierda", time: "Hace 2 h", symbol: "exclamationmark.triangle", tintHex: "FFB66E"),
        .init(level: "BAJA", title: "Revisión preventiva recomendada", detail: "Unidad M-028 · 38 días desde revisión", time: "Ayer", symbol: "wrench.adjustable", tintHex: "91B7FF")
    ]
}
