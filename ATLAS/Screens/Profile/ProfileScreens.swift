import AVFoundation
import Photos
import SwiftUI
import UIKit

struct ProfileScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 7) {
                    AtlasSectionLabel(index: "05", title: "YOU")
                    Text(store.profile?.user.fullName.ifEmpty("Tu perfil") ?? "Tu perfil")
                        .font(AtlasType.display(.largeTitle, weight: .semibold)).tracking(-1).foregroundStyle(AtlasColor.ink)
                    Text(store.profile?.user.email ?? "")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                }

                if let profile = store.profile {
                    HStack(spacing: 8) {
                        Metric(value: profile.role.atlasDisplay, label: "Rol")
                        Metric(value: String(store.devices.count), label: "Devices")
                        Metric(value: String(store.sessions.count), label: "Sessions")
                    }
                }

                section("WORKSPACE", rows: [
                    ("Organization", "building.2", AtlasRoute.organization),
                    ("Integrations", "link", AtlasRoute.integrations)
                ])
                section("ACCOUNT", rows: [
                    ("Security", "lock.shield", AtlasRoute.security),
                    ("Privacy", "hand.raised", AtlasRoute.privacy),
                    ("Device permissions", "switch.2", AtlasRoute.permissions),
                    ("Settings", "gearshape", AtlasRoute.settings)
                ])
                section("SUPPORT", rows: [
                    ("Help", "questionmark.circle", AtlasRoute.help),
                    ("About ATLAS", "info.circle", AtlasRoute.about)
                ])

                Button(role: .destructive) {
                    Task { await store.logout() }
                } label: {
                    HStack { Image(systemName: "rectangle.portrait.and.arrow.right"); Text("Cerrar sesión") }
                        .font(AtlasType.body(.body, weight: .semibold)).frame(maxWidth: .infinity, minHeight: 48)
                }
            }
            .padding(20)
        }
    }

    private func section(_ title: String, rows: [(String, String, AtlasRoute)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(AtlasType.label(.caption2, weight: .semibold)).tracking(0.8).foregroundStyle(AtlasColor.inkMuted)
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                PrimaryActionRow(title: row.0, subtitle: "", symbol: row.1) { open(row.2) }
            }
        }
    }
}

struct OrganizationScreen: View {
    @EnvironmentObject private var store: AtlasAppStore
    @State private var workspaceName = ""
    @State private var inviteEmail = ""
    @State private var inviteRole = "member"

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasBackHeader(title: "Organization", eyebrow: "WORKSPACE / TEAM")
                    if let organization = store.organization {
                        Text(organization.name).font(AtlasType.display(.title, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                        Text("Owner · \(organization.ownerId.prefix(8))…").font(AtlasType.mono(.caption)).foregroundStyle(AtlasColor.inkMuted)
                    }

                    AtlasSectionLabel(index: "01", title: "MEMBERS", trailing: String(format: "%02d", store.members.count))
                    ForEach(store.members) { member in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(member.fullName.ifEmpty(member.email)).font(AtlasType.heading(.subheadline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                Text(member.email).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                            }
                            Spacer(); Text(member.role.uppercased()).font(AtlasType.mono(.caption2)).foregroundStyle(AtlasColor.blue)
                        }.padding(.vertical, 8)
                    }

                    AtlasSectionLabel(index: "02", title: "WORKSPACES", trailing: String(format: "%02d", store.workspaces.count))
                    ForEach(store.workspaces) { workspace in MetadataLabel(title: "Workspace", value: workspace.name) }
                    HStack {
                        TextField("Nuevo workspace", text: $workspaceName).textFieldStyle(.roundedBorder)
                        Button("Crear") { Task { if await store.createWorkspace(name: workspaceName) { workspaceName = "" } } }
                    }

                    AtlasSectionLabel(index: "03", title: "INVITATIONS")
                    HStack { TextField("email@empresa.com", text: $inviteEmail).keyboardType(.emailAddress).textFieldStyle(.roundedBorder); Picker("Rol", selection: $inviteRole) { ForEach(["member", "viewer", "inspector", "technician", "admin"], id: \.self) { Text($0.atlasDisplay).tag($0) } }.pickerStyle(.menu) }
                    AtlasSecondaryButton(title: "Invitar miembro", symbol: "person.badge.plus") { Task { if await store.invite(email: inviteEmail, role: inviteRole) { inviteEmail = "" } } }
                }.padding(20)
            }
        }
        .task { await store.loadOrganizationDetails() }
    }
}

struct IntegrationsScreen: View {
    @EnvironmentObject private var store: AtlasAppStore
    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Integrations", eyebrow: "SYSTEM / EXTERNAL")
                    Text("ATLAS solo muestra integraciones que el backend conoce. Una integración no configurada no se presenta como funcional.")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                    if store.integrations.isEmpty {
                        AtlasEmptyState(title: "Sin integraciones configuradas", detail: "Conecta servicios externos cuando realmente estén disponibles en tu backend.", symbol: "link")
                    } else {
                        ForEach(store.integrations) { integration in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(integration.name).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink)
                                    Text(integration.provider.uppercased()).font(AtlasType.label(.caption2, weight: .semibold)).foregroundStyle(AtlasColor.inkMuted)
                                }
                                Spacer()
                                Text(integration.isConfigured ? "CONFIGURED" : integration.status.uppercased()).font(AtlasType.mono(.caption2)).foregroundStyle(integration.isConfigured ? AtlasColor.healthy : AtlasColor.inkMuted)
                            }.padding(.vertical, 12)
                            AtlasDivider()
                        }
                    }
                }.padding(20)
            }
        }
    }
}

struct SecurityScreen: View {
    @EnvironmentObject private var store: AtlasAppStore
    @State private var showDeleteAccount = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Security", eyebrow: "ACCOUNT / SESSIONS")
                    AtlasSectionLabel(index: "01", title: "SESSIONS", trailing: String(format: "%02d", store.sessions.count))
                    ForEach(store.sessions) { session in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack { Text(session.deviceName).font(AtlasType.heading(.headline, weight: .semibold)); Spacer(); Text(session.revokedAt == nil ? "ACTIVE" : "REVOKED").font(AtlasType.mono(.caption2)).foregroundStyle(session.revokedAt == nil ? AtlasColor.healthy : AtlasColor.critical) }
                            Text("\(session.ipAddress) · \(session.lastSeenAt.atlasRelative)").font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                            if session.revokedAt == nil { Button("Revocar sesión") { Task { await store.revokeSession(session.id) } }.font(AtlasType.body(.caption, weight: .semibold)).foregroundStyle(AtlasColor.critical) }
                        }.padding(.vertical, 10)
                        AtlasDivider()
                    }
                    AtlasSectionLabel(index: "02", title: "DEVICES", trailing: String(format: "%02d", store.devices.count))
                    ForEach(store.devices) { device in MetadataLabel(title: device.platform.uppercased(), value: "\(device.deviceName) · iOS \(device.osVersion)") }

                    AtlasSectionLabel(index: "03", title: "ZONA DE RIESGO")
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Eliminar tu cuenta es permanente.")
                            .font(AtlasType.heading(.headline, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                        Text("ATLAS eliminará tu cuenta, sesiones, preferencias y datos personales. Si eres el único miembro de una organización propia, también se eliminará ese espacio y sus datos. En organizaciones compartidas, la propiedad se transferirá a otro miembro y se retirará tu atribución personal.")
                            .font(AtlasType.body(.caption))
                            .foregroundStyle(AtlasColor.inkSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(role: .destructive) {
                            showDeleteAccount = true
                        } label: {
                            HStack(spacing: 12) {
                                Text("Eliminar cuenta")
                                    .font(AtlasType.body(.body, weight: .semibold))
                                Spacer()
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(AtlasColor.critical)
                            .padding(.horizontal, 18)
                            .frame(minHeight: 54)
                            .background(AtlasColor.surface)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AtlasColor.critical.opacity(0.35), lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(AtlasPressButtonStyle())
                    }
                }.padding(20)
            }
        }
        .task { await store.loadSecurityDetails() }
        .sheet(isPresented: $showDeleteAccount) {
            DeleteAccountConfirmationSheet()
                .environmentObject(store)
        }
    }
}

private struct DeleteAccountConfirmationSheet: View {
    @EnvironmentObject private var store: AtlasAppStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmation = ""
    @State private var isDeleting = false

    private var canDelete: Bool {
        confirmation.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "ELIMINAR" && !isDeleting
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AtlasColor.critical)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Eliminar cuenta")
                        .font(AtlasType.display(.title, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text("Esta acción no se puede deshacer. Se cerrará tu sesión en este dispositivo y ATLAS solicitará al backend la eliminación permanente de la cuenta.")
                        .font(AtlasType.body(.body))
                        .foregroundStyle(AtlasColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Escribe ELIMINAR para confirmar")
                        .font(AtlasType.label(.caption, weight: .semibold))
                        .foregroundStyle(AtlasColor.inkMuted)
                    TextField("ELIMINAR", text: $confirmation)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(AtlasType.mono(.body))
                        .padding(14)
                        .background(AtlasColor.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if let error = store.errorMessage, !error.isEmpty {
                    Text(error)
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.critical)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button(role: .destructive) {
                    Task {
                        isDeleting = true
                        let deleted = await store.deleteAccount()
                        isDeleting = false
                        if deleted { dismiss() }
                    }
                } label: {
                    HStack {
                        Text(isDeleting ? "Eliminando…" : "Eliminar mi cuenta definitivamente")
                            .font(AtlasType.body(.body, weight: .semibold))
                        Spacer()
                        if isDeleting {
                            ProgressView()
                        } else {
                            Image(systemName: "trash")
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 54)
                    .background(canDelete ? AtlasColor.critical : AtlasColor.blueGray)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!canDelete)

                Button("Cancelar") { dismiss() }
                    .font(AtlasType.body(.body, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkSecondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(isDeleting)
        }
        .presentationDetents([.large])
    }
}

struct PrivacyScreen: View {
    @EnvironmentObject private var store: AtlasAppStore
    @State private var attention = true
    @State private var updates = false
    @State private var analytics = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Privacy", eyebrow: "DATA / CONTROL")
                    Text("Los permisos del dispositivo se gestionan en iOS. Estas preferencias controlan el comportamiento de tu cuenta en ATLAS.")
                        .font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
                    Toggle("Notificaciones de atención", isOn: $attention)
                    Toggle("Actualizaciones de producto", isOn: $updates)
                    Toggle("Analytics", isOn: $analytics)
                    AtlasPrimaryButton(title: "Guardar preferencias", symbol: "checkmark") { Task { await store.savePreferences(attention: attention, updates: updates, analytics: analytics) } }
                    AtlasSecondaryButton(title: "Exportar mis datos", symbol: "square.and.arrow.up") {
                        Task { _ = try? await AtlasAPIClient.shared.accountDataExport() }
                    }
                }.padding(20)
            }
        }
        .onAppear {
            if let p = store.preferences { attention = p.attentionNotifications; updates = p.productUpdates; analytics = p.analyticsEnabled }
        }
    }
}

struct DevicePermissionsScreen: View {
    @StateObject private var permissions = AtlasPermissionCenter.shared
    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AtlasBackHeader(title: "Device permissions", eyebrow: "IOS / PRIVACY")
                    permission("Camera", permissions.camera, "camera", permissions.requestCamera)
                    permission("Photos", permissions.photos, "photo", permissions.requestPhotos)
                    permission("Location", permissions.location, "location", permissions.requestLocation)
                    permission("Microphone", permissions.microphone, "mic", permissions.requestMicrophone)
                    permission("Motion", permissions.motion, "gyroscope", permissions.requestMotion)
                    permission("Notifications", permissions.notifications, "bell", permissions.requestNotifications)
                }.padding(20)
            }
        }
        .onAppear { permissions.refresh() }
    }

    private func permission(_ title: String, _ status: AtlasPermissionStatus, _ symbol: String, _ request: @escaping () -> Void) -> some View {
        PermissionState(
            symbol: symbol,
            title: title,
            detail: "Estado actual: \(status.rawValue). ATLAS consulta el permiso real que informa iOS.",
            buttonTitle: status == .denied || status == .restricted ? "Abrir Ajustes" : (status == .allowed ? "Permitido" : "Solicitar permiso")
        ) {
            if status == .denied || status == .restricted { permissions.openSettings() }
            else if status != .allowed { request() }
        }
    }
}

struct SettingsScreen: View {
    let open: (AtlasRoute) -> Void
    @EnvironmentObject private var store: AtlasAppStore
    @State private var backendURL = AtlasConfiguration.baseURL.absoluteString
    @State private var saved = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    AtlasBackHeader(title: "Settings", eyebrow: "APP / CONFIGURATION")
                    AtlasSectionLabel(index: "API", title: "BACKEND")
                    TextField("https://atlas-api-fomq.onrender.com/api/v1", text: $backendURL)
                        .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                        .font(AtlasType.mono(.caption)).padding(12).background(AtlasColor.surfaceSecondary).clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Producción: atlas-api-fomq.onrender.com. Puedes cambiar este endpoint manualmente para desarrollo local cuando lo necesites.")
                        .font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted)
                    AtlasPrimaryButton(title: saved ? "Guardado" : "Guardar endpoint", symbol: "server.rack") {
                        Task { saved = await store.updateBackendURL(backendURL); if saved { await store.bootstrap() } }
                    }
                    PrimaryActionRow(title: "Permisos", subtitle: "Cámara, fotos, ubicación y sensores", symbol: "switch.2") { open(.permissions) }
                    PrimaryActionRow(title: "Privacidad", subtitle: "Preferencias y exportación", symbol: "hand.raised") { open(.privacy) }
                }.padding(20)
            }
        }
    }
}

struct HelpScreen: View {
    var body: some View { AtlasPage { ScrollView { VStack(alignment: .leading, spacing: 20) { AtlasBackHeader(title: "Help", eyebrow: "SUPPORT / GUIDE"); help("Getting started", "ATLAS usa por defecto la API de producción en Render. Inicia sesión y sincroniza Mundo."); help("Scanning", "La cámara captura evidencia; Vision procesa OCR local y el backend registra el world state."); help("Offline", "ATLAS marca operaciones locales y las envía por /sync/batch cuando vuelve la conectividad."); help("Troubleshooting", "Revisa Settings → Backend y permisos iOS. Para producción usa el endpoint HTTPS de Render; para desarrollo local, FastAPI debe escuchar en 0.0.0.0.") }.padding(20) } } }
    private func help(_ title: String, _ detail: String) -> some View { VStack(alignment: .leading, spacing: 5) { Text(title).font(AtlasType.heading(.headline, weight: .semibold)).foregroundStyle(AtlasColor.ink); Text(detail).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary) } }
}

struct AboutScreen: View {
    var body: some View { AtlasPage { VStack(alignment: .leading, spacing: 20) { AtlasBackHeader(title: "About ATLAS", eyebrow: "PHYSICAL INTELLIGENCE"); Spacer(); AtlasMark(size: 64); Text("ATLAS").font(AtlasType.display(.largeTitle, weight: .bold)).foregroundStyle(AtlasColor.ink); Text("INTELLIGENCE FOR A REAL WORLD").font(AtlasType.label(.caption, weight: .semibold)).tracking(1.2).foregroundStyle(AtlasColor.blue); Text("Mobile-first physical intelligence: assets, world states, evidence, inspections, changes and actions in one traceable system.").font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary); Spacer() }.padding(20) } }
}
