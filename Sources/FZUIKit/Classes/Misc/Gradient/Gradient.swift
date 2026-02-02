//
//  Gradient.swift
//
//
//  Created by Florian Zand on 13.05.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// A color gradient.
public struct Gradient: Hashable {
    /// The color stops of the gradient.
    public var stops: [ColorStop] = []
    
    /// The start point of the gradient.
    public var startPoint: FractionalPoint = .top
    
    /// The end point of the gradient.
    public var endPoint: FractionalPoint = .bottom
    
    /// The type of gradient.
    public var type: GradientType = .linear
    
    public var colorSpace: ColorModels.ColorSpace? = nil
    
    /// The colors of the gradient.
    public var colors: [NSUIColor] {
        get { stops.map({ $0.color }) }
        set { stops = newValue.stops }
    }
    
    /// Returns the gradient with the specified color stops.
    @discardableResult
    public func stops(_ stops: [ColorStop]) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified colors.
    @discardableResult
    public func colors(_ colors: [NSUIColor]) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified opacity.
    @discardableResult
    public func opacity(_ opacity: CGFloat) -> Self {
        Self(stops: stops.map({ $0.opacity(opacity) }), startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified opacity range.
    @discardableResult
    func opacity(_ range: ClosedRange<CGFloat>) -> Self {
        Self(stops: stops.opacity(range), startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified opacity range.
    @discardableResult
    func opacity(_ range: Range<CGFloat>) -> Self {
        Self(stops: stops.opacity(range), startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified start point.
    @discardableResult
    public func startPoint(_ startPoint: FractionalPoint) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified end point.
    @discardableResult
    public func endPoint(_ endPoint: FractionalPoint) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /// Returns the gradient with the specified gradient type.
    @discardableResult
    public func type(_ type: GradientType) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: type)
    }
    
    /**
     Creates a gradient from an array of colors.
     
     The gradient synthesizes its location values to evenly space the colors along the gradient.
     
     - Parameters:
        - colors: An array of colors.
        - startPoint: The start point of the gradient.
        - endPoint: The end point of the gradient.
        - type: The type of gradient.
     */
    public init(colors: [NSUIColor], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom, type: GradientType = .linear) {
        stops = colors.stops
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    /**
     Creates a gradient from an array of color stops.
     
     - Parameters:
        - stops: An array of color stops.
        - startPoint: The start point of the gradient.
        - endPoint: The end point of the gradient.
        - type: The type of gradient.
     */
    public init(stops: [ColorStop], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom, type: GradientType = .linear) {
        self.stops = stops
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    /**
     Returns a gradient for the specified preset.
     
     - Parameters:
        - preset: The gradient preset.
        - startPoint: The start point of the gradient.
        - endPoint: The end point of the gradient.
        - type: The type of gradient.
     */
    public init(preset: Preset, startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom, type: GradientType = .linear) {
        stops = preset.colors.stops
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.type = type
    }
    
    /// A linear gradient with the specified colors.
    public static func linear(_ colors: [NSUIColor], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: .linear)
    }
    
    /// A linear gradient with the specified color stops.
    public static func linear(_ stops: [ColorStop], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .linear)
    }
    
    /// A linear gradient with the specified preset.
    public static func linear(_ preset: Preset, startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(preset: preset, startPoint: startPoint, endPoint: endPoint, type: .linear)
    }
    
    /// A conic gradient with the specified colors.
    public static func conic(_ colors: [NSUIColor], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: .conic)
    }
    
    /// A conic gradient with the specified color stops.
    public static func conic(_ stops: [ColorStop], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .conic)
    }
    
    /// A conic gradient with the specified preset.
    public static func conic(_ preset: Preset, startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(preset: preset, startPoint: startPoint, endPoint: endPoint, type: .conic)
    }
    
    /// A radial gradient with the specified colors.
    public static func radial(_ colors: [NSUIColor], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(colors: colors, startPoint: startPoint, endPoint: endPoint, type: .radial)
    }
    
    /// A radial gradient with the specified color stops.
    public static func radial(_ stops: [ColorStop], startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(stops: stops, startPoint: startPoint, endPoint: endPoint, type: .radial)
    }
    
    /// A radial gradient with the specified preset.
    public static func radial(_ preset: Preset, startPoint: FractionalPoint = .top, endPoint: FractionalPoint = .bottom) -> Self {
        Self(preset: preset, startPoint: startPoint, endPoint: endPoint, type: .radial)
    }
    
    /// An empty gradient.
    public static let none = Gradient(stops: [])
}

public extension Gradient {
    /// The gradient type.
    enum GradientType: Int, Hashable, CustomStringConvertible {
        /// Linear gradient.
        case linear
        /// Conic gradient.
        case conic
        /// Radial gradient.
        case radial
        
        public var description: String {
            switch self {
            case .conic: return "conic"
            case .radial: return "radial"
            case .linear: return "axial"
            }
        }
        
        var gradientLayerType: CAGradientLayerType {
            CAGradientLayerType(rawValue: description)
        }
        
        init(_ gradientLayerType: CAGradientLayerType) {
            switch gradientLayerType {
            case .conic: self = .conic
            case .radial: self = .radial
            default: self = .linear
            }
        }
    }
    
    /// Color stop in a gradient.
    struct ColorStop: Hashable, CustomStringConvertible {
        /// The color for the stop.
        public var color: NSUIColor
        /// The parametric location of the stop.
        public var location: CGFloat
        
        public var description: String {
            "[color: \(color), location: \(location)]"
        }
        
        /// Returns the color stop with the specified color.
        public func color(_ color: NSUIColor) -> Self {
            Self(color: color, location: location)
        }
        
        /// Returns the color stop with the specified color opacity.
        public func opacity(_ opacity: CGFloat) -> Self {
            Self(color: color.withAlphaComponent(opacity), location: location)
        }
        
        /// Returns the color stop with the specified parametric location.
        public func location(_ location: CGFloat) -> Self {
            Self(color: color, location: location)
        }
        
        var transparent: Self {
            Self(color: color.withAlphaComponent(0.0), location: location)
        }
        
        /// Creates a color stop with a color and location.
        public init(color: NSUIColor, location: CGFloat) {
            self.color = color
            self.location = location
        }
    }
}

/// The Objective-C class for ``Gradient``.
public class __Gradient: NSObject, NSCopying {
    let gradient: Gradient
    
    init(_ gradient: Gradient) {
        self.gradient = gradient
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __Gradient(gradient)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        gradient == (object as? __Gradient)?.gradient
    }
}

extension Gradient: ReferenceConvertible {
    /// The Objective-C type for the configuration.
    public typealias ReferenceType = __Gradient
    
    public func _bridgeToObjectiveC() -> __Gradient {
        return __Gradient(self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __Gradient, result: inout Gradient?) {
        result = source.gradient
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __Gradient, result: inout Gradient?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __Gradient?) -> Gradient {
        if let source = source {
            var result: Gradient?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return Gradient(colors: [])
    }
    
    public var description: String {
        "[stops: \(stops), type: \(type), start: \(startPoint), end: \(endPoint)]"
    }
    
    public var debugDescription: String {
        description
    }
}

fileprivate extension [NSUIColor] {
    var stops: [Gradient.ColorStop] {
        var stops: [Gradient.ColorStop] = []
        if count == 1 {
            stops.append(.init(color: self[0], location: 0.0))
        } else if count > 1 {
            let split = 1.0 / CGFloat(count - 1)
            for i in 0 ..< count {
                stops.append(.init(color: self[i], location: split * CGFloat(i)))
            }
        }
        return stops
    }
}

fileprivate extension [Gradient.ColorStop] {
    func opacity(_ range: ClosedRange<CGFloat>) -> Self {
        guard !isEmpty else { return [] }
        let step = count > 1 ? (range.upperBound - range.lowerBound) / CGFloat(count - 1) : 0
        return (0..<count).map { self[$0].location(range.lowerBound + (CGFloat($0) * step)) }
    }
    
    func opacity(_ range: Range<CGFloat>) -> Self {
        guard !isEmpty else { return [] }
        let step = (range.upperBound - range.lowerBound) / CGFloat(count)
        return (0..<count).map { self[$0].location(range.lowerBound + (CGFloat($0) * step)) }
    }
}

public extension Gradient {
    /**
     Returns a `CGGradient` representation of the gradient.
     
     - Parameter colorSpace: The color space of the gradient, or `nil` to use the default color space.
     */
    func cgGradient(colorSpace: CGColorSpace? = nil) -> CGGradient? {
        guard stops.count > 0 else { return nil }
        return CGGradient(colorsSpace: colorSpace, colors: stops.map { $0.color.cgColor } as CFArray, locations: stops.map { $0.location })
    }
    
    /**
     Returns a `CGGradient` representation of the gradient.
     
     - Parameter colorSpace: The name of the color space for the gradient.
     */
    func cgGradient(colorSpace: CGColorSpaceName) -> CGGradient? {
        cgGradient(colorSpace: CGColorSpace(name: colorSpace))
    }
}

extension Gradient.ColorStop {
    
}

extension Gradient {
    func resolved() -> Gradient {
        guard let colorSpace = colorSpace else { return self }
        switch colorSpace {
        case .srgb: return self
        case .cmyk:
            guard let colorSpace = CGColorSpace(name: .extendedDisplayP3) else { break }
            let newStops = stops.compactMap({ stop in stop.color.usingColorSpace(colorSpace).map({ ColorStop(color: $0, location:  stop.location) }) })
            guard newStops.count == stops.count else { break }
            var gradient = self
            gradient.stops = newStops
            return gradient
        default: break
        }
        return resampled(in: colorSpace) ?? self
    }
    
    public func resampled(in colorSpace: ColorModels.ColorSpace, samplesPerUnit: CGFloat = 24) -> Self? {
        guard stops.count >= 2 else { return nil }
        var newStops: [ColorStop] = .init(reserveCapacity: stops.count * Int(samplesPerUnit))
        for (index, pair) in zip(stops, stops.dropFirst()).enumerated() {
            let stop1 = pair.0
            let stop2 = pair.1
            let delta = stop2.location - stop1.location
            let length = abs(delta)
            guard length > 0 else { continue }
            let color1 = stop1.color.components(for: colorSpace)
            let color2 = stop2.color.components(for: colorSpace)
            let sampleCount = max(2, Int(ceil(length * samplesPerUnit)))
            let startIndex = (index == 0) ? 0 : 1
            for i in startIndex..<sampleCount {
                let t = CGFloat(i) / CGFloat(sampleCount - 1)
                let location = stop1.location + t * delta
                #if os(macOS)
                let color = color1._mixed(with: color2, by: t).nsColor
                #else
                let color = color1._mixed(with: color2, by: t).uiColor
                #endif
                newStops.append(ColorStop(color: color, location: location))
            }
        }
        var gradient = self
        gradient.stops = newStops
        return gradient
    }
}

extension ColorModel {
    func _mixed(with color: any ColorModel, by fraction: Double) -> Self {
        mixed(with: color as! Self, by: fraction)
    }
}

extension NSUIColor {
    func components(for colorSpace: ColorModels.ColorSpace) -> any ColorModel {
        switch colorSpace {
        case .srgb: rgb()
        case .hsl: hsl()
        case .hsb: hsb()
        case .oklab: oklab()
        case .oklch: oklch()
        case .okhsb: okhsb()
        case .okhsl: okhsl()
        case .xyz: xyz()
        case .lab: lab()
        case .lch: lch()
        case .luv: luv()
        case .hpluv: hpluv()
        case .gray: gray()
        case .cmyk: cmyk()
        case .displayP3: displayP3()
        case .hwb: hwb()
        case .lchuv: lchuv()
        case .hsluv: hsluv()
        case .jzczhz: jzczhz()
        case .jzazbz: jzazbz()
        }
    }
}

#endif
