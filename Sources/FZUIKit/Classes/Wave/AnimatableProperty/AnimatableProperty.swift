//
//  AnimatableProperty.swift
//
//
//  Created by Florian Zand on 12.10.23.
//

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
  
 ``AnimatableArray`` containing `VectorArithmetic` values can be used as animatable data. ``AnimatableArray<Double>``is a animatable array with double values.
 
 Example:
 ```swift
 public struct SomeStruct {
    let value1: Double
    let value2: Double
 }
 
 extension SomeStruct: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        [value1, value2]
    }
 
    public init(_ animatableData: AnimatableArray<Double>) {
        self.value1 = animatableData[0]
        self.value1 = animatableData[1]
    }
 
    public static var zero: Self = SomeStruct(value1: 0, value2: 0)
 }
 ```
 */
public protocol AnimatableProperty: Equatable {
    
    /// The type defining the animatable representation of the value.
    associatedtype AnimatableData: VectorArithmetic
    
    /// The animatable representation of the value.
    var animatableData: AnimatableData { get }
    
    /// Initializes the value with the specified animatable representation of the value.
    init(_ animatableData: AnimatableData)
    
    /// The scaled integral representation of this value.
    var scaledIntegral: Self { get }
    
    /// The zero value.
    static var zero: Self { get }
}

public extension AnimatableProperty {
    var scaledIntegral: Self {
        self
    }
}

extension Optional: AnimatableProperty where Wrapped: AnimatableProperty {
    public var animatableData: Wrapped.AnimatableData {
        self.optional?.animatableData ?? Wrapped.zero.animatableData
    }
    
    public init(_ animatableData: Wrapped.AnimatableData) {
        self = Wrapped.init(animatableData)
    }
    
    public static var zero: Optional<Wrapped> {
        Wrapped.zero
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

extension AnimatableProperty where Self: NSNumber {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(value: animatableData[0])
    }
}

extension NSNumber: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        [doubleValue]
    }
    
    public static var zero: Self {
        Self(value: 0.0)
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

extension AnimatableProperty where Self: NSUIColor {
    public init(_ animatableData: AnimatableArray<Double>) {
        #if os(macOS)
        self.init(deviceRed: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
        #else
        self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
        #endif
    }
}

extension NSUIColor: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension AnimatableProperty where Self: CGColor {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(deviceRed: animatableData[0], green: animatableData[1], blue: animatableData[2], alpha: animatableData[3])
      //  self = NSUIColor(animatableData).cgColor as! Self
    }
    
    /**
     Creates a color object using the specified opacity and RGB component values in a device-dependent color space.
     
     - Parameters:
        - red: The red component, specified as a value from `0.0` to `1.0`.
        - green: The green component, specified as a value from `0.0` to `1.0`.
        - blue: The blue component, specified as a value from `0.0` to `1.0`.
        - alpha: The opacity value, specified as a value from `0.0` to `1.0`.
     */
    public init(deviceRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [red, green, blue, alpha])!
    }
}

extension CGColor: AnimatableProperty {
    public var animatableData: AnimatableArray<Double> {
        let components = self.rgbaComponents() ?? (0, 0, 0, 0)
        return [components.red, components.green, components.blue, components.alpha]
       // self.nsUIColor?.animatableData ?? [0,0,0,0]
    }
    
    public static var zero: Self {
        Self(red: 0, green: 0, blue: 0, alpha: 0)
    }
}

extension CGAffineTransform: AnimatableProperty, Animatable {
    @inlinable public init(_ animatableData: AnimatableArray<Double>) {
        self.init(animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4], animatableData[5])
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { [a, b, c, d, tx, ty, 0, 0] }
        set { self = .init(newValue) }
    }
    
    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension NSDirectionalEdgeInsets: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(top: animatableData[0], leading: animatableData[1], bottom: animatableData[2], trailing: animatableData[3])
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { [top, bottom, leading, trailing] }
        set { self = .init(newValue) }
    }
}

extension NSUIEdgeInsets: AnimatableProperty, Animatable {
    public var animatableData: AnimatableArray<Double> {
        get { [top, self.left, bottom, self.right] }
        set { self = .init(newValue) }
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(top: animatableData[0], left: animatableData[1], bottom: animatableData[2], right: animatableData[3])
    }
}

extension CGVector: AnimatableProperty, Animatable {
    public var animatableData: AnimatableArray<Double> {
        get { [dx, dy] }
        set { self = .init(newValue) }
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(dx: animatableData[0], dy: animatableData[1])
    }
}

#if canImport(QuartzCore)
extension CATransform3D: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(m11: animatableData[0], m12: animatableData[1], m13: animatableData[2], m14: animatableData[3], m21: animatableData[4], m22: animatableData[5], m23: animatableData[6], m24: animatableData[7], m31: animatableData[8], m32: animatableData[9], m33: animatableData[10], m34: animatableData[11], m41: animatableData[12], m42: animatableData[13], m43: animatableData[14], m44: animatableData[15])
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44] }
        set { self = .init(newValue) }
    }
}

extension CGQuaternion: AnimatableProperty, Animatable {
    public init(_ animatableData: AnimatableArray<Double>) {
        self.storage = .init(ix: animatableData[0], iy: animatableData[1], iz: animatableData[2], r: animatableData[3])
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { [self.storage.vector[0], self.storage.vector[1], self.storage.vector[2], self.storage.vector[3]] }
        set { self = .init(newValue) }
    }
    
    public static var zero: CGQuaternion {
        CGQuaternion.init(degree: 0, axis: .init(0, 0, 0))
    }
}
#endif

extension ContentConfiguration.Shadow: AnimatableProperty, Animatable {
    public static var zero: ContentConfiguration.Shadow {
        .none()
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), opacity: animatableData[4], radius: animatableData[5], offset: .init(animatableData[6], animatableData[7]))
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { (self._resolvedColor ?? .zero).animatableData + [opacity, radius, offset.x, offset.y] }
        set { self = .init(newValue) }
    }
}

extension ContentConfiguration.InnerShadow: AnimatableProperty, Animatable {
    public static var zero: ContentConfiguration.InnerShadow {
        .none()
    }
    
    public init(_ animatableData: AnimatableArray<Double>) {
        self.init(color: .init([animatableData[0], animatableData[1], animatableData[2], animatableData[3]]), opacity: animatableData[4], radius: animatableData[5], offset: .init(animatableData[6], animatableData[7]))
    }
    
    public var animatableData: AnimatableArray<Double> {
        get { (self._resolvedColor ?? .zero).animatableData + [opacity, radius, offset.x, offset.y] }
        set { self = .init(newValue) }
    }
}

internal extension CGColor {
    func animatable(to other: CGColor) -> CGColor {
        self.alpha == 0 ? other.withAlpha(0.0) : self
    }
}

internal extension NSUIColor {
    func animatable(to other: NSUIColor) -> NSUIColor {
        self.alphaComponent == 0 ? other.withAlphaComponent(0.0) : self
    }
}

// Ensures that two collections have the same amount of values for animating between them. If a collection is smaller than the other zero values are added.
internal protocol AnimatableCollection: RangeReplaceableCollection, BidirectionalCollection {
    var count: Int { get }
    // Append new zero values.
    mutating func appendNewValues(amount: Int)
    // Ensures both collections have the same amount of values for animating between them.
    mutating func makeAnimatable(to collection: inout any AnimatableCollection)
}

extension AnimatableCollection {
    mutating func makeAnimatable(to collection: inout any AnimatableCollection) {
        let diff = self.count - collection.count
        if diff < 0 {
            collection.appendNewValues(amount: (diff * -1))
        } else if diff > 0 {
            self.appendNewValues(amount: diff)
        }
    }
}

extension Array: AnimatableProperty, AnimatableCollection where Element: AnimatableProperty {
    public init(_ animatableData: AnimatableArray<Element.AnimatableData>) {
        self.init(animatableData.elements.compactMap({Element($0)}))
    }
    
    public var animatableData: AnimatableArray<Element.AnimatableData> {
        get { AnimatableArray<Element.AnimatableData>(self.compactMap({$0.animatableData})) }
    }
    
    public static var zero: Array<Element> {
        Self.init()
    }
    
    internal mutating func appendNewValues(amount: Int) {
        self.append(contentsOf: Array(repeating: .zero, count: amount))
    }
}

extension AnimatableArray: AnimatableCollection {
    internal mutating func appendNewValues(amount: Int) {
        self.append(contentsOf: Array(repeating: .zero, count: amount))
    }
}

extension Array: Animatable where Element: Animatable {
    
}
