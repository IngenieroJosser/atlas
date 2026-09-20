import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AtlasTab = .world
    @State private var path: [AtlasRoute] = []
    @State private var activeSheet: AtlasSheet?

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                AtlasBackdrop()

                Group {
                    switch selectedTab {
                    case .world:
                        WorldScreen(
                            open: { path.append($0) },
                            startScan: { activeSheet = .scan }
                        )
                    case .assets:
                        AssetsScreen(open: { path.append($0) })
                    case .changes:
                        ChangesScreen(open: { path.append($0) })
                    case .profile:
                        ProfileScreen(open: { path.append($0) })
                    }
                }
                .padding(.bottom, 94)

                AtlasDock(selectedTab: $selectedTab) {
                    activeSheet = .scan
                }
            }
            .navigationDestination(for: AtlasRoute.self) { route in
                routeView(route)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .scan:
                ScanFlowView()
            }
        }
    }

    @ViewBuilder
    private func routeView(_ route: AtlasRoute) -> some View {
        switch route {
        case .search:
            SearchScreen()
        case .notifications:
            NotificationsScreen()
        case .alerts:
            AlertsScreen(open: { path.append($0) })
        case .reports:
            ReportsScreen(open: { path.append($0) })
        case .reportDetail:
            ReportDetailScreen(open: { path.append($0) })
        case .reportExport:
            ReportExportScreen()
        case .assetDetail:
            AssetDetailScreen(open: { path.append($0) })
        case .addAsset:
            AddAssetScreen()
        case .editAsset:
            EditAssetScreen()
        case .spatialMap:
            SpatialMapScreen()
        case .digitalTwin:
            DigitalTwinScreen()
        case .inspections:
            InspectionsScreen(open: { path.append($0) })
        case .inspectionDetail:
            InspectionDetailScreen(open: { path.append($0) })
        case .findings:
            FindingsScreen(open: { path.append($0) })
        case .findingDetail:
            FindingDetailScreen()
        case .evidence:
            EvidenceScreen()
        case .maintenance:
            MaintenanceScreen(open: { path.append($0) })
        case .workOrderDetail:
            WorkOrderDetailScreen()
        case .askAtlas:
            AskAtlasScreen()
        case .aiHistory:
            AIHistoryScreen()
        case .compare:
            CompareScreen()
        case .activityLog:
            ActivityLogScreen()
        case .settings:
            SettingsScreen(open: { path.append($0) })
        case .account:
            AccountScreen()
        case .organization:
            OrganizationScreen()
        case .team:
            TeamScreen()
        case .subscription:
            SubscriptionScreen()
        case .integrations:
            IntegrationsScreen()
        case .security:
            SecurityScreen()
        case .syncStorage:
            SyncStorageScreen()
        case .permissions:
            PermissionsScreen()
        case .privacy:
            PrivacyScreen()
        case .help:
            HelpScreen()
        case .about:
            AboutScreen()
        case .onboarding:
            OnboardingPreviewScreen()
        case .login:
            LoginPreviewScreen(open: { path.append($0) })
        case .forgotPassword:
            ForgotPasswordScreen()
        case .verification:
            VerificationScreen()
        case .createAccount:
            CreateAccountPreviewScreen(open: { path.append($0) })
        case .screenMap:
            ScreenMapScreen(open: { path.append($0) })
        }
    }
}

#Preview {
    ContentView()
}
