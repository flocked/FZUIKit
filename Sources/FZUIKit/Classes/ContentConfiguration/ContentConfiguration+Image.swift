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

public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a view's displaying images.
    struct Image: Hashable {
        public var tintColor: NSUIColor? = nil
        public var tintColorTransformer: NSUIConfigurationColorTransformer? = nil
        public func resolvedTintColor(for color: NSUIColor) -> NSUIColor {
            return tintColorTransformer?(color) ?? color
        }

        public var maximumSize: CGSize = .zero
        public var reservedLayoutSize: CGSize = .zero
        public var accessibilityIgnoresInvertColors: Bool = false
        public var scaling: CALayerContentsGravity = .resizeAspectFill

        public var cornerRadius: CGFloat = 0.0
        public var cornerShape: NSUIViewCornerShape? = nil
        public var roundedCorners: CACornerMask = .all
        public var opacity: CGFloat = 1.0
        public var border: Border = .init()
        public var innerShadow: Shadow? = nil
        public var outerShadow: Shadow? = nil
        public var backgroundColor: NSUIColor? = nil
        public var backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil
        public func resolvedBackgroundColor() -> NSUIColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
            }
            return nil
        }

        public init(tintColor: NSUIColor? = nil,
                    tintColorTransformer: NSUIConfigurationColorTransformer? = nil,
                    cornerRadius: CGFloat = 0.0,
                    maximumSize: CGSize = .zero,
                    reservedLayoutSize: CGSize = .zero,
                    accessibilityIgnoresInvertColors: Bool = false,
                    scaling: CALayerContentsGravity = .resizeAspectFill,
                    cornerShape: NSUIViewCornerShape? = nil,
                    roundedCorners: CACornerMask = .all,
                    opacity: CGFloat = 1.0,
                    border: Border = Border(),
                    innerShadow: Shadow? = nil,
                    outerShadow: Shadow? = nil,
                    backgroundColor: NSUIColor? = nil,
                    backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil)
        {
            self.tintColor = tintColor
            self.tintColorTransformer = tintColorTransformer
            self.cornerRadius = cornerRadius
            self.maximumSize = maximumSize
            self.reservedLayoutSize = reservedLayoutSize
            self.accessibilityIgnoresInvertColors = accessibilityIgnoresInvertColors
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

        public static func scaled(_ scaling: CALayerContentsGravity, maxSize _: CGSize = .zero) -> Self { return Self(tintColor: nil, tintColorTransformer: nil, cornerRadius: 0.0, maximumSize: .zero, reservedLayoutSize: .zero, accessibilityIgnoresInvertColors: false, scaling: scaling) }

        public static func scaledTinted(_ scaling: CALayerContentsGravity, tintColor: NSUIColor) -> Self { return Self(tintColor: tintColor, tintColorTransformer: nil, cornerRadius: 0.0, maximumSize: .zero, reservedLayoutSize: .zero, accessibilityIgnoresInvertColors: false, scaling: scaling) }

        public static func rounded(_ cornerRadius: CGFloat, scaling: CALayerContentsGravity = .resizeAspectFill) -> Self { return Self(tintColor: nil, tintColorTransformer: nil, cornerRadius: cornerRadius, maximumSize: .zero, reservedLayoutSize: .zero, accessibilityIgnoresInvertColors: false, scaling: scaling) }

        public static func `default`() -> Self { return .scaled(.resizeAspectFill) }
    }
}

public extension ImageLayer {
    /// Applys the configuration’s values to the properties of the layer.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        contentTintColor = imageProperties.tintColor
        cornerRadius = imageProperties.cornerRadius
        imageScaling = imageProperties.scaling
    }
}

#if os(macOS)
public extension ImageView {
    /// Applys the configuration’s values to the properties of the view.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        if let tintColor = imageProperties.tintColor {
            contentTintColor = imageProperties.resolvedTintColor(for: tintColor)
        } else {
            contentTintColor = nil
        }
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

@available(macOS 10.15.1, *)
public extension NSImageView {
    /// Applys the configuration’s values to the properties of the view.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        if let tintColor = imageProperties.tintColor {
            contentTintColor = imageProperties.resolvedTintColor(for: tintColor)
        } else {
            contentTintColor = nil
        }
        cornerRadius = imageProperties.cornerRadius
        imageScaling = NSImageScaling(contentsGravity: imageProperties.scaling)
        cornerShape = imageProperties.cornerShape
        roundedCorners = imageProperties.roundedCorners
        alpha = imageProperties.opacity
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
public extension UIImageView {
    /// Applys the configuration’s values to the properties of the view.
    func configurate(using imageProperties: ContentConfiguration.Image) {
        if let tintColor = imageProperties.tintColor {
            self.tintColor = imageProperties.resolvedTintColor(for: tintColor)
        } else {
            tintColor = nil
        }
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
