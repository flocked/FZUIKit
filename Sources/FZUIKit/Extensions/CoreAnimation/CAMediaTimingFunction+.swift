//
//  CAMediaTimingFunction+.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import QuartzCore

public extension CAMediaTimingFunction {
    /// A linear timing function, which causes an animation to occur evenly over its duration.
    static let linear = CAMediaTimingFunction(name: .linear)
    /// The system default timing function. Use this function to ensure that the timing of your animations matches that of most system animations.
    static let `default` = CAMediaTimingFunction(name: .default)
    /// A ease-in timing function, which causes an animation to begin slowly and then speed up as it progresses.
    static let easeIn = CAMediaTimingFunction(name: .easeIn)
    /// A ease-out timing function, which causes an animation to begin quickly and then slow as it progresses.
    static let easeOut = CAMediaTimingFunction(name: .easeOut)
    /// A ease-in-ease-out timing function, which causes an animation to begin slowly, accelerate through the middle of its duration, and then slow again before completing.
    static let easeInEaseOut = CAMediaTimingFunction(name: .easeInEaseOut)
    /// A swift out timing function, based on Google's Material Design.`
    static let swiftOut = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        
    /// The control points.
    var controlPoints: (first: CGPoint, second: CGPoint) {
        var rawValues: [Float] = [0.0, 0.0]
        getControlPoint(at: 1, values: &rawValues)
        let first = CGPoint(x: CGFloat(rawValues[0]), y: CGFloat(rawValues[1]))
        getControlPoint(at: 2, values: &rawValues)
        let second = CGPoint(x: CGFloat(rawValues[0]), y: CGFloat(rawValues[1]))
        return (first, second)
    }
    
    /**
     Returns the y-value (progress) for a given fraction of time (x).

     - Parameters:
        - fractionComplete: The input progress (0...1).
        - epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
     - Returns: The eased progress (y).
     */
    func solve(at fractionComplete: Double, epsilon: Double = 0.0001) -> Double {
        let cps = controlPoints
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = cps.first
        let p2 = cps.second
        let p3 = CGPoint(x: 1, y: 1)
        var t = fractionComplete
        for _ in 0..<8 { // iteration cap
            let x = cubicBezier(t, p0.x, p1.x, p2.x, p3.x)
            let dx = cubicBezierDerivative(t, p0.x, p1.x, p2.x, p3.x)
            let error = x - fractionComplete
            if abs(error) < epsilon { break }
            if dx != 0 { t -= error / dx }
        }
        return cubicBezier(t, p0.y, p1.y, p2.y, p3.y)
    }

    /**
     Returns the velocity (dy/dx) at a given fraction of time (x).
     
     - Parameters:
        - fractionComplete: The input progress (0...1).
        - epsilon: The accuracy of the Newton–Raphson solver.
     - Returns: The velocity at the given fraction.
     */
    func velocity(at fractionComplete: Double, epsilon: Double = 0.0001) -> Double {
        let cps = controlPoints
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = cps.first
        let p2 = cps.second
        let p3 = CGPoint(x: 1, y: 1)
        var t = fractionComplete
        for _ in 0..<8 {
            let x = cubicBezier(t, p0.x, p1.x, p2.x, p3.x)
            let dx = cubicBezierDerivative(t, p0.x, p1.x, p2.x, p3.x)
            let error = x - fractionComplete
            if abs(error) < epsilon { break }
            if dx != 0 { t -= error / dx }
        }
        let dy = cubicBezierDerivative(t, p0.y, p1.y, p2.y, p3.y)
        let dx = cubicBezierDerivative(t, p0.x, p1.x, p2.x, p3.x)
        return dx == 0 ? 0 : dy / dx
    }
    
    fileprivate func cubicBezier(_ t: Double, _ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> Double {
        let t1 = 1 - t
        return Double(t1 * t1 * t1) * Double(a) + Double(3 * t1 * t1 * t) * Double(b) + Double(3 * t1 * t * t) * Double(c) + Double(t * t * t) * Double(d)
    }

    fileprivate func cubicBezierDerivative(_ t: Double, _ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> Double {
        let t1 = 1 - t
        return Double(3 * t1 * t1) * (Double(b) - Double(a)) + Double(6 * t1 * t) * (Double(c) - Double(b)) + Double(3 * t * t) * (Double(d) - Double(c))
    }
}
#endif
