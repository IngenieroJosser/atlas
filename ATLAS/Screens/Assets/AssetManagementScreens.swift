import SwiftUI

struct AddAssetScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var type = "Propiedad"
    @State private var location = ""
    private let types = ["Propiedad", "Vehículo", "Equipo", "Infraestructura"]

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Nuevo activo", title: "Añadir al mundo", subtitle: "Crea la identidad digital antes de capturar geometría, evidencia e historial.", backAction: { dismiss() })
                    AtlasKicker(index: "01", title: "Tipo de activo")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(types, id: \.self) { item in
                                Button { type = item } label: {
                                    Text(item)
                                        .font(AtlasType.ui(12.5, weight: .semibold))
                                        .foregroundStyle(type == item ? AtlasColor.void : AtlasColor.porcelainSoft)
                                        .padding(.horizontal, 14)
                                        .frame(height: 40)
                                        .background(Capsule().fill(type == item ? AtlasColor.porcelain : AtlasColor.graphite))
                                        .overlay(Capsule().stroke(type == item ? Color.clear : AtlasColor.border, lineWidth: 1))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    AtlasKicker(index: "02", title: "Identidad")
                    AtlasGlass {
                        VStack(spacing: 14) {
                            field("Nombre del activo", text: $name, icon: "textformat")
                            AtlasHairline()
                            field("Ubicación o referencia", text: $location, icon: "mappin.and.ellipse")
                        }
                    }
                    AtlasKicker(index: "03", title: "Siguiente paso")
                    AtlasGlass {
                        HStack(spacing: 14) {
                            Image(systemName: "viewfinder")
                                .font(.system(size: 22, weight: .light))
                                .foregroundStyle(AtlasColor.electricBright)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(AtlasColor.electric.opacity(0.1)))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Crear línea base")
                                    .font(AtlasType.ui(15, weight: .semibold)).foregroundStyle(AtlasColor.porcelain)
                                Text("Después de guardar podrás iniciar el primer escaneo del activo.")
                                    .font(AtlasType.ui(12.5)).foregroundStyle(AtlasColor.smoke)
                            }
                        }
                    }
                    AtlasPrimaryButton(title: "Guardar activo", symbol: "checkmark") { dismiss() }
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func field(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundStyle(AtlasColor.smoke)
            TextField(placeholder, text: text)
                .font(AtlasType.ui(14))
                .foregroundStyle(AtlasColor.porcelain)
        }
        .frame(height: 46)
    }
}

struct EditAssetScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "Apartamento Norte"
    @State private var reference = "ASSET-0012"
    @State private var notes = "Activo residencial principal"

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Activo / Edición", title: "Editar identidad", subtitle: "Actualiza metadatos sin alterar el historial físico ni las versiones capturadas.", backAction: { dismiss() })
                    AtlasGlass {
                        VStack(spacing: 18) {
                            editable("Nombre", value: $name)
                            AtlasHairline()
                            editable("Referencia", value: $reference)
                            AtlasHairline()
                            editable("Notas", value: $notes)
                        }
                    }
                    AtlasPrimaryButton(title: "Guardar cambios", symbol: "checkmark") { dismiss() }
                    AtlasSecondaryButton(title: "Archivar activo", symbol: "archivebox") {}
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }

    private func editable(_ label: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label.uppercased()).font(AtlasType.mono(8.5, weight: .semibold)).tracking(1).foregroundStyle(AtlasColor.smokeDark)
            TextField(label, text: value).font(AtlasType.ui(14.5, weight: .medium)).foregroundStyle(AtlasColor.porcelain)
        }
    }
}

struct SpatialMapScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Contexto espacial", title: "Mapa del activo", subtitle: "Explora espacios, hallazgos y elementos relacionados dentro del gemelo digital.", backAction: { dismiss() })
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous).fill(AtlasColor.graphite)
                        Canvas { context, size in
                            let grid: CGFloat = 28
                            var path = Path()
                            var x: CGFloat = 0
                            while x <= size.width { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)); x += grid }
                            var y: CGFloat = 0
                            while y <= size.height { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)); y += grid }
                            context.stroke(path, with: .color(AtlasColor.border), lineWidth: 0.7)
                        }
                        Image(systemName: "square.3.layers.3d.down.right")
                            .font(.system(size: 92, weight: .ultraLight))
                            .foregroundStyle(AtlasColor.electricBright.opacity(0.72))
                        VStack { HStack { AtlasTag(text: "7 espacios", tint: AtlasColor.electric); Spacer(); AtlasTag(text: "2 alertas", tint: AtlasColor.amber) }; Spacer() }.padding(16)
                    }
                    .frame(height: 360)
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
                    AtlasKicker(index: "01", title: "Capas")
                    HStack(spacing: 8) {
                        AtlasTag(text: "Geometría", tint: AtlasColor.electricBright)
                        AtlasTag(text: "Hallazgos", tint: AtlasColor.amber)
                        AtlasTag(text: "Activos", tint: AtlasColor.aqua)
                    }
                    AtlasKicker(index: "02", title: "Espacios")
                    ForEach(["Sala · 18,4 m²", "Cocina · 11,2 m²", "Habitación principal · 14,8 m²", "Baño · 5,6 m²"], id: \.self) { item in
                        HStack { Image(systemName: "square.dashed").foregroundStyle(AtlasColor.electricBright); Text(item).font(AtlasType.ui(14, weight: .medium)).foregroundStyle(AtlasColor.porcelain); Spacer(); Image(systemName: "chevron.right").foregroundStyle(AtlasColor.smokeDark) }
                        .padding(.vertical, 6)
                        AtlasHairline()
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}
