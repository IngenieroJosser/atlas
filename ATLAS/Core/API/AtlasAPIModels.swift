import Foundation

// MARK: - JSON

nonisolated enum JSONValue: Codable, Hashable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null }
        else if let value = try? container.decode(Bool.self) { self = .bool(value) }
        else if let value = try? container.decode(Double.self) { self = .number(value) }
        else if let value = try? container.decode(String.self) { self = .string(value) }
        else if let value = try? container.decode([String: JSONValue].self) { self = .object(value) }
        else if let value = try? container.decode([JSONValue].self) { self = .array(value) }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value") }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let value): value
        case .number(let value): String(value)
        case .bool(let value): String(value)
        default: nil
        }
    }
}

typealias JSONObject = [String: JSONValue]

// MARK: - Generic

nonisolated struct APIPage<T: Codable & Sendable>: Codable, Sendable {
    let items: [T]
    let total: Int
    let limit: Int
    let offset: Int
}

nonisolated struct APIMessage: Codable, Sendable { let message: String }

// MARK: - Auth

nonisolated struct APITokenPair: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
}

nonisolated struct APIUser: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let email: String
    let fullName: String
    let isActive: Bool
    let createdAt: Date
}

nonisolated struct APISession: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let deviceName: String
    let userAgent: String
    let ipAddress: String
    let expiresAt: Date
    let lastSeenAt: Date
    let revokedAt: Date?
    let createdAt: Date
}

nonisolated struct APIDevice: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let installationId: String
    let deviceName: String
    let platform: String
    let appVersion: String
    let osVersion: String
    let lastSeenAt: Date
}

// MARK: - World / Assets

nonisolated struct APIWorldOverview: Codable, Sendable {
    let assetsTotal: Int
    let monitoredAssets: Int
    let recentChanges: Int
    let requiresAttention: Int
    let lastSyncAt: Date?
    let attention: [JSONObject]
    let recentStates: [JSONObject]
    let changes: [JSONObject]
    let upcoming: [JSONObject]
}

nonisolated struct APIAsset: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let workspaceId: String?
    let name: String
    let category: String
    let description: String
    let identifier: String
    let location: String
    let status: String
    let responsibleUserId: String?
    let tags: [String]
    let notes: String
    let mainImageUrl: String?
    let metadataJson: JSONObject
    let archivedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let lastSyncedAt: Date?
}

nonisolated struct APIAssetSummary: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let workspaceId: String?
    let name: String
    let category: String
    let description: String
    let identifier: String
    let location: String
    let status: String
    let responsibleUserId: String?
    let tags: [String]
    let notes: String
    let mainImageUrl: String?
    let metadataJson: JSONObject
    let archivedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let lastSyncedAt: Date?
    let changesCount: Int
    let worldStatesCount: Int
    let openAnomaliesCount: Int
    let pendingMaintenanceCount: Int
    let latestStateAt: Date?
}

nonisolated struct APIWorldState: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String
    let captureSessionId: String?
    let sequenceNumber: Int
    let captureType: String
    let syncStatus: String
    let confidence: Double
    let conditionScore: Double?
    let conditionLabel: String
    let summary: String
    let geometryJson: JSONObject
    let propertiesJson: JSONObject
    let measurementsJson: JSONObject
    let recognizedText: String
    let localRef: String?
    let capturedAt: Date
}

nonisolated struct APIEvidence: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String?
    let worldStateId: String?
    let captureSessionId: String?
    let relationType: String
    let relationId: String?
    let storageKey: String
    let originalName: String
    let mimeType: String
    let sizeBytes: Int
    let sha256: String
    let evidenceType: String
    let note: String
    let metadataJson: JSONObject
    let createdAt: Date
}

nonisolated struct APITimelineItem: Codable, Identifiable, Hashable, Sendable {
    let type: String
    let id: String
    let occurredAt: Date
    let title: String
    let detail: String
    let metadata: JSONObject
}

nonisolated struct APIAssetDetail: Codable, Sendable {
    let asset: APIAssetSummary
    let latestState: APIWorldState?
    let latestInspection: JSONObject?
    let recentChanges: [JSONObject]
    let recentEvidence: [APIEvidence]
    let maintenance: [JSONObject]
    let activity: [APITimelineItem]
}

nonisolated struct APIDigitalTwin: Codable, Sendable {
    let asset: APIAsset
    let latestState: APIWorldState?
    let components: [JSONObject]
    let evidenceCount: Int
    let geometryAvailable: Bool
    let representation: String
}

nonisolated struct APICapture: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let userId: String
    let assetId: String?
    let captureMode: String
    let source: String
    let status: String
    let deviceCapabilities: JSONObject
    let analysisJson: JSONObject
    let suggestedAssetName: String
    let suggestedCategory: String
    let confidence: Double?
    let createdAt: Date
    let completedAt: Date?
}

nonisolated struct APICaptureCommitResult: Codable, Sendable {
    let asset: APIAsset
    let worldState: APIWorldState
    let detectedChanges: [JSONObject]
}

// MARK: - Inspections

nonisolated struct APIInspection: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String
    let createdBy: String?
    let inspectorUserId: String?
    let title: String
    let status: String
    let summary: String
    let confidence: Double?
    let scheduledFor: Date?
    let startedAt: Date?
    let completedAt: Date?
    let archivedAt: Date?
    let createdAt: Date
    let updatedAt: Date
}

nonisolated struct APIInspectionStep: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let inspectionId: String
    let stepKey: String
    let status: String
    let notes: String
    let dataJson: JSONObject
    let completedAt: Date?
}

nonisolated struct APIFinding: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let inspectionId: String
    let assetId: String
    let findingType: String
    let title: String
    let description: String
    let severity: String
    let confidence: Double?
    let status: String
    let metadataJson: JSONObject
    let createdAt: Date
}

nonisolated struct APIInspectionResult: Codable, Sendable {
    let inspection: APIInspection
    let steps: [APIInspectionStep]
    let findings: [APIFinding]
    let anomaliesCount: Int
    let evidenceCount: Int
}

// MARK: - Changes / Operations

nonisolated struct APIChange: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String
    let fromStateId: String?
    let toStateId: String?
    let changeType: String
    let title: String
    let description: String
    let confidence: Double?
    let severity: String
    let metadataJson: JSONObject
    let createdAt: Date
}

nonisolated struct APICompare: Codable, Sendable {
    let assetId: String
    let stateA: JSONObject
    let stateB: JSONObject
    let changes: [JSONObject]
    let interpretation: String
}

nonisolated struct APIAnomaly: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String
    let worldStateId: String?
    let findingId: String?
    let anomalyType: String
    let title: String
    let description: String
    let severity: String
    let confidence: Double?
    let status: String
    let locationText: String
    let evolutionJson: [JSONValue]
    let firstDetected: Date
    let lastObserved: Date
}

nonisolated struct APIMaintenance: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String
    let title: String
    let description: String
    let status: String
    let priority: String
    let dueAt: Date?
    let assigneeUserId: String?
    let suggestedByAtlas: Bool
    let sourceType: String?
    let sourceId: String?
    let createdAt: Date
    let completedAt: Date?
}

nonisolated struct APIWorkOrder: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let code: String
    let organizationId: String
    let assetId: String
    let anomalyId: String?
    let inspectionId: String?
    let maintenanceTaskId: String?
    let title: String
    let description: String
    let priority: String
    let status: String
    let assigneeUserId: String?
    let dueAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
}

nonisolated struct APIWorkOrderEvent: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let workOrderId: String
    let actorUserId: String?
    let eventType: String
    let detail: String
    let createdAt: Date
}

nonisolated struct APIWorkOrderDetail: Codable, Sendable {
    let workOrder: APIWorkOrder
    let events: [APIWorkOrderEvent]
}

// MARK: - Intelligence / Reports

nonisolated struct APISourceRef: Codable, Identifiable, Hashable, Sendable {
    var id: String
    let type: String
    let label: String
    let occurredAt: Date?
}

nonisolated struct APIAskAtlasResponse: Codable, Sendable {
    let interactionId: String
    let answer: String
    let confidence: String
    let sources: [APISourceRef]
    let recommendedAction: String
}

nonisolated struct APIInsight: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String?
    let title: String
    let statement: String
    let confidenceText: String
    let evidenceRefs: [JSONValue]
    let recommendation: String
    let basis: String
    let createdAt: Date
}

nonisolated struct APIReport: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let assetId: String?
    let inspectionId: String?
    let reportType: String
    let title: String
    let periodLabel: String
    let summary: String
    let findingsJson: [JSONValue]
    let changesJson: [JSONValue]
    let evidenceJson: [JSONValue]
    let recommendationsJson: [JSONValue]
    let status: String
    let exportKey: String?
    let createdBy: String?
    let createdAt: Date
}

nonisolated struct APIReportShare: Codable, Sendable { let token: String; let expiresAt: Date }

nonisolated struct APINotification: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let userId: String
    let organizationId: String
    let level: String
    let title: String
    let message: String
    let entityType: String?
    let entityId: String?
    let readAt: Date?
    let createdAt: Date
}

nonisolated struct APIAlert: Codable, Identifiable, Hashable, Sendable {
    var id: String { "\(entityType)-\(entityId)-\(occurredAt.timeIntervalSince1970)" }
    let level: String
    let title: String
    let detail: String
    let entityType: String
    let entityId: String
    let occurredAt: Date
}

nonisolated struct APIIntegration: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let provider: String
    let name: String
    let status: String
    let isConfigured: Bool
    let configPublicJson: JSONObject
}

// MARK: - Account / Organization

nonisolated struct APIProfile: Codable, Sendable {
    let user: APIUser
    let organizationId: String
    let organizationName: String
    let role: String
}

nonisolated struct APIPreferences: Codable, Hashable, Sendable {
    let attentionNotifications: Bool
    let productUpdates: Bool
    let analyticsEnabled: Bool
}

nonisolated struct APIOrganization: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let ownerId: String
    let createdAt: Date
    let updatedAt: Date
}

nonisolated struct APIMembership: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let userId: String
    let email: String
    let fullName: String
    let role: String
    let createdAt: Date
}

nonisolated struct APIWorkspace: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let name: String
    let createdAt: Date
}

nonisolated struct APIInvitation: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let organizationId: String
    let email: String
    let role: String
    let status: String
    let expiresAt: Date
    let createdAt: Date
}

nonisolated struct APISearchResult: Codable, Identifiable, Hashable, Sendable {
    let type: String
    let id: String
    let title: String
    let subtitle: String
    let route: String
    let metadata: JSONObject
}

// MARK: - Sync

nonisolated struct APISyncOperation: Codable, Hashable, Sendable {
    let idempotencyKey: String
    let localId: String
    let entityType: String
    let operation: String
    let payload: JSONObject
}

nonisolated struct APISyncResult: Codable, Hashable, Sendable {
    let idempotencyKey: String
    let localId: String
    let entityType: String
    let serverId: String
    let status: String
}

nonisolated struct APISyncBatchResponse: Codable, Sendable { let results: [APISyncResult] }
