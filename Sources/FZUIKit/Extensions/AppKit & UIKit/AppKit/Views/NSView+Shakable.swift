//
//  File.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
    import AppKit

    public extension Shakable {
        func shake() {
            // From https://stackoverflow.com/a/31755773/3939277

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

#endif
