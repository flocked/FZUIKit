//
//  VectorArithmetic+.swift
//
//
//  Created by Florian Zand on 20.10.23.
//

import Foundation
import SwiftUI

public extension VectorArithmetic {
    /// Multiplies each component of this value by the given value.
    static func * (lhs: inout Self, rhs: Double) {
        lhs.scale(by: rhs)
    }

    /// Returns a value with each component of this value multiplied by the given value.
    static func * (lhs: Self, rhs: Double) -> Self {
        lhs.scaled(by: rhs)
    }

    /// Divides each component of this value by the given value.
    static func / (lhs: inout Self, rhs: Double) {
        lhs.scale(by: 1.0 / rhs)
    }

    /// Returns a value with each component of this value divided by the given value.
    static func / (lhs: Self, rhs: Double) -> Self {
        lhs.scaled(by: 1.0 / rhs)
    }

    static prefix func - (lhs: Self) -> Self {
        lhs * -1
    }
}

public extension Collection where Element: VectorArithmetic {
    /// The average value of all values in the collection. If the collection is empty, it returns `zero.
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) * Double(count)
    }
}
