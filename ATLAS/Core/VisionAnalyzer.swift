import UIKit
@preconcurrency import Vision

struct AtlasVisionResult: Equatable, Sendable {
    let recognizedText: [String]
    let textConfidence: Float
}

enum AtlasVisionAnalyzer {
    static func analyze(image: UIImage) async -> AtlasVisionResult {
        guard let cgImage = image.cgImage else {
            return .empty
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest { request, _ in
                    let observations = request.results as? [VNRecognizedTextObservation] ?? []
                    let candidates = observations.compactMap { $0.topCandidates(1).first }
                    let strings = candidates.map(\.string)
                    let confidence: Float

                    if candidates.isEmpty {
                        confidence = 0
                    } else {
                        confidence = candidates.map(\.confidence).reduce(0, +) / Float(candidates.count)
                    }

                    continuation.resume(
                        returning: AtlasVisionResult(
                            recognizedText: strings,
                            textConfidence: confidence
                        )
                    )
                }

                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true

                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: .empty)
                }
            }
        }
    }
}

private extension AtlasVisionResult {
    static let empty = AtlasVisionResult(recognizedText: [], textConfidence: 0)
}
