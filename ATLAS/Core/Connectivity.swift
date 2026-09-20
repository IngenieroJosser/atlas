import Combine
import Network
import Foundation

final class AtlasConnectivityMonitor: ObservableObject {
    static let shared = AtlasConnectivityMonitor()

    @Published private(set) var isConnected = true
    @Published private(set) var usesWiFi = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.zyra.atlas.network")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.usesWiFi = path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: queue)
    }
}
