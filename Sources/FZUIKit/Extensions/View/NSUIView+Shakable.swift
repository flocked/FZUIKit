//
//  NSUIView+Shakable.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
    import AppKit

    extension NSView {
        /**
         Shakes the view.

         - Parameters:
            - numberOfShakes: The number of shakes. The default value is `4`.
            - durationOfShake: The duration of each shake. The default value is `0.5`.
            - vigourOfShake: The vigour of each shake. The default value is `0.02`.
         */
        public func shake(numberOfShakes: Int = 4, durationOfShake: TimeInterval = 0.5, vigourOfShake: CGFloat = 0.02) {
            let shakeAnimation = shakeAnimation(numberOfShakes: numberOfShakes, durationOfShake: durationOfShake, vigourOfShake: vigourOfShake, frame: frame)
            animations = ["frameOrigin": shakeAnimation]
            animator().setFrameOrigin(frame.origin)
        }
    }

    extension NSWindow {
        /**
         Shakes the window.

         - Parameters:
            - numberOfShakes: The number of shakes. The default value is `4`.
            - durationOfShake: The duration of each shake. The default value is `0.5`.
            - vigourOfShake: The vigour of each shake. The default value is `0.02`.
         */
        public func shake(numberOfShakes: Int = 4, durationOfShake: TimeInterval = 0.5, vigourOfShake: CGFloat = 0.02) {
            let shakeAnimation = shakeAnimation(numberOfShakes: numberOfShakes, durationOfShake: durationOfShake, vigourOfShake: vigourOfShake, frame: frame)
            animations = ["frameOrigin": shakeAnimation]
            animator().setFrameOrigin(frame.origin)
        }
    }

    private func shakeAnimation(numberOfShakes: Int = 4, durationOfShake: TimeInterval = 0.5, vigourOfShake: CGFloat = 0.02, frame: CGRect) -> CAKeyframeAnimation {
        let shakeAnimation = CAKeyframeAnimation()

        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x: frame.minX, y: frame.minY))

        for _ in 1 ... numberOfShakes {
            shakePath.addLine(to: CGPoint(x: frame.minX - frame.size.width * vigourOfShake,
                                          y: frame.minY))
            shakePath.addLine(to: CGPoint(x: frame.minX + frame.size.width * vigourOfShake,
                                          y: frame.minY))
        }

        shakePath.closeSubpath()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = CFTimeInterval(durationOfShake)
        return shakeAnimation
    }

#elseif os(iOS) || os(tvOS)
    import UIKit

    public extension UIView {
        /// Shakes the view.
        func shake() {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.duration = 0.6
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
            layer.add(animation, forKey: "shake")
        }
    }
#endif
