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
 
 The border of `NSView/UIView` and `CALayer` can be configurated using their `border` property.
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
    public var width: CGFloat = 0.0 {
        didSet { width = width.clamped(min: 0.0) }
    }
    
    /// The insets of the border.
    public var insets: NSDirectionalEdgeInsets = .init(0)
    
    /// The properties of the border dash.
    public var dash: Dash = Dash()
    
    /// Properties for the border dash.
    public struct Dash: Hashable, Codable {
        
        /// The pattern of the dash.
        public var pattern: [CGFloat] = [] {
            didSet {
                if pattern.count == 1, let value = pattern.first {
                    pattern = [value, value]
                }
            }
        }
        
        /// How far into the dash pattern the line starts.
        public var phase: CGFloat = 0
        
        /// The endpoint style of a dash segment.
        public var lineCap: CGLineCap = .butt
        
        /// The shape of the joints between connected dash segments.
        public var lineJoin: CGLineJoin = .miter
        
        /**
         The miter limit used when line join is set to `mitter`.
         
         If ``lineJoin`` is set to `mitter`, the miter limit determines whether the dash lines should be joined with a bevel instead of a miter. The length of the miter is divided by the line width. If the result is greater than the miter limit, the dash is drawn with a bevel.
         */
        public var mitterLimit: CGFloat = 10.0
        
        /// A Boolean value indicating whether the dash animates.
        public var animates: Bool = false
        
        /// The speed of the dash animation.
        public var animationSpeed: AnimationSpeed = .normal
        
        /// The speed of the dash animation.
        public enum AnimationSpeed: Hashable, Codable {
            /// Slow
            case slow
            /// Normal
            case normal
            /// Fast
            case fast
            /// Custom between `0.0`  (slow) and `1.0` (fast).
            case custom(Double)
            
            var duration: CGFloat {
                let speed: CGFloat
                switch self {
                case .slow: speed = 0.8
                case .normal: speed = 0.5
                case .fast: speed = 0.2
                case .custom(let value): speed = value.clamped(to: 0...1.0)
                }
                return speed.interpolated(from: (0.0, 1.0), to: (3.0, 0.1))
            }
        }
        
        public init(pattern: [CGFloat] = [], phase: CGFloat = 0, lineCap: CGLineCap = .butt, lineJoin: CGLineJoin = .miter, mitterLimit: CGFloat = 10.0, animates: Bool = false, animationSpeed: AnimationSpeed = .normal) {
            self.pattern = pattern
            self.phase = phase
            self.lineCap = lineCap
            self.lineJoin = lineJoin
            self.mitterLimit = mitterLimit
            self.animates = animates
            self.animationSpeed = animationSpeed
        }
        
        /// No dash pattern.
        public static let none = Self()
    }
    
    /// Creates a border configuration.
    public init(color: NSUIColor? = nil, colorTransformer: ColorTransformer? = nil, width: CGFloat = 0.0, dash: Dash = .none, insets: NSDirectionalEdgeInsets = .init(0)) {
        self.color = color
        self.width = width
        self.dash = dash
        self.colorTransformer = colorTransformer
        self.insets = insets
    }
    
    /// A configuration without a border.
    public static let none = Self()
    
    /// Returns the configuration with the specified dash pattern.
    public func dashed(_ patterh: [CGFloat] = [4, 4], phase: CGFloat = 0, lineCap: CGLineCap = .butt, lineJoin: CGLineJoin = .miter, mitterLimit: CGFloat = 10.0, animates: Bool = false, animationSpeed: Dash.AnimationSpeed = .normal) -> Self {
        var configuration = self
        configuration.dash = Dash(pattern: patterh, phase: phase, lineCap: lineCap, lineJoin: lineJoin, mitterLimit: mitterLimit, animates: animates, animationSpeed: animationSpeed)
        return configuration
    }
    
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
        Self(color: color, width: width, dash: .init(pattern: patterh, animates: animates))
    }
    
    var isInvisible: Bool {
        width == 0.0 || resolvedColor() == nil || resolvedColor()?.cgColor.alpha ?? 1.0 <= 0.0
    }
    
    /**
     A Boolean value indicating whether the border is visible.
     
     The border is visible if the ``width`` is larger than `0` and the ``color`` isn't `nil` and has an alpha value larger than `0`.
     */
    var isVisible: Bool {
        width > 0.0 && resolvedColor()?.alphaComponent ?? 0.0 > 0.0
    }
    
    var needsDashedBorder: Bool {
        (insets != .zero || dash.pattern.count > 1) && !isInvisible
    }
}

extension BorderConfiguration.Dash {
    init(_ layer: CAShapeLayer) {
        lineCap = layer.lineCap.cgLineCap
        lineJoin = layer.lineJoin.cgLineJoin
        phase = layer.lineDashPhase
        pattern = layer.lineDashPattern?.compactMap({ CGFloat($0.doubleValue) }) ?? []
        mitterLimit = layer.miterLimit
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        color = try container.decode(.color)
        width = try container.decode(.width)
        dash = try container.decode(.dash)
        insets = try container.decode(.insets)
    }
}

extension BorderConfiguration.Dash.AnimationSpeed: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .custom(value)
    }
}

extension NSUIView {
    var dashedBorderView: DashedBorderView? {
        get { getAssociatedValue("dashedBorderView") }
        set { setAssociatedValue(newValue, key: "dashedBorderView") }
    }
}

extension NSAttributedString {
    /**
     Applies the specified border configuration to the attributed string.

     - Parameter border: The border configuration to apply.

     - Returns: A new sttributed string with the specified border configuration applied.
     */
    func stroke(_ stroke: BorderConfiguration?) -> NSAttributedString {
        if let stroke = stroke {
            if let color = stroke.resolvedColor() {
                return applyingAttributes([.strokeColor: color, .strokeWidth: stroke.width])
            }
            return removingAttributes([.strokeColor]).applyingAttributes([.strokeWidth: stroke.width])
        } else {
            return removingAttributes([.strokeColor, .strokeWidth])
        }
    }
    
    /// The stroke configuration of the attributed string.
    var stroke: BorderConfiguration? {
        guard let color = strokeColor, let width = strokeWidth else { return nil }
        return BorderConfiguration(color: color, width: width)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension AttributedString {
    /// The stroke configuration of the attributed string.
    var stroke: BorderConfiguration? {
        get { nsAttributedString.stroke }
        set {
            self.strokeColor = newValue?.resolvedColor()
            self.strokeWidth = newValue?.width
        }
    }
    
    /// Sets the stroke configuration of the attributed string.
    func stroke(_ stroke: BorderConfiguration?) -> AttributedString {
        var string = self
        string.stroke = stroke
        return string
    }
}

/// The Objective-C class for ``BorderConfiguration``.
public class __BorderConfiguration: NSObject, NSCopying {
    let configuration: BorderConfiguration
    
    public init(configuration: BorderConfiguration) {
        self.configuration = configuration
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __BorderConfiguration(configuration: configuration)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        configuration == (object as? __BorderConfiguration)?.configuration
    }
}

extension BorderConfiguration: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __BorderConfiguration
    
    public func _bridgeToObjectiveC() -> __BorderConfiguration {
        return __BorderConfiguration(configuration: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __BorderConfiguration, result: inout BorderConfiguration?) {
        result = source.configuration
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
                        dash: Dash(
                        \tpattern: \(dash.pattern)
                        \tphase: \(dash.phase)
                        \tlineCap: \(dash.lineCap.rawValue)
                        \tlineJoin: \(dash.lineJoin.rawValue)
                        mitterLimit: \(dash.mitterLimit)
                        \tanimates: \(dash.animates)
                        )
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
        "Dash(patterh: \(pattern), phase: \(phase), lineCap: \(lineCap.rawValue), animates: \(animates))"
    }
}

extension Shape {
    /**
     Traces the outline of this shape with the specified border configuration.
     
     - Parameter border: The border configuration.
     */
    @ViewBuilder
    public func stroke(_ border: BorderConfiguration) -> some View {
        if border.dash.pattern.count <= 1 {
            stroke(Color(border.resolvedColor() ?? .clear), lineWidth: border.width)
                .padding(border.insets.edgeInsets)
        } else {
            stroke(Color(border.resolvedColor() ?? .clear), style: StrokeStyle(lineWidth: border.width, lineCap: border.dash.lineCap, lineJoin: border.dash.lineJoin, dash: border.dash.pattern, dashPhase: border.dash.phase))
                .padding(border.insets.edgeInsets)
        }
    }
}

extension CGLineCap: Codable {
    public var shapeLayerLineCap: CAShapeLayerLineCap {
        switch self {
        case .round: return .round
        case .square: return .square
        default: return .butt
        }
    }
}

extension CGLineJoin: Codable {
    public var shapeLayerLineJoin: CAShapeLayerLineJoin {
        switch self {
        case .round: return .round
        case .bevel: return .bevel
        default: return .miter
        }
    }
}

public extension CAShapeLayerLineJoin {
    var cgLineJoin: CGLineJoin {
        switch self {
        case .round: return .round
        case .bevel: return .bevel
        default: return .miter
        }
    }
}

public extension CAShapeLayerLineCap {
    var cgLineCap: CGLineCap {
        switch self {
        case .round: return .round
        case .square: return .square
        default: return .butt
        }
    }
}

#endif
