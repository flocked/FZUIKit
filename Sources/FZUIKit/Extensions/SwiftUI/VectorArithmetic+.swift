//
//  VectorArithmetic+.swift
//
//
//  Created by Florian Zand on 20.10.23.
//

import SwiftUI
import Accelerate
import Foundation

public typealias AnimatableVector = Array<Double>

extension Array: AdditiveArithmetic, VectorArithmetic where Self.Element == Double {
    public static var zero: Self = [0.0]
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        vDSP.add(lhs, rhs)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        vDSP.subtract(lhs, rhs)
    }

    public static func += (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.add(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.subtract(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }

    public mutating func scale(by rhs: Double) {
        self = vDSP.multiply(rhs, self)
    }

    public var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(self, self))
    }
}

extension AnimatablePair: ExpressibleByArrayLiteral where First == Second {
    public init(arrayLiteral elements: First...) {
        self.init(elements[0], elements[1])
    }
}

extension VectorArithmetic {
    public static func * (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: rhs)
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: rhs)
    }
}
