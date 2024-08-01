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
    import SwiftUI

    /**
     A configuration that specifies the appearance of a border.

     `NSView/UIView` and `CALayer` can be configurated by passing the configuration to `configurate(using configuration: BorderConfiguration)`.
     */
    public struct BorderConfiguration: Hashable {
        /// The color of the border.
        public var color: NSUIColor?

        /// The color transformer for resolving the border color.
        public var colorTransformer: ColorTransformer?

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
        
        /// How far into the dash pattern the line starts.
        public var dashPhase: CGFloat = 0
        
        /// The endpoint style of a segment.
        public var dashLineCap: CGLineCap = .butt

        /// The insets of the border.
        public var insets: NSDirectionalEdgeInsets = .init(0)

        /// Creates a border configuration.
        public init(color: NSUIColor? = nil,
                    colorTransformer: ColorTransformer? = nil,
                    width: CGFloat = 0.0,
                    dashPattern: [CGFloat] = [],
                    dashPhase: CGFloat = 0.0,
                    dashLineCap: CGLineCap = .butt,
                    insets: NSDirectionalEdgeInsets = .init(0))
        {
            self.color = color
            self.width = width
            self.dashPattern = dashPattern
            self.dashPhase = dashPhase
            self.dashLineCap = dashLineCap
            self.colorTransformer = colorTransformer
            self.insets = insets
        }

        /// A configuration without a border.
        public static func none() -> Self { Self() }

        /// A configuration for a black border.
        public static func black(width: CGFloat = 2.0) -> Self {
            Self(color: .black, width: width)
        }
        
        /// A configuration for a white border.
        public static func white(width: CGFloat = 2.0) -> Self {
            Self(color: .white, width: width)
        }

        /// A configuration for a border with the specified color.
        public static func color(_ color: NSUIColor, width: CGFloat = 2.0) -> Self {
            Self(color: color, width: width)
        }

        #if os(macOS)
        /// A configuration for a accent color border.
        public static func accentColor(width: CGFloat = 2.0) -> Self {
            Self(color: .controlAccentColor, width: width)
        }
        #else
        /// A configuration for a tint color border.
        @available(iOS 15.0, tvOS 15.0, *)
        public static func tintColor(width: CGFloat = 2.0) -> Self {
            Self(color: .tintColor, width: width)
        }
        #endif

        /// A configuration for a dashed border with the specified color.
        public static func dashed(color: NSUIColor = .black, width: CGFloat = 2.0, dashPattern: [CGFloat] = [4, 4]) -> Self {
            Self(color: color, width: width, dashPattern: dashPattern)
        }

        /// A Boolean value that indicates whether the border is invisible (when the color is `nil`, `clear` or the width `0`).
        var isInvisible: Bool {
            width == 0.0 || resolvedColor() == nil || resolvedColor() == .clear
        }

        var needsDashedBordlerLayer: Bool {
            insets != .zero || dashPattern != [] || !isInvisible
        }
    }

extension BorderConfiguration: Codable {
    public enum CodingKeys: String, CodingKey {
        case color
        case resolvedColor
        case width
        case dashPattern
        case insets
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(width, forKey: .width)
        try container.encode(dashPattern, forKey: .dashPattern)
        try container.encode(insets, forKey: .insets)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = .init(color: try values.decode(Optional<NSUIColor>.self, forKey: .color),
                     width: try values.decode(CGFloat.self, forKey: .width),
                     dashPattern: try values.decode([CGFloat].self, forKey: .dashPattern),
                     insets: try values.decode(NSDirectionalEdgeInsets.self, forKey: .insets))
    }
}

    extension NSUIView {
        /**
         Configurates the border apperance of the view.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func configurate(using configuration: BorderConfiguration) {
            #if os(macOS)
                dynamicColors.border = configuration.resolvedColor()
            #endif
            if configuration.needsDashedBordlerLayer {
                borderColor = nil
                #if os(macOS)
                _borderWidth = 0.0
                #else
                borderWidth = 0.0
                #endif
                if dashedBorderView == nil {
                    dashedBorderView = DashedBorderView()
                    addSubview(withConstraint: dashedBorderView!)
                    dashedBorderView?.sendToBack()
                }
                dashedBorderView?.configuration = configuration
            } else {
                dashedBorderView?.removeFromSuperview()
                dashedBorderView = nil
                let newColor = configuration.resolvedColor()?.resolvedColor(for: self)
                if borderColor?.alphaComponent == 0.0 || borderColor == nil {
                    borderColor = newColor?.withAlphaComponent(0.0) ?? .clear
                }
                borderColor = newColor
                #if os(macOS)
                _borderWidth = configuration.width
                #else
                borderWidth = configuration.width
                #endif
            }
        }

        var dashedBorderLayer: DashedBorderLayer? { optionalLayer?.firstSublayer(type: DashedBorderLayer.self) }
        
        var  dashedBorderView: DashedBorderView? {
            get { getAssociatedValue("dashedBorderView") }
            set { setAssociatedValue(newValue, key: "dashedBorderView") }
        }
    }

    extension CALayer {
        /**
         Configurates the border apperance of the view.

         - Parameters:
            - configuration:The configuration for configurating the apperance.
         */
        func configurate(using configuration: BorderConfiguration) {
            if configuration.needsDashedBordlerLayer {
                borderColor = nil
                borderWidth = 0.0
                let borderLayer = borderLayer ?? DashedBorderLayer()
                borderLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                borderLayer.configuration = configuration
                addSublayer(withConstraint: borderLayer, insets: configuration.insets)
            } else {
                borderLayer?.removeFromSuperlayer()
                borderColor = configuration.resolvedColor()?.cgColor
                borderWidth = configuration.width
            }
        }

        var borderLayer: DashedBorderLayer? {
            firstSublayer(type: DashedBorderLayer.self)
        }
    }

/// The Objective-C class for ``BorderConfiguration``.
public class __BorderConfiguration: NSObject, NSCopying {
    var color: NSUIColor?
    var colorTransformer: ColorTransformer?
    var width: CGFloat
    var dashPattern: [CGFloat]
    var dashPhase: CGFloat
    var dashLineCap: CGLineCap
    var insets: NSDirectionalEdgeInsets

    public init(color: NSUIColor?, colorTransformer: ColorTransformer?, width: CGFloat, dashPattern: [CGFloat], dashPhase: CGFloat, dashLineCap: CGLineCap, insets: NSDirectionalEdgeInsets) {
        self.color = color
        self.width = width
        self.dashPattern = dashPattern
        self.dashPhase = dashPhase
        self.dashLineCap = dashLineCap
        self.colorTransformer = colorTransformer
        self.insets = insets
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __BorderConfiguration(color: color, colorTransformer: colorTransformer, width: width, dashPattern: dashPattern, dashPhase: dashPhase, dashLineCap: dashLineCap, insets: insets)
    }
}

extension BorderConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __BorderConfiguration

    public func _bridgeToObjectiveC() -> __BorderConfiguration {
        return __BorderConfiguration(color: color, colorTransformer: colorTransformer, width: width, dashPattern: dashPattern, dashPhase: dashPhase, dashLineCap: dashLineCap, insets: insets)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __BorderConfiguration, result: inout BorderConfiguration?) {
        result = BorderConfiguration(color: source.color, colorTransformer: source.colorTransformer, width: source.width, dashPattern: source.dashPattern, dashPhase: source.dashPhase, dashLineCap: source.dashLineCap, insets: source.insets)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __BorderConfiguration, result: inout BorderConfiguration?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __BorderConfiguration?) -> BorderConfiguration {
        if let source = source {
            var result: BorderConfiguration?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return BorderConfiguration()
    }
    
    public var description: String {
                    """
                    BorderConfiguration(
                        color: \(String(describing: color))
                        colorTransformer: \(String(describing: colorTransformer))
                        width: \(width)
                        dashPattern: \(dashPattern)
                        dashPhase: \(dashPhase)
                        dashLineCap: \(dashLineCap.rawValue)
                        insets: \(insets)
                    )
                    """
    }

    public var debugDescription: String {
        description
    }
}

extension Shape {
    /**
     Traces the outline of this shape with the specified border configuration.
     
     - Parameter border: The border configuration.
     
     */
    @ViewBuilder
    public func stroke(_ border: BorderConfiguration) -> some View {
        if border.dashPattern.isEmpty {
            stroke(Color(border.resolvedColor() ?? .clear), lineWidth: border.width)
                .padding(border.insets.edgeInsets)
        } else {
            stroke(Color(border.resolvedColor() ?? .clear), style: StrokeStyle(lineWidth: border.width, lineCap: border.dashLineCap, dash: border.dashPattern, dashPhase: border.dashPhase))
                .padding(border.insets.edgeInsets)
        }
    }
}

#endif
