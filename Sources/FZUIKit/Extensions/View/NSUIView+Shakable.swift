//
//  NSView+Shakable.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
import AppKit

public extension Shakable {
    func shake() {
        let numberOfShakes = 4
        let durationOfShake: Float = 0.5
        let vigourOfShake: CGFloat = 0.02

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
        animations = ["frameOrigin": shakeAnimation]
        animator().setFrameOrigin(frame.origin)
    }
}

public protocol Shakable: NSAnimatablePropertyContainer {
    var frame: CGRect { get }
    func setFrameOrigin(_ newOrigin: CGPoint)
}

extension NSWindow: Shakable {}
extension NSView: Shakable {}

#elseif os(iOS) || os(tvOS)
import UIKit
public extension UIView {
    /// Shakes the view.
    func shake() {
         let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
         animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
         animation.duration = 0.6
         animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
         layer.add(animation, forKey: "shake")
     }
}
#endif
