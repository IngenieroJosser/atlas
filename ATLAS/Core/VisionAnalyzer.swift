import UIKit
import Vision

struct AtlasVisionResult: Equatable {
    let recognizedText: [String]
    let textConfidence: Float
}

enum AtlasVisionAnalyzer {
    static func analyze(image: UIImage) async -> AtlasVisionResult {
        guard let cgImage = image.cgImage else {
            return AtlasVisionResult(recognizedText: [], textConfidence: 0)
        }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let candidates = observations.compactMap { $0.topCandidates(1).first }
                let strings = candidates.map(\.string)
                let confidence = candidates.isEmpty
                    ? 0
                    : candidates.map(\.confidence).reduce(0, +) / Float(candidates.count)
                continuation.resume(returning: AtlasVisionResult(recognizedText: strings, textConfidence: confidence))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: AtlasVisionResult(recognizedText: [], textConfidence: 0))
                }
            }
        }
    }
}
