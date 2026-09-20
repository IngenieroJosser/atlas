import SwiftUI

struct ActivityLogScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Auditoría", title: "Registro de actividad", subtitle: "Quién hizo qué, cuándo y sobre qué activo.", backAction: { dismiss() })
                    ForEach(Array((AtlasSampleData.changes + AtlasSampleData.changes).enumerated()), id: \.offset) { _, change in
                        AtlasChangeRow(change: change).padding(.vertical, 4)
                        AtlasHairline()
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}
