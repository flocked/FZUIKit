//
//  DockProgress.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

#if os(macOS)
import AppKit
import simd


/**
Fixes the vertical alignment issue of the `CATextLayer` class.
*/
final class VerticallyCenteredTextLayer: CATextLayer {
    convenience init(frame rect: CGRect, center: CGPoint) {
        self.init()
        frame = rect
        frame.center = center
        contentsScale = NSScreen.main?.backingScaleFactor ?? 2
    }

    // From https://stackoverflow.com/a/44055040/6863743
    override func draw(in context: CGContext) {
        let height = bounds.size.height
        let deltaY = ((height - fontSize) / 2 - fontSize / 10) * -1

        context.saveGState()
        context.translateBy(x: 0, y: deltaY)
        super.draw(in: context)
        context.restoreGState()
    }
}


final class ProgressCircleShapeLayer: CAShapeLayer {
    convenience init(radius: Double, center: CGPoint) {
        self.init()
        fillColor = nil
        lineCap = .round
        position = center
        strokeEnd = 0

        let cgPath = NSBezierPath.progressCircle(radius: radius, center: center).cgPath
        path = cgPath
        bounds = cgPath.boundingBox
    }

    var progress: Double {
        get { strokeEnd }
        set {
            // Multiplying by `1.02` ensures that the start and end points meet at the end. Needed because of the round line cap.
            strokeEnd = newValue * 1.02
        }
    }
}


final class ProgressSquircleShapeLayer: CAShapeLayer {
    convenience init(rect: CGRect) {
        self.init()
        fillColor = nil
        lineCap = .round
        position = .zero
        strokeEnd = 0

        let cgPath = NSBezierPath
            .squircle(rect: rect)
            .rotating(byRadians: .pi, centerPoint: rect.center)
            .reversed
            .cgPath

        path = cgPath
        bounds = cgPath.boundingBox
    }

    var progress: Double {
        get { strokeEnd }
        set {
            // Multiplying by `1.02` ensures that the start and end points meet at the end. Needed because of the round line cap.
            strokeEnd = newValue * 1.02
        }
    }
}


internal extension NSBezierPath {
    static func progressCircle(radius: Double, center: CGPoint) -> Self {
        let startAngle = 90.0
        let path = self.init()
        path.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: startAngle - 360,
            clockwise: true
        )
        return path
    }
}

/**
 Provides functions for linear interpolation and easing effects.

 These functions are useful for animations and transitions, or anywhere you want to smoothly transition between two values.
 */
 enum Easing {
     /**
     Linearly interpolates between two values.

     Also known as `lerp`.

     - Parameters:
      - start: The start value.
      - end: The end value.
      - progress: The interpolation progress as a decimal between 0.0 and 1.0.

     - Returns: The interpolated value.
     */
     static func linearInterpolation(start: Double, end: Double, progress: Double) -> Double {
         assert(0...1 ~= progress, "Progress must be between 0.0 and 1.0")
         return Double(simd_mix(Float(start), Float(end), Float(progress)))
     }

     /**
     Provides an ease-in effect.

     - Parameter progress: The progress as a decimal between 0.0 and 1.0.

     - Returns: The eased value.
     */
     static private func easeIn(progress: Double) -> Double {
         assert(0...1 ~= progress, "Progress must be between 0.0 and 1.0")
         return Double(simd_smoothstep(0.0, 1.0, Float(progress)))
     }

     /**
     Provides an ease-out effect.

     - Parameter progress: The progress as a decimal between 0.0 and 1.0.

     - Returns: The eased value.
     */
     static private func easeOut(progress: Double) -> Double {
         assert(0...1 ~= progress, "Progress must be between 0.0 and 1.0")
         return 1 - easeIn(progress: 1 - progress)
     }

     /**
     Provides an ease-in-out effect.

     - Parameter progress: The progress as a decimal between 0.0 and 1.0.

     - Returns: The eased value.
     */
     static func easeInOut(progress: Double) -> Double {
         assert(0...1 ~= progress, "Progress must be between 0.0 and 1.0")

         return linearInterpolation(
             start: easeIn(progress: progress),
             end: easeOut(progress: progress),
             progress: progress
         )
     }
 }


#endif
