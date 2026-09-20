import AuthenticationServices
import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            AtlasColor.navy.ignoresSafeArea()

            VStack(spacing: 20) {
                AtlasMark(size: 62)
                    .environment(\.colorScheme, .dark)
                Text("ATLAS")
                    .font(AtlasType.display(.largeTitle, weight: .bold))
                    .tracking(5)
                    .foregroundStyle(.white)
                Text("INTELLIGENCE FOR A REAL WORLD")
                    .font(AtlasType.label(.caption, weight: .semibold))
                    .tracking(1.8)
                    .foregroundStyle(Color.white.opacity(0.58))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct OnboardingScreen: View {
    let continueAction: () -> Void
    @State private var page = 0

    private let steps = [
        ("01", "OBSERVA", "Captura el mundo real.", "Registra objetos, espacios y evidencia directamente desde el iPhone."),
        ("02", "RECUERDA", "Conserva la memoria de cada activo.", "Cada captura se convierte en un estado histórico que puedes consultar y comparar."),
        ("03", "ENTIENDE", "Detecta cambios y condiciones.", "ATLAS organiza evidencia, anomalías y contexto para explicar qué cambió."),
        ("04", "ACTÚA", "Convierte información física en decisiones.", "Inspecciona, crea mantenimiento, genera órdenes y conserva trazabilidad.")
    ]

    var body: some View {
        AtlasPage {
            VStack(spacing: 0) {
                HStack {
                    AtlasMark(size: 32)
                    Text("ATLAS")
                        .font(AtlasType.heading(.headline, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AtlasColor.ink)
                    Spacer()
                    Text("\(page + 1) / \(steps.count)")
                        .font(AtlasType.mono(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)

                TabView(selection: $page) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading, spacing: 18) {
                            Spacer()
                            Text(step.0)
                                .font(AtlasType.mono(.caption, weight: .semibold))
                                .foregroundStyle(AtlasColor.blue)
                            Text(step.1)
                                .font(AtlasType.label(.caption, weight: .semibold))
                                .tracking(1.5)
                                .foregroundStyle(AtlasColor.inkMuted)
                            Text(step.2)
                                .font(AtlasType.display(.largeTitle, weight: .semibold))
                                .tracking(-1)
                                .foregroundStyle(AtlasColor.ink)
                            Text(step.3)
                                .font(AtlasType.body(.body))
                                .foregroundStyle(AtlasColor.inkSecondary)
                                .lineSpacing(5)
                                .frame(maxWidth: 520, alignment: .leading)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 14) {
                    HStack(spacing: 6) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Capsule()
                                .fill(index == page ? AtlasColor.blue : AtlasColor.lineStrong)
                                .frame(width: index == page ? 24 : 8, height: 5)
                        }
                    }

                    AtlasPrimaryButton(
                        title: page == steps.count - 1 ? "Continuar" : "Siguiente",
                        symbol: "arrow.right"
                    ) {
                        if page == steps.count - 1 {
                            continueAction()
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) { page += 1 }
                        }
                    }
                }
                .padding(22)
            }
        }
    }
}

struct LoginScreen: View {
    let continueAction: () -> Void
    let createAction: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var showingRecovery = false

    var body: some View {
        AtlasPage {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        AtlasMark(size: 34)
                        Text("ATLAS")
                            .font(AtlasType.heading(.headline, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(AtlasColor.ink)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Accede a tu mundo físico.")
                            .font(AtlasType.display(.largeTitle, weight: .semibold))
                            .tracking(-1)
                            .foregroundStyle(AtlasColor.ink)
                        Text("Tus activos, estados, evidencia e inspecciones en una sola experiencia.")
                            .font(AtlasType.body(.body))
                            .foregroundStyle(AtlasColor.inkSecondary)
                    }

                    VStack(spacing: 14) {
                        field(title: "EMAIL", text: $email, secure: false)
                        field(title: "CONTRASEÑA", text: $password, secure: true)
                    }

                    AtlasPrimaryButton(title: "Continuar", symbol: "arrow.right", action: continueAction)

                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    }, onCompletion: { _ in
                        continueAction()
                    })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                    HStack {
                        Button("Recuperar contraseña") { showingRecovery = true }
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasColor.blue)
                        Spacer()
                        Button("Crear cuenta", action: createAction)
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasColor.blue)
                    }
                }
                .padding(24)
            }
        }
        .sheet(isPresented: $showingRecovery) {
            PasswordRecoverySheet()
                .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private func field(title: String, text: Binding<String>, secure: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.inkMuted)

            if secure {
                SecureField("••••••••", text: text)
                    .font(AtlasType.body(.body))
                    .padding(.horizontal, 14)
                    .frame(minHeight: 50)
                    .background(AtlasColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
            } else {
                TextField("nombre@empresa.com", text: text)
                    .font(AtlasType.body(.body))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 50)
                    .background(AtlasColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(AtlasColor.line) }
            }
        }
    }
}

private struct PasswordRecoverySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Recuperar acceso")
                .font(AtlasType.heading(.title2))
                .foregroundStyle(AtlasColor.ink)
            Text("Ingresa tu correo y te enviaremos las instrucciones disponibles para tu cuenta.")
                .font(AtlasType.body(.body))
                .foregroundStyle(AtlasColor.inkSecondary)
            TextField("correo@empresa.com", text: $email)
                .keyboardType(.emailAddress)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(AtlasColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            AtlasPrimaryButton(title: "Enviar instrucciones") { dismiss() }
        }
        .padding(24)
        .background(AtlasColor.background)
    }
}
