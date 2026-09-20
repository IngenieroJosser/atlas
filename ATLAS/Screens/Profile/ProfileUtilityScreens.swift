import SwiftUI

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
                    Button { open(.account) } label: { AtlasSettingRow(symbol: "person.crop.circle", title: "Cuenta", detail: "Perfil e identidad", tint: AtlasColor.aqua) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.organization) } label: { AtlasSettingRow(symbol: "building.2.crop.circle", title: "Organización", detail: "Espacios de trabajo y datos empresariales", tint: AtlasColor.electricBright) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.team) } label: { AtlasSettingRow(symbol: "person.2", title: "Equipo", detail: "Miembros, roles e invitaciones", tint: AtlasColor.violet) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.subscription) } label: { AtlasSettingRow(symbol: "creditcard", title: "Plan y suscripción", detail: "Uso, límites y facturación", tint: AtlasColor.lime) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.integrations) } label: { AtlasSettingRow(symbol: "puzzlepiece.extension", title: "Integraciones", detail: "Servicios, exportaciones y automatizaciones", tint: AtlasColor.electricBright) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.security) } label: { AtlasSettingRow(symbol: "lock.shield", title: "Seguridad", detail: "Sesiones, biometría y acceso", tint: AtlasColor.amber) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.syncStorage) } label: { AtlasSettingRow(symbol: "icloud.and.arrow.up", title: "Sincronización y almacenamiento", detail: "Nube, offline y consumo local", tint: AtlasColor.aqua) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.privacy) } label: { AtlasSettingRow(symbol: "hand.raised", title: "Privacidad y datos", detail: "Control de evidencia y procesamiento", tint: AtlasColor.amber) }.buttonStyle(.plain)
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
                    Button { open(.account) } label: { AtlasSettingRow(symbol: "person.crop.circle", title: "Cuenta") }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.permissions) } label: { AtlasSettingRow(symbol: "hand.raised", title: "Permisos del dispositivo", tint: AtlasColor.electricBright) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.security) } label: { AtlasSettingRow(symbol: "lock.shield", title: "Seguridad", tint: AtlasColor.amber) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.syncStorage) } label: { AtlasSettingRow(symbol: "icloud.and.arrow.up", title: "Sincronización y almacenamiento", tint: AtlasColor.aqua) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.integrations) } label: { AtlasSettingRow(symbol: "puzzlepiece.extension", title: "Integraciones", tint: AtlasColor.violet) }.buttonStyle(.plain)
                    AtlasHairline()
                    Button { open(.privacy) } label: { AtlasSettingRow(symbol: "hand.raised.fill", title: "Privacidad y datos", tint: AtlasColor.amber) }.buttonStyle(.plain)
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
                Text("ATLAS · PROTOTIPO UI v8.0")
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
        ("Exportar informe", .reportExport, "square.and.arrow.up"),
        ("Detalle de activo", .assetDetail, "cube.transparent"),
        ("Añadir activo", .addAsset, "plus.circle"),
        ("Editar activo", .editAsset, "pencil"),
        ("Mapa espacial", .spatialMap, "map"),
        ("Gemelo digital", .digitalTwin, "square.3.layers.3d"),
        ("Inspecciones", .inspections, "viewfinder"),
        ("Detalle de inspección", .inspectionDetail, "checklist"),
        ("Hallazgos", .findings, "exclamationmark.magnifyingglass"),
        ("Detalle de hallazgo", .findingDetail, "scope"),
        ("Evidencia", .evidence, "photo.on.rectangle.angled"),
        ("Mantenimiento", .maintenance, "wrench.and.screwdriver"),
        ("Detalle de orden", .workOrderDetail, "checklist.checked"),
        ("Preguntar a ATLAS", .askAtlas, "sparkles"),
        ("Historial de IA", .aiHistory, "text.bubble"),
        ("Comparar estados", .compare, "square.split.2x1"),
        ("Registro de actividad", .activityLog, "clock.arrow.circlepath"),
        ("Configuración", .settings, "gearshape"),
        ("Cuenta", .account, "person.crop.circle"),
        ("Organización", .organization, "building.2.crop.circle"),
        ("Equipo", .team, "person.2"),
        ("Plan y suscripción", .subscription, "creditcard"),
        ("Integraciones", .integrations, "puzzlepiece.extension"),
        ("Seguridad", .security, "lock.shield"),
        ("Sincronización", .syncStorage, "icloud.and.arrow.up"),
        ("Permisos", .permissions, "hand.raised"),
        ("Privacidad", .privacy, "hand.raised.fill"),
        ("Ayuda", .help, "questionmark.circle"),
        ("Acerca de ATLAS", .about, "info.circle"),
        ("Onboarding", .onboarding, "sparkles.rectangle.stack"),
        ("Iniciar sesión", .login, "person.badge.key"),
        ("Recuperar contraseña", .forgotPassword, "key"),
        ("Verificación", .verification, "checkmark.shield"),
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
