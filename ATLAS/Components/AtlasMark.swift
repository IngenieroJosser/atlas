import SwiftUI

struct AtlasMark: View {
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18, style: .continuous)
                .stroke(AtlasColor.blue, lineWidth: max(1.5, size * 0.045))
                .frame(width: size * 0.68, height: size * 0.68)
                .rotationEffect(.degrees(45))

            Circle()
                .stroke(AtlasColor.blue.opacity(0.35), lineWidth: max(1, size * 0.025))
                .frame(width: size * 0.92, height: size * 0.46)
                .rotationEffect(.degrees(-18))

            Circle()
                .fill(AtlasColor.blue)
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: size * 0.39, y: -size * 0.08)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Atlas")
    }
}
