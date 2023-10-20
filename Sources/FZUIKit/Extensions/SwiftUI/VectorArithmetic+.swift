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
/*
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
*/

extension Array: AdditiveArithmetic & VectorArithmetic where Element: VectorArithmetic  {
    public static func -= (lhs: inout Self, rhs: Self) {
        let range = (lhs.startIndex..<lhs.endIndex)
            .clamped(to: rhs.startIndex..<rhs.endIndex)

        for index in range {
            lhs[index] -= rhs[index]
        }
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    public static func += (lhs: inout Self, rhs: Self) {
        let range = (lhs.startIndex..<lhs.endIndex)
            .clamped(to: rhs.startIndex..<rhs.endIndex)
        for index in range {
            lhs[index] += rhs[index]
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    mutating public func scale(by rhs: Double) where Self == Array<Double> {
        Swift.print("Here Double")
        for index in startIndex..<endIndex {
            self[index].scale(by: rhs)
        }
    }
    
    mutating public func scale(by rhs: Double) where Self == Array<CGFloat> {
        Swift.print("Here CGFloat")
        for index in startIndex..<endIndex {
            self[index].scale(by: rhs)
        }
    }

    mutating public func scale(by rhs: Double) {
        for index in startIndex..<endIndex {
            self[index].scale(by: rhs)
        }
    }

    public var magnitudeSquared: Double {
        reduce(into: 0.0) { (result, new) in
            result += new.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
}


extension AnimatablePair: ExpressibleByArrayLiteral where First == Second {
    public init(arrayLiteral elements: First...) {
        self.init(elements[0], elements[1])
    }
}

extension AnimatablePair: Comparable where First: Comparable, First == Second {
    public static func < (lhs: AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) -> Bool {
        lhs.first < rhs.first && lhs.second < rhs.second
    }
}

extension VectorArithmetic {
    public static func * (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: rhs)
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: rhs)
    }
    
    public static func / (lhs: inout Self, rhs: Double)  {
        lhs.scale(by: 1.0 - rhs)
    }
    
    public static func / (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: 1.0 - rhs)
    }
}

