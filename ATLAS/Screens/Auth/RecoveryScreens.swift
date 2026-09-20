import SwiftUI

struct ForgotPasswordScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 24) {
                HStack { AtlasMark(size: 32); Spacer(); AtlasIconButton(symbol: "xmark") { dismiss() } }
                Spacer()
                Text("Recupera el acceso.").font(AtlasType.display(46, weight: .medium)).tracking(-1.4).foregroundStyle(AtlasColor.porcelain)
                Text("Ingresa tu correo y enviaremos un enlace seguro para restablecer la contraseña.").font(AtlasType.ui(14.5)).foregroundStyle(AtlasColor.smoke).lineSpacing(4)
                AtlasGlass { HStack(spacing: 10) { Image(systemName: "envelope").foregroundStyle(AtlasColor.smoke); TextField("correo@ejemplo.com", text: $email).font(AtlasType.ui(14)).foregroundStyle(AtlasColor.porcelain) }.frame(height: 44) }
                AtlasPrimaryButton(title: "Enviar enlace", symbol: "paperplane") { dismiss() }
                Spacer()
            }.padding(22)
        }
    }
}

struct VerificationScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""

    var body: some View {
        AtlasPage {
            VStack(alignment: .leading, spacing: 24) {
                HStack { AtlasMark(size: 32); Spacer(); AtlasIconButton(symbol: "xmark") { dismiss() } }
                Spacer()
                Text("Verifica tu identidad.").font(AtlasType.display(46, weight: .medium)).tracking(-1.4).foregroundStyle(AtlasColor.porcelain)
                Text("Introduce el código de seis dígitos enviado a tu correo.").font(AtlasType.ui(14.5)).foregroundStyle(AtlasColor.smoke)
                AtlasGlass { TextField("000000", text: $code).font(AtlasType.mono(26, weight: .bold)).tracking(8).foregroundStyle(AtlasColor.porcelain).multilineTextAlignment(.center).frame(height: 54) }
                AtlasPrimaryButton(title: "Verificar", symbol: "checkmark.shield") { dismiss() }
                AtlasSecondaryButton(title: "Reenviar código", symbol: "arrow.clockwise") {}
                Spacer()
            }.padding(22)
        }
    }
}
