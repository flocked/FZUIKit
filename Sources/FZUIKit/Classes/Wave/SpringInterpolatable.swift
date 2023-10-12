//
//  SpringInterpolatable.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation
import simd
import QuartzCore
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public protocol SpringInterpolatable: Equatable {
    associatedtype ValueType: SpringInterpolatable
    associatedtype VelocityType: VelocityProviding
    
    var scaledIntegral: Self { get }
    
    static func updateValue(spring: Spring, value: ValueType, target: ValueType, velocity: VelocityType, dt: TimeInterval) -> (value: ValueType, velocity: VelocityType)
}

public protocol VelocityProviding {
    static var zero: Self { get }
}

public extension SpringInterpolatable where Self: SIMDRepresentable {
    static func updateValue(spring: Spring, value: Self, target: Self, velocity: Self, dt: TimeInterval) -> (value: Self, velocity: Self) where Self.SIMDType.Scalar == CGFloat.NativeType {
        
        let value = value.simdRepresentation()
        let target = target.simdRepresentation()
        let velocity = velocity.simdRepresentation()
        
        let displacement = value - target
        let springForce = (-spring.stiffness * displacement)
        let dampingForce = (spring.damping * velocity)
        let force = springForce - dampingForce
        let acceleration = force / spring.mass
        
        let newVelocity = (velocity + (acceleration * dt))
        let newValue = (value + (newVelocity * dt))
        
        return (value: Self(newValue), velocity: Self(newVelocity))
    }
    
    var scaledIntegral: Self {
        self
    }
}

extension CGFloat: SpringInterpolatable, VelocityProviding { }
extension CGSize: SpringInterpolatable, VelocityProviding { }
extension CGPoint: SpringInterpolatable, VelocityProviding { }
extension CGRect: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: CGRect, target: CGRect, velocity: CGRect, dt: TimeInterval) -> (value: CGRect, velocity: CGRect) {
        let origin = CGPoint.updateValue(spring: spring, value: value.origin, target: target.origin, velocity: velocity.origin, dt: dt)
        let size = CGSize.updateValue(spring: spring, value: value.size, target: target.size, velocity: velocity.size, dt: dt)
        
        let newValue = CGRect(origin.value, size.value)
        let newVelocity = CGRect(origin.velocity, size.velocity)
        
        return (newValue, newVelocity)
    }
}

extension NSUIColor: SpringInterpolatable, VelocityProviding {
    public static var zero: Self {
        NSUIColor(red: 0, green: 0, blue: 0, alpha: 0) as! Self
    }
}

extension CGQuaternion: SpringInterpolatable, VelocityProviding { }

extension CATransform3D: SpringInterpolatable, VelocityProviding { }
extension CGAffineTransform: SpringInterpolatable, VelocityProviding {
    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension Float: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: Float, target: Float, velocity: Float, dt: TimeInterval) -> (value: Float, velocity: Float) {
        let values = CGFloat.updateValue(spring: spring, value: CGFloat(value), target: CGFloat(target), velocity: CGFloat(velocity), dt: dt)
        return (Float(values.value), Float(values.velocity))
    }
}

#endif
