//
//  ContentConfiguration+View.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)
    import AppKit
    public typealias VisualEffect = ContentConfiguration.VisualEffect
#elseif canImport(UIKit)
    import UIKit
    public typealias VisualEffect = UIVisualEffect
#endif

@available(macOS 10.15.1, iOS 14.0, *)
public extension ContentConfiguration {
    /// A configuration that specifies the appearance of a view.
    struct View: Hashable {
        public var cornerRadius: CGFloat = 0.0
        public var cornerCurve: CALayerCornerCurve = .circular
        public var roundedCorners: CACornerMask = .all
        public var cornerShape: NSUIViewCornerShape? = nil
        public var alpha: CGFloat = 1.0
        public var isHidden: Bool = false
        public var border: Border = .init()
        public var innerShadow: Shadow? = nil
        public var outerShadow: Shadow? = nil
        public var visualEffect: VisualEffect? = nil

        public var customView: NSUIView? = nil
        public var image: NSUIImage? = nil
        public var imageProperties: Image = .scaled(.resizeAspect)

        public var backgroundColor: NSUIColor? = nil
        public var backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil

        public func resolvedBackgroundColor() -> NSUIColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
            }
            return nil
        }

        /*

         public var cornerRadius: CGFloat = 0.0
         public var maximumSize: CGSize = .zero
         public var reservedLayoutSize: CGSize = .zero
         public var accessibilityIgnoresInvertColors: Bool = false
         public var scaling: CALayerContentsGravity = .resizeAspectFill

         public var cornerShape: NSUIViewCornerShape? = nil
         public var roundedCorners: CACornerMask = .all
         public var alpha: CGFloat = 1.0
         public var border: Border = Border()
         public var innerShadow: Shadow? = nil
         public var outerShadow: Shadow? = nil
         public var backgroundColor: NSUIColor? = nil
         public var backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil

         public func resolvedBackgroundColor() -> NSUIColor? {
             if let backgroundColor = self.backgroundColor {
                 return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
             }
             return nil
         }
         */

        public init(cornerRadius: CGFloat = 0.0,
                    cornerCurve: CALayerCornerCurve = .circular,
                    roundedCorners: CACornerMask = .all,
                    cornerShape: NSUIViewCornerShape? = nil,
                    alpha: CGFloat = 1.0,
                    isHidden: Bool = false,
                    border: Border = Border(),
                    innerShadow: Shadow? = nil,
                    outerShadow: Shadow? = nil,
                    visualEffect: VisualEffect? = nil,
                    customView: NSUIView? = nil,
                    image: NSUIImage? = nil,
                    imageProperties: Image = .scaled(.resizeAspect),
                    backgroundColor: NSUIColor? = nil,
                    backgroundColorTransformer: NSUIConfigurationColorTransformer? = nil)
        {
            self.cornerRadius = cornerRadius
            self.cornerCurve = cornerCurve
            self.roundedCorners = roundedCorners
            self.cornerShape = cornerShape
            self.alpha = alpha
            self.isHidden = isHidden
            self.border = border
            self.innerShadow = innerShadow
            self.outerShadow = outerShadow
            self.visualEffect = visualEffect
            self.customView = customView
            self.image = image
            self.imageProperties = imageProperties
            self.backgroundColor = backgroundColor
            self.backgroundColorTransformer = backgroundColorTransformer
        }
    }
}

#if os(macOS)
    public extension NSView {
        func configurate(using viewProperties: ContentConfiguration.View) {
            cornerRadius = viewProperties.cornerRadius
            cornerCurve = viewProperties.cornerCurve
            cornerShape = viewProperties.cornerShape
            roundedCorners = viewProperties.roundedCorners
            alpha = viewProperties.alpha
            isHidden = viewProperties.isHidden
            configurate(using: viewProperties.border)
            if let outerShadow = viewProperties.outerShadow {
                configurate(using: outerShadow)
            }
            backgroundColor = viewProperties.resolvedBackgroundColor()
            backgroundView = viewProperties.customView
            /*
             public var innerShadow: Shadow? = nil
             public var visualEffect: VisualEffect? = nil

             public var customView: NSUIView? = nil
             public var image: NSUIImage? = nil
             public var imageProperties: Image = .scaled(.resizeAspect)

             */
        }
    }

#elseif canImport(UIKit)
    public extension UIView {
        func configurate(using viewProperties: ContentConfiguration.View) {
            cornerRadius = viewProperties.cornerRadius
            cornerCurve = viewProperties.cornerCurve
            cornerShape = viewProperties.cornerShape
            roundedCorners = viewProperties.roundedCorners
            alpha = viewProperties.alpha
            isHidden = viewProperties.isHidden
            configurate(using: viewProperties.border)
            if let outerShadow = viewProperties.outerShadow {
                configurate(using: outerShadow)
            }
            backgroundColor = viewProperties.resolvedBackgroundColor()
            backgroundView = viewProperties.customView
        }
    }
#endif

/*
 extension NSView {
 func configurate(using viewProperties: ContentConfiguration.View) {
 self.wantsLayer = true
 self.layer?.masksToBounds = true
 self.configurate(using: viewProperties.border)
 self.alphaValue = viewProperties.alpha
 self.backgroundColor = viewProperties.backgroundColor
 self.roundedCorners = viewProperties.roundedCorners
 self.cornerRadius = viewProperties.cornerRadius

 let customViewIdentifier: NSUserInterfaceItemIdentifier = "ContentConfiguration.View_CustomView"
 let visualEffectIdentifier: NSUserInterfaceItemIdentifier = "ContentConfiguration.View_VisualEffect"
 let imageViewIdentifier: NSUserInterfaceItemIdentifier = "ContentConfiguration.View_ImageView"
 self.subviews(identifier: customViewIdentifier).forEach({$0.removeFromSuperview()})
 self.subviews(identifier: visualEffectIdentifier).forEach({$0.removeFromSuperview()})
 self.subviews(identifier: imageViewIdentifier).forEach({$0.removeFromSuperview()})

 if let image = viewProperties.image {
 let imageView = ImageView(image: image)
 imageView.identifier = imageViewIdentifier
 self.addSubview(withConstraint: imageView)
 imageView.configurate(using: viewProperties.imageProperties)
 imageView.roundedCorners = viewProperties.roundedCorners
 imageView.cornerRadius = viewProperties.cornerRadius
 imageView.sendToBack()
 } else {
 self.subviews(identifier: imageViewIdentifier).forEach({$0.removeFromSuperview()})
 }

 if let customView = viewProperties.customView {
 customView.identifier = customViewIdentifier
 self.addSubview(withConstraint: customView)
 customView.cornerRadius = viewProperties.cornerRadius
 customView.roundedCorners = viewProperties.roundedCorners
 customView.sendToBack()
 } else {
 self.subviews(identifier: customViewIdentifier).forEach({$0.removeFromSuperview()})
 }

 if let visualEffectProperties = viewProperties.visualEffect {
 let visualEffectView = NSVisualEffectView()
 visualEffectView.identifier = visualEffectIdentifier
 self.addSubview(withConstraint: visualEffectView)
 visualEffectView.cornerRadius = viewProperties.cornerRadius
 visualEffectView.roundedCorners = viewProperties.roundedCorners
 visualEffectView.configurate(using: visualEffectProperties)
 visualEffectView.sendToBack()
 } else {
 self.subviews(identifier: visualEffectIdentifier).forEach({$0.removeFromSuperview()})
 }

 if let innerShadow = viewProperties.innerShadow {
 self.configurate(using: innerShadow)
 }

 if let outerShadow = viewProperties.outerShadow {
 self.configurate(using: outerShadow)
 }

 }
 }
 */
