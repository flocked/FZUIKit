//
//  CAMediaTimingFunction+.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

#if canImport(QuartzCore)
    import QuartzCore

    public extension CAMediaTimingFunction {
        /// A linear timing function, which causes an animation to occur evenly over its duration.
        static var linear: CAMediaTimingFunction = .init(name: .linear)
        /// The system default timing function. Use this function to ensure that the timing of your animations matches that of most system animations.
        static var `default`: CAMediaTimingFunction = .init(name: .default)
        /// A ease-in timing function, which causes an animation to begin slowly and then speed up as it progresses.
        static var easeIn: CAMediaTimingFunction = .init(name: .easeIn)
        /// A ease-out timing function, which causes an animation to begin quickly and then slow as it progresses.
        static var easeOut: CAMediaTimingFunction = .init(name: .easeOut)
        /// A ease-in-ease-out timing function, which causes an animation to begin slowly, accelerate through the middle of its duration, and then slow again before completing.
        static var easeInEaseOut: CAMediaTimingFunction = .init(name: .easeInEaseOut)
        /// A swift out timing function, based on Google's Material Design.`
        static let swiftOut = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
    }
#endif
