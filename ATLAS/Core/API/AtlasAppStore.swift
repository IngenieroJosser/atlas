import AuthenticationServices
import Combine
import Foundation
import UIKit

@MainActor
final class AtlasAppStore: ObservableObject {
    static let shared = AtlasAppStore()

    enum SessionState: Equatable {
        case restoring
        case signedOut
        case signedIn
    }

    @Published private(set) var sessionState: SessionState = .restoring
    @Published private(set) var user: APIUser?
    @Published private(set) var profile: APIProfile?
    @Published private(set) var worldOverview: APIWorldOverview?

    @Published private(set) var assets: [APIAssetSummary] = []
    @Published private(set) var changes: [APIChange] = []
    @Published private(set) var inspections: [APIInspection] = []
    @Published private(set) var anomalies: [APIAnomaly] = []
    @Published private(set) var maintenance: [APIMaintenance] = []
    @Published private(set) var workOrders: [APIWorkOrder] = []
    @Published private(set) var reports: [APIReport] = []
    @Published private(set) var notifications: [APINotification] = []
    @Published private(set) var alerts: [APIAlert] = []
    @Published private(set) var insights: [APIInsight] = []
    @Published private(set) var integrations: [APIIntegration] = []
    @Published private(set) var organization: APIOrganization?
    @Published private(set) var members: [APIMembership] = []
    @Published private(set) var workspaces: [APIWorkspace] = []
    @Published private(set) var invitations: [APIInvitation] = []
    @Published private(set) var sessions: [APISession] = []
    @Published private(set) var devices: [APIDevice] = []
    @Published private(set) var preferences: APIPreferences?

    @Published var selectedAssetID: String?
    @Published var selectedChangeID: String?
    @Published var selectedInspectionID: String?
    @Published var selectedAnomalyID: String?
    @Published var selectedMaintenanceID: String?
    @Published var selectedWorkOrderID: String?
    @Published var selectedReportID: String?
    @Published var selectedInsightID: String?

    @Published private(set) var selectedAssetDetail: APIAssetDetail?
    @Published private(set) var selectedDigitalTwin: APIDigitalTwin?
    @Published private(set) var selectedChange: APIChange?
    @Published private(set) var selectedInspection: APIInspectionResult?
    @Published private(set) var selectedAnomaly: APIAnomaly?
    @Published private(set) var selectedMaintenance: APIMaintenance?
    @Published private(set) var selectedWorkOrder: APIWorkOrderDetail?
    @Published private(set) var selectedReport: APIReport?
    @Published private(set) var selectedInsight: APIInsight?
    @Published private(set) var selectedComparison: APICompare?
    @Published private(set) var assetStates: [APIWorldState] = []

    @Published private(set) var askResponse: APIAskAtlasResponse?
    @Published private(set) var searchResults: [APISearchResult] = []

    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastSuccessfulRefresh: Date?
    @Published private(set) var pendingOfflineOperations: Int = 0

    private let api: AtlasAPIClient
    private let offlineQueue = AtlasOfflineQueue.shared

    init(api: AtlasAPIClient = .shared) {
        self.api = api
        pendingOfflineOperations = offlineQueue.count
    }

    // MARK: Session

    func restoreSession() async {
        sessionState = .restoring
        do {
            let restored = try await api.restoreSession()
            user = restored
            sessionState = .signedIn
            await bootstrap()
        } catch {
            sessionState = .signedOut
            user = nil
        }
    }

    func login(email: String, password: String) async -> Bool {
        await performAuth {
            _ = try await self.api.login(email: email, password: password)
            self.user = try await self.api.me()
        }
    }

    func register(email: String, password: String, fullName: String, organizationName: String) async -> Bool {
        await performAuth {
            _ = try await self.api.register(email: email, password: password, fullName: fullName, organizationName: organizationName)
            self.user = try await self.api.me()
        }
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async -> Bool {
        guard let data = credential.identityToken, let token = String(data: data, encoding: .utf8) else {
            errorMessage = "Apple no entregó un identity token válido."
            return false
        }
        let name = [credential.fullName?.givenName, credential.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
        return await performAuth {
            _ = try await self.api.loginWithApple(identityToken: token, fullName: name)
            self.user = try await self.api.me()
        }
    }

    func logout() async {
        do { try await api.logout() } catch { apiClearFallback() }
        resetRemoteState()
        sessionState = .signedOut
    }

    func deleteAccount() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await api.deleteAccount()
            offlineQueue.clear()
            pendingOfflineOperations = 0
            UserDefaults.standard.removeObject(forKey: "atlas.installation.id")
            resetRemoteState()
            sessionState = .signedOut
            AtlasHaptics.success()
            return true
        } catch {
            errorMessage = error.localizedDescription
            AtlasHaptics.warning()
            return false
        }
    }

    private func apiClearFallback() {
        Task { await api.clearSession() }
    }

    private func performAuth(_ operation: @escaping () async throws -> Void) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await operation()
            sessionState = .signedIn
            await bootstrap()
            AtlasHaptics.success()
            return true
        } catch {
            errorMessage = error.localizedDescription
            sessionState = .signedOut
            AtlasHaptics.warning()
            return false
        }
    }

    // MARK: Bootstrap

    func bootstrap() async {
        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            async let overviewTask = api.worldOverview()
            async let assetsTask = api.assets(pageSize: 100)
            async let changesTask = api.changes(pageSize: 100)
            async let inspectionsTask = api.inspections(pageSize: 100)
            async let anomaliesTask = api.anomalies(pageSize: 100)
            async let maintenanceTask = api.maintenance(pageSize: 100)
            async let workOrdersTask = api.workOrders(pageSize: 100)
            async let reportsTask = api.reports(pageSize: 100)
            async let notificationsTask = api.notifications()
            async let alertsTask = api.alerts()
            async let insightsTask = api.insights()
            async let profileTask = api.profile()
            async let organizationTask = api.organization()
            async let integrationsTask = api.integrations()
            async let preferencesTask = api.preferences()

            let overview = try await overviewTask
            let assetsPage = try await assetsTask
            let changesPage = try await changesTask
            let inspectionsPage = try await inspectionsTask
            let anomaliesPage = try await anomaliesTask
            let maintenancePage = try await maintenanceTask
            let workOrdersPage = try await workOrdersTask
            let reportsPage = try await reportsTask
            let notifications = try await notificationsTask
            let alerts = try await alertsTask
            let insights = try await insightsTask
            let profile = try await profileTask
            let organization = try await organizationTask
            let integrations = try await integrationsTask
            let preferences = try await preferencesTask

            self.worldOverview = overview
            self.assets = assetsPage.items
            self.changes = changesPage.items
            self.inspections = inspectionsPage.items
            self.anomalies = anomaliesPage.items
            self.maintenance = maintenancePage.items
            self.workOrders = workOrdersPage.items
            self.reports = reportsPage.items
            self.notifications = notifications
            self.alerts = alerts
            self.insights = insights
            self.profile = profile
            self.user = profile.user
            self.organization = organization
            self.integrations = integrations
            self.preferences = preferences
            self.lastSuccessfulRefresh = Date()

            await registerCurrentDevice()
            await loadOrganizationDetails()
            await loadSecurityDetails()
            await flushOfflineQueueIfPossible()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshWorld() async {
        do {
            async let overviewTask = api.worldOverview()
            async let assetsTask = api.assets(pageSize: 100)
            async let changesTask = api.changes(pageSize: 100)
            let (overview, assetsPage, changesPage) = try await (overviewTask, assetsTask, changesTask)
            worldOverview = overview
            assets = assetsPage.items
            changes = changesPage.items
            lastSuccessfulRefresh = Date()
        } catch { errorMessage = error.localizedDescription }
    }

    // MARK: Selection / Details

    func selectAsset(_ id: String) async {
        selectedAssetID = id
        selectedAssetDetail = nil
        selectedDigitalTwin = nil
        assetStates = []
        do {
            async let detailTask = api.assetDetail(id)
            async let statesTask = api.worldStates(assetId: id)
            selectedAssetDetail = try await detailTask
            assetStates = try await statesTask
        } catch { errorMessage = error.localizedDescription }
    }

    func loadDigitalTwin() async {
        guard let id = selectedAssetID else { return }
        do { selectedDigitalTwin = try await api.digitalTwin(assetId: id) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectChange(_ id: String) async {
        selectedChangeID = id
        do { selectedChange = try await api.change(id) }
        catch { errorMessage = error.localizedDescription }
    }

    func loadComparison(assetId: String? = nil, stateA: String? = nil, stateB: String? = nil) async {
        guard let id = assetId ?? selectedAssetID ?? selectedChange?.assetId else { return }
        do { selectedComparison = try await api.compare(assetId: id, stateA: stateA, stateB: stateB) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectInspection(_ id: String) async {
        selectedInspectionID = id
        do { selectedInspection = try await api.inspection(id) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectAnomaly(_ id: String) async {
        selectedAnomalyID = id
        do { selectedAnomaly = try await api.anomaly(id) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectMaintenance(_ id: String) async {
        selectedMaintenanceID = id
        do { selectedMaintenance = try await api.maintenanceDetail(id) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectWorkOrder(_ id: String) async {
        selectedWorkOrderID = id
        do { selectedWorkOrder = try await api.workOrder(id) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectReport(_ id: String) async {
        selectedReportID = id
        do { selectedReport = try await api.report(id) }
        catch { errorMessage = error.localizedDescription }
    }

    func selectInsight(_ id: String) async {
        selectedInsightID = id
        do { selectedInsight = try await api.insight(id) }
        catch { errorMessage = error.localizedDescription }
    }

    // MARK: Search / AI

    func search(_ text: String) async {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            searchResults = []
            return
        }
        do { searchResults = try await api.search(text) }
        catch { errorMessage = error.localizedDescription }
    }

    func askAtlas(_ question: String, assetId: String? = nil) async {
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { askResponse = try await api.askAtlas(question, assetId: assetId) }
        catch { errorMessage = error.localizedDescription }
    }

    // MARK: Create / Update flows

    func createAsset(name: String, category: String, location: String, description: String, identifier: String, tags: [String], notes: String) async -> APIAsset? {
        do {
            let asset = try await api.createAsset(name: name, category: category, description: description, identifier: identifier, location: location, tags: tags, notes: notes)
            await refreshWorld()
            return asset
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func createInspection(assetId: String, title: String, scheduledFor: Date? = nil) async -> APIInspection? {
        do {
            let inspection = try await api.createInspection(assetId: assetId, title: title, scheduledFor: scheduledFor)
            let page = try await api.inspections(pageSize: 100)
            self.inspections = page.items
            return inspection
        } catch { errorMessage = error.localizedDescription; return nil }
    }

    func completeInspectionStep(stepKey: String, notes: String = "") async {
        guard let id = selectedInspectionID else { return }
        do {
            _ = try await api.updateInspectionStep(id, stepKey: stepKey, notes: notes)
            selectedInspection = try await api.inspection(id)
        } catch { errorMessage = error.localizedDescription }
    }

    func createWorkOrder(assetId: String, title: String, description: String, priority: String) async -> APIWorkOrder? {
        do {
            let order = try await api.createWorkOrder(.init(assetId: assetId, title: title, description: description, priority: priority))
            let page = try await api.workOrders(pageSize: 100)
            workOrders = page.items
            return order
        } catch { errorMessage = error.localizedDescription; return nil }
    }

    func createWorkOrderFromSelectedAnomaly() async {
        guard let id = selectedAnomalyID else { return }
        do {
            let order = try await api.workOrderFromAnomaly(id)
            workOrders.insert(order, at: 0)
            selectedWorkOrderID = order.id
        } catch { errorMessage = error.localizedDescription }
    }

    func requestInspectionForSelectedAnomaly() async {
        guard let id = selectedAnomalyID else { return }
        do {
            let inspection = try await api.inspectionFromAnomaly(id)
            inspections.insert(inspection, at: 0)
            selectedInspectionID = inspection.id
        } catch { errorMessage = error.localizedDescription }
    }

    func markSelectedAnomalyDismissed() async {
        guard let id = selectedAnomalyID else { return }
        do {
            selectedAnomaly = try await api.updateAnomaly(id, fields: ["status": .string("dismissed")])
            let page = try await api.anomalies(pageSize: 100)
            anomalies = page.items
        } catch { errorMessage = error.localizedDescription }
    }

    func completeMaintenance(_ id: String) async {
        do {
            selectedMaintenance = try await api.updateMaintenance(id, fields: ["status": .string("completed")])
            let page = try await api.maintenance(pageSize: 100)
            maintenance = page.items
        } catch { errorMessage = error.localizedDescription }
    }

    func createReport(type: String, title: String, assetId: String? = nil, inspectionId: String? = nil, period: String = "") async -> APIReport? {
        do {
            let report = try await api.createReport(reportType: type, title: title, assetId: assetId, inspectionId: inspectionId, periodLabel: period)
            reports.insert(report, at: 0)
            return report
        } catch { errorMessage = error.localizedDescription; return nil }
    }

    func markNotificationRead(_ id: String) async {
        do {
            let updated = try await api.markNotificationRead(id)
            if let index = notifications.firstIndex(where: { $0.id == id }) { notifications[index] = updated }
        } catch { errorMessage = error.localizedDescription }
    }

    func markAllNotificationsRead() async {
        do {
            _ = try await api.markAllNotificationsRead()
            notifications = try await api.notifications()
        } catch { errorMessage = error.localizedDescription }
    }

    // MARK: Scan pipeline

    func createCapture(mode: ScanMode) async throws -> APICapture {
        let capabilities: JSONObject = [
            "camera": .bool(true),
            "vision": .bool(true),
            "arkit": .bool(true),
            "lidar": .bool(AtlasDeviceCapabilities.lidarSceneReconstructionSupported),
            "room_plan": .bool(AtlasDeviceCapabilities.roomPlanSupported),
            "device": .string(UIDevice.current.model),
            "os": .string(UIDevice.current.systemVersion)
        ]
        return try await api.createCapture(mode: mode.apiValue, deviceCapabilities: capabilities)
    }

    func uploadCaptureEvidence(captureId: String, image: UIImage) async throws -> APIEvidence {
        guard let data = image.jpegData(compressionQuality: 0.86) else { throw AtlasAPIError.transport("No se pudo convertir la captura a JPEG.") }
        return try await api.uploadEvidence(captureId: captureId, data: data)
    }

    func analyzeCapture(captureId: String, mode: ScanMode, vision: AtlasVisionResult, suggestedName: String) async throws -> APICapture {
        try await api.analyzeCapture(
            captureId,
            recognizedText: vision.recognizedText.joined(separator: "\n"),
            suggestedAssetName: suggestedName,
            suggestedCategory: mode.apiValue,
            confidence: max(Double(vision.textConfidence), mode == .auto ? 0.72 : 0.88)
        )
    }

    func commitNewAsset(captureId: String, name: String, mode: ScanMode, location: String = "") async throws -> APICaptureCommitResult {
        let payload = CreateAssetPayload(name: name, category: mode.apiValue, location: location)
        let result = try await api.commitCapture(captureId, createAsset: payload)
        await refreshWorld()
        return result
    }

    func commitToExistingAsset(captureId: String, assetId: String) async throws -> APICaptureCommitResult {
        let result = try await api.commitCapture(captureId, assetId: assetId)
        await refreshWorld()
        return result
    }


    private func registerCurrentDevice() async {
        let key = "atlas.installation.id"
        let defaults = UserDefaults.standard
        let installationID: String
        if let existing = defaults.string(forKey: key) {
            installationID = existing
        } else {
            installationID = UUID().uuidString
            defaults.set(installationID, forKey: key)
        }
        do {
            _ = try await api.registerDevice(installationId: installationID)
        } catch {
            // Device registration is non-blocking for the main product flows.
        }
    }

    // MARK: Organization / Security / Settings

    func loadOrganizationDetails() async {
        do {
            async let membersTask = api.members()
            async let workspacesTask = api.workspaces()
            members = try await membersTask
            workspaces = try await workspacesTask
            do { invitations = try await api.invitations() } catch { invitations = [] }
        } catch { errorMessage = error.localizedDescription }
    }

    func loadSecurityDetails() async {
        do {
            async let sessionsTask = api.sessions()
            async let devicesTask = api.devices()
            sessions = try await sessionsTask
            devices = try await devicesTask
        } catch { errorMessage = error.localizedDescription }
    }

    func invite(email: String, role: String) async -> Bool {
        do { invitations.append(try await api.invite(email: email, role: role)); return true }
        catch { errorMessage = error.localizedDescription; return false }
    }

    func createWorkspace(name: String) async -> Bool {
        do { workspaces.append(try await api.createWorkspace(name: name)); return true }
        catch { errorMessage = error.localizedDescription; return false }
    }

    func revokeSession(_ id: String) async {
        do { _ = try await api.revokeSession(id); sessions.removeAll { $0.id == id } }
        catch { errorMessage = error.localizedDescription }
    }

    func savePreferences(attention: Bool, updates: Bool, analytics: Bool) async {
        do { preferences = try await api.updatePreferences(attentionNotifications: attention, productUpdates: updates, analyticsEnabled: analytics) }
        catch { errorMessage = error.localizedDescription }
    }

    func updateBackendURL(_ rawValue: String) async -> Bool {
        do {
            try await api.updateBaseURL(rawValue)
            return true
        } catch { errorMessage = error.localizedDescription; return false }
    }

    func backendURLString() async -> String { await api.currentBaseURL.absoluteString }

    // MARK: Offline queue

    func enqueueOfflineOperation(entityType: String, localId: String, payload: JSONObject, operation: String = "create") {
        offlineQueue.enqueue(.init(idempotencyKey: UUID().uuidString, localId: localId, entityType: entityType, operation: operation, payload: payload))
        pendingOfflineOperations = offlineQueue.count
    }

    func flushOfflineQueueIfPossible() async {
        let operations = offlineQueue.operations
        guard !operations.isEmpty else { pendingOfflineOperations = 0; return }
        do {
            let result = try await api.sync(operations)
            let completed = Set(result.results.filter { $0.status == "synced" || $0.status == "created" }.map(\.idempotencyKey))
            offlineQueue.remove(keys: completed)
            pendingOfflineOperations = offlineQueue.count
        } catch {
            pendingOfflineOperations = offlineQueue.count
        }
    }

    func clearError() { errorMessage = nil }

    private func resetRemoteState() {
        user = nil; profile = nil; worldOverview = nil
        assets = []; changes = []; inspections = []; anomalies = []; maintenance = []; workOrders = []; reports = []
        notifications = []; alerts = []; insights = []; integrations = []; organization = nil; members = []; workspaces = []; invitations = []; sessions = []; devices = []; preferences = nil
        selectedAssetID = nil; selectedChangeID = nil; selectedInspectionID = nil; selectedAnomalyID = nil; selectedMaintenanceID = nil; selectedWorkOrderID = nil; selectedReportID = nil; selectedInsightID = nil
        selectedAssetDetail = nil; selectedDigitalTwin = nil; selectedChange = nil; selectedInspection = nil; selectedAnomaly = nil; selectedMaintenance = nil; selectedWorkOrder = nil; selectedReport = nil; selectedInsight = nil; selectedComparison = nil
        askResponse = nil; searchResults = []
    }
}

private extension ScanMode {
    var apiValue: String {
        switch self {
        case .auto: "auto"
        case .property: "property"
        case .vehicle: "vehicle"
        case .equipment: "equipment"
        case .infrastructure: "infrastructure"
        case .document: "document"
        case .other: "other"
        }
    }
}

final class AtlasOfflineQueue {
    static let shared = AtlasOfflineQueue()
    private let key = "atlas.offline.operations"
    private let defaults = UserDefaults.standard

    var operations: [APISyncOperation] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([APISyncOperation].self, from: data)) ?? []
    }

    var count: Int { operations.count }

    func enqueue(_ operation: APISyncOperation) {
        var current = operations
        current.append(operation)
        save(current)
    }

    func remove(keys: Set<String>) {
        save(operations.filter { !keys.contains($0.idempotencyKey) })
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }

    private func save(_ value: [APISyncOperation]) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) }
    }
}
