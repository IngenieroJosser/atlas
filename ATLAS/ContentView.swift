// ATLAS v7.1 — Single Target / Drop-in Safe
import SwiftUI
import Foundation


// MARK: - AtlasModels.swift

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
    case assetDetail
    case digitalTwin
    case inspections
    case inspectionDetail
    case askAtlas
    case compare
    case settings
    case account
    case privacy
    case help
    case about
    case onboarding
    case login
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


// MARK: - AtlasComponents.swift

struct AtlasAssetRow: View {
    let asset: AtlasAsset
    var compact = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(asset.tint.opacity(0.11))
                Image(systemName: asset.symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(asset.tint)
            }
            .frame(width: compact ? 44 : 50, height: compact ? 44 : 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.type)
                    .font(AtlasType.mono(8.5, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(AtlasColor.smoke)
                Text(asset.name)
                    .font(AtlasType.ui(compact ? 14.5 : 16, weight: .semibold))
                    .foregroundStyle(AtlasColor.porcelain)
                    .lineLimit(1)
                Text(asset.detail)
                    .font(AtlasType.ui(12.5))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 8) {
                Text(asset.state)
                    .font(AtlasType.ui(11.5, weight: .semibold))
                    .foregroundStyle(asset.tint)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AtlasColor.smokeDark)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AtlasChangeRow: View {
    let change: AtlasChange

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 5) {
                Circle()
                    .fill(change.tint)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(change.tint.opacity(0.18))
                    .frame(width: 1, height: 44)
            }
            .padding(.top, 5)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(change.title)
                        .font(AtlasType.ui(14.5, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                    Spacer()
                    Text(change.time)
                        .font(AtlasType.mono(8.5, weight: .semibold))
                        .foregroundStyle(AtlasColor.smokeDark)
                }
                Text(change.detail)
                    .font(AtlasType.ui(12.5))
                    .foregroundStyle(AtlasColor.smoke)
            }
        }
    }
}

struct AtlasMetric: View {
    let value: String
    let label: String
    var tint: Color = AtlasColor.electricBright

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(AtlasType.rounded(27, weight: .bold))
                .foregroundStyle(AtlasColor.porcelain)
            HStack(spacing: 5) {
                Circle().fill(tint).frame(width: 5, height: 5)
                Text(label.uppercased())
                    .font(AtlasType.mono(8.2, weight: .semibold))
                    .tracking(0.7)
                    .foregroundStyle(AtlasColor.smoke)
            }
        }
    }
}

struct AtlasActionRow: View {
    let index: String
    let symbol: String
    let title: String
    let detail: String
    var tint: Color = AtlasColor.electricBright

    var body: some View {
        HStack(spacing: 14) {
            Text(index)
                .font(AtlasType.mono(9, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 22, alignment: .leading)

            ZStack {
                Circle().fill(tint.opacity(0.11))
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(tint)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AtlasType.ui(15, weight: .semibold))
                    .foregroundStyle(AtlasColor.porcelain)
                Text(detail)
                    .font(AtlasType.ui(12.3))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AtlasColor.smoke)
        }
        .padding(.vertical, 8)
    }
}

struct AtlasSettingRow: View {
    let symbol: String
    let title: String
    var detail: String? = nil
    var tint: Color = AtlasColor.electricBright

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(tint.opacity(0.11))
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(tint)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AtlasType.ui(14.5, weight: .medium))
                    .foregroundStyle(AtlasColor.porcelain)
                if let detail {
                    Text(detail)
                        .font(AtlasType.ui(11.5))
                        .foregroundStyle(AtlasColor.smoke)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AtlasColor.smokeDark)
        }
        .padding(.vertical, 5)
    }
}

struct AtlasEmptyState: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: symbol)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(AtlasColor.electricBright)
            Text(title)
                .font(AtlasType.display(26, weight: .medium))
                .foregroundStyle(AtlasColor.porcelain)
            Text(detail)
                .font(AtlasType.ui(13.5))
                .foregroundStyle(AtlasColor.smoke)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

struct AtlasSearchField: View {
    @Binding var text: String
    var placeholder: String = "Buscar"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AtlasColor.smoke)
            TextField(placeholder, text: $text)
                .font(AtlasType.ui(14.5))
                .foregroundStyle(AtlasColor.porcelain)
                .tint(AtlasColor.electricBright)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AtlasColor.smoke)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.045)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
    }
}


// MARK: - WorldScreens.swift

struct WorldScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                header
                hero
                signalStrip
                intelligence
                recentAssets
                recentChanges
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 34)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            AtlasMark(size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text("ATLAS")
                    .font(AtlasType.ui(13.5, weight: .bold))
                    .tracking(2.6)
                    .foregroundStyle(AtlasColor.porcelain)
                Text("INTELIGENCIA FÍSICA")
                    .font(AtlasType.mono(7.5, weight: .semibold))
                    .tracking(1.1)
                    .foregroundStyle(AtlasColor.smoke)
            }

            Spacer()

            AtlasIconButton(symbol: "magnifyingglass") { open(.search) }
            AtlasIconButton(symbol: "bell") { open(.notifications) }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(AtlasColor.aqua).frame(width: 6, height: 6)
                    Text("SISTEMA EN LÍNEA")
                        .font(AtlasType.mono(8.5, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(AtlasColor.smoke)
                }
                Spacer()
                Text("20 SEP 2026")
                    .font(AtlasType.mono(8.5, weight: .medium))
                    .foregroundStyle(AtlasColor.smokeDark)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Tu mundo,\nconvertido en inteligencia.")
                    .font(AtlasType.display(47, weight: .medium))
                    .tracking(-1.75)
                    .foregroundStyle(AtlasColor.porcelain)
                    .lineSpacing(-2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Captura la realidad una vez. ATLAS recuerda su estado, detecta lo que cambió y transforma evidencia física en decisiones.")
                    .font(AtlasType.ui(14.5, weight: .regular))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(4)
            }

            AtlasWorldLens()
                .frame(height: 300)

            HStack(spacing: 10) {
                Button(action: startScan) {
                    HStack(spacing: 9) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 15, weight: .bold))
                        Text("Escanear ahora")
                            .font(AtlasType.ui(14.5, weight: .semibold))
                    }
                    .foregroundStyle(AtlasColor.void)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(AtlasColor.porcelain))
                }
                .buttonStyle(.plain)

                Button { open(.askAtlas) } label: {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                        .frame(width: 52, height: 52)
                        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Color.white.opacity(0.05)))
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var signalStrip: some View {
        VStack(alignment: .leading, spacing: 15) {
            AtlasKicker(index: "00", title: "Estado del sistema", trailing: "En vivo")
            HStack(spacing: 0) {
                AtlasMetric(value: "12", label: "Activos", tint: AtlasColor.electricBright)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AtlasMetric(value: "03", label: "Atención", tint: AtlasColor.amber)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AtlasMetric(value: "41", label: "Cambios", tint: AtlasColor.violet)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AtlasMetric(value: "98%", label: "Sync", tint: AtlasColor.aqua)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 2)
        }
    }

    private var intelligence: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "01", title: "Inteligencia", trailing: "Contextual")

            Text("Lee la realidad desde\ncuatro ángulos.")
                .font(AtlasType.display(34, weight: .medium))
                .tracking(-1.05)
                .foregroundStyle(AtlasColor.porcelain)
                .lineSpacing(-1)

            VStack(spacing: 0) {
                Button { open(.askAtlas) } label: {
                    AtlasActionRow(index: "A", symbol: "sparkles", title: "Preguntar a ATLAS", detail: "Consulta tu mundo físico con memoria y contexto.", tint: AtlasColor.electricBright)
                }
                .buttonStyle(.plain)
                AtlasHairline()
                Button { open(.compare) } label: {
                    AtlasActionRow(index: "B", symbol: "square.split.2x1", title: "Comparar estados", detail: "Observa exactamente qué cambió entre dos capturas.", tint: AtlasColor.violet)
                }
                .buttonStyle(.plain)
                AtlasHairline()
                Button { open(.alerts) } label: {
                    AtlasActionRow(index: "C", symbol: "exclamationmark.triangle", title: "Alertas", detail: "Prioriza anomalías, riesgos y mantenimiento.", tint: AtlasColor.amber)
                }
                .buttonStyle(.plain)
                AtlasHairline()
                Button { open(.reports) } label: {
                    AtlasActionRow(index: "D", symbol: "doc.text", title: "Informes", detail: "Evidencia estructurada para compartir o auditar.", tint: AtlasColor.aqua)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var recentAssets: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "02", title: "Mundo reciente", trailing: "12 activos")

            HStack(alignment: .bottom) {
                Text("Activos con memoria.")
                    .font(AtlasType.display(32, weight: .medium))
                    .tracking(-1)
                    .foregroundStyle(AtlasColor.porcelain)
                Spacer()
                Button("Ver todos") { open(.assetDetail) }
                    .font(AtlasType.ui(12.5, weight: .semibold))
                    .foregroundStyle(AtlasColor.electricBright)
            }

            VStack(spacing: 0) {
                ForEach(Array(AtlasSampleData.assets.prefix(3).enumerated()), id: \.element.id) { index, asset in
                    Button { open(.assetDetail) } label: {
                        AtlasAssetRow(asset: asset)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    if index < 2 { AtlasHairline() }
                }
            }
        }
    }

    private var recentChanges: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "03", title: "Cambios recientes", trailing: "Hoy")
            Text("Lo que cambió importa.")
                .font(AtlasType.display(32, weight: .medium))
                .tracking(-1)
                .foregroundStyle(AtlasColor.porcelain)

            VStack(spacing: 16) {
                ForEach(AtlasSampleData.changes.prefix(3)) { change in
                    AtlasChangeRow(change: change)
                }
            }
        }
    }
}


// MARK: - AssetScreens.swift

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
            VStack(alignment: .leading, spacing: 24) {
                AtlasScreenHeader(
                    eyebrow: "Biblioteca física",
                    title: "Tus activos",
                    subtitle: "Cada activo conserva identidad, geometría, evidencia, versiones, hallazgos y una línea de tiempo propia.",
                    trailingSymbol: "plus",
                    trailingAction: {}
                )

                AtlasSearchField(text: $query, placeholder: "Buscar activo, tipo o ubicación")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter)
                                    .font(AtlasType.ui(12.5, weight: .semibold))
                                    .foregroundStyle(selectedFilter == filter ? AtlasColor.void : AtlasColor.porcelainSoft)
                                    .padding(.horizontal, 14)
                                    .frame(height: 38)
                                    .background(Capsule().fill(selectedFilter == filter ? AtlasColor.porcelain : Color.white.opacity(0.045)))
                                    .overlay(Capsule().stroke(selectedFilter == filter ? Color.clear : AtlasColor.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                HStack(spacing: 12) {
                    AtlasMetric(value: "12", label: "Activos")
                    Spacer()
                    AtlasMetric(value: "5", label: "Clases", tint: AtlasColor.violet)
                    Spacer()
                    AtlasMetric(value: "03", label: "Atención", tint: AtlasColor.amber)
                }
                .padding(.vertical, 4)

                AtlasKicker(index: "01", title: "Índice", trailing: "\(filtered.count) visibles")

                VStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, asset in
                        Button { open(.assetDetail) } label: {
                            AtlasAssetRow(asset: asset)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        if index < filtered.count - 1 { AtlasHairline() }
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
                        trailingSymbol: "ellipsis",
                        trailingAction: {}
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
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: [AtlasColor.graphite2, AtlasColor.voidSoft], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 250)

            RadialGradient(colors: [AtlasColor.electric.opacity(0.22), .clear], center: .center, startRadius: 10, endRadius: 150)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

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
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
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
                        trailingAction: {}
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


// MARK: - ChangeScreens.swift

struct ChangesScreen: View {
    let open: (AtlasRoute) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                AtlasScreenHeader(
                    eyebrow: "Motor de cambios",
                    title: "Lo que cambió",
                    subtitle: "ATLAS compara estados del mundo físico y conserva una línea de tiempo explicable de cada modificación.",
                    trailingSymbol: "square.split.2x1",
                    trailingAction: { open(.compare) }
                )

                HStack(spacing: 0) {
                    AtlasMetric(value: "41", label: "Cambios", tint: AtlasColor.violet).frame(maxWidth: .infinity, alignment: .leading)
                    AtlasMetric(value: "06", label: "Nuevos", tint: AtlasColor.electricBright).frame(maxWidth: .infinity, alignment: .leading)
                    AtlasMetric(value: "03", label: "Revisar", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                }

                AtlasKicker(index: "01", title: "Línea de tiempo", trailing: "Últimos 30 días")

                VStack(spacing: 18) {
                    ForEach(AtlasSampleData.changes) { change in
                        AtlasChangeRow(change: change)
                    }
                }

                AtlasSecondaryButton(title: "Comparar dos estados", symbol: "square.split.2x1") {
                    open(.compare)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 34)
        }
    }
}

struct CompareScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Comparación",
                        title: "Estado A → Estado B",
                        subtitle: "Una lectura diferencial del mismo activo en dos momentos distintos.",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 10) {
                        stateCard(date: "03 SEP", title: "Estado A", tint: AtlasColor.electricBright)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AtlasColor.smoke)
                        stateCard(date: "20 SEP", title: "Estado B", tint: AtlasColor.aqua)
                    }

                    AtlasGlass {
                        VStack(alignment: .leading, spacing: 18) {
                            AtlasKicker(index: "Δ", title: "Delta físico", trailing: "17 días")
                            Text("4 cambios detectados")
                                .font(AtlasType.display(31, weight: .medium))
                                .tracking(-0.8)
                                .foregroundStyle(AtlasColor.porcelain)
                            deltaRow(symbol: "drop.triangle", title: "Nueva anomalía superficial", detail: "Cocina · pared norte", tint: AtlasColor.amber)
                            deltaRow(symbol: "rectangle.portrait", title: "Acabado modificado", detail: "Sala · muro oeste", tint: AtlasColor.violet)
                            deltaRow(symbol: "shippingbox", title: "Objeto añadido", detail: "Habitación principal", tint: AtlasColor.aqua)
                            deltaRow(symbol: "minus.circle", title: "Objeto retirado", detail: "Sala · estantería", tint: AtlasColor.electricBright)
                        }
                    }

                    AtlasKicker(index: "01", title: "Confianza del cambio")
                    HStack(spacing: 0) {
                        AtlasMetric(value: "96%", label: "Geometría", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "91%", label: "Visual", tint: AtlasColor.electricBright).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "88%", label: "Contexto", tint: AtlasColor.violet).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func stateCard(date: String, title: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date)
                .font(AtlasType.mono(8.5, weight: .bold))
                .foregroundStyle(AtlasColor.smoke)
            Text(title)
                .font(AtlasType.ui(14.5, weight: .semibold))
                .foregroundStyle(AtlasColor.porcelain)
            RoundedRectangle(cornerRadius: 8)
                .fill(tint)
                .frame(width: 24, height: 3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasColor.border, lineWidth: 1))
    }

    private func deltaRow(symbol: String, title: String, detail: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(Circle().fill(tint.opacity(0.11)))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.ui(13.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(11.5)).foregroundStyle(AtlasColor.smoke)
            }
            Spacer()
        }
    }
}


// MARK: - IntelligenceScreens.swift

struct AskAtlasScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var prompt = ""
    @State private var answerVisible = false

    private let suggestions = [
        "¿Qué activos requieren atención?",
        "¿Qué cambió esta semana?",
        "Resume el estado del Apartamento Norte",
        "¿Qué mantenimiento recomiendas?"
    ]

    var body: some View {
        AtlasPage {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        AtlasScreenHeader(
                            eyebrow: "Inteligencia contextual",
                            title: "Pregunta a ATLAS",
                            subtitle: "Consulta el historial, estado, relaciones y evidencia de tu mundo físico.",
                            backAction: { dismiss() }
                        )

                        AtlasGlass {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 9) {
                                    Circle().fill(AtlasColor.aqua).frame(width: 7, height: 7)
                                    Text("CONTEXTO ACTIVO · 12 ACTIVOS")
                                        .font(AtlasType.mono(8.5, weight: .bold))
                                        .tracking(1)
                                        .foregroundStyle(AtlasColor.smoke)
                                }

                                Text("¿Qué quieres entender de tu mundo?")
                                    .font(AtlasType.display(30, weight: .medium))
                                    .tracking(-0.8)
                                    .foregroundStyle(AtlasColor.porcelain)

                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button {
                                        prompt = suggestion
                                    } label: {
                                        HStack {
                                            Text(suggestion)
                                                .font(AtlasType.ui(13))
                                                .foregroundStyle(AtlasColor.porcelainSoft)
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(AtlasColor.smoke)
                                        }
                                        .padding(.vertical, 7)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if answerVisible {
                            AtlasGlass {
                                VStack(alignment: .leading, spacing: 14) {
                                    AtlasTag(text: "Respuesta contextual", tint: AtlasColor.electric, symbol: "sparkles")
                                    Text("Hay 3 elementos que requieren atención prioritaria.")
                                        .font(AtlasType.display(27, weight: .medium))
                                        .foregroundStyle(AtlasColor.porcelain)
                                    Text("La principal señal proviene del Apartamento Norte: una anomalía de humedad apareció en la cocina respecto a la inspección del 3 de septiembre. También hay un cambio visual sin clasificar en el vehículo y una revisión preventiva pendiente en la unidad M-028.")
                                        .font(AtlasType.ui(13.5))
                                        .foregroundStyle(AtlasColor.porcelainSoft)
                                        .lineSpacing(4)
                                    Text("ATLAS no sustituye una inspección profesional; presenta evidencia y contexto para acelerar la decisión.")
                                        .font(AtlasType.ui(11.5))
                                        .foregroundStyle(AtlasColor.smoke)
                                        .lineSpacing(3)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 120)
                }

                HStack(spacing: 10) {
                    TextField("Pregunta sobre tus activos…", text: $prompt, axis: .vertical)
                        .font(AtlasType.ui(14))
                        .foregroundStyle(AtlasColor.porcelain)
                        .tint(AtlasColor.electricBright)
                        .lineLimit(1...4)

                    Button {
                        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        withAnimation(.easeOut(duration: 0.2)) { answerVisible = true }
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AtlasColor.void)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(AtlasColor.porcelain))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AtlasColor.graphite.opacity(0.96))
                .overlay(Rectangle().fill(AtlasColor.border).frame(height: 1), alignment: .top)
            }
        }
    }
}

struct AlertsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Señales prioritarias",
                        title: "Alertas",
                        subtitle: "Riesgos, anomalías y mantenimiento que merecen revisión humana.",
                        backAction: { dismiss() }
                    )

                    HStack(spacing: 0) {
                        AtlasMetric(value: "03", label: "Abiertas", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "01", label: "Alta", tint: AtlasColor.coral).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "07", label: "Resueltas", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Abiertas", trailing: "Ordenadas por prioridad")

                    ForEach(AtlasSampleData.alerts) { alert in
                        Button { open(.inspectionDetail) } label: {
                            AtlasGlass {
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 13).fill(alert.tint.opacity(0.11))
                                        Image(systemName: alert.symbol)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(alert.tint)
                                    }
                                    .frame(width: 44, height: 44)

                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(alert.level)
                                                .font(AtlasType.mono(8.5, weight: .bold))
                                                .tracking(0.8)
                                                .foregroundStyle(alert.tint)
                                            Spacer()
                                            Text(alert.time)
                                                .font(AtlasType.ui(10.5))
                                                .foregroundStyle(AtlasColor.smokeDark)
                                        }
                                        Text(alert.title)
                                            .font(AtlasType.ui(15, weight: .semibold))
                                            .foregroundStyle(AtlasColor.porcelain)
                                        Text(alert.detail)
                                            .font(AtlasType.ui(12.2))
                                            .foregroundStyle(AtlasColor.smoke)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }
}

struct ReportsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Documentación",
                        title: "Informes",
                        subtitle: "Inspecciones estructuradas con evidencia, hallazgos, métricas y trazabilidad.",
                        backAction: { dismiss() },
                        trailingSymbol: "plus",
                        trailingAction: {}
                    )

                    HStack(spacing: 0) {
                        AtlasMetric(value: "18", label: "Generados").frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "05", label: "Compartidos", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "02", label: "Borradores", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Recientes")
                    reportCard(title: "Inspección · Apartamento Norte", date: "20 SEP 2026", status: "Listo", tint: AtlasColor.aqua)
                        .onTapGesture { open(.reportDetail) }
                    reportCard(title: "Comparación · Vehículo diario", date: "19 SEP 2026", status: "Listo", tint: AtlasColor.electricBright)
                        .onTapGesture { open(.reportDetail) }
                    reportCard(title: "Estado · Unidad M-028", date: "18 SEP 2026", status: "Borrador", tint: AtlasColor.amber)
                        .onTapGesture { open(.reportDetail) }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func reportCard(title: String, date: String, status: String, tint: Color) -> some View {
        AtlasGlass {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(tint)
                    Spacer()
                    AtlasTag(text: status, tint: tint)
                }
                Text(title)
                    .font(AtlasType.display(25, weight: .medium))
                    .foregroundStyle(AtlasColor.porcelain)
                HStack {
                    Text(date)
                        .font(AtlasType.mono(8.5, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AtlasColor.smoke)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasColor.smoke)
                }
            }
        }
    }
}

struct ReportDetailScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Informe / RPT-2041",
                        title: "Apartamento Norte",
                        subtitle: "Inspección del 20 de septiembre de 2026.",
                        backAction: { dismiss() },
                        trailingSymbol: "square.and.arrow.up",
                        trailingAction: {}
                    )

                    AtlasGlass {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("RESUMEN EJECUTIVO")
                                .font(AtlasType.mono(8.5, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(AtlasColor.smoke)
                            Text("Estado general estable con dos hallazgos moderados.")
                                .font(AtlasType.display(29, weight: .medium))
                                .foregroundStyle(AtlasColor.porcelain)
                            Text("La inspección cubrió 84,2 m², 7 espacios y 32 evidencias visuales. No se detectaron hallazgos críticos. La anomalía principal corresponde a una posible humedad en la cocina.")
                                .font(AtlasType.ui(13.5))
                                .foregroundStyle(AtlasColor.porcelainSoft)
                                .lineSpacing(4)
                        }
                    }

                    HStack(spacing: 0) {
                        AtlasMetric(value: "92", label: "Salud", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "32", label: "Evidencias").frame(maxWidth: .infinity, alignment: .leading)
                        AtlasMetric(value: "02", label: "Hallazgos", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AtlasKicker(index: "01", title: "Recomendaciones")
                    recommendation("Validar origen de humedad", detail: "Inspeccionar tubería, sellado y unión ventana-pared.")
                    recommendation("Documentar intervención", detail: "Crear un nuevo estado después de cualquier reparación.")

                    AtlasPrimaryButton(title: "Compartir informe", symbol: "square.and.arrow.up") {}
                    AtlasSecondaryButton(title: "Exportar PDF", symbol: "arrow.down.doc") {}
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func recommendation(_ title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AtlasColor.aqua)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke).lineSpacing(3)
            }
        }
    }
}


// MARK: - ScanScreens.swift

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var step: ScanStep = .intro
    @State private var mode: ScanMode = .space
    @State private var progress: Double = 0.18

    var body: some View {
        ZStack {
            AtlasBackdrop()

            switch step {
            case .intro:
                ScanIntroView(mode: $mode, start: { withAnimation(.easeInOut(duration: 0.25)) { step = .capture } }, close: { dismiss() })
            case .capture:
                ScanCaptureView(mode: mode, progress: $progress, finish: { withAnimation(.easeInOut(duration: 0.25)) { step = .processing } }, close: { dismiss() })
            case .processing:
                ScanProcessingView(continueAction: { withAnimation(.easeInOut(duration: 0.25)) { step = .result } })
            case .result:
                ScanResultView(close: { dismiss() })
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct ScanIntroView: View {
    @Binding var mode: ScanMode
    let start: () -> Void
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                AtlasTag(text: "Nuevo escaneo", tint: AtlasColor.electric, symbol: "viewfinder")
                Spacer()
                AtlasIconButton(symbol: "xmark", action: close)
            }

            Spacer()

            Text("Convierte el mundo físico\nen un estado verificable.")
                .font(AtlasType.display(46, weight: .medium))
                .tracking(-1.5)
                .foregroundStyle(AtlasColor.porcelain)
                .lineSpacing(-2)

            Text("Elige qué vas a capturar. ATLAS adaptará el flujo de percepción, evidencia y análisis al tipo de activo.")
                .font(AtlasType.ui(14.5))
                .foregroundStyle(AtlasColor.smoke)
                .lineSpacing(4)

            VStack(spacing: 10) {
                ForEach(ScanMode.allCases) { item in
                    Button {
                        mode = item
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: item.symbol)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(mode == item ? AtlasColor.void : AtlasColor.electricBright)
                                .frame(width: 42, height: 42)
                                .background(RoundedRectangle(cornerRadius: 13).fill(mode == item ? AtlasColor.porcelain : AtlasColor.electric.opacity(0.10)))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.rawValue)
                                    .font(AtlasType.ui(15, weight: .semibold))
                                    .foregroundStyle(AtlasColor.porcelain)
                                Text(modeDescription(item))
                                    .font(AtlasType.ui(12))
                                    .foregroundStyle(AtlasColor.smoke)
                            }
                            Spacer()
                            Image(systemName: mode == item ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(mode == item ? AtlasColor.aqua : AtlasColor.smokeDark)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(mode == item ? 0.065 : 0.025)))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(mode == item ? AtlasColor.borderStrong : AtlasColor.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            AtlasPrimaryButton(title: "Iniciar captura", symbol: "viewfinder", action: start)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 24)
    }

    private func modeDescription(_ mode: ScanMode) -> String {
        switch mode {
        case .space: return "Habitaciones, propiedades y geometría espacial."
        case .object: return "Equipos, productos y activos individuales."
        case .vehicle: return "Exterior, componentes y cambios visibles."
        }
    }
}

private struct ScanCaptureView: View {
    let mode: ScanMode
    @Binding var progress: Double
    let finish: () -> Void
    let close: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [AtlasColor.graphite3, AtlasColor.void], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            scanGrid

            VStack {
                HStack {
                    AtlasTag(text: mode.rawValue, tint: AtlasColor.aqua, symbol: mode.symbol)
                    Spacer()
                    AtlasIconButton(symbol: "xmark", action: close)
                }

                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 78, weight: .ultraLight))
                        .foregroundStyle(AtlasColor.electricBright.opacity(0.8))
                        .shadow(color: AtlasColor.electric.opacity(0.22), radius: 28)

                    Text("Muévete lentamente alrededor del activo")
                        .font(AtlasType.display(27, weight: .medium))
                        .foregroundStyle(AtlasColor.porcelain)
                        .multilineTextAlignment(.center)
                    Text("Mantén las superficies dentro del marco para completar la geometría y la evidencia visual.")
                        .font(AtlasType.ui(12.5))
                        .foregroundStyle(AtlasColor.smoke)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 30)

                Spacer()

                VStack(spacing: 14) {
                    HStack {
                        Text("CAPTURA")
                            .font(AtlasType.mono(8.5, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(AtlasColor.smoke)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(AtlasType.rounded(16, weight: .bold))
                            .foregroundStyle(AtlasColor.porcelain)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08))
                            Capsule().fill(LinearGradient(colors: [AtlasColor.electric, AtlasColor.aqua], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * progress)
                        }
                    }
                    .frame(height: 6)

                    HStack(spacing: 10) {
                        Button {
                            progress = min(1.0, progress + 0.22)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera")
                                Text("Capturar")
                            }
                            .font(AtlasType.ui(14, weight: .semibold))
                            .foregroundStyle(AtlasColor.porcelain)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(RoundedRectangle(cornerRadius: 17).fill(Color.white.opacity(0.06)))
                            .overlay(RoundedRectangle(cornerRadius: 17).stroke(AtlasColor.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        Button(action: finish) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(AtlasColor.void)
                                .frame(width: 52, height: 52)
                                .background(RoundedRectangle(cornerRadius: 17).fill(AtlasColor.porcelain))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
                .background(RoundedRectangle(cornerRadius: 25).fill(AtlasColor.graphite.opacity(0.92)))
                .overlay(RoundedRectangle(cornerRadius: 25).stroke(AtlasColor.border, lineWidth: 1))
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
    }

    private var scanGrid: some View {
        GeometryReader { proxy in
            Path { path in
                let w = proxy.size.width
                let h = proxy.size.height
                for i in 0...8 {
                    let y = h * CGFloat(i) / 8
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: w, y: y))
                }
                for i in 0...6 {
                    let x = w * CGFloat(i) / 6
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: h))
                }
            }
            .stroke(Color.white.opacity(0.035), lineWidth: 0.6)
        }
        .ignoresSafeArea()
    }
}

private struct ScanProcessingView: View {
    @State private var spin = false
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(AtlasColor.borderStrong, lineWidth: 1)
                    .frame(width: 150, height: 150)
                Circle()
                    .trim(from: 0.08, to: 0.74)
                    .stroke(LinearGradient(colors: [AtlasColor.electricBright, AtlasColor.aqua], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(spin ? 360 : 0))
                AtlasMark(size: 48)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) { spin = true }
            }

            VStack(spacing: 10) {
                Text("Construyendo el estado del mundo")
                    .font(AtlasType.display(31, weight: .medium))
                    .foregroundStyle(AtlasColor.porcelain)
                    .multilineTextAlignment(.center)
                Text("Estamos consolidando geometría, evidencia, contexto y cambios detectados.")
                    .font(AtlasType.ui(13.5))
                    .foregroundStyle(AtlasColor.smoke)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 30)

            VStack(spacing: 10) {
                processingRow("Geometría espacial", state: "Listo", tint: AtlasColor.aqua)
                processingRow("Evidencia visual", state: "Listo", tint: AtlasColor.aqua)
                processingRow("Cambios y anomalías", state: "Analizando", tint: AtlasColor.electricBright)
            }
            .padding(.horizontal, 20)

            Spacer()

            AtlasPrimaryButton(title: "Ver resultado", symbol: "arrow.right", action: continueAction)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
    }

    private func processingRow(_ title: String, state: String, tint: Color) -> some View {
        HStack {
            Text(title).font(AtlasType.ui(13.5, weight: .medium)).foregroundStyle(AtlasColor.porcelainSoft)
            Spacer()
            Text(state).font(AtlasType.mono(8.5, weight: .bold)).tracking(0.8).foregroundStyle(tint)
        }
        .padding(.vertical, 6)
    }
}

private struct ScanResultView: View {
    let close: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    AtlasTag(text: "Escaneo completado", tint: AtlasColor.aqua, symbol: "checkmark")
                    Spacer()
                    AtlasIconButton(symbol: "xmark", action: close)
                }

                Text("El mundo ya tiene\nuna nueva versión.")
                    .font(AtlasType.display(43, weight: .medium))
                    .tracking(-1.4)
                    .foregroundStyle(AtlasColor.porcelain)
                    .lineSpacing(-2)

                AtlasGlass {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("APARTAMENTO NORTE")
                                    .font(AtlasType.mono(8.5, weight: .bold))
                                    .tracking(1)
                                    .foregroundStyle(AtlasColor.smoke)
                                Text("Estado #14")
                                    .font(AtlasType.display(27, weight: .medium))
                                    .foregroundStyle(AtlasColor.porcelain)
                            }
                            Spacer()
                            Image(systemName: "cube.transparent")
                                .font(.system(size: 26, weight: .light))
                                .foregroundStyle(AtlasColor.electricBright)
                        }

                        HStack(spacing: 0) {
                            AtlasMetric(value: "32", label: "Evidencias").frame(maxWidth: .infinity, alignment: .leading)
                            AtlasMetric(value: "02", label: "Hallazgos", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                            AtlasMetric(value: "92", label: "Salud", tint: AtlasColor.aqua).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                AtlasKicker(index: "01", title: "Hallazgos")
                resultFinding("Posible humedad", detail: "Cocina · pared norte", tint: AtlasColor.amber)
                resultFinding("Cambio de acabado", detail: "Sala · muro oeste", tint: AtlasColor.violet)

                AtlasPrimaryButton(title: "Guardar y cerrar", symbol: "checkmark", action: close)
                AtlasSecondaryButton(title: "Generar informe", symbol: "doc.text") {}
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
    }

    private func resultFinding(_ title: String, detail: String, tint: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(Circle().fill(tint.opacity(0.11)))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(12)).foregroundStyle(AtlasColor.smoke)
            }
            Spacer()
            Text("REVISAR").font(AtlasType.mono(8, weight: .bold)).tracking(0.8).foregroundStyle(tint)
        }
    }
}


// MARK: - ProfileUtilityScreens.swift

struct ProfileScreen: View {
    let open: (AtlasRoute) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                AtlasScreenHeader(
                    eyebrow: "Espacio personal",
                    title: "Tu ATLAS",
                    subtitle: "Cuenta, preferencias, privacidad y acceso a todas las capacidades del producto."
                )

                profileCard

                AtlasKicker(index: "01", title: "Producto")
                VStack(spacing: 0) {
                    Button { open(.notifications) } label: { AtlasSettingRow(symbol: "bell", title: "Notificaciones", detail: "Alertas, cambios e inspecciones") }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.reports) } label: { AtlasSettingRow(symbol: "doc.text", title: "Informes", detail: "Documentos y exportaciones", tint: AtlasColor.aqua) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.screenMap) } label: { AtlasSettingRow(symbol: "square.grid.3x3", title: "Mapa de pantallas", detail: "Acceso al prototipo completo", tint: AtlasColor.violet) }.buttonStyle(.plain)
                }

                AtlasKicker(index: "02", title: "Cuenta y sistema")
                VStack(spacing: 0) {
                    Button { open(.settings) } label: { AtlasSettingRow(symbol: "gearshape", title: "Configuración", detail: "Preferencias, análisis y sincronización") }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.account) } label: { AtlasSettingRow(symbol: "person.crop.circle", title: "Cuenta", detail: "Perfil y organización", tint: AtlasColor.aqua) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.privacy) } label: { AtlasSettingRow(symbol: "lock.shield", title: "Privacidad y datos", detail: "Control de evidencia y procesamiento", tint: AtlasColor.amber) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.help) } label: { AtlasSettingRow(symbol: "questionmark.circle", title: "Ayuda", detail: "Guías y soporte") }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.about) } label: { AtlasSettingRow(symbol: "info.circle", title: "Acerca de ATLAS", detail: "Versión y concepto", tint: AtlasColor.violet) }.buttonStyle(.plain)
                }

                AtlasSecondaryButton(title: "Ver experiencia de bienvenida", symbol: "sparkles") {
                    open(.onboarding)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 34)
        }
    }

    private var profileCard: some View {
        AtlasGlass {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [AtlasColor.electric, AtlasColor.violet], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("JC")
                        .font(AtlasType.rounded(16, weight: .bold))
                        .foregroundStyle(AtlasColor.porcelain)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Joss Corvian")
                        .font(AtlasType.ui(16, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                    Text("Espacio personal · Pro")
                        .font(AtlasType.ui(12.5))
                        .foregroundStyle(AtlasColor.smoke)
                }
                Spacer()
                AtlasTag(text: "PRO", tint: AtlasColor.aqua)
            }
        }
    }
}

struct SearchScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasScreenHeader(eyebrow: "Búsqueda global", title: "Encuentra cualquier cosa", subtitle: "Busca activos, informes, inspecciones, hallazgos y cambios.", backAction: { dismiss() })
                    AtlasSearchField(text: $query, placeholder: "Buscar en ATLAS")

                    AtlasKicker(index: "01", title: query.isEmpty ? "Recientes" : "Resultados")
                    ForEach(AtlasSampleData.assets.prefix(query.isEmpty ? 4 : 5)) { asset in
                        AtlasAssetRow(asset: asset).padding(.vertical, 7)
                        AtlasHairline()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }
}

struct NotificationsScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Centro de actividad", title: "Notificaciones", subtitle: "Señales importantes sobre el estado de tu mundo físico.", backAction: { dismiss() }, trailingSymbol: "checkmark", trailingAction: {})

                    notification("Nueva anomalía detectada", detail: "Apartamento Norte · Cocina", time: "18 min", symbol: "drop.triangle", tint: AtlasColor.amber)
                    notification("Inspección finalizada", detail: "Unidad M-028 · Sin críticos", time: "2 h", symbol: "checkmark.seal", tint: AtlasColor.aqua)
                    notification("Nuevo estado disponible", detail: "Vehículo diario · Exterior", time: "Ayer", symbol: "square.stack.3d.up", tint: AtlasColor.electricBright)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func notification(_ title: String, detail: String, time: String, symbol: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 13) {
            ZStack {
                Circle().fill(tint.opacity(0.11))
                Image(systemName: symbol).font(.system(size: 15, weight: .semibold)).foregroundStyle(tint)
            }
            .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(AtlasType.ui(14.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(12)).foregroundStyle(AtlasColor.smoke)
            }
            Spacer()
            Text(time).font(AtlasType.mono(8.5, weight: .medium)).foregroundStyle(AtlasColor.smokeDark)
        }
    }
}

struct SettingsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var sync = true
    @State private var haptics = true
    @State private var localAnalysis = true

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Preferencias", title: "Configuración", subtitle: "Ajusta cómo ATLAS captura, analiza y sincroniza tu mundo.", backAction: { dismiss() })

                    AtlasKicker(index: "01", title: "Experiencia")
                    AtlasGlass {
                        VStack(spacing: 18) {
                            toggleRow("Respuesta háptica", detail: "Confirmaciones sutiles durante escaneos", value: $haptics)
                            AtlasHairline()
                            toggleRow("Análisis local", detail: "Priorizar procesamiento en el dispositivo", value: $localAnalysis)
                            AtlasHairline()
                            toggleRow("Sincronización automática", detail: "Subir nuevos estados cuando haya conexión", value: $sync)
                        }
                    }

                    AtlasKicker(index: "02", title: "Administración")
                    Button { open(.account) } label: { AtlasSettingRow(symbol: "person.crop.circle", title: "Cuenta y organización") }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.privacy) } label: { AtlasSettingRow(symbol: "lock.shield", title: "Privacidad y datos", tint: AtlasColor.amber) }.buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }

    private func toggleRow(_ title: String, detail: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(11.5)).foregroundStyle(AtlasColor.smoke)
            }
            Spacer()
            Toggle("", isOn: value).labelsHidden().tint(AtlasColor.electric)
        }
    }
}

struct AccountScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Identidad", title: "Cuenta", subtitle: "Perfil personal y contexto de organización.", backAction: { dismiss() })
                    AtlasGlass {
                        VStack(alignment: .leading, spacing: 18) {
                            labeledValue("Nombre", value: "Joss Corvian")
                            AtlasHairline()
                            labeledValue("Correo", value: "joss@atlas.app")
                            AtlasHairline()
                            labeledValue("Plan", value: "ATLAS Pro")
                            AtlasHairline()
                            labeledValue("Organización", value: "Espacio personal")
                        }
                    }
                    AtlasSecondaryButton(title: "Editar perfil", symbol: "pencil") {}
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func labeledValue(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke)
            Spacer()
            Text(value).font(AtlasType.ui(13.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
        }
    }
}

struct PrivacyScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Control de datos", title: "Privacidad", subtitle: "ATLAS separa captura, procesamiento y sincronización para darte control sobre la evidencia física.", backAction: { dismiss() })
                    privacyBlock("Procesamiento local", detail: "Siempre que el dispositivo lo permita, las tareas compatibles pueden ejecutarse en el iPhone.", symbol: "iphone", tint: AtlasColor.aqua)
                    privacyBlock("Evidencia cifrada", detail: "Las capturas y documentos deben almacenarse con controles de acceso y cifrado en tránsito y reposo.", symbol: "lock.shield", tint: AtlasColor.electricBright)
                    privacyBlock("Control de eliminación", detail: "El usuario debe poder revisar y eliminar activos, estados y evidencia según las políticas aplicables.", symbol: "trash", tint: AtlasColor.amber)
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func privacyBlock(_ title: String, detail: String, symbol: String, tint: Color) -> some View {
        AtlasGlass {
            VStack(alignment: .leading, spacing: 13) {
                Image(systemName: symbol).font(.system(size: 21, weight: .medium)).foregroundStyle(tint)
                Text(title).font(AtlasType.display(25, weight: .medium)).foregroundStyle(AtlasColor.porcelain)
                Text(detail).font(AtlasType.ui(13)).foregroundStyle(AtlasColor.smoke).lineSpacing(4)
            }
        }
    }
}

struct HelpScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Soporte", title: "Ayuda", subtitle: "Aprende a capturar, interpretar y administrar tu mundo en ATLAS.", backAction: { dismiss() })
                    AtlasSearchField(text: $query, placeholder: "Buscar una guía")
                    guide("Primer escaneo", detail: "Cómo crear tu primer estado del mundo", symbol: "viewfinder")
                    guide("Gemelos digitales", detail: "Cómo interpretar espacios y componentes", symbol: "cube.transparent")
                    guide("Cambios y alertas", detail: "Cómo revisar anomalías y prioridades", symbol: "exclamationmark.triangle")
                    guide("Informes", detail: "Cómo generar y compartir evidencia", symbol: "doc.text")
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func guide(_ title: String, detail: String, symbol: String) -> some View {
        AtlasSettingRow(symbol: symbol, title: title, detail: detail)
    }
}

struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 28) {
                HStack { Spacer(); AtlasIconButton(symbol: "xmark") { dismiss() } }
                Spacer()
                AtlasMark(size: 58)
                Text("ATLAS")
                    .font(AtlasType.ui(15, weight: .bold)).tracking(4).foregroundStyle(AtlasColor.porcelain)
                Text("Inteligencia para\nel mundo físico.")
                    .font(AtlasType.display(46, weight: .medium))
                    .tracking(-1.4)
                    .foregroundStyle(AtlasColor.porcelain)
                    .lineSpacing(-2)
                Text("Una plataforma para observar, recordar, comparar y entender activos reales mediante evidencia, contexto y memoria temporal.")
                    .font(AtlasType.ui(14)).foregroundStyle(AtlasColor.smoke).lineSpacing(4)
                Spacer()
                Text("ATLAS · PROTOTIPO UI v7.0")
                    .font(AtlasType.mono(8.5, weight: .bold)).tracking(1).foregroundStyle(AtlasColor.smokeDark)
            }
            .padding(22)
        }
    }
}

struct OnboardingPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("Captura", "Convierte espacios, objetos y vehículos en estados verificables.", "viewfinder"),
        ("Recuerda", "Cada estado queda ligado al activo, su evidencia y su historia.", "clock.arrow.circlepath"),
        ("Entiende", "ATLAS detecta cambios y organiza señales para ayudarte a decidir.", "sparkles")
    ]

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    AtlasMark(size: 32)
                    Spacer()
                    AtlasIconButton(symbol: "xmark") { dismiss() }
                }
                Spacer()
                Image(systemName: pages[page].2)
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(AtlasColor.electricBright)
                Text(pages[page].0)
                    .font(AtlasType.display(48, weight: .medium))
                    .tracking(-1.5)
                    .foregroundStyle(AtlasColor.porcelain)
                Text(pages[page].1)
                    .font(AtlasType.ui(15)).foregroundStyle(AtlasColor.smoke).lineSpacing(4)
                HStack(spacing: 7) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule().fill(index == page ? AtlasColor.porcelain : AtlasColor.borderStrong)
                            .frame(width: index == page ? 26 : 7, height: 7)
                    }
                }
                Spacer()
                AtlasPrimaryButton(title: page == pages.count - 1 ? "Entrar a ATLAS" : "Continuar", symbol: "arrow.right") {
                    if page < pages.count - 1 { withAnimation { page += 1 } } else { dismiss() }
                }
            }
            .padding(22)
        }
    }
}

struct ScreenMapScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    private let routes: [(String, AtlasRoute, String)] = [
        ("Búsqueda global", .search, "magnifyingglass"),
        ("Notificaciones", .notifications, "bell"),
        ("Alertas", .alerts, "exclamationmark.triangle"),
        ("Informes", .reports, "doc.text"),
        ("Detalle de informe", .reportDetail, "doc.richtext"),
        ("Detalle de activo", .assetDetail, "cube.transparent"),
        ("Gemelo digital", .digitalTwin, "square.3.layers.3d"),
        ("Inspecciones", .inspections, "viewfinder"),
        ("Detalle de inspección", .inspectionDetail, "checklist"),
        ("Preguntar a ATLAS", .askAtlas, "sparkles"),
        ("Comparar estados", .compare, "square.split.2x1"),
        ("Configuración", .settings, "gearshape"),
        ("Cuenta", .account, "person.crop.circle"),
        ("Privacidad", .privacy, "lock.shield"),
        ("Ayuda", .help, "questionmark.circle"),
        ("Acerca de ATLAS", .about, "info.circle"),
        ("Onboarding", .onboarding, "sparkles.rectangle.stack"),
        ("Iniciar sesión", .login, "person.badge.key"),
        ("Crear cuenta", .createAccount, "person.crop.circle.badge.plus")
    ]

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Prototipo completo", title: "Mapa de pantallas", subtitle: "Acceso directo a todos los estados y flujos montados en esta versión.", backAction: { dismiss() })
                    ForEach(Array(routes.enumerated()), id: \.offset) { index, item in
                        Button { open(item.1) } label: {
                            HStack(spacing: 13) {
                                Text(String(format: "%02d", index + 1))
                                    .font(AtlasType.mono(8.5, weight: .bold)).foregroundStyle(AtlasColor.electricBright).frame(width: 24, alignment: .leading)
                                Image(systemName: item.2).font(.system(size: 15, weight: .medium)).foregroundStyle(AtlasColor.porcelainSoft).frame(width: 28)
                                Text(item.0).font(AtlasType.ui(14.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                                Spacer()
                                Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(AtlasColor.smoke)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        AtlasHairline()
                    }
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}


// MARK: - AuthScreens.swift

struct LoginPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        AtlasMark(size: 34)
                        Spacer()
                        AtlasIconButton(symbol: "xmark") { dismiss() }
                    }

                    Spacer(minLength: 20)

                    Text("Vuelve a tu mundo.")
                        .font(AtlasType.display(46, weight: .medium))
                        .tracking(-1.5)
                        .foregroundStyle(AtlasColor.porcelain)

                    Text("Accede a tus activos, estados, inspecciones y contexto acumulado.")
                        .font(AtlasType.ui(14.5))
                        .foregroundStyle(AtlasColor.smoke)
                        .lineSpacing(4)

                    VStack(spacing: 12) {
                        field("Correo", text: $email, symbol: "envelope")
                        secureField("Contraseña", text: $password, symbol: "lock")
                    }

                    AtlasPrimaryButton(title: "Iniciar sesión", symbol: "arrow.right") {}

                    Button("¿Olvidaste tu contraseña?") {}
                        .font(AtlasType.ui(12.5, weight: .semibold))
                        .foregroundStyle(AtlasColor.electricBright)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.plain)

                    HStack(spacing: 10) {
                        AtlasHairline().frame(maxWidth: .infinity)
                        Text("O")
                            .font(AtlasType.mono(8.5, weight: .bold))
                            .foregroundStyle(AtlasColor.smokeDark)
                        AtlasHairline().frame(maxWidth: .infinity)
                    }

                    AtlasSecondaryButton(title: "Continuar con Apple", symbol: "apple.logo") {}
                }
                .padding(22)
                .padding(.bottom, 40)
            }
        }
    }

    private func field(_ placeholder: String, text: Binding<String>, symbol: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: symbol).foregroundStyle(AtlasColor.smoke)
            TextField(placeholder, text: text)
                .font(AtlasType.ui(14.5))
                .foregroundStyle(AtlasColor.porcelain)
                .tint(AtlasColor.electricBright)
        }
        .padding(.horizontal, 15)
        .frame(height: 52)
        .background(RoundedRectangle(cornerRadius: 17).fill(Color.white.opacity(0.045)))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AtlasColor.border, lineWidth: 1))
    }

    private func secureField(_ placeholder: String, text: Binding<String>, symbol: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: symbol).foregroundStyle(AtlasColor.smoke)
            SecureField(placeholder, text: text)
                .font(AtlasType.ui(14.5))
                .foregroundStyle(AtlasColor.porcelain)
                .tint(AtlasColor.electricBright)
        }
        .padding(.horizontal, 15)
        .frame(height: 52)
        .background(RoundedRectangle(cornerRadius: 17).fill(Color.white.opacity(0.045)))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AtlasColor.border, lineWidth: 1))
    }
}

struct CreateAccountPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var accepted = true

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        AtlasMark(size: 34)
                        Spacer()
                        AtlasIconButton(symbol: "xmark") { dismiss() }
                    }

                    Text("Crea tu primer mundo.")
                        .font(AtlasType.display(46, weight: .medium))
                        .tracking(-1.5)
                        .foregroundStyle(AtlasColor.porcelain)

                    Text("Tu cuenta conecta activos, evidencia y versiones para que ATLAS pueda construir memoria física con el tiempo.")
                        .font(AtlasType.ui(14.5))
                        .foregroundStyle(AtlasColor.smoke)
                        .lineSpacing(4)

                    VStack(spacing: 12) {
                        input("Nombre", text: $name, symbol: "person")
                        input("Correo", text: $email, symbol: "envelope")
                    }

                    Toggle(isOn: $accepted) {
                        Text("Acepto los términos y la política de privacidad.")
                            .font(AtlasType.ui(12.5))
                            .foregroundStyle(AtlasColor.smoke)
                    }
                    .tint(AtlasColor.electric)

                    AtlasPrimaryButton(title: "Crear cuenta", symbol: "arrow.right") {}
                    AtlasSecondaryButton(title: "Continuar con Apple", symbol: "apple.logo") {}
                }
                .padding(22)
                .padding(.bottom, 40)
            }
        }
    }

    private func input(_ placeholder: String, text: Binding<String>, symbol: String) -> some View {
        HStack(spacing: 11) {
            Image(systemName: symbol).foregroundStyle(AtlasColor.smoke)
            TextField(placeholder, text: text)
                .font(AtlasType.ui(14.5))
                .foregroundStyle(AtlasColor.porcelain)
                .tint(AtlasColor.electricBright)
        }
        .padding(.horizontal, 15)
        .frame(height: 52)
        .background(RoundedRectangle(cornerRadius: 17).fill(Color.white.opacity(0.045)))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AtlasColor.border, lineWidth: 1))
    }
}


// MARK: - ContentView.swift

struct ContentView: View {
    @State private var selectedTab: AtlasTab = .world
    @State private var path: [AtlasRoute] = []
    @State private var activeSheet: AtlasSheet?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                AtlasBackdrop()

                Group {
                    switch selectedTab {
                    case .world:
                        WorldScreen(
                            open: { path.append($0) },
                            startScan: { activeSheet = .scan }
                        )
                    case .assets:
                        AssetsScreen(open: { path.append($0) })
                    case .changes:
                        ChangesScreen(open: { path.append($0) })
                    case .profile:
                        ProfileScreen(open: { path.append($0) })
                    }
                }
                .padding(.bottom, 94)

                AtlasDock(selectedTab: $selectedTab) {
                    activeSheet = .scan
                }
            }
            .navigationDestination(for: AtlasRoute.self) { route in
                routeView(route)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .scan:
                ScanFlowView()
            }
        }
    }

    @ViewBuilder
    private func routeView(_ route: AtlasRoute) -> some View {
        switch route {
        case .search:
            SearchScreen()
        case .notifications:
            NotificationsScreen()
        case .alerts:
            AlertsScreen(open: { path.append($0) })
        case .reports:
            ReportsScreen(open: { path.append($0) })
        case .reportDetail:
            ReportDetailScreen()
        case .assetDetail:
            AssetDetailScreen(open: { path.append($0) })
        case .digitalTwin:
            DigitalTwinScreen()
        case .inspections:
            InspectionsScreen(open: { path.append($0) })
        case .inspectionDetail:
            InspectionDetailScreen(open: { path.append($0) })
        case .askAtlas:
            AskAtlasScreen()
        case .compare:
            CompareScreen()
        case .settings:
            SettingsScreen(open: { path.append($0) })
        case .account:
            AccountScreen()
        case .privacy:
            PrivacyScreen()
        case .help:
            HelpScreen()
        case .about:
            AboutScreen()
        case .onboarding:
            OnboardingPreviewScreen()
        case .login:
            LoginPreviewScreen()
        case .createAccount:
            CreateAccountPreviewScreen()
        case .screenMap:
            ScreenMapScreen(open: { path.append($0) })
        }
    }
}

private struct AtlasDock: View {
    @Binding var selectedTab: AtlasTab
    let startScan: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            dockButton(.world)
            dockButton(.assets)

            Button(action: startScan) {
                ZStack {
                    Circle()
                        .fill(AtlasColor.porcelain)
                        .frame(width: 54, height: 54)
                        .shadow(color: AtlasColor.electric.opacity(0.22), radius: 18, y: 8)
                    Image(systemName: "viewfinder")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AtlasColor.void)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Escanear")

            dockButton(.changes)
            dockButton(.profile)
        }
        .padding(.horizontal, 8)
        .frame(height: 70)
        .background(
            Capsule()
                .fill(AtlasColor.graphite.opacity(0.94))
                .overlay(Capsule().stroke(AtlasColor.borderStrong, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.34), radius: 24, y: 12)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func dockButton(_ tab: AtlasTab) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.18)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                Text(tab.title)
                    .font(AtlasType.ui(8.5, weight: selectedTab == tab ? .semibold : .regular))
            }
            .foregroundStyle(selectedTab == tab ? AtlasColor.porcelain : AtlasColor.smoke)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
