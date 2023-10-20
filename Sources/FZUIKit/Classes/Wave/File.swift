import AppKit
import SwiftUI
import Accelerate

@available(macOS 14.0, *)
extension SwiftUI.Spring {
    func update<V>(value: inout V, velocity: inout V, target: V, deltaTime: TimeInterval) where V : AnimatableData {
        var val = value.animatableData
        var vel = velocity.animatableData
        let tar = target.animatableData
                
        self.update(value: &val, velocity: &vel, target: tar, deltaTime: deltaTime)

        value = V(val)
        velocity = V(vel)
    }
}

public protocol AnimatableData {
    associatedtype AnimatableData: VectorArithmetic
    var animatableData: AnimatableData { get }
    init(_ animatableData: AnimatableData)
}

extension AnimatableData where Self.AnimatableData == Self {
    public var animatableData: Self {
        self
    }
    
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension Float: AnimatableData {
    public var animatableData: Self {
        self
    }
    public init(_ animatableData: Self) {
        self = animatableData
    }
}
 
extension Double: AnimatableData {
    public var animatableData: Self {
        self
    }
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGFloat: AnimatableData {
    public var animatableData: Self {
        self
    }
    public init(_ animatableData: Self) {
        self = animatableData
    }
}

extension CGPoint: AnimatableData {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        [x, y]
    }
    
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(animatableData.first, animatableData.second)
    }
}

extension CGSize: AnimatableData {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        [width, height]
    }
    
    public init(_ animatableData: AnimatablePair<CGFloat, CGFloat>) {
        self.init(animatableData.first, animatableData.second)
    }
}

extension CGRect: AnimatableData {
    public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData> {
        [self.origin.animatableData, self.size.animatableData]
    }
    
    public init(_ animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData>) {
        self.init(CGPoint(animatableData.first), CGSize(animatableData.second))
    }
}

extension CATransform3D: AnimatableData {
    public init(_ animatableData: AnimatableVector) {
        self.init(m11: animatableData[0], m12: animatableData[1], m13: animatableData[2], m14: animatableData[3], m21: animatableData[4], m22: animatableData[5], m23: animatableData[6], m24: animatableData[7], m31: animatableData[8], m32: animatableData[9], m33: animatableData[10], m34: animatableData[11], m41: animatableData[12], m42: animatableData[13], m43: animatableData[14], m44: animatableData[15])
    }
    
    public var animatableData: AnimatableVector {
        return [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
    }
}

extension AnimatableData where Self: NSColor {
    public init(_ animatableData: AnimatableVector) {
        self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[1], alpha: animatableData[1])
    }
}

extension NSColor: AnimatableData {
    public var animatableData: AnimatableVector {
        let rgba = self.rgbaComponents()
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
}

extension AnimatableData where Self: CGColor {
    public init(_ animatableData: AnimatableVector) {
        self.init(red: animatableData[0], green: animatableData[1], blue: animatableData[1], alpha: animatableData[1])
    }
}

extension CGColor: AnimatableData {
    public var animatableData: AnimatableVector {
        let rgba = self.rgbaComponents() ?? (0, 0, 0, 1)
        return [rgba.red, rgba.green, rgba.blue, rgba.alpha]
    }
}

extension Array: AnimatableData where Self.Element == Double { }

extension CGAffineTransform: AnimatableData {
    @inlinable public init(_ animatableData: AnimatableVector) {
        self.init(animatableData[0], animatableData[1], animatableData[2], animatableData[3], animatableData[4], animatableData[5])
    }
    
    /// `SIMD8` representation of the value.
    public var animatableData: AnimatableVector {
        return [a, b, c, d, tx, ty, 0, 0]
    }
}


extension CGQuaternion: AnimatableData {
    public init(_ animatableData: AnimatableVector) {
        self.storage = .init(ix: animatableData[0], iy: animatableData[1], iz: animatableData[2], r: animatableData[3])
    }
    
    public var animatableData: AnimatableVector {
        [self.storage.vector[0], self.storage.vector[1], self.storage.vector[2], self.storage.vector[3]]
    }
}
