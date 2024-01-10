//
//  InnerShadowLayer.swift
//
//
//  Created by Florian Zand on 16.09.21.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Foundation
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

    /// A layer with an inner shadow.
    public class InnerShadowLayer: CALayer {
        /// The configuration of the inner shadow.
        public var configuration: ShadowConfiguration {
            get { ShadowConfiguration(color: innerShadowColorDynamic, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point) }
            set {
                innerShadowColorDynamic = newValue._resolvedColor
                if let parentView = parentView {
                    shadowColor = newValue._resolvedColor?.resolvedColor(for: parentView).cgColor
                    #if os(macOS)
                        parentView.dynamicColors.innerShadow = newValue._resolvedColor
                    #endif
                } else {
                    shadowColor = newValue._resolvedColor?.cgColor
                }
                shadowOpacity = Float(newValue.opacity)
                let needsUpdate = shadowOffset != newValue.offset.size || shadowRadius != newValue.radius
                isUpdating = true
                shadowOffset = newValue.offset.size
                shadowRadius = newValue.radius
                isUpdating = false
                if needsUpdate {
                    updateShadowPath()
                }
            }
        }

        var innerShadowColorDynamic: NSUIColor?

        var isUpdating: Bool = false

        /**
         Initalizes an inner shadow layer with the specified configuration.

         - Parameter configuration: The configuration of the inner shadow.
         - Returns: The inner shadow layer.
         */
        public init(configuration: ShadowConfiguration) {
            super.init()
            self.configuration = configuration
        }

        override public init() {
            super.init()
            sharedInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        override public init(layer: Any) {
            super.init(layer: layer)
            sharedInit()
        }

        func sharedInit() {
            shadowOpacity = 0
            shadowColor = nil
            backgroundColor = .clear
            masksToBounds = true
            shadowOffset = .zero
            shadowRadius = 0.0
        }

        override public var shadowRadius: CGFloat {
            didSet { if !isUpdating, oldValue != shadowRadius { self.updateShadowPath() } }
        }

        override public var shadowOffset: CGSize {
            didSet { if !isUpdating, oldValue != shadowOffset { self.updateShadowPath() } }
        }

        override public var bounds: CGRect {
            didSet {
                if !isUpdating, oldValue != bounds {
                    updateShadowPath()
                }
            }
        }

        override public var cornerRadius: CGFloat {
            didSet { if !isUpdating, oldValue != cornerRadius {
                updateShadowPath()
            } }
        }

        func updateShadowPath() {
            let path: NSUIBezierPath
            let innerPart: NSUIBezierPath
            if cornerRadius != 0.0 {
                path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
                #if os(macOS)
                    innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
                #else
                    innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
                #endif
            } else {
                path = NSUIBezierPath(rect: bounds.insetBy(dx: -20, dy: -20))
                #if os(macOS)
                    innerPart = NSUIBezierPath(rect: bounds).reversed
                #else
                    innerPart = NSUIBezierPath(rect: bounds).reversing()
                #endif
            }
            path.append(innerPart)
            shadowPath = path.cgPath
        }
    }

#endif
