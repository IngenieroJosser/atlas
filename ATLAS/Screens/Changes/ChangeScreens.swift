import SwiftUI

struct ChangesScreen: View {
    let open: (AtlasRoute) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                AtlasScreenHeader(
                    eyebrow: "ATLAS / CHANGE ENGINE",
                    title: "Lo importante es saber qué cambió.",
                    subtitle: "Una línea de tiempo legible de cada modificación física, con evidencia y confianza asociadas.",
                    trailingSymbol: "square.split.2x1",
                    trailingAction: { open(.compare) }
                )

                HStack(spacing: 0) {
                    AtlasMetric(value: "41", label: "Cambios", tint: AtlasColor.violet).frame(maxWidth: .infinity, alignment: .leading)
                    AtlasMetric(value: "06", label: "Nuevos", tint: AtlasColor.electricBright).frame(maxWidth: .infinity, alignment: .leading)
                    AtlasMetric(value: "03", label: "Revisar", tint: AtlasColor.amber).frame(maxWidth: .infinity, alignment: .leading)
                }

                AtlasKicker(index: "01 / 02", title: "Línea de tiempo", trailing: "Últimos 30 días")

                AtlasEditorialHeading(
                    kicker: "Cambios recientes",
                    title: "Una historia física que sí puedes leer.",
                    detail: "ATLAS registra eventos relevantes sin esconderlos detrás de gráficas o paneles innecesarios."
                )

                VStack(spacing: 18) {
                    ForEach(AtlasSampleData.changes) { change in
                        AtlasChangeRow(change: change)
                        if change.id != AtlasSampleData.changes.last?.id { AtlasHairline() }
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AtlasColor.graphite))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))

                VStack(alignment: .leading, spacing: 12) {
                    AtlasKicker(index: "02 / 02", title: "Comparación", trailing: "Estado A → B")
                    AtlasSecondaryButton(title: "Comparar dos estados", symbol: "arrow.up.right") {
                        open(.compare)
                    }
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
        .background(RoundedRectangle(cornerRadius: 18).fill(AtlasColor.graphite))
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
