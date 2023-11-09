//
//  CAPropertyAnimation+Key.swift
//
//
//  Created by Florian Zand on 09.11.23.
//

#if canImport(QuartzCore)
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
            case .caLayer(let property):           return property.rawValue
            case .shapeLayer(let property):        return property.rawValue
            case .emitterLayer(let property):      return property.rawValue
            case .gradientLayer(let property):     return property.rawValue
            case .replicationLayer(let property):  return property.rawValue
            case .textLayer(let property):         return property.rawValue
            }
        }
    }
}

public extension CALayer {
    /// The properties that can be animated.
    enum CALayerAnimatableProperty: String {

        /// CGPoint
        case anchorPoint = "anchorPoint"
        /// CGPoint
        case anchorPointZ = "anchorPointZ"
        /// CGColor?
        case backgroundColor = "backgroundColor"
        /// [CIFilter]? (uses default CATransition, sub-properties of filters are animated using default CABasicAnimation)
        case backgroundFilters = "backgroundFilters"
        /// CGColor?
        case borderColor = "borderColor"
        /// CGFloat
        case borderWidth = "borderWidth"
        /// CGRect
        case bounds = "bounds"
        /// CGpoint
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
        case compositingFilter = "compositingFilter"
        /// typically a CGImageRef, but may be something else
        case contents = "contents"
        /// CGRect
        case contentsRect = "contentsRect"
        /// CGFloat
        case contentsScale = "contentsScale"
        /// CGRect
        case contentsCenter = "contentsCenter"
        /// CGFloat
        case cornerRadius = "cornerRadius"
        /// Bool (no default animation)
        case doubleSided = "doubleSided"
        /// [CIFilter]? (uses default CATransition, sub-properties of filters are animated using default CABasicAnimation)
        case filters = "filters"
        /// CGRect (!!not animatable!! use bounds and position)
        case frame = "frame"
        /// Bool
        case hidden = "hidden"
        /// Bool
        case masksToBounds = "masksToBounds"
        /// Float
        case minificationFilterBias = "minificationFilterBias"
        /// Float (0 <= opacity <= 1)
        case opacity = "opacity"
        /// CGPoint
        case position = "position"
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
        case shadowColor = "shadowColor"
        /// CGSize (default is (0,-3))
        case shadowOffset = "shadowOffset"
        /// Float (0 <= shadowOpacity <= 1); default is 0
        case shadowOpacity = "shadowOpacity"
        /// CGpath?
        case shadowPath = "shadowPath"
        /// CGFloat (default is 3)
        case shadowRadius = "shadowRadius"
        /// [CALayer]?
        case sublayers = "sublayers"
        /// Bool
        case shouldRasterize = "shouldRasterize"
        /// CGFloat
        case rasterizationScale = "rasterizationScale"
        /// CATransform3D
        case sublayerTransform = "sublayerTransform"
        /// CGSize
        case translation = "transform.translation"
        /// CGFloat
        case translationX = "transform.translation.x"
        /// CGFloat
        case translationY = "transform.translation.y"
        /// CGFloat
        case translationZ = "transform.translation.z"
        /// CATransform3D
        case transform = "transform"
        /// CGFloat
        case zPosition = "zPosition"
    }
}

public extension CAShapeLayer {

    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CGColor?
        case fillColor = "fillColor"
        /// [NSNumber]?
        case lineDashPhase = "lineDashPhase"
        /// CGFloat
        case lineWidth = "lineWidth"
        /// CGFloat
        case miterLimit = "miterLimit"
        /// CGColor?
        case strokeColor = "strokeColor"
        /// CGFloat
        case strokeStart = "strokeStart"
        /// CGFloat
        case strokeEnd = "strokeEnd"
    }
}

public extension CAEmitterLayer {

    /// The properties that can be animated.
    enum AnimatableProperty: String {

        /// CGPoint
        case emitterPosition = "emitterPosition"
        /// CGFloat
        case emitterZPosition = "emitterZPosition"
        /// CGSize
        case emitterSize = "emitterSize"
    }
}

public extension CAGradientLayer {
    
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// [CGColor]? ([Any]? by Apple docs, but CGColor works as well)
        case colors = "colors"
        /// [NSNuber]?
        case locations = "locations"
        /// CGPoint
        case endPoint = "endPoint"
        /// CGPoint
        case startPoint = "startPoint"
    }

}

public extension CAReplicatorLayer {
    
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CFTimeInterval (Double)
        case instanceDelay = "instanceDelay"
        /// CATransform3D
        case instanceTransform = "instanceTransform"
        /// Float
        case instanceRedOffset = "instanceRedOffset"
        /// Float
        case instanceGreenOffset = "instanceGreenOffset"
        /// Float
        case instanceBlueOffset = "instanceBlueOffset"
        /// Float
        case instanceAlphaOffset = "instanceAlphaOffset"
    }
}

public extension CATextLayer {
    
    /// The properties that can be animated.
    enum AnimatableProperty: String {
        /// CGSize
        case fontSize = "fontSize"
        /// CGColor?
        case foregroundColor = "foregroundColor"
    }
}

#endif
