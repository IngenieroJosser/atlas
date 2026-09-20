import SwiftUI

struct BottomNavigation: View {
    @Binding var selectedTab: AtlasTab
    let startScan: () -> Void

    @Namespace private var selectionNamespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            tab(.world)
            tab(.assets)
            scanAction
            tab(.changes)
            tab(.profile)
        }
        .padding(.horizontal, 8)
        .padding(.top, 7)
        .padding(.bottom, 4)
        .background(AtlasColor.surface.opacity(0.97))
        .overlay(alignment: .top) {
            Rectangle().fill(AtlasColor.line).frame(height: 1)
        }
    }

    private var scanAction: some View {
        Button {
            AtlasHaptics.impact(.medium)
            startScan()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AtlasColor.navy)
                        .frame(width: 48, height: 38)
                    Image(systemName: "viewfinder")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text("Escanear")
                    .font(AtlasType.label(.caption2, weight: .semibold))
                    .foregroundStyle(AtlasColor.ink)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(AtlasCompactPressButtonStyle())
        .accessibilityLabel("Escanear")
    }

    private func tab(_ tab: AtlasTab) -> some View {
        Button {
            guard selectedTab != tab else { return }
            AtlasHaptics.selection()
            if reduceMotion {
                selectedTab = tab
            } else {
                withAnimation(AtlasMotion.softSpring) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 5) {
                ZStack(alignment: .bottom) {
                    Image(systemName: tab.symbol)
                        .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                        .frame(height: 23)

                    if selectedTab == tab {
                        Rectangle()
                            .fill(AtlasColor.blue)
                            .frame(width: 16, height: 2)
                            .offset(y: 4)
                            .matchedGeometryEffect(id: "atlas-tab-indicator", in: selectionNamespace)
                    }
                }

                Text(tab.title)
                    .font(AtlasType.label(.caption2, weight: selectedTab == tab ? .semibold : .medium))
            }
            .foregroundStyle(selectedTab == tab ? AtlasColor.ink : AtlasColor.inkMuted)
            .frame(maxWidth: .infinity, minHeight: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(AtlasCompactPressButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}
