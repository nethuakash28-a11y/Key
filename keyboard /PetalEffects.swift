import UIKit

final class PetalEffects {
    private let symbols = ["🌹", "🌸", "💗", "🌷"]
    private lazy var images: [CGImage] = symbols.compactMap { Self.render($0) }

    private static func render(_ s: String) -> CGImage? {
        let size = CGSize(width: 28, height: 28)
        let r = UIGraphicsImageRenderer(size: size)
        return r.image { _ in
            (s as NSString).draw(at: .zero, withAttributes: [.font: UIFont.systemFont(ofSize: 22)])
        }.cgImage
    }

    /// Key eka touch karapu thanin rose/petal burst ekak
    func burst(in view: UIView, at point: CGPoint) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = point
        emitter.emitterShape = .point
        emitter.renderMode = .oldestFirst
        emitter.zPosition = 100

        emitter.emitterCells = images.map { img in
            let c = CAEmitterCell()
            c.contents = img
            c.birthRate = 14
            c.lifetime = 1.3
            c.velocity = 70
            c.velocityRange = 40
            c.emissionLongitude = -.pi / 2
            c.emissionRange = .pi / 1.4
            c.yAcceleration = 90          // petals slowly fall down
            c.spin = 1.5
            c.spinRange = 3
            c.scale = 0.55
            c.scaleRange = 0.35
            c.scaleSpeed = -0.2
            c.alphaSpeed = -0.7
            return c
        }
        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { emitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { emitter.removeFromSuperlayer() }
    }
}
