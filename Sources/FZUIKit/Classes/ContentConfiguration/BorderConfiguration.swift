//
//  BorderConfiguration.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

    /**
     A configuration that specifies the appearance of a border.

     `NSView/UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: BorderConfiguration)`.
     */
    public struct BorderConfiguration: Hashable {
        /// The color of the border.
        public var color: NSUIColor? {
            didSet { updateResolvedColor() }
        }

        /// The color transformer for resolving the border color.
        public var colorTransformer: ColorTransformer? {
            didSet { updateResolvedColor() }
        }

        /// Generates the resolved border color, using the border color and color transformer.
        public func resolvedColor() -> NSUIColor? {
            if let color = color {
                return colorTransformer?(color) ?? color
            }
            return nil
        }

        /// The width of the border.
        public var width: CGFloat = 0.0

        /// The dash pattern of the border.
        public var dashPattern: [CGFloat] = []

        /// The insets of the border.
        public var insets: NSDirectionalEdgeInsets = .init(0)

        /// Initalizes a border configuration.
        public init(color: NSUIColor? = nil,
                    colorTransformer: ColorTransformer? = nil,
                    width: CGFloat = 0.0,
                    dashPattern: [CGFloat] = [],
                    insets: NSDirectionalEdgeInsets = .init(0))
        {
            self.color = color
            self.width = width
            self.dashPattern = dashPattern
            self.colorTransformer = colorTransformer
            self.insets = insets
            updateResolvedColor()
        }

        /// A border configuration without a border.
        public static func none() -> Self { Self() }

        /// A configuration for a black border.
        public static func black(width: CGFloat = 2.0) -> Self {
            Self(color: .black, width: width)
        }

        /// A configuration for a border with the specified color.
        public static func color(_ color: NSUIColor, width: CGFloat = 2.0) -> Self {
            Self(color: color, width: width)
        }

        #if os(macOS)
            /// A configuration for a border with controlAccent color.
            public static func controlAccent(width: CGFloat = 2.0) -> Self {
                Self(color: .controlAccentColor, width: width)
            }
        #endif

        /// A configuration for a dashed border with the specified color.
        public static func dashed(color: NSUIColor = .black, width: CGFloat = 2.0) -> Self {
            Self(color: color, width: width, dashPattern: [2])
        }

        var _resolvedColor: NSUIColor?
        mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }

        /// A Boolean value that indicates whether the border is invisible (when the color is `nil`, `clear` or the width `0`).
        public var isInvisible: Bool {
            width == 0.0 || _resolvedColor == nil || _resolvedColor == .clear
        }

        var needsDashedBordlerLayer: Bool {
            insets != .zero || dashPattern != []
        }
    }

    public extension NSUIView {
        /**
         Configurates the border apperance of the view.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func configurate(using configuration: BorderConfiguration) {
            #if os(macOS)
                dynamicColors.border = configuration._resolvedColor
            #endif
            if configuration.isInvisible || !configuration.needsDashedBordlerLayer {
                optionalLayer?.borderLayer?.removeFromSuperlayer()
            }
            if configuration.needsDashedBordlerLayer {
                borderColor = nil
                borderWidth = 0.0
                if optionalLayer?.borderLayer == nil {
                    let borderedLayer = DashedBorderLayer()
                    optionalLayer?.addSublayer(withConstraint: borderedLayer, insets: configuration.insets)
                    borderedLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                }
                optionalLayer?.borderLayer?.configuration = configuration
            } else {
                let newColor = configuration._resolvedColor?.resolvedColor(for: self)
                if borderColor?.alphaComponent == 0.0 || borderColor == nil {
                    borderColor = newColor?.withAlphaComponent(0.0) ?? .clear
                }
                borderColor = newColor
                borderWidth = configuration.width
            }
        }

        internal var dashedBorderLayer: DashedBorderLayer? { optionalLayer?.firstSublayer(type: DashedBorderLayer.self) }
    }

    public extension CALayer {
        /**
         Configurates the border apperance of the view.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func configurate(using configuration: BorderConfiguration) {
            if configuration.isInvisible || !configuration.needsDashedBordlerLayer {
                borderLayer?.removeFromSuperlayer()
            }

            if configuration.needsDashedBordlerLayer {
                borderColor = nil
                borderWidth = 0.0
                if borderLayer == nil {
                    let borderedLayer = DashedBorderLayer()
                    addSublayer(withConstraint: borderedLayer, insets: configuration.insets)
                    borderedLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                }
                borderLayer?.configuration = configuration
            } else {
                borderColor = configuration._resolvedColor?.cgColor
                borderWidth = configuration.width
            }
        }

        internal var borderLayer: DashedBorderLayer? {
            firstSublayer(type: DashedBorderLayer.self)
        }
    }
#endif
