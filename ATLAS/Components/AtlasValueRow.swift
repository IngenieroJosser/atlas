import SwiftUI

struct AtlasValueRow: View {
    let label: String
    let value: String
    var tint: Color = AtlasColor.porcelain

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(AtlasType.ui(12.5, weight: .medium))
                .foregroundStyle(AtlasColor.smoke)
            Spacer()
            Text(value)
                .font(AtlasType.ui(13.5, weight: .semibold))
                .foregroundStyle(tint)
                .multilineTextAlignment(.trailing)
        }
    }
}
