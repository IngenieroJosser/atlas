import Foundation

extension APIAssetSummary {
    var presentation: AtlasAsset {
        AtlasAsset(
            kind: category.uppercased(),
            name: name,
            subtitle: [location, identifier].filter { !$0.isEmpty }.joined(separator: " · ").ifEmpty("Activo ATLAS"),
            symbol: category.atlasSymbol,
            health: status.atlasHealth,
            updated: (latestStateAt ?? updatedAt).atlasRelative,
            changes: changesCount,
            syncState: lastSyncedAt == nil ? .local : .synced
        )
    }
}

extension APIAsset {
    var presentation: AtlasAsset {
        AtlasAsset(kind: category.uppercased(), name: name, subtitle: [location, identifier].filter { !$0.isEmpty }.joined(separator: " · ").ifEmpty("Activo ATLAS"), symbol: category.atlasSymbol, health: status.atlasHealth, updated: updatedAt.atlasRelative, changes: 0, syncState: lastSyncedAt == nil ? .local : .synced)
    }
}

extension APIChange {
    func presentation(assetName: String? = nil) -> AtlasChange {
        AtlasChange(type: changeType.replacingOccurrences(of: "_", with: " ").uppercased(), title: title, asset: assetName ?? "Activo", detail: description, time: createdAt.atlasCompact, symbol: changeType.atlasChangeSymbol, health: severity.atlasHealth)
    }
}

extension APIInspection {
    func presentation(assetName: String? = nil) -> AtlasInspection {
        AtlasInspection(title: title, asset: assetName ?? "Activo", date: (scheduledFor ?? updatedAt).atlasRelative, status: status.atlasDisplay, progress: status.lowercased() == "completed" ? 1 : (status.lowercased().contains("progress") ? 0.66 : 0))
    }
}

extension APIWorkOrder {
    func presentation(assetName: String? = nil) -> AtlasWorkOrder {
        AtlasWorkOrder(code: code, asset: assetName ?? "Activo", title: title, priority: priority.uppercased(), status: status.atlasDisplay, assignee: assigneeUserId == nil ? "Sin asignar" : "Asignada")
    }
}

extension APIEvidence {
    var presentation: AtlasEvidence {
        AtlasEvidence(title: originalName.ifEmpty(evidenceType.capitalized), detail: "\(evidenceType.capitalized) · \(ByteCountFormatter.string(fromByteCount: Int64(sizeBytes), countStyle: .file))", symbol: mimeType.hasPrefix("image/") ? "photo" : "doc")
    }
}

extension Date {
    var atlasRelative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_CO")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var atlasCompact: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_CO")
        formatter.dateFormat = Calendar.current.isDateInToday(self) ? "HH:mm" : "dd MMM"
        return formatter.string(from: self).uppercased()
    }

    var atlasFull: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_CO")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension String {
    var atlasHealth: AtlasHealth {
        switch lowercased() {
        case "healthy", "ok", "good": .healthy
        case "verified", "completed", "closed": .verified
        case "attention", "medium", "review": .attention
        case "warning", "high": .warning
        case "critical", "severe", "urgent": .critical
        default: .stable
        }
    }

    var atlasSymbol: String {
        switch lowercased() {
        case "property", "propiedad", "building", "space": "building.2"
        case "vehicle", "vehículo", "car": "car.side"
        case "equipment", "equipo": "gearshape.2"
        case "infrastructure", "infraestructura": "bolt.horizontal.circle"
        case "document", "documento": "doc.text"
        default: "shippingbox"
        }
    }

    var atlasChangeSymbol: String {
        let value = lowercased()
        if value.contains("geometry") { return "ruler" }
        if value.contains("surface") || value.contains("anomaly") { return "exclamationmark.triangle" }
        if value.contains("condition") { return "checkmark.seal" }
        if value.contains("state") { return "square.stack.3d.up" }
        return "clock.arrow.circlepath"
    }

    var atlasDisplay: String {
        replacingOccurrences(of: "_", with: " ").split(separator: " ").map { $0.capitalized }.joined(separator: " ")
    }

    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}
