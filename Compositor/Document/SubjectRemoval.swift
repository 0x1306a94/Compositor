import Vision
import CoreImage

nonisolated enum SubjectRemoval {
    enum Failure: LocalizedError {
        case noSubject
        var errorDescription: String? { "No foreground subject was detected in this layer. Try an image with a more distinct subject." }
    }
    static func run(_ image: CGImage) throws -> CGImage {
        let handler = VNImageRequestHandler(cgImage: image, orientation: .up)
        let request = VNGenerateForegroundInstanceMaskRequest()
        try handler.perform([request])
        guard let result = request.results?.first, !result.allInstances.isEmpty else { throw Failure.noSubject }
        let buffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        let source = CIImage(cgImage: image)
        let mask = CIImage(cvPixelBuffer: buffer)
        let output = source.applyingFilter("CIBlendWithMask", parameters: [
            kCIInputBackgroundImageKey: CIImage(color: .clear).cropped(to: source.extent),
            kCIInputMaskImageKey: mask
        ])
        return try PixelAdjust.render(output, width: image.width, height: image.height, isMask: false)
    }
}
