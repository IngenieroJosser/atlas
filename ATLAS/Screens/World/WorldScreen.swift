import SwiftUI

struct WorldScreen: View {
    let open: (AtlasRoute) -> Void
    let startScan: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 34) {
                header
                hero
                journeyStrip
                liveWorldSection
                assetsSection
                intelligenceSection
                howItWorksSection
                changesSection
                footer
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 36)
        }
    }

    private var header: some View {
        HStack(spacing: 11) {
            AtlasMark(size: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("ATLAS / PHYSICAL OS")
                    .font(AtlasType.mono(8.5, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.porcelain)
                Text("Colombia → mundo físico")
                    .font(AtlasType.ui(10.5, weight: .medium))
                    .foregroundStyle(AtlasColor.smoke)
            }

            Spacer()

            AtlasIconButton(symbol: "magnifyingglass") { open(.search) }
            AtlasIconButton(symbol: "bell") { open(.notifications) }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            AtlasTag(text: "Inteligencia física", tint: AtlasColor.electric, symbol: "sparkles")

            VStack(alignment: .leading, spacing: 10) {
                Text("Mira distinto.\nEntiende más.")
                    .font(AtlasType.display(46, weight: .bold))
                    .tracking(-1.9)
                    .foregroundStyle(AtlasColor.porcelain)
                    .fixedSize(horizontal: false, vertical: true)

                Text("ATLAS convierte espacios, objetos y vehículos en estados vivos que puedes inspeccionar, comparar y entender sin perder contexto.")
                    .font(AtlasType.ui(14.5))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(3)
            }

            HStack(spacing: 10) {
                Button(action: startScan) {
                    HStack(spacing: 9) {
                        Text("Escanear ahora")
                            .font(AtlasType.ui(14, weight: .semibold))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 17)
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AtlasColor.electric))
                }
                .buttonStyle(.plain)

                Button { open(.assetDetail) } label: {
                    Text("Explorar activos")
                        .font(AtlasType.ui(14, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                        .padding(.horizontal, 17)
                        .frame(height: 50)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AtlasColor.graphite))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AtlasColor.borderStrong, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var journeyStrip: some View {
        HStack(spacing: 0) {
            journeyItem("01", "Observa", "Captura")
            journeyDivider
            journeyItem("02", "Compara", "Entiende")
            journeyDivider
            journeyItem("03", "Actúa", "Resuelve")
        }
        .padding(.vertical, 14)
        .overlay(alignment: .top) { AtlasHairline() }
        .overlay(alignment: .bottom) { AtlasHairline() }
    }

    private func journeyItem(_ number: String, _ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(number)
                .font(AtlasType.mono(8, weight: .bold))
                .foregroundStyle(AtlasColor.electric)
            Text(title)
                .font(AtlasType.ui(12.5, weight: .semibold))
                .foregroundStyle(AtlasColor.porcelain)
            Text(detail)
                .font(AtlasType.ui(10.5))
                .foregroundStyle(AtlasColor.smoke)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var journeyDivider: some View {
        Rectangle()
            .fill(AtlasColor.border)
            .frame(width: 1, height: 40)
    }

    private var liveWorldSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "01 / 04", title: "Estado vivo", trailing: "Live preview")

            AtlasEditorialHeading(
                kicker: "Lectura del mundo",
                title: "Una lectura clara de lo que existe ahora.",
                detail: "Menos ruido visual. Más contexto sobre el activo, su estado y lo que merece atención."
            )

            AtlasWorldLens()
                .frame(height: 310)

            HStack(spacing: 0) {
                AtlasMetric(value: "12", label: "Activos", tint: AtlasColor.electric)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AtlasMetric(value: "03", label: "Atención", tint: AtlasColor.amber)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AtlasMetric(value: "41", label: "Cambios", tint: AtlasColor.violet)
                    .frame(maxWidth: .infinity, alignment: .leading)
                AtlasMetric(value: "98%", label: "Sync", tint: AtlasColor.aqua)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 4)
        }
    }

    private var assetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "02 / 04", title: "Selección", trailing: "3 activos")

            HStack(alignment: .bottom) {
                AtlasEditorialHeading(
                    kicker: "Tu índice físico",
                    title: "Activos que merecen tu atención.",
                    detail: "Cada elemento conserva estado, evidencia e historial en una sola lectura."
                )
                Spacer(minLength: 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(AtlasSampleData.assets.prefix(3).enumerated()), id: \.element.id) { index, asset in
                        Button { open(.assetDetail) } label: {
                            AtlasFeaturedAssetCard(asset: asset, index: String(format: "%02d", index + 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)

            Button { open(.assetDetail) } label: {
                HStack {
                    Text("Ver biblioteca completa")
                        .font(AtlasType.ui(13, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AtlasColor.porcelain)
                .padding(.vertical, 3)
            }
            .buttonStyle(.plain)
        }
    }

    private var intelligenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "03 / 04", title: "Inteligencia", trailing: "Contexto conectado")

            AtlasEditorialHeading(
                kicker: "Menos pantallas",
                title: "Más contexto. Menos interpretación manual.",
                detail: "ATLAS conecta evidencia, cambios y decisiones en herramientas simples que hacen avanzar el trabajo."
            )

            HStack(spacing: 10) {
                Button { open(.askAtlas) } label: {
                    AtlasEditorialActionCard(
                        index: "01",
                        symbol: "sparkles",
                        title: "Preguntar",
                        detail: "Consulta tus activos con historial y evidencia.",
                        tint: AtlasColor.electric
                    )
                }
                .buttonStyle(.plain)

                Button { open(.compare) } label: {
                    AtlasEditorialActionCard(
                        index: "02",
                        symbol: "square.split.2x1",
                        title: "Comparar",
                        detail: "Descubre exactamente qué cambió entre estados.",
                        tint: AtlasColor.violet
                    )
                }
                .buttonStyle(.plain)
            }

            Button { open(.reports) } label: {
                HStack(spacing: 13) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("03 / INFORMES")
                            .font(AtlasType.mono(8.2, weight: .bold))
                            .foregroundStyle(AtlasColor.aqua)
                        Text("Convierte evidencia en un documento claro y accionable.")
                            .font(AtlasType.ui(14.5, weight: .semibold))
                            .foregroundStyle(AtlasColor.porcelain)
                    }
                    Spacer()
                    Image(systemName: "doc.text")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AtlasColor.aqua)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AtlasColor.smokeDark)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AtlasColor.graphite))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AtlasKicker(index: "04 / 04", title: "Cómo funciona", trailing: "4 pasos")

            AtlasEditorialHeading(
                kicker: "Un recorrido sin ruido",
                title: "De observar a actuar, sin perderte.",
                detail: "Cada paso lleva naturalmente al siguiente, sin convertir la experiencia en un panel complejo."
            )

            VStack(spacing: 0) {
                AtlasFlowStep(index: "01", title: "Observa", detail: "Usa la cámara para capturar el estado real de un espacio, objeto o vehículo.", route: "Ruta / cámara · evidencia · geometría")
                AtlasHairline()
                AtlasFlowStep(index: "02", title: "Entiende", detail: "ATLAS organiza lo capturado y construye una lectura contextual del activo.", route: "Ruta / activo · estado · hallazgos")
                AtlasHairline()
                AtlasFlowStep(index: "03", title: "Compara", detail: "Revisa diferencias entre versiones y encuentra cambios relevantes.", route: "Ruta / versiones · delta · confianza")
                AtlasHairline()
                AtlasFlowStep(index: "04", title: "Actúa", detail: "Genera informes, crea seguimiento y convierte hallazgos en trabajo trazable.", route: "Ruta / informe · orden · cierre")
            }
        }
    }

    private var changesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cambios recientes")
                    .font(AtlasType.display(24, weight: .bold))
                    .tracking(-0.6)
                    .foregroundStyle(AtlasColor.porcelain)
                Spacer()
                Button("Ver todos") { open(.activityLog) }
                    .font(AtlasType.ui(12, weight: .semibold))
                    .foregroundStyle(AtlasColor.electric)
            }

            VStack(spacing: 16) {
                ForEach(AtlasSampleData.changes.prefix(3)) { change in
                    AtlasChangeRow(change: change)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AtlasColor.graphite))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
        }
    }

    private var footer: some View {
        HStack {
            Text("ATLAS / PHYSICAL INTELLIGENCE")
                .font(AtlasType.mono(7.8, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(AtlasColor.smokeDark)
            Spacer()
            Text("© 2026")
                .font(AtlasType.mono(7.8, weight: .medium))
                .foregroundStyle(AtlasColor.smokeDark)
        }
        .padding(.top, 6)
    }
}
