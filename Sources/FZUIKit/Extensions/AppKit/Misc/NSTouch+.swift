//
//  NSTouch+.swift
//
//
//  Created by Florian Zand on 22.02.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTouch {
    /// The position of the touch for the specified size.
    public func position(for size: CGSize) -> CGPoint {
        CGPoint(x: normalizedPosition.x * size.width, y: normalizedPosition.y * size.height)
    }
 
    var id: ObjectIdentifier {
        ObjectIdentifier(identity)
    }
}

extension Sequence where Element == NSTouch {
    /// Returns the offset of each touch compared to the specified touches.
    public func offsets<S: Sequence<NSTouch>>(to previousTouches: S) -> [NSTouch: CGPoint] {
        var offsets: [NSTouch: CGPoint] = [:]
        let previousTouchesDict = Dictionary(uniqueKeysWithValues: previousTouches.map { ($0.id, $0) })
        for touch in self {
            if let oldTouch = previousTouchesDict[touch.id] {
                offsets[touch] = CGPoint(x: touch.normalizedPosition.x - oldTouch.normalizedPosition.x, y: touch.normalizedPosition.y - oldTouch.normalizedPosition.y)
            }
        }
        return offsets
    }
}

extension Collection where Element == NSTouch {
    /**
     Returns the total offset the touches moved, compared to the specified touches.
     
     If the minimum or maximum amount of touches allowed isn't matched, `zero` is returned.
     
     - Parameters:
        - previousTouches: The touches to compare.
        - minimumTouches: The minimum amount of touches required.
        - maximumTouches: The maximum amount of touches allowed.
     */
    public func totalOffset<S: Collection<NSTouch>>(to previousTouches: S, minimumTouches: Int = 1, maximumTouches: Int = .max) -> CGPoint {
        guard count >= minimumTouches, count <= maximumTouches, count == previousTouches.count else {
            return .zero
        }
        return offsets(to: previousTouches).values.reduce(into: CGPoint.zero) { totalOffset, offset in
            totalOffset += offset
        }
    }
}


#endif
