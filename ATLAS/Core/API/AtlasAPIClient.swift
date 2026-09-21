import Foundation
import Security
import UIKit

// MARK: - Configuration

nonisolated enum AtlasConfiguration {
    // v2 intentionally uses a new preference key so installations that previously
    // stored localhost/LAN development URLs migrate to the Render production API.
    private static let key = "atlas.api.baseURL.v2"
    static let defaultBaseURL = "https://atlas-api-fomq.onrender.com/api/v1"

    static var baseURL: URL {
        let raw = UserDefaults.standard.string(forKey: key) ?? defaultBaseURL
        return URL(string: raw) ?? URL(string: defaultBaseURL)!
    }

    static func setBaseURL(_ rawValue: String) throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else {
            throw AtlasAPIError.invalidURL
        }

        let normalized = trimmed.hasSuffix("/") ? String(trimmed.dropLast()) : trimmed
        UserDefaults.standard.set(normalized, forKey: key)
    }

    static func resetToProduction() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Errors

nonisolated enum AtlasAPIError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case http(Int, String)
    case decoding(String)
    case notAuthenticated
    case emptyResponse
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "La URL del backend no es válida."
        case .invalidResponse: "ATLAS recibió una respuesta no válida del servidor."
        case .http(let status, let message): "Servidor \(status): \(message)"
        case .decoding(let message): "No se pudo interpretar la respuesta: \(message)"
        case .notAuthenticated: "La sesión expiró. Inicia sesión nuevamente."
        case .emptyResponse: "El servidor respondió sin contenido."
        case .transport(let message): "No se pudo conectar con ATLAS API: \(message)"
        }
    }
}

// MARK: - Keychain

nonisolated enum AtlasKeychain {
    private static let service = "com.zyra.ATLAS.api"

    static func save(_ value: String, key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        var insert = query
        insert[kSecValueData as String] = data
        SecItemAdd(insert as CFDictionary, nil)
    }

    static func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - API Client

actor AtlasAPIClient {
    static let shared = AtlasAPIClient()

    private let accessKey = "access-token"
    private let refreshKey = "refresh-token"
    private var accessToken: String?
    private var refreshToken: String?

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session
        self.accessToken = AtlasKeychain.read(accessKey)
        self.refreshToken = AtlasKeychain.read(refreshKey)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = AtlasDateCodec.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO-8601 date: \(string)")
        }
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    var hasStoredSession: Bool { refreshToken != nil }
    var currentBaseURL: URL { AtlasConfiguration.baseURL }

    func updateBaseURL(_ rawValue: String) throws {
        try AtlasConfiguration.setBaseURL(rawValue)
    }

    func clearSession() {
        accessToken = nil
        refreshToken = nil
        AtlasKeychain.delete(accessKey)
        AtlasKeychain.delete(refreshKey)
    }

    private func save(tokens: APITokenPair) {
        accessToken = tokens.accessToken
        refreshToken = tokens.refreshToken
        AtlasKeychain.save(tokens.accessToken, key: accessKey)
        AtlasKeychain.save(tokens.refreshToken, key: refreshKey)
    }

    // MARK: Auth

    func health() async throws -> JSONObject { try await request(path: "health", authorized: false) }

    func register(email: String, password: String, fullName: String, organizationName: String) async throws -> APITokenPair {
        struct Body: Encodable { let email: String; let password: String; let fullName: String; let organizationName: String }
        let tokens: APITokenPair = try await request(path: "auth/register", method: "POST", body: Body(email: email, password: password, fullName: fullName, organizationName: organizationName), authorized: false)
        save(tokens: tokens)
        return tokens
    }

    func login(email: String, password: String, deviceName: String? = nil) async throws -> APITokenPair {
        struct Body: Encodable, Sendable { let email: String; let password: String; let deviceName: String }
        let resolvedDeviceName = if let deviceName {
            deviceName
        } else {
            await MainActor.run { UIDevice.current.name }
        }
        let tokens: APITokenPair = try await request(path: "auth/login", method: "POST", body: Body(email: email, password: password, deviceName: resolvedDeviceName), authorized: false)
        save(tokens: tokens)
        return tokens
    }

    func loginWithApple(identityToken: String, fullName: String, deviceName: String? = nil) async throws -> APITokenPair {
        struct Body: Encodable, Sendable { let identityToken: String; let fullName: String; let deviceName: String }
        let resolvedDeviceName = if let deviceName {
            deviceName
        } else {
            await MainActor.run { UIDevice.current.name }
        }
        let tokens: APITokenPair = try await request(path: "auth/apple", method: "POST", body: Body(identityToken: identityToken, fullName: fullName, deviceName: resolvedDeviceName), authorized: false)
        save(tokens: tokens)
        return tokens
    }

    func restoreSession() async throws -> APIUser {
        if accessToken == nil { try await refreshAccessToken() }
        return try await me()
    }

    func me() async throws -> APIUser { try await request(path: "auth/me") }

    func logout() async throws {
        guard let refreshToken else { clearSession(); return }
        struct Body: Encodable { let refreshToken: String }
        let _: APIMessage = try await request(path: "auth/logout", method: "POST", body: Body(refreshToken: refreshToken), authorized: false)
        clearSession()
    }

    func requestPasswordReset(email: String) async throws -> JSONObject {
        struct Body: Encodable { let email: String }
        return try await request(path: "auth/password-reset/request", method: "POST", body: Body(email: email), authorized: false)
    }

    func confirmPasswordReset(token: String, newPassword: String) async throws -> APIMessage {
        struct Body: Encodable { let token: String; let newPassword: String }
        return try await request(path: "auth/password-reset/confirm", method: "POST", body: Body(token: token, newPassword: newPassword), authorized: false)
    }

    // MARK: World

    func worldOverview() async throws -> APIWorldOverview { try await request(path: "world/overview") }

    // MARK: Assets

    func assets(page: Int = 1, pageSize: Int = 50, search: String? = nil, category: String? = nil, status: String? = nil, location: String? = nil, hasAnomalies: Bool? = nil, hasChanges: Bool? = nil, maintenancePending: Bool? = nil) async throws -> APIPage<APIAssetSummary> {
        var query = pageQuery(page, pageSize)
        append(&query, "q", search); append(&query, "category", category); append(&query, "status", status); append(&query, "location", location)
        append(&query, "has_anomalies", hasAnomalies); append(&query, "pending_maintenance", maintenancePending)
        return try await request(path: "assets", query: query)
    }

    func createAsset(name: String, category: String, description: String = "", identifier: String = "", location: String = "", tags: [String] = [], notes: String = "") async throws -> APIAsset {
        struct Body: Encodable {
            let name, category, description, identifier, location: String
            let status: String
            let tags: [String]
            let responsibleUserId: String?
            let workspaceId: String?
            let notes: String
            let mainImageUrl: String?
            let metadataJson: JSONObject
        }
        return try await request(path: "assets", method: "POST", body: Body(name: name, category: category, description: description, identifier: identifier, location: location, status: "stable", tags: tags, responsibleUserId: nil, workspaceId: nil, notes: notes, mainImageUrl: nil, metadataJson: [:]))
    }

    func assetDetail(_ id: String) async throws -> APIAssetDetail { try await request(path: "assets/\(id)") }

    func updateAsset(_ id: String, fields: JSONObject) async throws -> APIAsset {
        try await request(path: "assets/\(id)", method: "PATCH", body: fields)
    }

    func archiveAsset(_ id: String) async throws { try await requestVoid(path: "assets/\(id)", method: "DELETE") }

    func worldStates(assetId: String) async throws -> [APIWorldState] { try await request(path: "assets/\(assetId)/states") }

    func createWorldState(assetId: String, captureType: String, recognizedText: String, confidence: Double, conditionLabel: String = "unknown", conditionScore: Double? = nil, geometry: JSONObject = [:], properties: JSONObject = [:], measurements: JSONObject = [:], localRef: String? = nil, captureSessionId: String? = nil) async throws -> APIWorldState {
        struct Body: Encodable {
            let captureType, syncStatus: String
            let confidence: Double
            let conditionScore: Double?
            let conditionLabel, summary: String
            let geometryJson, propertiesJson, measurementsJson: JSONObject
            let recognizedText: String
            let localRef, captureSessionId: String?
        }
        return try await request(path: "assets/\(assetId)/states", method: "POST", body: Body(captureType: captureType, syncStatus: "synced", confidence: confidence, conditionScore: conditionScore, conditionLabel: conditionLabel, summary: "", geometryJson: geometry, propertiesJson: properties, measurementsJson: measurements, recognizedText: recognizedText, localRef: localRef, captureSessionId: captureSessionId))
    }

    func digitalTwin(assetId: String) async throws -> APIDigitalTwin { try await request(path: "assets/\(assetId)/digital-twin") }
    func timeline(assetId: String) async throws -> [APITimelineItem] { try await request(path: "assets/\(assetId)/timeline") }

    // MARK: Captures / Evidence

    func createCapture(mode: String, assetId: String? = nil, deviceCapabilities: JSONObject) async throws -> APICapture {
        struct Body: Encodable { let captureMode, source: String; let assetId: String?; let deviceCapabilities: JSONObject }
        return try await request(path: "captures", method: "POST", body: Body(captureMode: mode, source: "camera", assetId: assetId, deviceCapabilities: deviceCapabilities))
    }

    func capture(_ id: String) async throws -> APICapture { try await request(path: "captures/\(id)") }
    func captureEvidence(_ id: String) async throws -> [APIEvidence] { try await request(path: "captures/\(id)/evidence") }

    func uploadEvidence(captureId: String, data: Data, filename: String = "capture.jpg", mimeType: String = "image/jpeg", evidenceType: String = "photo", note: String = "") async throws -> APIEvidence {
        let fields = ["evidence_type": evidenceType, "note": note]
        return try await multipart(path: "captures/\(captureId)/evidence", data: data, filename: filename, mimeType: mimeType, fields: fields)
    }

    func analyzeCapture(_ captureId: String, recognizedText: String, suggestedAssetName: String, suggestedCategory: String, confidence: Double, geometry: JSONObject = [:], properties: JSONObject = [:], measurements: JSONObject = [:], conditionScore: Double? = nil) async throws -> APICapture {
        struct Body: Encodable {
            let recognizedText: String
            let geometryJson, propertiesJson, measurementsJson: JSONObject
            let conditionScore: Double?
            let suggestedAssetName, suggestedCategory: String
            let confidence: Double
        }
        return try await request(path: "captures/\(captureId)/analyze", method: "POST", body: Body(recognizedText: recognizedText, geometryJson: geometry, propertiesJson: properties, measurementsJson: measurements, conditionScore: conditionScore, suggestedAssetName: suggestedAssetName, suggestedCategory: suggestedCategory, confidence: confidence))
    }

    func commitCapture(_ captureId: String, assetId: String? = nil, createAsset: CreateAssetPayload? = nil, syncStatus: String = "synced") async throws -> APICaptureCommitResult {
        struct Body: Encodable { let assetId: String?; let createAsset: CreateAssetPayload?; let syncStatus: String }
        return try await request(path: "captures/\(captureId)/commit", method: "POST", body: Body(assetId: assetId, createAsset: createAsset, syncStatus: syncStatus))
    }

    func evidence(_ id: String) async throws -> APIEvidence { try await request(path: "evidence/\(id)") }
    func evidenceContent(_ id: String) async throws -> Data { try await requestData(path: "evidence/\(id)/content") }

    // MARK: Inspections

    func inspections(page: Int = 1, pageSize: Int = 50, status: String? = nil, assetId: String? = nil) async throws -> APIPage<APIInspection> {
        var query = pageQuery(page, pageSize); append(&query, "status", status); append(&query, "asset_id", assetId)
        return try await request(path: "inspections", query: query)
    }

    func createInspection(assetId: String, title: String, scheduledFor: Date? = nil) async throws -> APIInspection {
        struct Body: Encodable { let assetId, title: String; let scheduledFor: Date?; let inspectorUserId: String? }
        return try await request(path: "inspections", method: "POST", body: Body(assetId: assetId, title: title, scheduledFor: scheduledFor, inspectorUserId: nil))
    }

    func inspection(_ id: String) async throws -> APIInspectionResult { try await request(path: "inspections/\(id)") }
    func updateInspection(_ id: String, fields: JSONObject) async throws -> APIInspection { try await request(path: "inspections/\(id)", method: "PATCH", body: fields) }
    func inspectionSteps(_ id: String) async throws -> [APIInspectionStep] { try await request(path: "inspections/\(id)/steps") }

    func updateInspectionStep(_ id: String, stepKey: String, status: String = "completed", notes: String = "", data: JSONObject = [:]) async throws -> APIInspectionStep {
        struct Body: Encodable { let status, notes: String; let dataJson: JSONObject }
        return try await request(path: "inspections/\(id)/steps/\(stepKey)", method: "PUT", body: Body(status: status, notes: notes, dataJson: data))
    }

    func findings(inspectionId: String) async throws -> [APIFinding] { try await request(path: "inspections/\(inspectionId)/findings") }

    func createFinding(inspectionId: String, title: String, findingType: String = "observation", description: String = "", severity: String = "info", confidence: Double? = nil) async throws -> APIFinding {
        struct Body: Encodable { let title, findingType, description, severity: String; let confidence: Double?; let metadataJson: JSONObject }
        return try await request(path: "inspections/\(inspectionId)/findings", method: "POST", body: Body(title: title, findingType: findingType, description: description, severity: severity, confidence: confidence, metadataJson: [:]))
    }

    func workOrderFromInspection(_ inspectionId: String, assetId: String, title: String, description: String = "", priority: String = "medium") async throws -> APIWorkOrder {
        let body = WorkOrderPayload(assetId: assetId, title: title, description: description, priority: priority, anomalyId: nil, inspectionId: inspectionId, maintenanceTaskId: nil, assigneeUserId: nil, dueAt: nil)
        return try await request(path: "inspections/\(inspectionId)/work-order", method: "POST", body: body)
    }

    // MARK: Changes / Anomalies

    func changes(page: Int = 1, pageSize: Int = 50, assetId: String? = nil, severity: String? = nil, changeType: String? = nil) async throws -> APIPage<APIChange> {
        var query = pageQuery(page, pageSize); append(&query, "asset_id", assetId); append(&query, "severity", severity); append(&query, "change_type", changeType)
        return try await request(path: "changes", query: query)
    }

    func change(_ id: String) async throws -> APIChange { try await request(path: "changes/\(id)") }

    func compare(assetId: String, stateA: String? = nil, stateB: String? = nil) async throws -> APICompare {
        var query: [URLQueryItem] = []; append(&query, "state_a_id", stateA); append(&query, "state_b_id", stateB)
        return try await request(path: "changes/compare/\(assetId)", query: query)
    }

    func anomalies(page: Int = 1, pageSize: Int = 50, assetId: String? = nil, status: String? = nil, severity: String? = nil) async throws -> APIPage<APIAnomaly> {
        var query = pageQuery(page, pageSize); append(&query, "asset_id", assetId); append(&query, "status", status); append(&query, "severity", severity)
        return try await request(path: "anomalies", query: query)
    }

    func createAnomaly(assetId: String, worldStateId: String? = nil, findingId: String? = nil, anomalyType: String = "surface", title: String, description: String = "", severity: String = "medium", confidence: Double? = nil, locationText: String = "") async throws -> APIAnomaly {
        struct Body: Encodable { let assetId, anomalyType, title, description, severity, locationText: String; let worldStateId, findingId: String?; let confidence: Double? }
        return try await request(path: "anomalies", method: "POST", body: Body(assetId: assetId, anomalyType: anomalyType, title: title, description: description, severity: severity, locationText: locationText, worldStateId: worldStateId, findingId: findingId, confidence: confidence))
    }

    func anomaly(_ id: String) async throws -> APIAnomaly { try await request(path: "anomalies/\(id)") }
    func updateAnomaly(_ id: String, fields: JSONObject) async throws -> APIAnomaly { try await request(path: "anomalies/\(id)", method: "PATCH", body: fields) }
    func workOrderFromAnomaly(_ id: String) async throws -> APIWorkOrder { try await request(path: "anomalies/\(id)/work-order", method: "POST", body: EmptyBody()) }
    func inspectionFromAnomaly(_ id: String) async throws -> APIInspection { try await request(path: "anomalies/\(id)/inspection", method: "POST", body: EmptyBody()) }

    // MARK: Maintenance / Work Orders

    func maintenance(page: Int = 1, pageSize: Int = 50, assetId: String? = nil, status: String? = nil, priority: String? = nil) async throws -> APIPage<APIMaintenance> {
        var query = pageQuery(page, pageSize); append(&query, "asset_id", assetId); append(&query, "status", status)
        return try await request(path: "maintenance", query: query)
    }

    func createMaintenance(assetId: String, title: String, description: String = "", status: String = "upcoming", priority: String = "medium", dueAt: Date? = nil, suggestedByAtlas: Bool = false) async throws -> APIMaintenance {
        struct Body: Encodable { let assetId, title, description, status, priority: String; let dueAt: Date?; let assigneeUserId: String?; let suggestedByAtlas: Bool; let sourceType, sourceId: String? }
        return try await request(path: "maintenance", method: "POST", body: Body(assetId: assetId, title: title, description: description, status: status, priority: priority, dueAt: dueAt, assigneeUserId: nil, suggestedByAtlas: suggestedByAtlas, sourceType: nil, sourceId: nil))
    }

    func maintenanceDetail(_ id: String) async throws -> APIMaintenance { try await request(path: "maintenance/\(id)") }
    func updateMaintenance(_ id: String, fields: JSONObject) async throws -> APIMaintenance { try await request(path: "maintenance/\(id)", method: "PATCH", body: fields) }
    func workOrderFromMaintenance(_ id: String) async throws -> APIWorkOrder { try await request(path: "maintenance/\(id)/work-order", method: "POST", body: EmptyBody()) }

    func workOrders(page: Int = 1, pageSize: Int = 50, status: String? = nil, priority: String? = nil, assetId: String? = nil) async throws -> APIPage<APIWorkOrder> {
        var query = pageQuery(page, pageSize); append(&query, "status", status); append(&query, "priority", priority); append(&query, "asset_id", assetId)
        return try await request(path: "work-orders", query: query)
    }

    func createWorkOrder(_ payload: WorkOrderPayload) async throws -> APIWorkOrder { try await request(path: "work-orders", method: "POST", body: payload) }
    func workOrder(_ id: String) async throws -> APIWorkOrderDetail { try await request(path: "work-orders/\(id)") }
    func updateWorkOrder(_ id: String, fields: JSONObject) async throws -> APIWorkOrder { try await request(path: "work-orders/\(id)", method: "PATCH", body: fields) }

    // MARK: Intelligence

    func askAtlas(_ question: String, assetId: String? = nil) async throws -> APIAskAtlasResponse {
        struct Body: Encodable { let question: String; let assetId: String? }
        return try await request(path: "intelligence/ask", method: "POST", body: Body(question: question, assetId: assetId))
    }

    func intelligenceHistory(page: Int = 1, pageSize: Int = 50, assetId: String? = nil) async throws -> [JSONObject] {
        var query = pageQuery(page, pageSize); append(&query, "asset_id", assetId)
        return try await request(path: "intelligence/history", query: query)
    }

    func insights(assetId: String? = nil) async throws -> [APIInsight] {
        var query: [URLQueryItem] = []; append(&query, "asset_id", assetId)
        return try await request(path: "intelligence/insights", query: query)
    }

    func createInsight(assetId: String?, title: String, statement: String, confidence: String, recommendation: String, basis: String) async throws -> APIInsight {
        struct Body: Encodable { let assetId: String?; let title, statement, confidence: String; let evidenceRefs: [JSONObject]; let recommendation, basis: String }
        return try await request(path: "intelligence/insights", method: "POST", body: Body(assetId: assetId, title: title, statement: statement, confidence: confidence, evidenceRefs: [], recommendation: recommendation, basis: basis))
    }

    func insight(_ id: String) async throws -> APIInsight { try await request(path: "intelligence/insights/\(id)") }

    // MARK: Reports

    func reports(page: Int = 1, pageSize: Int = 50, reportType: String? = nil, assetId: String? = nil) async throws -> APIPage<APIReport> {
        var query = pageQuery(page, pageSize); append(&query, "report_type", reportType); append(&query, "asset_id", assetId)
        return try await request(path: "reports", query: query)
    }

    func createReport(reportType: String, title: String, assetId: String? = nil, inspectionId: String? = nil, periodLabel: String = "") async throws -> APIReport {
        struct Body: Encodable { let reportType, title: String; let assetId, inspectionId: String?; let periodLabel: String }
        return try await request(path: "reports", method: "POST", body: Body(reportType: reportType, title: title, assetId: assetId, inspectionId: inspectionId, periodLabel: periodLabel))
    }

    func report(_ id: String) async throws -> APIReport { try await request(path: "reports/\(id)") }
    func sharedReport(token: String) async throws -> APIReport { try await request(path: "reports/shared/\(token)", authorized: false) }
    func exportReport(_ id: String) async throws -> Data {
        try await perform(path: "reports/\(id)/export", method: "POST", body: Optional<EmptyBody>.none, query: [], authorized: true, retryAfterRefresh: true)
    }
    func shareReport(_ id: String, hours: Int = 72) async throws -> APIReportShare { try await request(path: "reports/\(id)/share", method: "POST", body: EmptyBody(), query: [URLQueryItem(name: "hours", value: String(hours))]) }

    // MARK: Notifications / Search

    func notifications(unreadOnly: Bool = false) async throws -> [APINotification] { try await request(path: "notifications", query: [URLQueryItem(name: "unread_only", value: String(unreadOnly))]) }
    func markNotificationRead(_ id: String) async throws -> APINotification { try await request(path: "notifications/\(id)/read", method: "PATCH", body: EmptyBody()) }
    func markAllNotificationsRead() async throws -> APIMessage { try await request(path: "notifications/read-all", method: "POST", body: EmptyBody()) }
    func alerts() async throws -> [APIAlert] { try await request(path: "alerts") }

    func search(_ queryText: String, limit: Int = 30) async throws -> [APISearchResult] {
        try await request(path: "search", query: [URLQueryItem(name: "q", value: queryText), URLQueryItem(name: "limit", value: String(limit))])
    }

    // MARK: Organization / Profile

    func organization() async throws -> APIOrganization { try await request(path: "organization") }
    func updateOrganization(name: String) async throws -> APIOrganization { struct Body: Encodable { let name: String }; return try await request(path: "organization", method: "PATCH", body: Body(name: name)) }
    func members() async throws -> [APIMembership] { try await request(path: "organization/members") }
    func workspaces() async throws -> [APIWorkspace] { try await request(path: "organization/workspaces") }
    func createWorkspace(name: String) async throws -> APIWorkspace { struct Body: Encodable { let name: String }; return try await request(path: "organization/workspaces", method: "POST", body: Body(name: name)) }
    func invitations() async throws -> [APIInvitation] { try await request(path: "organization/invitations") }
    func invite(email: String, role: String) async throws -> APIInvitation { struct Body: Encodable { let email, role: String }; return try await request(path: "organization/invitations", method: "POST", body: Body(email: email, role: role)) }
    func integrations() async throws -> [APIIntegration] { try await request(path: "integrations") }

    func profile() async throws -> APIProfile { try await request(path: "account/profile") }
    func updateProfile(fullName: String) async throws -> APIProfile { struct Body: Encodable { let fullName: String }; return try await request(path: "account/profile", method: "PATCH", body: Body(fullName: fullName)) }
    func preferences() async throws -> APIPreferences { try await request(path: "account/preferences") }
    func updatePreferences(attentionNotifications: Bool? = nil, productUpdates: Bool? = nil, analyticsEnabled: Bool? = nil) async throws -> APIPreferences {
        struct Body: Encodable { let attentionNotifications, productUpdates, analyticsEnabled: Bool? }
        return try await request(path: "account/preferences", method: "PATCH", body: Body(attentionNotifications: attentionNotifications, productUpdates: productUpdates, analyticsEnabled: analyticsEnabled))
    }
    func sessions() async throws -> [APISession] { try await request(path: "account/sessions") }
    func revokeSession(_ id: String) async throws -> APIMessage { try await request(path: "account/sessions/\(id)", method: "DELETE") }
    func devices() async throws -> [APIDevice] { try await request(path: "account/devices") }
    func registerDevice(installationId: String, pushToken: String? = nil) async throws -> APIDevice {
        struct Body: Encodable, Sendable {
            let installationId: String
            let deviceName: String
            let pushToken: String?
            let appVersion: String
            let osVersion: String
        }

        let deviceInfo = await MainActor.run {
            (
                name: UIDevice.current.name,
                osVersion: UIDevice.current.systemVersion,
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            )
        }

        return try await request(
            path: "account/devices",
            method: "POST",
            body: Body(
                installationId: installationId,
                deviceName: deviceInfo.name,
                pushToken: pushToken,
                appVersion: deviceInfo.appVersion,
                osVersion: deviceInfo.osVersion
            )
        )
    }
    func accountDataExport() async throws -> JSONObject { try await request(path: "account/data-export") }

    func deleteAccount() async throws -> APIMessage {
        struct Body: Encodable, Sendable { let confirmation: String }
        let response: APIMessage = try await request(
            path: "account",
            method: "DELETE",
            body: Body(confirmation: "DELETE")
        )
        clearSession()
        return response
    }

    // MARK: Offline Sync

    func sync(_ operations: [APISyncOperation]) async throws -> APISyncBatchResponse {
        struct Body: Encodable { let operations: [APISyncOperation] }
        return try await request(path: "sync/batch", method: "POST", body: Body(operations: operations))
    }

    // MARK: Networking internals

    private func request<Response: Decodable & Sendable>(path: String, method: String = "GET", query: [URLQueryItem] = [], authorized: Bool = true) async throws -> Response {
        try await request(path: path, method: method, body: Optional<EmptyBody>.none, query: query, authorized: authorized)
    }

    private func request<Body: Encodable & Sendable, Response: Decodable & Sendable>(path: String, method: String, body: Body?, query: [URLQueryItem] = [], authorized: Bool = true) async throws -> Response {
        let data = try await perform(path: path, method: method, body: body, query: query, authorized: authorized, retryAfterRefresh: true)
        guard !data.isEmpty else { throw AtlasAPIError.emptyResponse }
        do { return try decoder.decode(Response.self, from: data) }
        catch { throw AtlasAPIError.decoding(error.localizedDescription) }
    }

    private func requestVoid(path: String, method: String) async throws {
        _ = try await perform(path: path, method: method, body: Optional<EmptyBody>.none, query: [], authorized: true, retryAfterRefresh: true)
    }

    private func requestData(path: String) async throws -> Data {
        try await perform(path: path, method: "GET", body: Optional<EmptyBody>.none, query: [], authorized: true, retryAfterRefresh: true)
    }

    private func perform<Body: Encodable & Sendable>(path: String, method: String, body: Body?, query: [URLQueryItem], authorized: Bool, retryAfterRefresh: Bool) async throws -> Data {
        var components = URLComponents(url: AtlasConfiguration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !query.isEmpty { components?.queryItems = query }
        guard let url = components?.url else { throw AtlasAPIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = 35
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        if let body {
            req.httpBody = try encoder.encode(body)
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if authorized {
            guard let accessToken else { throw AtlasAPIError.notAuthenticated }
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else { throw AtlasAPIError.invalidResponse }
            if http.statusCode == 401, authorized, retryAfterRefresh, refreshToken != nil {
                try await refreshAccessToken()
                return try await perform(path: path, method: method, body: body, query: query, authorized: authorized, retryAfterRefresh: false)
            }
            guard 200..<300 ~= http.statusCode else {
                throw AtlasAPIError.http(http.statusCode, Self.errorMessage(from: data))
            }
            return data
        } catch let error as AtlasAPIError { throw error }
        catch { throw AtlasAPIError.transport(error.localizedDescription) }
    }

    private func multipart<Response: Decodable & Sendable>(path: String, data: Data, filename: String, mimeType: String, fields: [String: String], retryAfterRefresh: Bool = true) async throws -> Response {
        guard let accessToken else { throw AtlasAPIError.notAuthenticated }
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: AtlasConfiguration.baseURL.appendingPathComponent(path))
        req.httpMethod = "POST"
        req.timeoutInterval = 60
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        for (key, value) in fields {
            body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n")
        }
        body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\nContent-Type: \(mimeType)\r\n\r\n")
        body.append(data); body.append("\r\n--\(boundary)--\r\n")
        req.httpBody = body
        let (responseData, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw AtlasAPIError.invalidResponse }
        if http.statusCode == 401, retryAfterRefresh, refreshToken != nil {
            try await refreshAccessToken()
            return try await multipart(path: path, data: data, filename: filename, mimeType: mimeType, fields: fields, retryAfterRefresh: false)
        }
        guard 200..<300 ~= http.statusCode else { throw AtlasAPIError.http(http.statusCode, Self.errorMessage(from: responseData)) }
        do { return try decoder.decode(Response.self, from: responseData) }
        catch { throw AtlasAPIError.decoding(error.localizedDescription) }
    }

    private func refreshAccessToken() async throws {
        guard let refreshToken else { clearSession(); throw AtlasAPIError.notAuthenticated }
        struct Body: Encodable, Sendable { let refreshToken: String }
        do {
            let tokens: APITokenPair = try await request(path: "auth/refresh", method: "POST", body: Body(refreshToken: refreshToken), authorized: false)
            save(tokens: tokens)
        } catch {
            clearSession()
            throw AtlasAPIError.notAuthenticated
        }
    }

    private static func errorMessage(from data: Data) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let detail = object["detail"] as? String { return detail }
            if let message = object["message"] as? String { return message }
            if let detail = object["detail"] { return String(describing: detail) }
        }
        return String(data: data, encoding: .utf8) ?? "Error desconocido"
    }

    private func pageQuery(_ page: Int, _ pageSize: Int) -> [URLQueryItem] {
        let safePage = max(1, page)
        let safeSize = min(max(1, pageSize), 100)
        return [
            URLQueryItem(name: "limit", value: String(safeSize)),
            URLQueryItem(name: "offset", value: String((safePage - 1) * safeSize))
        ]
    }
    private func append(_ query: inout [URLQueryItem], _ name: String, _ value: String?) { if let value, !value.isEmpty { query.append(.init(name: name, value: value)) } }
    private func append(_ query: inout [URLQueryItem], _ name: String, _ value: Bool?) { if let value { query.append(.init(name: name, value: String(value))) } }
}

nonisolated struct EmptyBody: Encodable, Sendable {}

nonisolated struct CreateAssetPayload: Codable, Sendable {
    let name: String
    let category: String
    var description: String = ""
    var identifier: String = ""
    var location: String = ""
    var status: String = "stable"
    var tags: [String] = []
    var responsibleUserId: String? = nil
    var workspaceId: String? = nil
    var notes: String = ""
    var mainImageUrl: String? = nil
    var metadataJson: JSONObject = [:]
}

nonisolated struct WorkOrderPayload: Codable, Sendable {
    let assetId: String
    let title: String
    var description: String = ""
    var priority: String = "medium"
    var anomalyId: String? = nil
    var inspectionId: String? = nil
    var maintenanceTaskId: String? = nil
    var assigneeUserId: String? = nil
    var dueAt: Date? = nil
}

private nonisolated enum AtlasDateCodec {
    static func date(from value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: value) { return date }

        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        return basic.date(from: value)
    }
}

nonisolated private extension Data {
    mutating func append(_ string: String) { if let data = string.data(using: .utf8) { append(data) } }
}
