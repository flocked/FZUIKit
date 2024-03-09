//
//  NSUIView+Shakable.swift
//
//
//  Created by Florian Zand on 03.02.23.
//


#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIView {
    /**
     Shakes the view.
     
     - Parameters:
     - numberOfShakes: The number of shakes.
     - shakeDuration: The duration of each shake.
     - vigourOfShake: The vigour of each shake.
     */
    public func shake(numberOfShakes: Int = 3, shakeDuration: TimeInterval = 0.5, vigourOfShake: CGFloat = 0.02) {
        let shakeAnimation = shakeAnimation(numberOfShakes: numberOfShakes, shakeDuration: shakeDuration, vigourOfShake: vigourOfShake, frame: frame)
        #if os(macOS)
        animations = ["frameOrigin": shakeAnimation]
        animator().frame.origin.x += 0.01
        animator().frame.origin.x -= 0.01
        #else
        layer.add(shakeAnimation, forKey: "position")
        #endif
    }
}

#if os(macOS)
extension NSWindow {
    /**
     Shakes the window.
     
     - Parameters:
     - numberOfShakes: The number of shakes. The default value is `4`.
     - shakeDuration: The duration of each shake. The default value is `0.5`.
     - vigourOfShake: The vigour of each shake. The default value is `0.02`.
     */
    public func shake(numberOfShakes: Int = 4, shakeDuration: TimeInterval = 0.5, vigourOfShake: CGFloat = 0.02) {
        let shakeAnimation = shakeAnimation(numberOfShakes: numberOfShakes, shakeDuration: shakeDuration, vigourOfShake: vigourOfShake, frame: frame)
        animations = ["frameOrigin": shakeAnimation]
        animator().setFrameOrigin(frame.origin)
    }
}
#endif

private func shakeAnimation(numberOfShakes: Int = 4, shakeDuration: TimeInterval = 0.5, vigourOfShake: CGFloat = 0.02, frame: CGRect) -> CAKeyframeAnimation {
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
    shakeAnimation.duration = CFTimeInterval(shakeDuration)
    return shakeAnimation
}

#endif
