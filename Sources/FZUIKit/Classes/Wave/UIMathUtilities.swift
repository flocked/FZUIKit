//
//  UIMathUtilities.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

import Foundation

public func rubberband(value: CGFloat, range: ClosedRange<CGFloat>, interval: CGFloat, c: CGFloat = 0.55) -> CGFloat {
    // * x = distance from the edge
    // * c = constant value, UIScrollView uses 0.55
    // * d = dimension, either width or height
    // b = (1.0 – (1.0 / ((x * c / d) + 1.0))) * d
    if range.contains(value) {
        return value
    }

    let d: CGFloat = interval

    if value > range.upperBound {
        let x = value - range.upperBound
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        return range.upperBound + b
    } else {
        let x = range.lowerBound - value
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        return range.lowerBound - b
    }
}

/// Projects a scalar value based on a scalar velocity.
public func project(value: CGFloat, velocity: CGFloat, decelerationRate: CGFloat = 0.998) -> CGFloat {
    value + project(initialVelocity: velocity, decelerationRate: decelerationRate)
}

/// Projects a 2D point based on a 2D velocity.
public func project(point: CGPoint, velocity: CGPoint, decelerationRate: CGFloat = 0.998) -> CGPoint {
    CGPoint(
        x: point.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
        y: point.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
    )
}

func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
    (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
}

public func initialAnimationVelocity(for gestureVelocity: CGPoint, from currentPosition: CGPoint, to finalPosition: CGPoint) -> CGVector {
    var animationVelocity = CGVector.zero
    let xDistance = finalPosition.x - currentPosition.x
    let yDistance = finalPosition.y - currentPosition.y
    if xDistance != 0 {
        animationVelocity.dx = gestureVelocity.x / xDistance
    }
    if yDistance != 0 {
        animationVelocity.dy = gestureVelocity.y / yDistance
    }
    return animationVelocity
}
