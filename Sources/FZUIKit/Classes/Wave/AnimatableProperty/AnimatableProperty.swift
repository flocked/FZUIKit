//
//  AnimatableData.swift
//
//
//  Created by Florian Zand on 12.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI
import FZSwiftUtils


/**
 A type that describes an animatable value.
 
 `Double`, `Float`, `CGFloat`, `CGPoint`, `CGSize`, `CGRect`, `CGColor`, `CATransform3D`, `CGAffineTransform`, `NSUIColor`, `NSUIEdgeInsets` `NSDirectionalEdgeInsets` and `CGQuaternion` conform to `AnimatableProperty`.
 
 An array of `AnimatableProperty` also conforms to it.
 
 ``AnimatableArray`` containing `VectorArithmetic` elements can be used as animatable data. ``AnimatableVector``is a animatable array with double values.
 
 Example:
 ```swift
 public struct SomeStruct {
    let value1: Double
    let value2: Double
 }
 
 extension SomeStruct: AnimatableProperty {
    public var animatableData: AnimatableVector {
        [value1, value2]
    }
 
    public init(_ animatableData: AnimatableVector) {
        self.value1 = animatableData[0]
        self.value1 = animatableData[1]
    }
 
    public static var zero: Self = SomeStruct(value1: 0, value2: 0)
 }
 ```
 */
public protocol AnimatableProperty: Equatable {
    /// The type defining the animatable representation of the value.
    associatedtype AnimatableData: VectorArithmetic = Self
    /// The animatable representation of the value.
    var animatableData: AnimatableData { get }
    /// Initializes the value with the specified animatable representation of the value.
    init(_ animatableData: AnimatableData)
    /// The scaled integral representation of the value.
    var scaledIntegral: Self { get }
    /// The zero value.
    static var zero: Self { get }
}

public extension AnimatableProperty {
    var scaledIntegral: Self {
        self
    }
}

extension AnimatableProperty where Self.AnimatableData: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.animatableData < rhs.animatableData
    }
}

extension AnimatableProperty where Self.AnimatableData == Self {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension Float: AnimatableProperty { }
 
extension Double: AnimatableProperty {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGFloat: AnimatableProperty {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGPoint: AnimatableProperty {
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(animatableData.first, animatableData.second)
    }
}

extension CGSize: AnimatableProperty {
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(animatableData.first, animatableData.second)
    }
}

extension CGRect: AnimatableProperty {
    public init(_ animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData>) {
        self.init(CGPoint(animatableData.first), CGSize(animatableData.second))
    }
}

extension CATransform3D: AnimatableProperty {
    public init(_ animatableData: AnimatableVector) {
        self.init(m11: animatableData[0], m12: animatableData[1], m13: animatableData[2], m14: animatableData[3], m21: animatableData[4], m22: animatableData[5], m23: animatableData[6], m24: animatableData[7], m31: animatableData[8], m32: animatableData[9], m33: animatableData[10], m34: animatableData[11], m41: animatableData[12], m42: animatableData[13], m43: animatableData[14], m44: animatableData[15])
    }
    
    public var animatableData: AnimatableVector {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}

extension AnimatableProperty where Self: NSUIColor {
    public init(_ animatableData: AnimatableVector) {
        self.init(deviceRed: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
    }
}

extension NSUIColor: AnimatableProperty {
    public var animatableData: AnimatableVector {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension AnimatableProperty where Self: CGColor {
    public init(_ animatableData: AnimatableVector) {
        self = NSUIColor(animatableData).cgColor as! Self
    }
}

extension CGColor: AnimatableProperty {
    public var animatableData: AnimatableVector {
        self.nsUIColor?.animatableData ?? [0,0,0,0]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension CGAffineTransform: AnimatableProperty {
    @inlinable public init(_ animatableData: AnimatableVector) {
        self.init(animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4], animatableData[5])
    }
    
    public var animatableData: AnimatableVector {
        return [a, b, c, d, tx, ty, 0, 0]
    }
    
    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension CGQuaternion: AnimatableProperty {
    public init(_ animatableData: AnimatableVector) {
        self.storage = .init(ix: animatableData[0], iy: animatableData[1], iz: animatableData[2], r: animatableData[3])
    }
    
    public var animatableData: AnimatableVector {
        [self.storage.vector[0], self.storage.vector[1], self.storage.vector[2], self.storage.vector[3]]
    }
    
    public static var zero: CGQuaternion {
        CGQuaternion.init(degree: 0, axis: .init(0, 0, 0))
    }
}

extension NSDirectionalEdgeInsets: AnimatableProperty {
    public init(_ animatableData: AnimatableVector) {
        self.init(top: animatableData[0], leading: animatableData[1], bottom: animatableData[2], trailing: animatableData[3])
    }
    
    public var animatableData: AnimatableVector {
        [top, bottom, leading, trailing]
    }
}

extension NSUIEdgeInsets: AnimatableProperty {
    public var animatableData: AnimatableVector {
        [top, self.left, bottom, self.right]
    }
    
    public init(_ animatableData: AnimatableVector) {
        self.init(top: animatableData[0], left: animatableData[1], bottom: animatableData[2], right: animatableData[3])
    }
}

extension Array: AnimatableProperty, AnimatableArrayType where Element: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Element.AnimatableData>) {
        self.init(animatableData.elements.compactMap({Element($0)}))
    }
    
    public var animatableData: AnimatableArray<Element.AnimatableData> {
        AnimatableArray<Element.AnimatableData>(self.compactMap({$0.animatableData}))
    }
    
    public static var zero: Array<Element> {
        Self.init()
    }
    
    internal mutating func appendZeroValues(amount: Int) {
        self.append(contentsOf: Array(repeating: .zero, count: amount))
    }
}

internal protocol AnimatableArrayType {
    var count: Int { get }
    mutating func appendZeroValues(amount: Int)
}

extension CGVector: AnimatableProperty {
    public var animatableData: AnimatableVector {
        [dx, dy]
    }
    
    public init(_ animatableData: AnimatableVector) {
        self.init(dx: animatableData[0], dy: animatableData[1])
    }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
extension SwiftUI.Spring {
    /**
     Updates the current value and velocity of a spring.
     
     - Parameters:
        - value: The current value of the spring.
        - velocity: The current velocity of the spring.
        - target: The target that value is moving towards.
        - deltaTime: The amount of time that has passed since the spring was at the position specified by value.
     */
    public func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V : AnimatableProperty {
        var val = value.animatableData
        var vel = velocity.animatableData
        let tar = target.animatableData
                
        self.update(value: &val, velocity: &vel, target: tar, deltaTime: deltaTime)
        value = V(val)
        velocity = V(vel)
    }
    
    /// Calculates the value of the spring at a given time for a starting and ending value for the spring to travel.
    public func value<V>(fromValue: V, toValue: V, initialVelocity: V, time: TimeInterval) -> V where V: AnimatableProperty {
        let target = fromValue.animatableData - toValue.animatableData
        let newVal = fromValue.animatableData + self.value(target: target, initialVelocity: initialVelocity.animatableData, time: time)
        return V(newVal)
        /*
        let fromValue = AnimatableProxy(fromValue)
        let toValue = AnimatableProxy(toValue)
        let initialVelocity = AnimatableProxy(initialVelocity)
        
        
        let newValue = V(self.value(fromValue: fromValue, toValue: toValue, initialVelocity: initialVelocity, time: time).animatableData)
        return newValue
         */
    }
    
    /// Calculates the velocity of the spring at a given time given a starting and ending value for the spring to travel.
    public func velocity<V>(fromValue: V, toValue: V, initialVelocity: V, time: TimeInterval) -> V where V: AnimatableProperty {
        let target = fromValue.animatableData - toValue.animatableData
        let newVel = fromValue.animatableData + self.velocity(target: target, initialVelocity: initialVelocity.animatableData, time: time)
        return V(newVel)

/*
        let fromValue = AnimatableProxy(fromValue)
        let toValue = AnimatableProxy(toValue)
        let initialVelocity = AnimatableProxy(initialVelocity)
        let newVelocity = V(self.velocity(fromValue: fromValue, toValue: toValue, initialVelocity: initialVelocity, time: time).animatableData)
        return newVelocity
 */
    }
    
    /**
     Calculates the force upon the spring given a current position, target, and velocity amount of change.
     
     This value is in units of the vector type per second squared.
     */
    public func force<V>(target: V, position: V, velocity: V) -> V where V: AnimatableProperty {
        V(force(target: target.animatableData, position: position.animatableData, velocity: velocity.animatableData))
    }
    
    /**
     Calculates the force upon the spring given a current position, velocity, and divisor from the starting and end values for the spring to travel.
     
     This value is in units of the vector type per second squared.
     */
    public func force<V>(fromValue: V, toValue: V, position: V, velocity: V) -> V where V: AnimatableProperty {
        let fromValue = AnimatableProxy(fromValue)
        let toValue = AnimatableProxy(toValue)
        let position = AnimatableProxy(position)
        let velocity = AnimatableProxy(velocity)
        
        return V(force(fromValue: fromValue, toValue: toValue, position: position, velocity: velocity).animatableData)
    }
    
    /**
     The estimated duration required for the spring system to be considered at rest.
     
     The epsilon value specifies the threshhold for how small all subsequent values need to be before the spring is considered to have settled.
     */
    public func settlingDuration<V>(target: V, initialVelocity: V, epsilon: Double) -> TimeInterval where V: AnimatableProperty {
        self.settlingDuration(target: target.animatableData, initialVelocity: initialVelocity.animatableData, epsilon: epsilon)
    }
    
    /**
     The estimated duration required for the spring system to be considered at rest.
     
     The epsilon value specifies the threshhold for how small all subsequent values need to be before the spring is considered to have settled.
     */
    public func settlingDuration<V>(fromValue: V, toValue: V, initialVelocity: V, epsilon: Double) -> TimeInterval where V: AnimatableProperty {
        /*
        let target = fromValue.animatableData - toValue.animatableData
        self.settlingDuration(target: target, initialVelocity: initialVelocity.animatableData, epsilon: epsilon)
        */
        let fromValue = AnimatableProxy(fromValue)
        let toValue = AnimatableProxy(toValue)
        let initialVelocity = AnimatableProxy(initialVelocity)
        
        return self.settlingDuration(fromValue: fromValue, toValue: toValue, initialVelocity: initialVelocity, epsilon: epsilon)
    }
}

internal struct AnimatableProxy<Value: AnimatableProperty>: Animatable {
    var animatableData: Value.AnimatableData
    
    init(_ value: Value) {
        self.animatableData = value.animatableData
    }
}

#endif
