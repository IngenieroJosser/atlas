import SwiftUI

struct BottomNavigation: View {
    @Binding var selectedTab: AtlasTab
    let startScan: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tab(.world)
            tab(.assets)

            Button(action: startScan) {
                VStack(spacing: 5) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 38)
                        .background(AtlasColor.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Text("Escanear")
                        .font(AtlasType.label(.caption2, weight: .semibold))
                        .foregroundStyle(AtlasColor.blue)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Escanear")

            tab(.changes)
            tab(.profile)
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { AtlasDivider() }
    }

    private func tab(_ tab: AtlasTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                Text(tab.title)
                    .font(AtlasType.label(.caption2, weight: selectedTab == tab ? .semibold : .medium))
            }
            .foregroundStyle(selectedTab == tab ? AtlasColor.blue : AtlasColor.inkMuted)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.plain)
    }
}
