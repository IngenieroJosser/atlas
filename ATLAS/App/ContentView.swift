import SwiftUI

struct AtlasRootView: View {
    @AppStorage("atlas.didOnboard") private var didOnboard = false
    @AppStorage("atlas.authenticated") private var authenticated = false
    @State private var splashFinished = false

    var body: some View {
        Group {
            if !splashFinished {
                SplashScreen()
                    .transition(.opacity)
            } else if !didOnboard {
                OnboardingScreen {
                    didOnboard = true
                }
            } else if !authenticated {
                LoginScreen(
                    continueAction: { authenticated = true },
                    createAction: { authenticated = true }
                )
            } else {
                ContentView()
            }
        }
        .animation(.easeOut(duration: 0.24), value: splashFinished)
        .task {
            try? await Task.sleep(for: .milliseconds(900))
            splashFinished = true
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AtlasTab = .world
    @State private var path: [AtlasRoute] = []
    @State private var activeSheet: AtlasSheet?

    var body: some View {
        NavigationStack(path: $path) {
            AtlasPage {
                Group {
                    switch selectedTab {
                    case .world:
                        WorldScreen(open: open, startScan: startScan)
                    case .assets:
                        AssetsScreen(open: open, startScan: startScan)
                    case .changes:
                        ChangesScreen(open: open)
                    case .profile:
                        ProfileScreen(open: open)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomNavigation(selectedTab: $selectedTab, startScan: startScan)
            }
            .navigationDestination(for: AtlasRoute.self) { route in
                routeView(route)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .scan:
                ScanFlowView()
            }
        }
    }

    private func open(_ route: AtlasRoute) {
        path.append(route)
    }

    private func startScan() {
        activeSheet = .scan
    }

    @ViewBuilder
    private func routeView(_ route: AtlasRoute) -> some View {
        switch route {
        case .search: SearchScreen(open: open)
        case .filters: FiltersScreen()
        case .notifications: NotificationsScreen(open: open)
        case .alerts: AlertsScreen(open: open)
        case .reports: ReportsScreen(open: open)
        case .reportDetail: ReportDetailScreen()
        case .assetDetail: AssetDetailScreen(open: open, startScan: startScan)
        case .addAsset: CreateAssetScreen()
        case .digitalTwin: DigitalTwinScreen()
        case .inspections: InspectionsScreen(open: open)
        case .newInspection: NewInspectionScreen(open: open)
        case .inspectionResult: InspectionResultScreen(open: open)
        case .changeDetail: ChangeDetailScreen(open: open)
        case .compare: CompareScreen()
        case .anomalyDetail: AnomalyDetailScreen(open: open)
        case .maintenance: MaintenanceScreen(open: open)
        case .maintenanceDetail: MaintenanceDetailScreen(open: open)
        case .workOrders: WorkOrdersScreen(open: open)
        case .createWorkOrder: CreateWorkOrderScreen()
        case .workOrderDetail: WorkOrderDetailScreen(open: open)
        case .askAtlas: AskAtlasScreen(open: open)
        case .atlasInsight: AtlasInsightScreen(open: open)
        case .organization: OrganizationScreen()
        case .integrations: IntegrationsScreen()
        case .security: SecurityScreen()
        case .privacy: PrivacyScreen()
        case .permissions: DevicePermissionsScreen()
        case .help: HelpScreen()
        case .settings: SettingsScreen(open: open)
        case .about: AboutScreen()
        }
    }
}

#Preview {
    ContentView()
}
