import SwiftUI
import AVFoundation
import UIKit

struct OrganizationScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Workspace", title: "Organización", subtitle: "Administra el contexto empresarial donde viven activos, equipos y políticas.", backAction: { dismiss() })
                    AtlasGlass { VStack(spacing: 16) { AtlasValueRow(label: "Nombre", value: "ATLAS Lab"); AtlasHairline(); AtlasValueRow(label: "Workspace", value: "atlas-lab"); AtlasHairline(); AtlasValueRow(label: "Miembros", value: "8"); AtlasHairline(); AtlasValueRow(label: "Activos", value: "12") } }
                    AtlasKicker(index: "01", title: "Políticas")
                    AtlasSettingRow(symbol: "person.2", title: "Acceso por roles", detail: "Administrador, inspector, lector", tint: AtlasColor.violet)
                    AtlasHairline(); AtlasSettingRow(symbol: "tray.full", title: "Retención de evidencia", detail: "365 días", tint: AtlasColor.aqua)
                    AtlasHairline(); AtlasSettingRow(symbol: "globe", title: "Región de datos", detail: "Latinoamérica", tint: AtlasColor.electricBright)
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}

struct TeamScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Colaboración", title: "Equipo", subtitle: "Personas con acceso al workspace y su nivel de responsabilidad.", backAction: { dismiss() }, trailingSymbol: "person.badge.plus", trailingAction: {})
                    ForEach([("JC", "Joss Corvian", "Administrador"), ("AM", "Ana Martínez", "Inspectora"), ("CR", "Carlos Ríos", "Lector")], id: \.1) { item in HStack(spacing: 13) { Circle().fill(AtlasColor.electric.opacity(0.14)).frame(width: 44, height: 44).overlay(Text(item.0).font(AtlasType.rounded(12, weight: .bold)).foregroundStyle(AtlasColor.electricBright)); VStack(alignment: .leading, spacing: 3) { Text(item.1).font(AtlasType.ui(14.5, weight: .semibold)).foregroundStyle(AtlasColor.porcelain); Text(item.2).font(AtlasType.ui(11.5)).foregroundStyle(AtlasColor.smoke) }; Spacer(); Image(systemName: "ellipsis").foregroundStyle(AtlasColor.smoke) }.padding(.vertical, 7); AtlasHairline() }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}

struct SubscriptionScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Plan", title: "ATLAS Pro", subtitle: "Capacidad para inspecciones profesionales, historial y análisis avanzado.", backAction: { dismiss() })
                    AtlasGlass { VStack(alignment: .leading, spacing: 18) { Text("PRO").font(AtlasType.mono(9, weight: .bold)).tracking(1.4).foregroundStyle(AtlasColor.aqua); Text("$29 / mes").font(AtlasType.display(38, weight: .medium)).foregroundStyle(AtlasColor.porcelain); Text("Facturación mensual · Renovación automática").font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke); AtlasHairline(); AtlasValueRow(label: "Escaneos este mes", value: "18 / ilimitados"); AtlasValueRow(label: "Almacenamiento", value: "8,4 GB / 100 GB"); AtlasValueRow(label: "Miembros", value: "3 / 10") } }
                    AtlasPrimaryButton(title: "Administrar suscripción", symbol: "creditcard") {}
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}

struct IntegrationsScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Conectividad", title: "Integraciones", subtitle: "Conecta ATLAS con almacenamiento, automatización y sistemas de trabajo.", backAction: { dismiss() })
                    ForEach([("square.and.arrow.up", "Exportaciones", "PDF, JSON y enlaces compartibles", AtlasColor.electricBright), ("bolt.horizontal.circle", "Webhooks", "Eventos para flujos externos", AtlasColor.amber), ("icloud", "iCloud", "Sincronización privada entre dispositivos", AtlasColor.aqua), ("network", "API empresarial", "Acceso programático a activos y eventos", AtlasColor.violet)], id: \.1) { item in AtlasSettingRow(symbol: item.0, title: item.1, detail: item.2, tint: item.3); AtlasHairline() }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}

struct SecurityScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var biometric = true
    @State private var lock = true

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Protección", title: "Seguridad", subtitle: "Controla acceso, sesiones y protección local de la evidencia.", backAction: { dismiss() })
                    AtlasGlass { VStack(spacing: 18) { toggle("Face ID", detail: "Solicitar biometría al abrir ATLAS", value: $biometric); AtlasHairline(); toggle("Bloqueo automático", detail: "Proteger la app tras inactividad", value: $lock) } }
                    AtlasKicker(index: "01", title: "Sesiones")
                    AtlasSettingRow(symbol: "iphone", title: "Este iPhone", detail: "Activo ahora · iPhone 18 Pro", tint: AtlasColor.aqua)
                    AtlasHairline(); AtlasSettingRow(symbol: "laptopcomputer", title: "MacBook", detail: "Último acceso hoy 10:14", tint: AtlasColor.electricBright)
                    AtlasSecondaryButton(title: "Cerrar otras sesiones", symbol: "rectangle.portrait.and.arrow.right") {}
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func toggle(_ title: String, detail: String, value: Binding<Bool>) -> some View { HStack { VStack(alignment: .leading, spacing: 3) { Text(title).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain); Text(detail).font(AtlasType.ui(11.5)).foregroundStyle(AtlasColor.smoke) }; Spacer(); Toggle("", isOn: value).labelsHidden().tint(AtlasColor.electric) } }
}

struct SyncStorageScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var autoSync = true
    @State private var wifiOnly = false

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Datos", title: "Sincronización", subtitle: "Decide qué permanece en el dispositivo y qué se sincroniza con la nube.", backAction: { dismiss() })
                    AtlasGlass { VStack(alignment: .leading, spacing: 10) { Text("8,4 GB").font(AtlasType.display(40, weight: .medium)).foregroundStyle(AtlasColor.porcelain); Text("de 100 GB utilizados").font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke); GeometryReader { proxy in ZStack(alignment: .leading) { Capsule().fill(AtlasColor.voidSoft); Capsule().fill(AtlasColor.electricBright).frame(width: proxy.size.width * 0.084) } }.frame(height: 7) } }
                    AtlasGlass { VStack(spacing: 18) { toggle("Sincronización automática", value: $autoSync); AtlasHairline(); toggle("Solo Wi‑Fi", value: $wifiOnly) } }
                    AtlasSettingRow(symbol: "arrow.clockwise.icloud", title: "Sincronizar ahora", detail: "Última sincronización hace 3 min", tint: AtlasColor.aqua)
                    AtlasHairline(); AtlasSettingRow(symbol: "internaldrive", title: "Caché local", detail: "1,2 GB · disponible sin conexión", tint: AtlasColor.electricBright)
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
    private func toggle(_ title: String, value: Binding<Bool>) -> some View { HStack { Text(title).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain); Spacer(); Toggle("", isOn: value).labelsHidden().tint(AtlasColor.electric) } }
}

struct PermissionsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cameraStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(
                        eyebrow: "Dispositivo",
                        title: "Permisos",
                        subtitle: "ATLAS solo solicita acceso cuando una capacidad lo necesita.",
                        backAction: { dismiss() }
                    )

                    permissionRow(
                        symbol: "camera",
                        title: "Cámara",
                        detail: "Necesaria para escanear espacios, objetos y vehículos.",
                        status: cameraLabel,
                        tint: cameraTint,
                        action: cameraAction
                    )
                    AtlasHairline()

                    permissionRow(symbol: "waveform", title: "Micrófono", detail: "Para notas de voz durante inspecciones.", status: "Opcional", tint: AtlasColor.violet)
                    AtlasHairline()
                    permissionRow(symbol: "location", title: "Ubicación", detail: "Para añadir contexto geográfico a un activo.", status: "Opcional", tint: AtlasColor.electric)
                    AtlasHairline()
                    permissionRow(symbol: "photo", title: "Fotos", detail: "Para importar evidencia existente.", status: "Opcional", tint: AtlasColor.amber)

                    AtlasGlass {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(AtlasColor.electric)
                            Text("La cámara se solicita al iniciar un escaneo. Si la bloqueas, puedes volver a activarla desde Ajustes → ATLAS.")
                                .font(AtlasType.ui(13))
                                .foregroundStyle(AtlasColor.smoke)
                                .lineSpacing(3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .onAppear { cameraStatus = AVCaptureDevice.authorizationStatus(for: .video) }
    }

    private var cameraLabel: String {
        switch cameraStatus {
        case .authorized: return "Permitido"
        case .notDetermined: return "Sin solicitar"
        case .denied: return "Bloqueado"
        case .restricted: return "Restringido"
        @unknown default: return "Desconocido"
        }
    }

    private var cameraTint: Color {
        cameraStatus == .authorized ? AtlasColor.aqua : (cameraStatus == .denied ? AtlasColor.coral : AtlasColor.amber)
    }

    private func cameraAction() {
        switch cameraStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraStatus = granted ? .authorized : .denied
                }
            }
        case .denied, .restricted:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        default:
            break
        }
    }

    private func permissionRow(
        symbol: String,
        title: String,
        detail: String,
        status: String,
        tint: Color,
        action: (() -> Void)? = nil
    ) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 12).fill(tint.opacity(0.09)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AtlasType.ui(14.5, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                    Text(detail)
                        .font(AtlasType.ui(11.5))
                        .foregroundStyle(AtlasColor.smoke)
                }
                Spacer()
                Text(status)
                    .font(AtlasType.ui(10.5, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
