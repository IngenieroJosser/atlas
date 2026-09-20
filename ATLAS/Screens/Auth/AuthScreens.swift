import SwiftUI

struct LoginPreviewScreen: View {
    let open: (AtlasRoute) -> Void
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

                    Button("¿Olvidaste tu contraseña?") { open(.forgotPassword) }
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
        .background(RoundedRectangle(cornerRadius: 17).fill(AtlasColor.graphite))
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
        .background(RoundedRectangle(cornerRadius: 17).fill(AtlasColor.graphite))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AtlasColor.border, lineWidth: 1))
    }
}

struct CreateAccountPreviewScreen: View {
    let open: (AtlasRoute) -> Void
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

                    AtlasPrimaryButton(title: "Crear cuenta", symbol: "arrow.right") { open(.verification) }
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
        .background(RoundedRectangle(cornerRadius: 17).fill(AtlasColor.graphite))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(AtlasColor.border, lineWidth: 1))
    }
}
