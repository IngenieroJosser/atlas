import SwiftUI

struct AtlasAssetRow: View {
    let asset: AtlasAsset
    var compact = false

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(asset.tint.opacity(0.09))
                Image(systemName: asset.symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(asset.tint)
            }
            .frame(width: compact ? 42 : 46, height: compact ? 42 : 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.type)
                    .font(AtlasType.mono(8, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(AtlasColor.smoke)
                Text(asset.name)
                    .font(AtlasType.ui(compact ? 14.5 : 15.5, weight: .semibold))
                    .foregroundStyle(AtlasColor.porcelain)
                    .lineLimit(1)
                Text(asset.detail)
                    .font(AtlasType.ui(12))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 7) {
                Text(asset.state)
                    .font(AtlasType.ui(11, weight: .semibold))
                    .foregroundStyle(asset.tint)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(AtlasColor.smokeDark)
            }
        }
        .padding(.vertical, 5)
    }
}

struct AtlasChangeRow: View {
    let change: AtlasChange

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Text(change.time)
                .font(AtlasType.mono(8, weight: .bold))
                .foregroundStyle(AtlasColor.smokeDark)
                .frame(width: 42, alignment: .leading)
                .padding(.top, 2)

            Rectangle()
                .fill(change.tint)
                .frame(width: 2, height: 45)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                Text(change.title)
                    .font(AtlasType.ui(14, weight: .semibold))
                    .foregroundStyle(AtlasColor.porcelain)
                Text(change.detail)
                    .font(AtlasType.ui(12))
                    .foregroundStyle(AtlasColor.smoke)
            }

            Spacer(minLength: 4)
        }
    }
}

struct AtlasMetric: View {
    let value: String
    let label: String
    var tint: Color = AtlasColor.electricBright

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(AtlasType.display(26, weight: .bold))
                .tracking(-0.7)
                .foregroundStyle(AtlasColor.porcelain)
            HStack(spacing: 5) {
                Rectangle()
                    .fill(tint)
                    .frame(width: 10, height: 2)
                Text(label.uppercased())
                    .font(AtlasType.mono(7.8, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(AtlasColor.smoke)
            }
        }
    }
}

struct AtlasActionRow: View {
    let index: String
    let symbol: String
    let title: String
    let detail: String
    var tint: Color = AtlasColor.electricBright

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Text(index)
                .font(AtlasType.mono(8.5, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 22, alignment: .leading)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Image(systemName: symbol)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(tint)
                    Text(title)
                        .font(AtlasType.ui(14.5, weight: .semibold))
                        .foregroundStyle(AtlasColor.porcelain)
                }
                Text(detail)
                    .font(AtlasType.ui(12))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(AtlasColor.smokeDark)
                .padding(.top, 3)
        }
        .padding(.vertical, 9)
    }
}

struct AtlasSettingRow: View {
    let symbol: String
    let title: String
    var detail: String? = nil
    var tint: Color = AtlasColor.electricBright

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AtlasType.ui(14.5, weight: .medium))
                    .foregroundStyle(AtlasColor.porcelain)
                if let detail {
                    Text(detail)
                        .font(AtlasType.ui(11.5))
                        .foregroundStyle(AtlasColor.smoke)
                }
            }

            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(AtlasColor.smokeDark)
        }
        .padding(.vertical, 7)
    }
}

struct AtlasEmptyState: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(AtlasColor.electricBright)
            Text(title)
                .font(AtlasType.display(28, weight: .bold))
                .tracking(-0.7)
                .foregroundStyle(AtlasColor.porcelain)
            Text(detail)
                .font(AtlasType.ui(13.5))
                .foregroundStyle(AtlasColor.smoke)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 30)
    }
}

struct AtlasSearchField: View {
    @Binding var text: String
    var placeholder: String = "Buscar"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AtlasColor.smoke)
            TextField(placeholder, text: $text)
                .font(AtlasType.ui(14))
                .foregroundStyle(AtlasColor.porcelain)
                .tint(AtlasColor.electricBright)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AtlasColor.smoke)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AtlasColor.graphite))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
    }
}

struct AtlasFeaturedAssetCard: View {
    let asset: AtlasAsset
    let index: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(index)
                    .font(AtlasType.mono(8.5, weight: .bold))
                    .foregroundStyle(AtlasColor.smokeDark)
                Spacer()
                AtlasTag(text: asset.state, tint: asset.tint)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(asset.tint.opacity(0.08))
                Image(systemName: asset.symbol)
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(asset.tint.opacity(0.72))
            }
            .frame(height: 118)

            VStack(alignment: .leading, spacing: 5) {
                Text(asset.type)
                    .font(AtlasType.mono(8, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(AtlasColor.smoke)
                Text(asset.name)
                    .font(AtlasType.display(20, weight: .bold))
                    .tracking(-0.4)
                    .foregroundStyle(AtlasColor.porcelain)
                Text(asset.detail)
                    .font(AtlasType.ui(11.5))
                    .foregroundStyle(AtlasColor.smoke)
            }
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AtlasColor.graphite))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
    }
}

struct AtlasEditorialActionCard: View {
    let index: String
    let symbol: String
    let title: String
    let detail: String
    var tint: Color = AtlasColor.electric

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(index)
                    .font(AtlasType.mono(8.5, weight: .bold))
                    .foregroundStyle(tint)
                Spacer()
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }

            Text(title)
                .font(AtlasType.display(19, weight: .bold))
                .tracking(-0.35)
                .foregroundStyle(AtlasColor.porcelain)

            Text(detail)
                .font(AtlasType.ui(12))
                .foregroundStyle(AtlasColor.smoke)
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(AtlasColor.graphite))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
    }
}

struct AtlasFlowStep: View {
    let index: String
    let title: String
    let detail: String
    let route: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(index)
                .font(AtlasType.display(22, weight: .bold))
                .foregroundStyle(AtlasColor.electric)
                .frame(width: 34, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AtlasType.ui(14.5, weight: .semibold))
                    .foregroundStyle(AtlasColor.porcelain)
                Text(detail)
                    .font(AtlasType.ui(12.3))
                    .foregroundStyle(AtlasColor.smoke)
                    .lineSpacing(2)
                Text(route)
                    .font(AtlasType.mono(7.8, weight: .medium))
                    .foregroundStyle(AtlasColor.smokeDark)
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }
}
