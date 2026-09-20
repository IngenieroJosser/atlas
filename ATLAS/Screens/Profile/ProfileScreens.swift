import SwiftUI

struct ProfileScreen: View {
    let open: (AtlasRoute) -> Void
    @AppStorage("atlas.authenticated") private var authenticated = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                AtlasEditorialHeader(
                    eyebrow: "YOU",
                    title: "Tu espacio dentro de ATLAS.",
                    subtitle: "Organización, dispositivos, permisos, seguridad y preferencias."
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("JOSS CORVIAN")
                        .font(AtlasType.heading(.title2, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text("Administrador · ATLAS Workspace")
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }

                profileGroup("01", "WORKSPACE", [
                    ("Organización", "Miembros, roles y workspaces", "building.2", AtlasRoute.organization),
                    ("Integraciones", "Cloud, APIs y sistemas externos", "link", AtlasRoute.integrations),
                    ("Reportes", "Historial y documentos", "doc.text", AtlasRoute.reports)
                ])

                profileGroup("02", "DEVICE & PRIVACY", [
                    ("Permisos", "Cámara, fotos, ubicación, micrófono…", "checkmark.shield", AtlasRoute.permissions),
                    ("Seguridad", "Face ID, sesiones y dispositivos", "lock.shield", AtlasRoute.security),
                    ("Privacidad", "Qué datos usa ATLAS y para qué", "hand.raised", AtlasRoute.privacy)
                ])

                profileGroup("03", "ATLAS", [
                    ("Ajustes", "Apariencia, notificaciones y sincronización", "gearshape", AtlasRoute.settings),
                    ("Ayuda", "Uso, escaneo y solución de problemas", "questionmark.circle", AtlasRoute.help),
                    ("Acerca de", "Physical Intelligence Platform", "info.circle", AtlasRoute.about)
                ])

                Button {
                    authenticated = false
                } label: {
                    Text("Cerrar sesión")
                        .font(AtlasType.body(.body, weight: .semibold))
                        .foregroundStyle(AtlasColor.critical)
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
    }

    private func profileGroup(_ index: String, _ title: String, _ items: [(String, String, String, AtlasRoute)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AtlasSectionLabel(index: index, title: title)
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                PrimaryActionRow(title: item.0, subtitle: item.1, symbol: item.2) { open(item.3) }
                if idx < items.count - 1 { AtlasDivider() }
            }
        }
    }
}

struct OrganizationScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "ORGANIZATION",
                        title: "ATLAS Workspace.",
                        subtitle: "Organización, miembros, roles, workspaces e invitaciones.",
                        backAction: { dismiss() }
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        AtlasSectionLabel(index: "01", title: "ORGANIZATION")
                        detail("Nombre", "ATLAS Workspace")
                        detail("Miembros", "04")
                        detail("Workspaces", "02")
                    }

                    memberSection

                    VStack(alignment: .leading, spacing: 10) {
                        AtlasSectionLabel(index: "03", title: "WORKSPACES")
                        PrimaryActionRow(title: "Operación principal", subtitle: "12 activos · 41 cambios", symbol: "square.grid.2x2") {}
                        AtlasDivider()
                        PrimaryActionRow(title: "Piloto", subtitle: "3 activos · entorno controlado", symbol: "flask") {}
                    }
                }
                .padding(20)
            }
        }
    }

    private var memberSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            AtlasSectionLabel(index: "02", title: "MEMBERS")
            member("JC", "Joss Corvian", "Administrador")
            AtlasDivider()
            member("DC", "Diana C.", "Inspector")
            AtlasDivider()
            member("MT", "Mateo T.", "Técnico")
        }
    }

    private func member(_ initials: String, _ name: String, _ role: String) -> some View {
        HStack(spacing: 12) {
            Text(initials)
                .font(AtlasType.label(.caption, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
                .frame(width: 38, height: 38)
                .background(AtlasColor.blueSoft)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                Text(role).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func detail(_ key: String, _ value: String) -> some View {
        HStack { Text(key).foregroundStyle(AtlasColor.inkSecondary); Spacer(); Text(value).fontWeight(.semibold).foregroundStyle(AtlasColor.ink) }
            .font(AtlasType.body(.subheadline))
            .padding(.vertical, 7)
    }
}

struct IntegrationsScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "INTEGRATIONS",
                        title: "Conecta ATLAS cuando exista una integración real.",
                        subtitle: "No mostramos conectores como activos si todavía no están configurados.",
                        backAction: { dismiss() }
                    )

                    integration("Cloud storage", "No conectado", "externaldrive", false)
                    AtlasDivider()
                    integration("Enterprise API", "Disponible en configuración empresarial", "point.3.connected.trianglepath.dotted", false)
                    AtlasDivider()
                    integration("Sistemas externos", "Sin conectores configurados", "square.stack.3d.up.slash", false)

                    AtlasEmptyState(
                        eyebrow: "INTEGRATIONS / EMPTY",
                        title: "Aún no hay integraciones activas.",
                        detail: "Cuando conectes un sistema, ATLAS mostrará aquí el estado real de la conexión y la última sincronización.",
                        actionTitle: nil,
                        action: nil
                    )
                }
                .padding(20)
            }
        }
    }

    private func integration(_ name: String, _ detail: String, _ symbol: String, _ active: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).foregroundStyle(AtlasColor.blue).frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                Text(detail).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
            }
            Spacer()
            Circle().fill(active ? AtlasColor.healthy : AtlasColor.lineStrong).frame(width: 8, height: 8)
        }
        .padding(.vertical, 12)
    }
}

struct SecurityScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var faceID = true

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(eyebrow: "SECURITY", title: "Protección clara y visible.", backAction: { dismiss() })

                    Toggle("Usar Face ID cuando esté disponible", isOn: $faceID)
                        .font(AtlasType.body(.body, weight: .medium))
                        .tint(AtlasColor.blue)
                        .padding(.vertical, 10)
                    AtlasDivider()
                    PrimaryActionRow(title: "Sesiones", subtitle: "1 sesión activa", symbol: "key") {}
                    AtlasDivider()
                    PrimaryActionRow(title: "Dispositivos", subtitle: "JCORVIAN iPhone · este dispositivo", symbol: "iphone") {}
                    AtlasDivider()
                    PrimaryActionRow(title: "Protección de datos", subtitle: "Cifrado y almacenamiento local", symbol: "lock.doc") {}
                }
                .padding(20)
            }
        }
    }
}

struct PrivacyScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    AtlasEditorialHeader(
                        eyebrow: "PRIVACY",
                        title: "Tus datos físicos deben ser comprensibles.",
                        subtitle: "ATLAS separa lo que captura, lo que procesa y lo que sincroniza.",
                        backAction: { dismiss() }
                    )

                    privacy("Cámara", "Se usa para capturar evidencia y crear estados del mundo. La captura ocurre solo cuando abres el escáner.")
                    privacy("Ubicación", "Puede asociar contexto territorial a un activo cuando tú concedas permiso.")
                    privacy("Fotos", "Permite seleccionar evidencia existente desde tu fototeca.")
                    privacy("Micrófono", "Reservado para notas por voz cuando esa función esté activa.")
                    privacy("Movimiento", "Puede complementar experiencias espaciales compatibles.")
                    privacy("Analítica", "Debe distinguir métricas de producto de la evidencia física registrada.")
                    privacy("Datos del mundo físico", "Estados, evidencia, hallazgos y relaciones pertenecen al workspace que los crea.")
                }
                .padding(20)
            }
        }
    }

    private func privacy(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
            Text(text).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary).lineSpacing(4)
            AtlasDivider().padding(.top, 8)
        }
    }
}

struct DevicePermissionsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var permissions = AtlasPermissionCenter.shared

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(
                        eyebrow: "DEVICE PERMISSIONS",
                        title: "Controla qué puede usar ATLAS.",
                        subtitle: "Los estados que ves aquí provienen de iOS, no de valores simulados.",
                        backAction: { dismiss() }
                    )

                    permission("Cámara", "camera", permissions.camera, request: permissions.requestCamera)
                    permission("Fotos", "photo", permissions.photos, request: permissions.requestPhotos)
                    permission("Ubicación", "location", permissions.location, request: permissions.requestLocation)
                    permission("Micrófono", "mic", permissions.microphone, request: permissions.requestMicrophone)
                    permission("Movimiento", "figure.walk.motion", permissions.motion, request: permissions.requestMotion)
                    permission("Notificaciones", "bell", permissions.notifications, request: permissions.requestNotifications)
                }
                .padding(20)
            }
        }
        .onAppear { permissions.refresh() }
    }

    private func permission(_ name: String, _ symbol: String, _ status: AtlasPermissionStatus, request: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).foregroundStyle(AtlasColor.blue).frame(width: 32)
            Text(name).font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.ink)
            Spacer()
            Button {
                if status == .denied || status == .restricted {
                    permissions.openSettings()
                } else if status == .notDetermined {
                    request()
                }
            } label: {
                Text(status.rawValue.uppercased())
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(status.color)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(status.color.opacity(0.08))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(status == .allowed)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { AtlasDivider() }
    }
}

struct SettingsScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasEditorialHeader(eyebrow: "SETTINGS", title: "ATLAS, a tu manera.", backAction: { dismiss() })
                    Toggle("Notificaciones de atención", isOn: $notificationsEnabled)
                        .font(AtlasType.body(.body, weight: .medium))
                        .tint(AtlasColor.blue)
                        .padding(.vertical, 12)
                    AtlasDivider()
                    PrimaryActionRow(title: "Permisos", subtitle: "Estados reales de iOS", symbol: "checkmark.shield") { open(.permissions) }
                    AtlasDivider()
                    PrimaryActionRow(title: "Privacidad", subtitle: "Captura y datos físicos", symbol: "hand.raised") { open(.privacy) }
                    AtlasDivider()
                    PrimaryActionRow(title: "Integraciones", subtitle: "Sistemas externos", symbol: "link") { open(.integrations) }
                }
                .padding(20)
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
                    AtlasEditorialHeader(eyebrow: "HELP", title: "Encuentra una respuesta sin perderte.", backAction: { dismiss() })
                    AtlasSearchField(text: $query, placeholder: "Buscar ayuda")
                    help("Primeros pasos", "Cómo crear tu primer estado del mundo")
                    help("Escaneo", "Cámara, captura y buenas prácticas")
                    help("Activos", "Estados, evidencia y memoria")
                    help("Inspecciones", "Flujos guiados y resultados")
                    help("Privacidad", "Permisos y datos físicos")
                    help("Solución de problemas", "Cámara, sincronización y acceso")
                    help("Contactar soporte", "Escalar un problema al equipo ATLAS")
                }
                .padding(20)
            }
        }
    }

    private func help(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(AtlasType.body(.body, weight: .semibold)).foregroundStyle(AtlasColor.ink)
            Text(detail).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
            AtlasDivider().padding(.top, 10)
        }.padding(.vertical, 6)
    }
}

struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 24) {
                AtlasEditorialHeader(eyebrow: "ABOUT", title: "ATLAS", subtitle: "INTELLIGENCE FOR A REAL WORLD", backAction: { dismiss() })
                Spacer()
                AtlasMark(size: 72)
                Text("Physical Intelligence Platform")
                    .font(AtlasType.heading(.title2, weight: .semibold))
                    .foregroundStyle(AtlasColor.ink)
                Text("ATLAS organiza observación, memoria, cambios, evidencia y acciones alrededor de elementos reales. La interfaz prioriza trazabilidad y contexto por encima del ruido visual.")
                    .font(AtlasType.body(.body))
                    .foregroundStyle(AtlasColor.inkSecondary)
                    .lineSpacing(5)
                Spacer()
                Text("ATLAS · 2026")
                    .font(AtlasType.mono(.caption2))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            .padding(20)
        }
    }
}
