//
//  CAPropertyAnimation+Key.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import QuartzCore

public extension CAPropertyAnimation {
    /// Creates and returns an CAPropertyAnimation instance for the specified animatable property and duration.
    convenience init(_ key: CAPropertyAnimation.Key, duration: Double) {
        self.init(keyPath: key.keyPath)
        self.duration = duration
    }

    /// The keys of the animatable properties.
    enum Key {
        case caLayer(_ property: CALayer.CALayerAnimatableProperty)
        case shapeLayer(_ property: CAShapeLayer.AnimatableProperty)
        case emitterLayer(_ property: CAEmitterLayer.AnimatableProperty)
        case gradientLayer(_ property: CAGradientLayer.AnimatableProperty)
        case replicationLayer(_ property: CAReplicatorLayer.AnimatableProperty)
        case textLayer(_ property: CATextLayer.AnimatableProperty)

        var keyPath: String {
            switch self {
            case let .caLayer(property): return property.rawValue
            case let .shapeLayer(property): return property.rawValue
            case let .emitterLayer(property): return property.rawValue
            case let .gradientLayer(property): return property.rawValue
            case let .replicationLayer(property): return property.rawValue
            case let .textLayer(property): return property.rawValue
            }
        }
    }
}

public extension CALayer {
    /// The properties that can be animated.
    enum CALayerAnimatableProperty: String {
        /// CGPoint
        case anchorPoint
        /// CGPoint
        case anchorPointZ
        /// CGColor?
        case backgroundColor
        /// [CIFilter]? (uses default CATransition, sub-properties of filters are animated using default CABasicAnimation)
        case backgroundFilters
        /// CGColor?
        case borderColor
        /// CGFloat
        case borderWidth
        /// CGRect
        case bounds
        /// CGPoint
        case boundsOrigin = "bounds.origin"
        /// CGFloat
        case boundsOriginX = "bounds.origin.x"
        /// CGFloat
        case boundsOriginY = "bounds.origin.y"
        /// CGSize
        case boundsSize = "bounds.size"
        /// CGFloat
        case boundsWidth = "bounds.size.width"
        /// CGFloat
        case boundsHeight = "bounds.size.height"
        /// CIFilter? (uses default CATransition, sub-properties of filters are animated using default CABasicAnimation)
        case compositingFilter
        /// typically a CGImageRef, but may be something else
        case contents
        /// CGRect
        case contentsRect
        /// CGFloat
        case contentsScale
        /// CGRect
        case contentsCenter
        /// CGFloat
        case cornerRadius
        /// Bool (no default animation)
        case doubleSided
        /// [CIFilter]? (uses default CATransition, sub-properties of filters are animated using default CABasicAnimation)
        case filters
        /// CGRect (!!not animatable!! use bounds and position)
        case frame
        /// Bool
        case hidden
        /// Bool
        case masksToBounds
        /// Float
        case minificationFilterBias
        /// Float (0 <= opacity <= 1)
        case opacity
        /// CGPoint
        case position
        /// CGFloat
        case positionX = "position.x"
        /// CGFloat
        case positionY = "position.y"
        /// CGFloat
        case rotationX = "transform.rotation.x"
        /// CGFloat
        case rotationY = "transform.rotation.y"
        /// CGFloat
        case rotationZ = "transform.rotation.z"
        /// CGFloat
        case scale = "transform.scale"
        /// CGFloat
        case scaleX = "transform.scale.x"
        /// CGFloat
        case scaleY = "transform.scale.y"
        /// CGFloat
        case scaleZ = "transform.scale.z"
        /// CGColor?
        case shadowColor
        /// CGSize (default is (0,-3))
        case shadowOffset
        /// Float (0 <= shadowOpacity <= 1); default is 0
        case shadowOpacity
        /// CGpath?
        case shadowPath
        /// CGFloat (default is 3)
        case shadowRadius
        /// [CALayer]?
        case sublayers
        /// Bool
        case shouldRasterize
        /// CGFloat
        case rasterizationScale
        /// CATransform3D
        case sublayerTransform
        /// CGSize
        case translation = "transform.translation"
        /// CGFloat
        case translationX = "transform.translation.x"
        /// CGFloat
        case translationY = "transform.translation.y"
        /// CGFloat
        case translationZ = "transform.translation.z"
        /// CATransform3D
        case transform
        /// CGFloat
        case zPosition
    }
}

public extension CAShapeLayer {
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CGColor?
        case fillColor
        /// [NSNumber]?
        case lineDashPhase
        /// CGFloat
        case lineWidth
        /// CGFloat
        case miterLimit
        /// CGColor?
        case strokeColor
        /// CGFloat
        case strokeStart
        /// CGFloat
        case strokeEnd
    }
}

public extension CAEmitterLayer {
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CGPoint
        case emitterPosition
        /// CGFloat
        case emitterZPosition
        /// CGSize
        case emitterSize
    }
}

public extension CAGradientLayer {
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// [CGColor]? ([Any]? by Apple docs, but CGColor works as well)
        case colors
        /// [NSNuber]?
        case locations
        /// CGPoint
        case endPoint
        /// CGPoint
        case startPoint
    }
}

public extension CAReplicatorLayer {
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CFTimeInterval (Double)
        case instanceDelay
        /// CATransform3D
        case instanceTransform
        /// Float
        case instanceRedOffset
        /// Float
        case instanceGreenOffset
        /// Float
        case instanceBlueOffset
        /// Float
        case instanceAlphaOffset
    }
}

public extension CATextLayer {
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CGSize
        case fontSize
        /// CGColor?
        case foregroundColor
    }
}

#endif
