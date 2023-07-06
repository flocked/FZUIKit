//
//  ContentConfiguration+Image.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a view's displaying images.
    struct Image: Hashable {
        /// The tint color of the image.
        public var tintColor: NSUIColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the tint color.
        public var tintColorTransformer: NSUIConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved tint color for the specified tint color, using the tint color and color transformer.
        public func resolvedTintColor() -> NSUIColor? {
            if let tintColor = self.tintColor {
                return tintColorTransformer?(tintColor) ?? tintColor
            }
            return nil
        }

        /**
         A maximum size for the image.
         
         The default value is CGSizeZero. Setting a width or height of zero makes the size unconstrained on that dimension. If the image exceeds maximumSize size on either dimension, the view reduces its size proportionately, maintaining aspect ratio.
         */
        public var maximumSize: CGSize = .zero
        /// The image scaling.
        public var scaling: CALayerContentsGravity = .resizeAspectFill
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: SymbolConfiguration? = nil

        public var cornerRadius: CGFloat = 0.0
        public var cornerShape: NSUIViewCornerShape? = nil
        public var roundedCorners: CACornerMask = .all
        public var opacity: CGFloat = 1.0
        public var border: Border = .init()
        public var innerShadow: InnerShadow? = nil
        public var outerShadow: Shadow? = nil
        /// The background color of the image.
        public var backgroundColor: NSUIColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The color transformer for resolving the background color.
        public var backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSUIColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        internal var _resolvedbackgroundColor: NSUIColor? = nil
        internal var _resolvedTintColor: NSUIColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedbackgroundColor = resolvedBackgroundColor()
            _resolvedTintColor = resolvedTintColor()
        }

        public init(tintColor: NSUIColor? = nil,
                    tintColorTransformer: NSUIConfigurationColorTransformer? = nil,
                    cornerRadius: CGFloat = 0.0,
                    maximumSize: CGSize = .zero,
                    scaling: CALayerContentsGravity = .resizeAspectFill,
                    cornerShape: NSUIViewCornerShape? = nil,
                    roundedCorners: CACornerMask = .all,
                    opacity: CGFloat = 1.0,
                    border: Border = Border(),
                    innerShadow: InnerShadow? = nil,
                    outerShadow: Shadow? = nil,
                    backgroundColor: NSUIColor? = nil,
                    backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil)
        {
            self.tintColor = tintColor
            self.tintColorTransformer = tintColorTransformer
            self.cornerRadius = cornerRadius
            self.maximumSize = maximumSize
            self.scaling = scaling
            self.cornerShape = cornerShape
            self.roundedCorners = roundedCorners
            self.opacity = opacity
            self.border = border
            self.innerShadow = innerShadow
            self.outerShadow = outerShadow
            self.backgroundColor = backgroundColor
            self.backgroundColorTransformer = backgroundColorTransformer
        }

        /*
        public static func scaled(_ scaling: CALayerContentsGravity, maxSize _: CGSize = .zero) -> Self { return Self(tintColor: nil, tintColorTransformer: nil, cornerRadius: 0.0, maximumSize: .zero, reservedLayoutSize: .zero, accessibilityIgnoresInvertColors: false, scaling: scaling) }

        public static func scaledTinted(_ scaling: CALayerContentsGravity, tintColor: NSUIColor) -> Self { return Self(tintColor: tintColor, tintColorTransformer: nil, cornerRadius: 0.0, maximumSize: .zero, reservedLayoutSize: .zero, accessibilityIgnoresInvertColors: false, scaling: scaling) }

        public static func rounded(_ cornerRadius: CGFloat, scaling: CALayerContentsGravity = .resizeAspectFill) -> Self { return Self(tintColor: nil, tintColorTransformer: nil, cornerRadius: cornerRadius, maximumSize: .zero, reservedLayoutSize: .zero, accessibilityIgnoresInvertColors: false, scaling: scaling) }
*/
        public static func `default`() -> Self { Self() }
    }
}
@available(macOS 12.0, iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension ImageLayer {
    /// Applys the configuration’s values to the properties of the layer.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        contentTintColor = imageProperties.tintColor
        cornerRadius = imageProperties.cornerRadius
        imageScaling = imageProperties.scaling
    }
}

#if os(macOS)
@available(macOS 12.0, *)
public extension ImageView {
    /// Applys the configuration’s values to the properties of the view.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        contentTintColor = imageProperties._resolvedTintColor
        cornerRadius = imageProperties.cornerRadius
        imageScaling = imageProperties.scaling
        cornerShape = imageProperties.cornerShape
        roundedCorners = imageProperties.roundedCorners
        alpha = imageProperties.opacity
        configurate(using: imageProperties.border)
        backgroundColor = imageProperties.resolvedBackgroundColor()
        if let outerShadow = imageProperties.outerShadow {
            configurate(using: outerShadow)
        }
    }
}

@available(macOS 12.0, *)
public extension NSImageView {
    /// Applys the configuration’s values to the properties of the view.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        contentTintColor = imageProperties._resolvedTintColor
        cornerRadius = imageProperties.cornerRadius
        imageScaling = NSImageScaling(contentsGravity: imageProperties.scaling)
        cornerShape = imageProperties.cornerShape
        roundedCorners = imageProperties.roundedCorners
        alphaValue = imageProperties.opacity
        configurate(using: imageProperties.border)
        backgroundColor = imageProperties.resolvedBackgroundColor()
        if let outerShadow = imageProperties.outerShadow {
            configurate(using: outerShadow)
        }
        /*
         self.maximumSize = maximumSize
         self.reservedLayoutSize = reservedLayoutSize
         self.accessibilityIgnoresInvertColors = accessibilityIgnoresInvertColors
         self.innerShadow = innerShadow
         self.outerShadow = outerShadow
         self.backgroundColor = backgroundColor
         self.backgroundColorTransformer = backgroundColorTransformer
         */
    }
}

#elseif canImport(UIKit)
@available(iOS 16.0, tvOS 16.0, watchOS 7.0, *)
public extension UIImageView {
    /// Applys the configuration’s values to the properties of the view.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        tintColor = imageProperties._resolvedTintColor
        layer.cornerRadius = imageProperties.cornerRadius
        //  self.cornerShape = imageProperties.cornerShape
        layer.maskedCorners = imageProperties.roundedCorners
        alpha = imageProperties.opacity
        configurate(using: imageProperties.border)
        backgroundColor = imageProperties.resolvedBackgroundColor()
        contentMode = UIView.ContentMode(contentsGravity: imageProperties.scaling)
        if let outerShadow = imageProperties.outerShadow {
            configurate(using: outerShadow)
        }
    }
}

#endif
