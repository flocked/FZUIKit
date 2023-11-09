//
//  CAMediaTimingFunction+.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if canImport(QuartzCore)
import QuartzCore

public extension CAMediaTimingFunction {
    /// Linear pacing, which causes an animation to occur evenly over its duration.
    static var linear: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear)
    /// The system default timing function. Use this function to ensure that the timing of your animations matches that of most system animations.
    static var `default`: CAMediaTimingFunction = CAMediaTimingFunction(name: .default)
    /// Ease-in pacing, which causes an animation to begin slowly and then speed up as it progresses.
    static var easeIn: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeIn)
    /// Ease-out pacing, which causes an animation to begin quickly and then slow as it progresses.
    static var easeOut: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut)
    /// Ease-in-ease-out pacing, which causes an animation to begin slowly, accelerate through the middle of its duration, and then slow again before completing.
    static var easeInEaseOut: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    static let swiftOut   = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
}
#endif
