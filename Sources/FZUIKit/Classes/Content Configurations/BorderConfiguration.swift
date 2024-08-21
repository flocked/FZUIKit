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

extension CGLineCap: Codable { }

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
        
        /// Properties for the border dash.
        public struct Dash: Hashable, Codable {
            /// The dash pattern of the border.
            public var pattern: [CGFloat] = []
            /// How far into the dash pattern the line starts.
            public var phase: CGFloat = 0
            /// The endpoint style of a segment.
            public var lineCap: CGLineCap = .butt
            /// A Boolean value that indicates whether a dashed border animates.
            public var animates: Bool = false
        }
        
        /// The properties of the border dash.
        public var dash: Dash = Dash()

        /// The insets of the border.
        public var insets: NSDirectionalEdgeInsets = .init(0)

        /// Creates a border configuration.
        public init(color: NSUIColor? = nil,
                    colorTransformer: ColorTransformer? = nil,
                    width: CGFloat = 0.0,
                    insets: NSDirectionalEdgeInsets = .init(0)) {
            self.color = color
            self.width = width
            self.colorTransformer = colorTransformer
            self.insets = insets
        }
        
        init(color: NSUIColor? = nil,
                    colorTransformer: ColorTransformer? = nil,
                    width: CGFloat = 0.0,
                    dash: Dash,
                    insets: NSDirectionalEdgeInsets = .init(0)) {
            self.color = color
            self.width = width
            self.dash = dash
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
        public static func dashed(color: NSUIColor = .black, width: CGFloat = 2.0, patterh: [CGFloat] = [4, 4], animates: Bool = false) -> Self {
            var border = Self(color: color, width: width)
            border.dash.pattern = patterh
            border.dash.animates = animates
            return border
        }

        /// A Boolean value that indicates whether the border is invisible (when the color is `nil`, `clear` or the width `0`).
        var isInvisible: Bool {
            width == 0.0 || resolvedColor() == nil || resolvedColor() == .clear
        }

        var needsDashedBorderView: Bool {
            insets != .zero || !dash.pattern.isEmpty || !isInvisible
        }
    }

extension BorderConfiguration: Codable {
    public enum CodingKeys: String, CodingKey {
        case color
        case width
        case dash
        case insets
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(width, forKey: .width)
        try container.encode(dash, forKey: .dash)
        try container.encode(insets, forKey: .insets)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self = .init(color: try values.decode(Optional<NSUIColor>.self, forKey: .color),
                     width: try values.decode(CGFloat.self, forKey: .width),
                     dash: try values.decode(Dash.self, forKey: .width),
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
            if configuration.needsDashedBorderView {
                borderColor = nil
                #if os(macOS)
                _borderWidth = 0.0
                #else
                borderWidth = 0.0
                #endif
                if dashedBorderView == nil {
                    dashedBorderView = DashedBorderView()
                    addSubview(withConstraint: dashedBorderView!)
                    dashedBorderView?.sendToFront()
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
        
        var dashedBorderView: DashedBorderView? {
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
            if configuration.needsDashedBorderView {
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
    var dash: BorderConfiguration.Dash
    var insets: NSDirectionalEdgeInsets

    public init(color: NSUIColor?, colorTransformer: ColorTransformer?, width: CGFloat, dash: BorderConfiguration.Dash, insets: NSDirectionalEdgeInsets) {
        self.color = color
        self.width = width
        self.colorTransformer = colorTransformer
        self.dash = dash
        self.insets = insets
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __BorderConfiguration(color: color, colorTransformer: colorTransformer, width: width, dash: dash, insets: insets)
    }
}

extension BorderConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __BorderConfiguration

    public func _bridgeToObjectiveC() -> __BorderConfiguration {
        return __BorderConfiguration(color: color, colorTransformer: colorTransformer, width: width, dash: dash, insets: insets)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __BorderConfiguration, result: inout BorderConfiguration?) {
        result = BorderConfiguration(color: source.color, colorTransformer: source.colorTransformer, width: source.width, dash: source.dash, insets: source.insets)
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
                        color: \(color?.description ?? "-")
                        colorTransformer: \(colorTransformer?.id ?? "-")
                        width: \(width)
                        dash: \(dash)
                        insets: \(insets)
                    )
                    """
    }

    public var debugDescription: String {
        description
    }
}

extension BorderConfiguration.Dash: CustomStringConvertible {
    public var description: String {
                            """
                            Dash(
                                patterh: \(pattern)
                                phase: \(phase)
                                lineCap: \(lineCap.rawValue)
                                animates: \(animates)
                            )
                            """
    }
}

extension Shape {
    /**
     Traces the outline of this shape with the specified border configuration.
     
     - Parameter border: The border configuration.
     
     */
    @ViewBuilder
    public func stroke(_ border: BorderConfiguration) -> some View {
        if border.dash.pattern.isEmpty {
            stroke(Color(border.resolvedColor() ?? .clear), lineWidth: border.width)
                .padding(border.insets.edgeInsets)
        } else {
            stroke(Color(border.resolvedColor() ?? .clear), style: StrokeStyle(lineWidth: border.width, lineCap: border.dash.lineCap, dash: border.dash.pattern, dashPhase: border.dash.phase))
                .padding(border.insets.edgeInsets)
        }
    }
}

#endif
