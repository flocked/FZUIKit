//
//  SpringInterpolatable.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation


public protocol SpringInterpolatable: Equatable {
    associatedtype ValueType: SpringInterpolatable
    associatedtype VelocityType: VelocityProviding

    var scaledIntegral: Self { get }

    static func updateValue(spring: Spring, value: ValueType, target: ValueType, velocity: VelocityType, dt: TimeInterval) -> (value: ValueType, velocity: VelocityType)
}

public protocol VelocityProviding {
    static var zero: Self { get }
}

extension CGFloat: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGFloat
    public typealias VelocityType = CGFloat

    public static func updateValue(spring: Spring, value: CGFloat, target: CGFloat, velocity: CGFloat, dt: TimeInterval) -> (value: CGFloat, velocity: CGFloat) {
        precondition(spring.response > 0, "Shouldn't be calculating spring physics with a frequency response of zero.")

        let displacement = value - target
        let springForce = (-spring.stiffness * displacement)
        let dampingForce = (spring.dampingCoefficient * velocity)
        let force = springForce - dampingForce
        let acceleration = force / spring.mass

        let newVelocity = (velocity + (acceleration * dt))
        let newValue = (value + (newVelocity * dt))

        return (value: newValue, velocity: newVelocity)
    }
}

extension CGSize: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGSize
    public typealias VelocityType = CGSize

    public static func updateValue(spring: Spring, value: CGSize, target: CGSize, velocity: CGSize, dt: TimeInterval) -> (value: CGSize, velocity: CGSize) {
        let (newValueX, newVelocityX) = CGFloat.updateValue(spring: spring, value: value.width, target: target.width, velocity: velocity.width, dt: dt)
        let (newValueY, newVelocityY) = CGFloat.updateValue(spring: spring, value: value.height, target: target.height, velocity: velocity.height, dt: dt)

        let newValue = CGSize(width: newValueX, height: newValueY)
        let newVelocity = CGSize(width: newVelocityX, height: newVelocityY)

        return (value: newValue, velocity: newVelocity)
    }
}

extension CGPoint: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGPoint
    public typealias VelocityType = CGPoint

    public static func updateValue(spring: Spring, value: CGPoint, target: CGPoint, velocity: CGPoint, dt: TimeInterval) -> (value: CGPoint, velocity: CGPoint) {
        let (newValueX, newVelocityX) = CGFloat.updateValue(spring: spring, value: value.x, target: target.x, velocity: velocity.x, dt: dt)
        let (newValueY, newVelocityY) = CGFloat.updateValue(spring: spring, value: value.y, target: target.y, velocity: velocity.y, dt: dt)

        let newValue = CGPoint(x: newValueX, y: newValueY)
        let newVelocity = CGPoint(x: newVelocityX, y: newVelocityY)

        return (value: newValue, velocity: newVelocity)
    }
}

extension CGRect: SpringInterpolatable, VelocityProviding {
    public typealias ValueType = CGRect
    public typealias VelocityType = CGRect

    public static func updateValue(spring: Spring, value: CGRect, target: CGRect, velocity: CGRect, dt: TimeInterval) -> (value: CGRect, velocity: CGRect) {
        let (origin, originVelocity) = CGPoint.updateValue(spring: spring, value: value.origin, target: target.origin, velocity: velocity.origin, dt: dt)
        let (size, sizeVelocity) = CGSize.updateValue(spring: spring, value: value.size, target: target.size, velocity: velocity.size, dt: dt)

        let newValue = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        let newVelocity = CGRect(x: originVelocity.x, y: originVelocity.y, width: sizeVelocity.width, height: sizeVelocity.height)

        return (value: newValue, velocity: newVelocity)
    }
}

extension RGBAComponents: SpringInterpolatable, VelocityProviding {

    typealias ValueType = RGBAComponents
    typealias VelocityType = RGBAComponents

    static func updateValue(spring: Spring, value: RGBAComponents, target: RGBAComponents, velocity: RGBAComponents, dt: TimeInterval) -> (value: RGBAComponents, velocity: RGBAComponents) {
        let (newR, newVelocityR) = CGFloat.updateValue(spring: spring, value: value.r, target: target.r, velocity: velocity.r, dt: dt)
        let (newG, newVelocityG) = CGFloat.updateValue(spring: spring, value: value.g, target: target.g, velocity: velocity.g, dt: dt)
        let (newB, newVelocityB) = CGFloat.updateValue(spring: spring, value: value.b, target: target.b, velocity: velocity.b, dt: dt)
        let (newA, newVelocityA) = CGFloat.updateValue(spring: spring, value: value.a, target: target.a, velocity: velocity.a, dt: dt)

        let newValue = RGBAComponents(r: newR, g: newG, b: newB, a: newA)
        let newVelocity = RGBAComponents(r: newVelocityR, g: newVelocityG, b: newVelocityB, a: newVelocityA)

        return (value: newValue, newVelocity)
    }

    var scaledIntegral: RGBAComponents {
        self
    }

    static var zero: RGBAComponents {
        RGBAComponents(r: 0, g: 0, b: 0, a: 0)
    }

}

extension HSLAComponents: SpringInterpolatable, VelocityProviding {

    typealias ValueType = HSLAComponents
    typealias VelocityType = HSLAComponents

    static func updateValue(spring: Spring, value: HSLAComponents, target: HSLAComponents, velocity: HSLAComponents, dt: TimeInterval) -> (value: HSLAComponents, velocity: HSLAComponents) {
        let (newH, newVelocityH) = CGFloat.updateValue(spring: spring, value: value.h, target: target.h, velocity: velocity.h, dt: dt)
        let (newS, newVelocityS) = CGFloat.updateValue(spring: spring, value: value.s, target: target.s, velocity: velocity.s, dt: dt)
        let (newL, newVelocityL) = CGFloat.updateValue(spring: spring, value: value.l, target: target.l, velocity: velocity.l, dt: dt)
        let (newA, newVelocityA) = CGFloat.updateValue(spring: spring, value: value.a, target: target.a, velocity: velocity.a, dt: dt)

        let newValue = HSLAComponents(h: newH, s: newS, l: newL, a: newA)
        let newVelocity = HSLAComponents(h: newVelocityH, s: newVelocityS, l: newVelocityL, a: newVelocityA)

        return (value: newValue, newVelocity)
    }

    var scaledIntegral: HSLAComponents {
        self
    }

    static var zero: HSLAComponents {
        HSLAComponents(h: 0, s: 0, l: 0, a: 0)
    }

}

extension CGAffineTransform: SpringInterpolatable, VelocityProviding {

    public typealias ValueType = CGAffineTransform
    public typealias VelocityType = CGAffineTransform

    public static func updateValue(spring: Spring, value: CGAffineTransform, target: CGAffineTransform, velocity: CGAffineTransform, dt: TimeInterval) -> (value: CGAffineTransform, velocity: CGAffineTransform) {
                
        let (newA, newVelocityA) = CGFloat.updateValue(spring: spring, value: value.a, target: target.a, velocity: velocity.a, dt: dt)
        let (newB, newVelocityB) = CGFloat.updateValue(spring: spring, value: value.b, target: target.b, velocity: velocity.b, dt: dt)
        let (newC, newVelocityC) = CGFloat.updateValue(spring: spring, value: value.c, target: target.c, velocity: velocity.c, dt: dt)
        let (newD, newVelocityD) = CGFloat.updateValue(spring: spring, value: value.d, target: target.d, velocity: velocity.d, dt: dt)
        let (newTX, newVelocityTX) = CGFloat.updateValue(spring: spring, value: value.tx, target: target.tx, velocity: velocity.tx, dt: dt)
        let (newTY, newVelocityTY) = CGFloat.updateValue(spring: spring, value: value.ty, target: target.ty, velocity: velocity.ty, dt: dt)


        let newValue = CGAffineTransform(a: newA, b: newB, c: newC, d: newD, tx: newTX, ty: newTY)
        let newVelocity = CGAffineTransform(a: newVelocityA, b: newVelocityB, c: newVelocityC, d: newVelocityD, tx: newVelocityTX, ty: newVelocityTY)

        return (value: newValue, newVelocity)
    }

    public var scaledIntegral: CGAffineTransform {
        self
    }

    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }

}

import QuartzCore
extension CATransform3D: SpringInterpolatable, VelocityProviding {
    public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        CATransform3DEqualToTransform(lhs, rhs)
    }

    public typealias ValueType = CATransform3D
    public typealias VelocityType = CATransform3D

    public static func updateValue(spring: Spring, value: CATransform3D, target: CATransform3D, velocity: CATransform3D, dt: TimeInterval) -> (value: CATransform3D, velocity: CATransform3D) {
                
        let (new11, newVelocity11) = CGFloat.updateValue(spring: spring, value: value.m11, target: target.m11, velocity: velocity.m11, dt: dt)
        let (new12, newVelocity12) = CGFloat.updateValue(spring: spring, value: value.m12, target: target.m12, velocity: velocity.m12, dt: dt)
        let (new13, newVelocity13) = CGFloat.updateValue(spring: spring, value: value.m13, target: target.m13, velocity: velocity.m13, dt: dt)
        let (new14, newVelocity14) = CGFloat.updateValue(spring: spring, value: value.m14, target: target.m14, velocity: velocity.m14, dt: dt)
        let (new21, newVelocity21) = CGFloat.updateValue(spring: spring, value: value.m21, target: target.m21, velocity: velocity.m21, dt: dt)
        let (new22, newVelocity22) = CGFloat.updateValue(spring: spring, value: value.m22, target: target.m22, velocity: velocity.m22, dt: dt)
        let (new23, newVelocity23) = CGFloat.updateValue(spring: spring, value: value.m23, target: target.m23, velocity: velocity.m23, dt: dt)
        let (new24, newVelocity24) = CGFloat.updateValue(spring: spring, value: value.m24, target: target.m24, velocity: velocity.m24, dt: dt)
        let (new31, newVelocity31) = CGFloat.updateValue(spring: spring, value: value.m31, target: target.m31, velocity: velocity.m31, dt: dt)
        let (new32, newVelocity32) = CGFloat.updateValue(spring: spring, value: value.m32, target: target.m32, velocity: velocity.m32, dt: dt)
        let (new33, newVelocity33) = CGFloat.updateValue(spring: spring, value: value.m33, target: target.m33, velocity: velocity.m33, dt: dt)
        let (new34, newVelocity34) = CGFloat.updateValue(spring: spring, value: value.m34, target: target.m34, velocity: velocity.m34, dt: dt)
        let (new41, newVelocity41) = CGFloat.updateValue(spring: spring, value: value.m41, target: target.m41, velocity: velocity.m41, dt: dt)
        let (new42, newVelocity42) = CGFloat.updateValue(spring: spring, value: value.m42, target: target.m42, velocity: velocity.m42, dt: dt)
        let (new43, newVelocity43) = CGFloat.updateValue(spring: spring, value: value.m43, target: target.m43, velocity: velocity.m43, dt: dt)
        let (new44, newVelocity44) = CGFloat.updateValue(spring: spring, value: value.m44, target: target.m44, velocity: velocity.m44, dt: dt)
        
        let newValue = CATransform3D(m11: new11, m12: new12, m13: new13, m14: new14, m21: new21, m22: new22, m23: new23, m24: new24, m31: new31, m32: new32, m33: new33, m34: new34, m41: new41, m42: new42, m43: new43, m44: new44)
        let newVelocity = CATransform3D(m11: newVelocity11, m12: newVelocity12, m13: newVelocity13, m14: newVelocity14, m21: newVelocity21, m22: newVelocity22, m23: newVelocity23, m24: newVelocity24, m31: newVelocity31, m32: newVelocity32, m33: newVelocity33, m34: newVelocity34, m41: newVelocity41, m42: newVelocity42, m43: newVelocity43, m44: newVelocity44)

        return (value: newValue, newVelocity)
    }

    public var scaledIntegral: CATransform3D {
        self
    }
}

#endif
