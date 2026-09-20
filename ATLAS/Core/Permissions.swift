import AVFoundation
import Combine
import CoreLocation
import CoreMotion
import Photos
import SwiftUI
import UIKit
import UserNotifications

enum AtlasPermissionStatus: String {
    case allowed = "Permitido"
    case notDetermined = "Sin solicitar"
    case denied = "Bloqueado"
    case restricted = "Restringido"

    var color: Color {
        switch self {
        case .allowed: return AtlasColor.healthy
        case .notDetermined: return AtlasColor.attention
        case .denied, .restricted: return AtlasColor.critical
        }
    }
}

final class AtlasPermissionCenter: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = AtlasPermissionCenter()

    @Published var camera: AtlasPermissionStatus = .notDetermined
    @Published var photos: AtlasPermissionStatus = .notDetermined
    @Published var location: AtlasPermissionStatus = .notDetermined
    @Published var microphone: AtlasPermissionStatus = .notDetermined
    @Published var motion: AtlasPermissionStatus = .notDetermined
    @Published var notifications: AtlasPermissionStatus = .notDetermined

    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()

    override private init() {
        super.init()
        locationManager.delegate = self
        refresh()
    }

    func refresh() {
        camera = mapAV(AVCaptureDevice.authorizationStatus(for: .video))
        microphone = mapAV(AVCaptureDevice.authorizationStatus(for: .audio))
        photos = mapPhoto(PHPhotoLibrary.authorizationStatus(for: .readWrite))
        location = mapLocation(locationManager.authorizationStatus)
        motion = mapMotion(CMMotionActivityManager.authorizationStatus())
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notifications = self?.mapNotification(settings.authorizationStatus) ?? .notDetermined
            }
        }
    }

    func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
            DispatchQueue.main.async { self?.refresh() }
        }
    }

    func requestPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
            DispatchQueue.main.async { self?.refresh() }
        }
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestMicrophone() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] _ in
            DispatchQueue.main.async { self?.refresh() }
        }
    }

    func requestMotion() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            motion = .restricted
            return
        }
        motionManager.startActivityUpdates(to: .main) { [weak self] _ in
            self?.motionManager.stopActivityUpdates()
            self?.refresh()
        }
    }

    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.refresh() }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        location = mapLocation(manager.authorizationStatus)
    }

    private func mapAV(_ status: AVAuthorizationStatus) -> AtlasPermissionStatus {
        switch status {
        case .authorized: return .allowed
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .restricted
        }
    }

    private func mapPhoto(_ status: PHAuthorizationStatus) -> AtlasPermissionStatus {
        switch status {
        case .authorized, .limited: return .allowed
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .restricted
        }
    }

    private func mapLocation(_ status: CLAuthorizationStatus) -> AtlasPermissionStatus {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: return .allowed
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .restricted
        }
    }

    private func mapMotion(_ status: CMAuthorizationStatus) -> AtlasPermissionStatus {
        switch status {
        case .authorized: return .allowed
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .restricted
        }
    }

    private func mapNotification(_ status: UNAuthorizationStatus) -> AtlasPermissionStatus {
        switch status {
        case .authorized, .provisional, .ephemeral: return .allowed
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        @unknown default: return .restricted
        }
    }
}
