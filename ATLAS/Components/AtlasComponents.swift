import SwiftUI

struct AppHeader: View {
    let greeting: String
    let openSearch: () -> Void
    let openNotifications: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                AtlasMark(size: 30)

                VStack(alignment: .leading, spacing: 1) {
                    Text("ATLAS")
                        .font(AtlasType.heading(.headline, weight: .bold))
                        .tracking(2.4)
                        .foregroundStyle(AtlasColor.ink)
                    Text("PHYSICAL INTELLIGENCE")
                        .font(AtlasType.label(.caption2, weight: .semibold))
                        .tracking(1.0)
                        .foregroundStyle(AtlasColor.blue)
                }

                Spacer()
                HeaderIcon(symbol: "magnifyingglass", label: "Buscar", action: openSearch)
                HeaderIcon(symbol: "bell", label: "Notificaciones", action: openNotifications)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(greeting)
                    .font(AtlasType.body(.subheadline, weight: .medium))
                    .foregroundStyle(AtlasColor.inkSecondary)
                Spacer()
                Text("WORLD / 01")
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
        .atlasStagger(0, distance: 6)
    }
}

struct HeaderIcon: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
                .frame(width: 40, height: 40)
                .background(AtlasColor.surface)
                .clipShape(Circle())
                .overlay { Circle().stroke(AtlasColor.line, lineWidth: 1) }
        }
        .buttonStyle(AtlasCompactPressButtonStyle())
        .accessibilityLabel(label)
    }
}

struct MetadataLabel: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.inkMuted)
            Text(value)
                .font(AtlasType.heading(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
        }
    }
}

struct StatusBadge: View {
    let health: AtlasHealth

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(health.color).frame(width: 6, height: 6)
            Text(health.rawValue.uppercased())
                .font(AtlasType.mono(.caption2, weight: .semibold))
                .tracking(0.5)
        }
        .foregroundStyle(health.color)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(health.color.opacity(0.08))
        .clipShape(Capsule())
        .accessibilityLabel("Estado: \(health.rawValue)")
        .animation(AtlasMotion.fastAnimation, value: health.rawValue)
    }
}

struct SyncBadge: View {
    let state: AtlasSyncState

    var body: some View {
        Text(state.rawValue)
            .font(AtlasType.mono(.caption2, weight: .semibold))
            .foregroundStyle(state.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(state.color.opacity(0.08))
            .clipShape(Capsule())
        .animation(AtlasMotion.fastAnimation, value: state.rawValue)
    }
}

struct Metric: View {
    let value: String
    let label: String
    var footnote: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(AtlasType.display(.title, weight: .semibold))
                .tracking(-0.8)
                .foregroundStyle(AtlasColor.ink)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.9)
                .foregroundStyle(AtlasColor.inkSecondary)
            if let footnote {
                Text(footnote)
                    .font(AtlasType.body(.caption2, weight: .medium))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasScaleReveal()
    }
}

struct AssetRow: View {
    let asset: AtlasAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(AtlasColor.blueSoft)
                    Image(systemName: asset.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Text(asset.kind)
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.75)
                            .foregroundStyle(AtlasColor.inkMuted)
                        if asset.changes > 0 {
                            Text("· \(String(format: "%02d", asset.changes)) CAMBIOS")
                                .font(AtlasType.mono(.caption2, weight: .semibold))
                                .foregroundStyle(AtlasColor.blue)
                        }
                    }
                    Text(asset.name)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                        .multilineTextAlignment(.leading)
                    Text("\(asset.subtitle) · \(asset.updated)")
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 9) {
                    StatusBadge(health: asset.health)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
            }
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(AtlasPressButtonStyle())
        .overlay(alignment: .bottom) { AtlasDivider() }
        .atlasScreenEntrance(distance: 7)
    }
}

struct WorldStateRow: View {
    let index: String
    let asset: AtlasAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                Text(index)
                    .font(AtlasType.display(.title3, weight: .medium))
                    .tracking(-0.6)
                    .foregroundStyle(AtlasColor.blue)
                    .frame(width: 38, alignment: .leading)

                VStack(alignment: .leading, spacing: 5) {
                    Text(asset.name)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text("\(asset.kind) / \(asset.updated)")
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)
                }

                Spacer()
                SyncBadge(state: asset.syncState)
            }
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(AtlasPressButtonStyle())
        .atlasScreenEntrance(distance: 7)
    }
}

struct ChangeRow: View {
    let change: AtlasChange
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(change.time)
                        .font(AtlasType.mono(.caption2, weight: .semibold))
                        .foregroundStyle(AtlasColor.inkMuted)
                    Rectangle()
                        .fill(change.health.color)
                        .frame(width: 22, height: 2)
                }
                .frame(width: 48, alignment: .leading)
                .padding(.top, 2)

                VStack(alignment: .leading, spacing: 6) {
                    Text(change.type)
                        .font(AtlasType.label(.caption2, weight: .semibold))
                        .tracking(0.75)
                        .foregroundStyle(change.health.color)
                    Text(change.title)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text("\(change.asset) · \(change.detail)")
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
                    .padding(.top, 2)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(AtlasPressButtonStyle())
        .overlay(alignment: .bottom) { AtlasDivider() }
        .atlasScreenEntrance(distance: 7)
    }
}

struct InspectionRow: View {
    let inspection: AtlasInspection
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Text(inspection.progress == 1 ? "✓" : inspection.progress > 0 ? "↗" : "○")
                    .font(AtlasType.display(.title3, weight: .medium))
                    .foregroundStyle(inspection.progress == 1 ? AtlasColor.healthy : AtlasColor.blue)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(inspection.status.uppercased())
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.75)
                            .foregroundStyle(inspection.progress == 1 ? AtlasColor.healthy : AtlasColor.blue)
                        Spacer()
                        Text(inspection.date)
                            .font(AtlasType.mono(.caption2))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }
                    Text(inspection.title)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text(inspection.asset)
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)

                    if inspection.progress > 0 && inspection.progress < 1 {
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Rectangle().fill(AtlasColor.line)
                                Rectangle().fill(AtlasColor.blue).frame(width: proxy.size.width * inspection.progress)
                            }
                        }
                        .frame(height: 2)
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(AtlasPressButtonStyle())
    }
}

struct EvidenceCard: View {
    let evidence: AtlasEvidence

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("EVIDENCIA")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.inkMuted)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }

            Image(systemName: evidence.symbol)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(AtlasColor.blue)
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)

            Spacer(minLength: 0)

            Text(evidence.title)
                .font(AtlasType.heading(.headline, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
            Text(evidence.detail)
                .font(AtlasType.body(.caption, weight: .medium))
                .foregroundStyle(AtlasColor.inkMuted)
        }
        .padding(16)
        .frame(width: 202, height: 164, alignment: .leading)
        .background(AtlasColor.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(AtlasColor.blue).frame(height: 2)
        }
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(AtlasColor.line) }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .atlasScaleReveal()
    }
}

struct AlertRow: View {
    let level: String
    let title: String
    let detail: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 13) {
                Divider()
                    .frame(width: 3)
                    .overlay(color)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(level.uppercased())
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(color)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }
                    Text(title)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text(detail)
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .padding(.vertical, 5)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(AtlasPressButtonStyle())
        .atlasScreenEntrance(distance: 7)
    }
}

struct AtlasSearchField: View {
    @Binding var text: String
    var placeholder: String = "Buscar en ATLAS"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AtlasColor.inkMuted)
            TextField(placeholder, text: $text)
                .font(AtlasType.body(.body, weight: .medium))
                .foregroundStyle(AtlasColor.ink)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .buttonStyle(AtlasPressButtonStyle())
                .accessibilityLabel("Limpiar búsqueda")
            }
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 50)
        .background(AtlasColor.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(AtlasColor.lineStrong).frame(height: 1) }
    }
}

struct PrimaryActionRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasColor.blue)
                    .frame(width: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AtlasType.heading(.subheadline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text(subtitle)
                        .font(AtlasType.body(.caption, weight: .medium))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(AtlasPressButtonStyle())
    }
}

struct AIInsight: View {
    let title: String
    let text: String
    let confidence: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                Text("ATLAS / INSIGHT")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Color.white.opacity(0.68))
                Spacer()
                Text(confidence)
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(Color.white)
            }

            Rectangle()
                .fill(AtlasColor.blue)
                .frame(width: 44, height: 3)

            Text(title)
                .font(AtlasType.heading(.title2, weight: .semibold))
                .tracking(-0.5)
                .foregroundStyle(.white)

            Text(text)
                .font(AtlasType.body(.body, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.78))
                .lineSpacing(4)

            HStack(spacing: 8) {
                Image(systemName: "link")
                Text("EVIDENCIA TRAZABLE")
            }
            .font(AtlasType.label(.caption2, weight: .semibold))
            .tracking(0.75)
            .foregroundStyle(Color.white.opacity(0.72))
        }
        .padding(20)
        .background(AtlasColor.navy)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .atlasScaleReveal()
    }
}

struct ComparisonView: View {
    var body: some View {
        HStack(spacing: 0) {
            comparisonState(label: "ANTES", date: "12 SEP", symbol: "square.dashed")
            Rectangle().fill(AtlasColor.line).frame(width: 1)
            comparisonState(label: "DESPUÉS", date: "20 SEP", symbol: "square.dashed.inset.filled")
        }
        .background(AtlasColor.surface)
        .overlay(alignment: .top) { Rectangle().fill(AtlasColor.blue).frame(height: 2) }
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(AtlasColor.line) }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .atlasScaleReveal()
    }

    private func comparisonState(label: String, date: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(label)
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.inkMuted)
                Spacer()
                Text(date)
                    .font(AtlasType.mono(.caption2))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            Image(systemName: symbol)
                .font(.system(size: 42, weight: .ultraLight))
                .foregroundStyle(AtlasColor.blue)
                .frame(maxWidth: .infinity, minHeight: 82)
            Text(label == "ANTES" ? "Estado 017" : "Estado 018")
                .font(AtlasType.heading(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
}

struct AtlasLoadingState: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 14) {
            AtlasProcessingIndicator(color: AtlasColor.blue, size: 24)
            Text(title).font(AtlasType.heading(.headline)).foregroundStyle(AtlasColor.ink)
            Text(detail).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted).multilineTextAlignment(.center)
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
        .atlasScaleReveal()
    }
}

struct AtlasEmptyState: View {
    let eyebrow: String
    let title: String
    let detail: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(eyebrow.uppercased())
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.blue)
            Text(title)
                .font(AtlasType.heading(.title2, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
            Text(detail)
                .font(AtlasType.body(.body))
                .foregroundStyle(AtlasColor.inkSecondary)
                .lineSpacing(4)
            if let actionTitle, let action {
                AtlasPrimaryButton(title: actionTitle, symbol: "viewfinder", action: action)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 28)
        .atlasScreenEntrance(distance: 10)
    }
}

struct AtlasErrorState: View {
    let title: String
    let detail: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(AtlasColor.critical)
            Text(title).font(AtlasType.heading(.title3)).foregroundStyle(AtlasColor.ink)
            Text(detail).font(AtlasType.body(.body)).foregroundStyle(AtlasColor.inkSecondary)
            Button("Intentar de nuevo", action: retry)
                .font(AtlasType.body(.body, weight: .semibold))
                .foregroundStyle(AtlasColor.blue)
        }
        .padding(.vertical, 24)
        .atlasScaleReveal()
    }
}

struct PermissionState: View {
    let symbol: String
    let title: String
    let detail: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(AtlasColor.blue)
                .frame(width: 72, height: 72)
                .background(AtlasColor.blueSoft)
                .clipShape(Circle())
            Text(title)
                .font(AtlasType.heading(.title2))
                .foregroundStyle(AtlasColor.ink)
                .multilineTextAlignment(.center)
            Text(detail)
                .font(AtlasType.body(.body))
                .foregroundStyle(AtlasColor.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            AtlasPrimaryButton(title: buttonTitle, symbol: "arrow.right", action: action)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 520)
        .atlasScaleReveal()
    }
}

struct AssetCard: View {
    let asset: AtlasAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text(asset.kind)
                        .font(AtlasType.label(.caption2, weight: .semibold))
                        .tracking(0.75)
                        .foregroundStyle(AtlasColor.inkMuted)
                    Spacer()
                    Image(systemName: asset.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                }
                Text(asset.name)
                    .font(AtlasType.heading(.title3, weight: .semibold))
                    .tracking(-0.4)
                    .foregroundStyle(AtlasColor.ink)
                    .multilineTextAlignment(.leading)
                Text(asset.subtitle)
                    .font(AtlasType.body(.caption, weight: .medium))
                    .foregroundStyle(AtlasColor.inkMuted)
                Spacer(minLength: 4)
                HStack {
                    StatusBadge(health: asset.health)
                    Spacer()
                    Text(asset.updated)
                        .font(AtlasType.mono(.caption2))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
            }
            .padding(16)
            .frame(width: 224, height: 172, alignment: .leading)
            .background(AtlasColor.surface)
            .overlay(alignment: .bottom) { Rectangle().fill(AtlasColor.blue).frame(height: 2) }
            .overlay { RoundedRectangle(cornerRadius: 14).stroke(AtlasColor.line) }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(AtlasPressButtonStyle())
        .atlasScaleReveal()
    }
}

struct Timeline: View {
    let items: [(String, String, String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 6) {
                        Circle().fill(AtlasColor.blue).frame(width: 7, height: 7)
                        if index < items.count - 1 {
                            Rectangle().fill(AtlasColor.line).frame(width: 1, height: 42)
                        }
                    }
                    .padding(.top, 6)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.0)
                            .font(AtlasType.mono(.caption2))
                            .foregroundStyle(AtlasColor.inkMuted)
                        Text(item.1)
                            .font(AtlasType.body(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                        Text(item.2)
                            .font(AtlasType.body(.caption))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }
                    Spacer()
                }
                .padding(.vertical, 7)
                .atlasStagger(index, distance: 7, baseDelay: 0.035)
            }
        }
    }
}

struct FilterSheet<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(AtlasColor.lineStrong)
                .frame(width: 34, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 18)
            content
        }
        .padding(.horizontal, 20)
        .background(AtlasColor.background)
        .atlasScreenEntrance(distance: 14)
    }
}

extension AtlasEmptyState {
    init(title: String, detail: String, symbol: String) {
        self.init(
            eyebrow: "ATLAS / EMPTY",
            title: title,
            detail: detail,
            actionTitle: nil,
            action: nil
        )
    }
}
