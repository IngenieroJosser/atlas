import SwiftUI

struct MaintenanceScreen: View {
    let open: (AtlasRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Operación", title: "Mantenimiento", subtitle: "Convierte hallazgos en trabajo trazable y verifica que el mundo vuelva a un estado saludable.", backAction: { dismiss() })
                    HStack { AtlasMetric(value: "04", label: "Abiertas"); Spacer(); AtlasMetric(value: "01", label: "Vencida", tint: AtlasColor.coral); Spacer(); AtlasMetric(value: "12", label: "Cerradas", tint: AtlasColor.aqua) }
                    AtlasKicker(index: "01", title: "Órdenes activas")
                    ForEach([("WO-0183", "Revisar filtración en cocina", "ALTA", AtlasColor.coral), ("WO-0182", "Inspección preventiva M-028", "MEDIA", AtlasColor.amber), ("WO-0179", "Verificar cambio visual del vehículo", "BAJA", AtlasColor.electricBright)], id: \.0) { item in
                        Button { open(.workOrderDetail) } label: {
                            HStack(spacing: 12) { Text(item.0).font(AtlasType.mono(8.5, weight: .bold)).foregroundStyle(item.3).frame(width: 58, alignment: .leading); VStack(alignment: .leading, spacing: 3) { Text(item.1).font(AtlasType.ui(14, weight: .semibold)).foregroundStyle(AtlasColor.porcelain); Text(item.2).font(AtlasType.mono(8, weight: .bold)).foregroundStyle(item.3) }; Spacer(); Image(systemName: "chevron.right").foregroundStyle(AtlasColor.smokeDark) }.padding(.vertical, 9)
                        }.buttonStyle(.plain); AtlasHairline()
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}

struct WorkOrderDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completed = false

    var body: some View {
        AtlasPage {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    AtlasScreenHeader(eyebrow: "Orden / WO-0183", title: "Revisar filtración en cocina", subtitle: "Originada desde el hallazgo F-028.", backAction: { dismiss() })
                    AtlasGlass { VStack(spacing: 15) { AtlasValueRow(label: "Prioridad", value: "Alta", tint: AtlasColor.coral); AtlasHairline(); AtlasValueRow(label: "Responsable", value: "Sin asignar"); AtlasHairline(); AtlasValueRow(label: "Vence", value: "22 SEP 2026", tint: AtlasColor.amber); AtlasHairline(); AtlasValueRow(label: "Activo", value: "Apartamento Norte") } }
                    AtlasKicker(index: "01", title: "Checklist")
                    ForEach(["Inspeccionar unión ventana-pared", "Medir humedad superficial", "Registrar evidencia posterior", "Confirmar causa probable"], id: \.self) { task in HStack(spacing: 12) { Image(systemName: completed ? "checkmark.circle.fill" : "circle").foregroundStyle(completed ? AtlasColor.aqua : AtlasColor.smoke); Text(task).font(AtlasType.ui(13.5)).foregroundStyle(AtlasColor.porcelainSoft); Spacer() }.padding(.vertical, 5) }
                    AtlasPrimaryButton(title: completed ? "Orden completada" : "Completar orden", symbol: "checkmark") { completed = true }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 40)
            }
        }
    }
}
