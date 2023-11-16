//
//  TimingFunction.swift
//  
//
//  Created by Florian Zand on 20.10.23.
//

import Foundation

/// Timing functions are used to convert linear input time (`0.0 -> 1.0`) to transformed output time (also `0.0 -> 1.0`).
public enum TimingFunction {
    /// No easing.
    case linear
    
    /// The specified unit bezier is used to drive the timing function.
    case bezier(UnitBezier)
    
    /// The specified function is used as timing function.
    case function((Double)->(Double))
    
    /// Initializes a bezier timing function with the given control points.
    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self = .bezier(UnitBezier(x1: x1, y1: y1, x2: x2, y2: y2))
    }
        
    /**
     Transforms the specified time.
     
     - Parameters:
        - x: The input time (ranges between 0.0 and 1.0).
        - epsilon: The required precision of the result (where `x * epsilon` is the maximum time segment to be evaluated).
     - Returns: The resulting output time.
     */
    public func solve(at time: Double, epsilon: Double) -> Double {
        switch self {
        case .linear:
            return time
        case .bezier(let unitBezier):
            return unitBezier.solve(x: time, epsilon: epsilon)
        case .function(let function):
            return function(time)
        }
    }
    
    /**
     Transforms the specified time.
     
     - Parameters:
        - x: The input time (ranges between 0.0 and 1.0).
        - duration: The duration of the solving value. It is used to calculate the required precision of the result.
     - Returns: The resulting output time.
     */
    public func solve(at time: Double, duration: Double) -> Double {
        switch self {
        case .linear:
            return time
        case .bezier(let unitBezier):
            return unitBezier.solve(x: time, epsilon: 1.0 / (duration * 1000.0))
        case .function(let function):
            return function(time)
        }
    }
}

extension TimingFunction {
    /// A `easeIn` timing function, equivalent to `kCAMediaTimingFunctionEaseIn`.
    public static var easeIn: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 1.0, y2: 1.0)
    }
    
    /// A `easeOut` timing function, equivalent to `kCAMediaTimingFunctionEaseOut`.
    public static var easeOut: TimingFunction {
        return TimingFunction(x1: 0.0, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// A `easeInEaseOut` timing function, equivalent to `kCAMediaTimingFunctionEaseInEaseOut`.
    public static var easeInEaseOut: TimingFunction {
        return TimingFunction(x1: 0.42, y1: 0.0, x2: 0.58, y2: 1.0)
    }
    
    /// A `swiftOut` timing function, inspired by the default curve in Google Material Design.
    public static var swiftOut: TimingFunction {
        return TimingFunction(x1: 0.4, y1: 0.0, x2: 0.2, y2: 1.0)
    }
    
    /// A `easeInBounce` timing function.
    static var easeInBounce: TimingFunction {
        return TimingFunction.function({ x in
            return easeInBounce(x: x)
        })
    }
    
    /// A `easeOutBounce` timing function.
    static var easeOutBounce: TimingFunction {
        return TimingFunction.function({ x in
            return easeOutBounce(x: x)
        })
    }
    
    /// A `easeInOutBounce` timing function.
    static var easeInOutBounce: TimingFunction {
        return TimingFunction.function({ x in
            return easeInOutBounce(x: x)
        })
    }
    
    /// A `easeInOutCirc` timing function.
    static var easeInOutCirc: TimingFunction {
        return TimingFunction.function({ x in
            return easeInOutCirc(x: x)
        })
    }
}

private extension TimingFunction {
    static func easeOutBounce(x: Double) -> Double {
        if (x < 1 / 2.75) {
            return 7.5625 * x * x
        } else if (x < 2 / 2.75) {
            return 7.5625 * (x - 1.5 / 2.75) * (x - 1.5) + 0.75
        } else if (x < 2.5 / 2.75) {
            return 7.5625 * (x - 2.25 / 2.75) * (x - 2.25) + 0.9375
        } else {
            return 7.5625 * (x - 2.625 / 2.75) * (x - 2.625) + 0.984375
        }
    }

    static func easeInBounce(x: Double) -> Double {
        return 1 - easeOutBounce(x: 1 - x)
    }
    
    static func easeInOutBounce(x: Double) -> Double {
        if (x < 0.5) {
            return (1 - easeOutBounce(x: 1 - 2 * x)) / 2
        } else {
            return (1 + easeOutBounce(x: 2 * x - 1)) / 2
        }
    }
    
    static func easeInOutCirc(x: Double) -> Double {
        if (x < 0.5) {
            return (1 - sqrt(1 - pow(2 * x, 2))) / 2
        } else {
            return (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
        }
    }
}

extension TimingFunction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: TimingFunction, rhs: TimingFunction) -> Bool {
        switch (lhs, rhs) {
        case (.linear, .linear), (.easeOut, .easeOut), (.easeInEaseOut, .easeInEaseOut), (.swiftOut, .swiftOut), (.easeIn, .easeIn):
            return true
        case (.bezier(let bezier1), .bezier(let bezier2)):
            return bezier1 == bezier2
        default:
            return false
        }
    }
}

extension TimingFunction: CustomStringConvertible {
    /// The name of the timing function.
    public var name: String {
        switch self {
        case .linear:
            return "Linear"
        case .easeIn:
            return "EaseIn"
        case .easeOut:
            return "EaseOut"
        case .easeInEaseOut:
            return "EaseInEaseOut"
        case .swiftOut:
            return "SwiftOut"
        case .easeInOutCirc:
            return "EaseInOutCirc"
        case .easeInBounce:
            return "EaseInBounce"
        case .easeOutBounce:
            return "EaseOutBounce"
        case .easeInOutBounce:
            return "EaseInOutBounce"
        case .function(_):
            return "Function"
        case .bezier(let unitBezier):
            return "Bezier(x1: \(unitBezier.first.x),  y1: \(unitBezier.first.y), x2: \(unitBezier.second.x), y2: \(unitBezier.second.y))"
        }
    }
    
    public var description: String {
        return "TimingFunction: \(name)"
    }
}

#if canImport(QuartzCore)

import QuartzCore

extension TimingFunction {
    /// Initializes a timing function with a unit bezier derived from the given Core Animation timing function.
    public init(_ coreAnimationTimingFunction: CAMediaTimingFunction) {
        let controlPoints: [(x: Double, y: Double)] = (0...3).map { (index) in
            var rawValues: [Float] = [0.0, 0.0]
            coreAnimationTimingFunction.getControlPoint(at: index, values: &rawValues)
            return (x: Double(rawValues[0]), y: Double(rawValues[1]))
        }
        
        self.init(
            x1: controlPoints[1].x,
            y1: controlPoints[1].y,
            x2: controlPoints[2].x,
            y2: controlPoints[2].y)
    }
}

#endif
