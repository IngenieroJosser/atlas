import ARKit
import RoomPlan

struct AtlasDeviceCapabilities {
    static var roomPlanSupported: Bool {
        RoomCaptureSession.isSupported
    }

    static var lidarSceneReconstructionSupported: Bool {
        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    static var worldTrackingSupported: Bool {
        ARWorldTrackingConfiguration.isSupported
    }
}
