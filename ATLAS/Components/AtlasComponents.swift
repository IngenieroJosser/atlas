import SwiftUI

struct AppHeader: View {
    let greeting: String
    let openSearch: () -> Void
    let openNotifications: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AtlasMark(size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text("ATLAS")
                    .font(AtlasType.heading(.headline, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(AtlasColor.ink)
                Text(greeting)
                    .font(AtlasType.body(.caption))
                    .foregroundStyle(AtlasColor.inkMuted)
            }

            Spacer()

            HeaderIcon(symbol: "magnifyingglass", label: "Buscar", action: openSearch)
            HeaderIcon(symbol: "bell", label: "Notificaciones", action: openNotifications)
        }
    }
}

struct HeaderIcon: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct MetadataLabel: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(AtlasType.label(.caption2))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.inkMuted)
            Text(value)
                .font(AtlasType.body(.subheadline, weight: .medium))
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
                .foregroundStyle(AtlasColor.ink)
            Text(label.uppercased())
                .font(AtlasType.label(.caption2, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(AtlasColor.inkMuted)
            if let footnote {
                Text(footnote)
                    .font(AtlasType.body(.caption2))
                    .foregroundStyle(AtlasColor.inkSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AssetRow: View {
    let asset: AtlasAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: asset.symbol)
                        .font(.system(size: 19, weight: .medium))
                        .foregroundStyle(AtlasColor.blue)
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(asset.kind)
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(AtlasColor.inkMuted)
                        Text(asset.name)
                            .font(AtlasType.heading(.headline, weight: .semibold))
                            .foregroundStyle(AtlasColor.ink)
                            .multilineTextAlignment(.leading)
                        Text(asset.subtitle)
                            .font(AtlasType.body(.caption))
                            .foregroundStyle(AtlasColor.inkSecondary)
                    }

                    Spacer(minLength: 12)

                    VStack(alignment: .trailing, spacing: 8) {
                        StatusBadge(health: asset.health)
                        Text(asset.updated)
                            .font(AtlasType.body(.caption2))
                            .foregroundStyle(AtlasColor.inkMuted)
                        if asset.changes > 0 {
                            Text(String(format: "%02d CAMBIOS", asset.changes))
                                .font(AtlasType.mono(.caption2, weight: .semibold))
                                .foregroundStyle(AtlasColor.blue)
                        }
                    }
                }
                .padding(.vertical, 16)

                AtlasDivider()
            }
        }
        .buttonStyle(.plain)
    }
}

struct WorldStateRow: View {
    let index: String
    let asset: AtlasAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 14) {
                Text(index)
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.blue)
                    .frame(width: 28, alignment: .leading)

                VStack(alignment: .leading, spacing: 5) {
                    Text(asset.name)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text("\(asset.kind) · \(asset.updated)")
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }

                Spacer()
                SyncBadge(state: asset.syncState)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

struct ChangeRow: View {
    let change: AtlasChange
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 6) {
                    Circle()
                        .fill(change.health.color)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(AtlasColor.line)
                        .frame(width: 1, height: 56)
                }
                .padding(.top, 6)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(change.type)
                            .font(AtlasType.label(.caption2, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(change.health.color)
                        Spacer()
                        Text(change.time)
                            .font(AtlasType.mono(.caption2))
                            .foregroundStyle(AtlasColor.inkMuted)
                    }
                    Text(change.title)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text(change.asset)
                        .font(AtlasType.body(.subheadline, weight: .medium))
                        .foregroundStyle(AtlasColor.inkSecondary)
                    Text(change.detail)
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .padding(.bottom, 16)
            }
        }
        .buttonStyle(.plain)
    }
}

struct InspectionRow: View {
    let inspection: AtlasInspection
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(inspection.status.uppercased())
                        .font(AtlasType.label(.caption2, weight: .semibold))
                        .tracking(0.8)
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
                    .font(AtlasType.body(.caption))
                    .foregroundStyle(AtlasColor.inkSecondary)

                if inspection.progress > 0 && inspection.progress < 1 {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AtlasColor.line)
                            Capsule().fill(AtlasColor.blue).frame(width: proxy.size.width * inspection.progress)
                        }
                    }
                    .frame(height: 3)
                }
            }
            .padding(.vertical, 15)
        }
        .buttonStyle(.plain)
    }
}

struct EvidenceCard: View {
    let evidence: AtlasEvidence

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: evidence.symbol)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AtlasColor.blue)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            Spacer(minLength: 10)
            Text(evidence.title)
                .font(AtlasType.heading(.headline, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
            Text(evidence.detail)
                .font(AtlasType.body(.caption))
                .foregroundStyle(AtlasColor.inkMuted)
        }
        .padding(16)
        .frame(width: 190, height: 150, alignment: .leading)
        .background(AtlasColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AtlasColor.line) }
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
            HStack(alignment: .top, spacing: 14) {
                Rectangle()
                    .fill(color)
                    .frame(width: 3, height: 62)
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 5) {
                    Text(level.uppercased())
                        .font(AtlasType.label(.caption2, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(color)
                    Text(title)
                        .font(AtlasType.heading(.headline, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text(detail)
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
                    .padding(.top, 20)
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
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
                .font(AtlasType.body(.body))
                .foregroundStyle(AtlasColor.ink)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Limpiar búsqueda")
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 48)
        .background(AtlasColor.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct PrimaryActionRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AtlasColor.blue)
                    .frame(width: 34)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AtlasType.body(.body, weight: .semibold))
                        .foregroundStyle(AtlasColor.ink)
                    Text(subtitle)
                        .font(AtlasType.body(.caption))
                        .foregroundStyle(AtlasColor.inkMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}

struct AIInsight: View {
    let title: String
    let text: String
    let confidence: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                AtlasSectionLabel(index: "AI", title: "ATLAS / INSIGHT")
                Spacer()
            }
            Text(title)
                .font(AtlasType.heading(.title3, weight: .semibold))
                .foregroundStyle(AtlasColor.ink)
            Text(text)
                .font(AtlasType.body(.body))
                .foregroundStyle(AtlasColor.inkSecondary)
                .lineSpacing(4)
            HStack {
                Text("EVIDENCIA TRAZABLE")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.blue)
                Spacer()
                Text("CONFIANZA \(confidence)")
                    .font(AtlasType.mono(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
        }
        .padding(.vertical, 18)
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
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AtlasColor.line) }
    }

    private func comparisonState(label: String, date: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(label)
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.inkMuted)
                Spacer()
                Text(date)
                    .font(AtlasType.mono(.caption2))
                    .foregroundStyle(AtlasColor.inkMuted)
            }
            Image(systemName: symbol)
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(AtlasColor.blue)
                .frame(maxWidth: .infinity, minHeight: 90)
            Text(label == "ANTES" ? "Estado 017" : "Estado 018")
                .font(AtlasType.body(.subheadline, weight: .semibold))
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
            ProgressView().tint(AtlasColor.blue)
            Text(title).font(AtlasType.heading(.headline)).foregroundStyle(AtlasColor.ink)
            Text(detail).font(AtlasType.body(.caption)).foregroundStyle(AtlasColor.inkMuted).multilineTextAlignment(.center)
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
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
    }
}

struct AssetCard: View {
    let asset: AtlasAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: asset.symbol)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(AtlasColor.blue)
                    Spacer()
                    StatusBadge(health: asset.health)
                }
                Text(asset.name)
                    .font(AtlasType.heading(.headline, weight: .semibold))
                    .foregroundStyle(AtlasColor.ink)
                    .multilineTextAlignment(.leading)
                Text(asset.subtitle)
                    .font(AtlasType.body(.caption))
                    .foregroundStyle(AtlasColor.inkMuted)
                HStack {
                    Text(asset.updated)
                        .font(AtlasType.mono(.caption2))
                        .foregroundStyle(AtlasColor.inkMuted)
                    Spacer()
                    if asset.changes > 0 {
                        Text("\(asset.changes) cambios")
                            .font(AtlasType.mono(.caption2, weight: .semibold))
                            .foregroundStyle(AtlasColor.blue)
                    }
                }
            }
            .padding(16)
            .frame(width: 220, alignment: .leading)
            .background(AtlasColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AtlasColor.line) }
        }
        .buttonStyle(.plain)
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
    }
}
