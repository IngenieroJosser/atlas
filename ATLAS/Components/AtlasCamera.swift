import AVFoundation
import Combine
import SwiftUI
import UIKit

enum AtlasCameraState: Equatable {
    case idle
    case requesting
    case ready
    case denied
    case unavailable
    case failed
}

final class AtlasCameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published private(set) var state: AtlasCameraState = .idle
    @Published private(set) var captureCount = 0
    @Published private(set) var lastPhoto: UIImage?
    @Published var flashEnabled = false

    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.zyra.atlas.camera.session")
    private var configured = false

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            DispatchQueue.main.async { self.state = .requesting }
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                granted ? self.configureAndStart() : DispatchQueue.main.async { self.state = .denied }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { self.state = .denied }
        @unknown default:
            DispatchQueue.main.async { self.state = .failed }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func capturePhoto() {
        guard state == .ready else { return }
        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(flashEnabled ? .on : .off) {
            settings.flashMode = flashEnabled ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if !self.configured {
                guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    DispatchQueue.main.async { self.state = .unavailable }
                    return
                }

                do {
                    let input = try AVCaptureDeviceInput(device: camera)
                    self.session.beginConfiguration()
                    self.session.sessionPreset = .photo

                    guard self.session.canAddInput(input), self.session.canAddOutput(self.photoOutput) else {
                        self.session.commitConfiguration()
                        DispatchQueue.main.async { self.state = .failed }
                        return
                    }

                    self.session.addInput(input)
                    self.session.addOutput(self.photoOutput)
                    self.session.commitConfiguration()
                    self.configured = true
                } catch {
                    DispatchQueue.main.async { self.state = .failed }
                    return
                }
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }

            DispatchQueue.main.async { self.state = .ready }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }

        DispatchQueue.main.async {
            self.lastPhoto = image
            self.captureCount += 1
        }
    }
}

struct AtlasCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> AtlasCameraPreviewView {
        let view = AtlasCameraPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: AtlasCameraPreviewView, context: Context) {
        uiView.previewLayer.session = session
    }
}

final class AtlasCameraPreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
