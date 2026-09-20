import AuthenticationServices
import SwiftUI

struct SplashScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        ZStack {
            AtlasColor.navy.ignoresSafeArea()

            VStack(spacing: 20) {
                AtlasMark(size: 62)
                    .environment(\.colorScheme, .dark)
                    .scaleEffect(reduceMotion || revealed ? 1 : 0.88)
                    .opacity(reduceMotion || revealed ? 1 : 0)

                Text("ATLAS")
                    .font(AtlasType.display(.largeTitle, weight: .bold))
                    .tracking(revealed || reduceMotion ? 5 : 8)
                    .foregroundStyle(.white)
                    .opacity(reduceMotion || revealed ? 1 : 0)
                    .offset(y: reduceMotion || revealed ? 0 : 6)

                Text("INTELLIGENCE FOR A REAL WORLD")
                    .font(AtlasType.label(.caption, weight: .semibold))
                    .tracking(1.8)
                    .foregroundStyle(Color.white.opacity(0.58))
                    .opacity(reduceMotion || revealed ? 1 : 0)
                    .offset(y: reduceMotion || revealed ? 0 : 5)
            }
        }
        .accessibilityElement(children: .combine)
        .onAppear {
            if reduceMotion {
                revealed = true
            } else {
                withAnimation(.easeOut(duration: 0.48)) { revealed = true }
            }
        }
    }
}

struct OnboardingScreen: View {
    let continueAction: () -> Void
    @State private var page = 0
    @Namespace private var progressNamespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let steps = [
        ("01", "OBSERVA", "Captura el mundo real.", "Registra objetos, espacios y evidencia directamente desde el iPhone."),
        ("02", "RECUERDA", "Conserva la memoria de cada activo.", "Cada captura se convierte en un estado histórico que puedes consultar y comparar."),
        ("03", "ENTIENDE", "Detecta cambios y condiciones.", "ATLAS organiza evidencia, anomalías y contexto para explicar qué cambió."),
        ("04", "ACTÚA", "Convierte información física en decisiones.", "Inspecciona, crea mantenimiento, genera órdenes y conserva trazabilidad.")
    ]

    var body: some View {
        AtlasPage {
            VStack(spacing: 0) {
                topBar
                pages
                footer
            }
        }
    }

    private var topBar: some View {
        HStack {
            AtlasMark(size: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text("ATLAS")
                    .font(AtlasType.heading(.headline, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(AtlasColor.ink)
                Text("FIRST RUN / \(String(format: "%02d", page + 1))")
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            Spacer()
            Text("\(page + 1) / \(steps.count)")
                .font(AtlasType.mono(.caption, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .atlasStagger(0, distance: 6)
    }

    private var pages: some View {
        TabView(selection: $page) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                VStack(alignment: .leading, spacing: 18) {
                    Spacer(minLength: 24)

                    ZStack(alignment: .bottomLeading) {
                        AtlasColor.navy

                        Text(step.0)
                            .font(AtlasType.display(.largeTitle, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.07))
                            .scaleEffect(3.5, anchor: .bottomLeading)
                            .offset(x: 28, y: 14)

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("(\(step.0)) / \(step.1)")
                                    .font(AtlasType.label(.caption2, weight: .semibold))
                                    .tracking(1.0)
                                    .foregroundStyle(Color.white.opacity(0.58))
                                Spacer()
                                Rectangle().fill(AtlasColor.blue).frame(width: 38, height: 3)
                            }

                            Spacer()

                            Text(step.2)
                                .font(AtlasType.display(.largeTitle, weight: .semibold))
                                .tracking(-1.25)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(step.3)
                                .font(AtlasType.body(.body, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.72))
                                .lineSpacing(5)
                                .frame(maxWidth: 460, alignment: .leading)
                        }
                        .padding(22)
                    }
                    .frame(maxHeight: 430)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    HStack(alignment: .top, spacing: 14) {
                        Text("ATLAS")
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(1.0)
                            .foregroundStyle(AtlasColor.blue)
                        Text("Cada paso reduce incertidumbre sobre un elemento del mundo real.")
                            .font(AtlasType.body(.caption, weight: .medium))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }

                    Spacer(minLength: 18)
                }
                .padding(.horizontal, 22)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: page) { _, _ in AtlasHaptics.selection() }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { index in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(AtlasColor.lineStrong)
                            .frame(width: 26, height: 2)
                        if index == page {
                            Rectangle()
                                .fill(AtlasColor.blue)
                                .frame(width: 26, height: 2)
                                .matchedGeometryEffect(id: "onboarding-progress", in: progressNamespace)
                        }
                    }
                }
                Spacer()
            }

            AtlasPrimaryButton(
                title: page == steps.count - 1 ? "Entrar a ATLAS" : "Continuar",
                symbol: "arrow.right"
            ) {
                if page == steps.count - 1 {
                    AtlasHaptics.success()
                    continueAction()
                } else {
                    AtlasHaptics.selection()
                    if reduceMotion { page += 1 }
                    else { withAnimation(AtlasMotion.softSpring) { page += 1 } }
                }
            }
        }
        .padding(22)
        .atlasStagger(1, distance: 8)
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    loginHero
                    form
                }
            }
        }
        .sheet(isPresented: $showingRecovery) {
            PasswordRecoverySheet()
                .presentationDetents([.medium])
        }
    }

    private var loginHero: some View {
        ZStack(alignment: .bottomLeading) {
            AtlasColor.navy

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    AtlasMark(size: 34)
                        .environment(\.colorScheme, .dark)
                    Text("ATLAS")
                        .font(AtlasType.heading(.headline, weight: .bold))
                        .tracking(2.3)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("SECURE / 01")
                        .font(AtlasType.mono(.caption2, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.46))
                }

                Spacer()

                Rectangle().fill(AtlasColor.blue).frame(width: 44, height: 3)

                Text("Accede a tu\nmundo físico.")
                    .font(AtlasType.display(.largeTitle, weight: .semibold))
                    .tracking(-1.3)
                    .foregroundStyle(.white)

                Text("Estados, evidencia e inspecciones conectados a una sola memoria.")
                    .font(AtlasType.body(.body))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .lineSpacing(4)
            }
            .padding(22)
        }
        .frame(height: 330)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .atlasStagger(0)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(spacing: 14) {
                field(title: "EMAIL", text: $email, secure: false)
                field(title: "CONTRASEÑA", text: $password, secure: true)
            }
            .atlasStagger(1)

            AtlasPrimaryButton(title: "Continuar", symbol: "arrow.right") {
                AtlasHaptics.success()
                continueAction()
            }
            .atlasStagger(2)

            HStack(spacing: 12) {
                Rectangle().fill(AtlasColor.line).frame(height: 1)
                Text("O")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
                Rectangle().fill(AtlasColor.line).frame(height: 1)
            }

            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.email, .fullName]
            }, onCompletion: { _ in
                AtlasHaptics.success()
                continueAction()
            })
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .atlasStagger(3)

            HStack {
                Button("Recuperar contraseña") { showingRecovery = true }
                    .font(AtlasType.body(.subheadline, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkSecondary)
                Spacer()
                Button("Crear cuenta →") {
                    AtlasHaptics.selection()
                    createAction()
                }
                .font(AtlasType.body(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
            }
            .atlasStagger(4)
        }
        .padding(.horizontal, 22)
        .padding(.top, 28)
        .padding(.bottom, 30)
    }

    @ViewBuilder
    private func field(title: String, text: Binding<String>, secure: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.9)
                .foregroundStyle(AtlasColor.inkMuted)

            Group {
                if secure {
                    SecureField("••••••••", text: text)
                } else {
                    TextField("nombre@empresa.com", text: text)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
            }
            .font(AtlasType.body(.body, weight: .medium))
            .padding(.horizontal, 0)
            .frame(minHeight: 48)
            .overlay(alignment: .bottom) {
                Rectangle().fill(AtlasColor.lineStrong).frame(height: 1)
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
            AtlasPrimaryButton(title: "Enviar instrucciones") {
                AtlasHaptics.success()
                dismiss()
            }
        }
        .padding(24)
        .background(AtlasColor.background)
        .atlasScreenEntrance(distance: 14)
    }
}
