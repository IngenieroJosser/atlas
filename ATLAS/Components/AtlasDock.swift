import SwiftUI

struct AtlasDock: View {
    @Binding var selectedTab: AtlasTab
    let startScan: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            dockButton(.world)
            dockButton(.assets)

            Button(action: startScan) {
                HStack(spacing: 7) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 14, weight: .bold))
                    Text("Escanear")
                        .font(AtlasType.ui(11.5, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AtlasColor.electric))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Escanear")

            dockButton(.changes)
            dockButton(.profile)
        }
        .padding(7)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.98))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AtlasColor.border, lineWidth: 1))
                .shadow(color: AtlasColor.shadow, radius: 18, y: 8)
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func dockButton(_ tab: AtlasTab) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.18)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .regular))
                Text(tab.title)
                    .font(AtlasType.ui(8.5, weight: selectedTab == tab ? .semibold : .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(selectedTab == tab ? AtlasColor.porcelain : AtlasColor.smoke)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(selectedTab == tab ? AtlasColor.voidSoft : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
