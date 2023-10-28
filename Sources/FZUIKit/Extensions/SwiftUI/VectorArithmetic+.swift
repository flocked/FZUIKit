//
//  VectorArithmetic+.swift
//
//
//  Created by Florian Zand on 20.10.23.
//

import Foundation
import Accelerate
import SwiftUI

public typealias AnimatableVector = Array<Double>

public protocol KyProtocol: Collection, BidirectionalCollection, MutableCollection, RandomAccessCollection, RangeReplaceableCollection, Sequence, AdditiveArithmetic, VectorArithmetic { }

extension Array: AdditiveArithmetic & VectorArithmetic where Element: VectorArithmetic  {
    public static func -= (lhs: inout Self, rhs: Self) {
        if var lh = lhs as? AnimatableVector, var rh = rhs as? AnimatableVector {
            Swift.print("aaa")
            let count = Swift.min(lh.count, rh.count)
            vDSP.subtract(lh[0..<count], rh[0..<count], result: &lh[0..<count])
            lhs = lh as! Self
        } else {
            let range = (lhs.startIndex..<lhs.endIndex)
                .clamped(to: rhs.startIndex..<rhs.endIndex)
            
            for index in range {
                lhs[index] -= rhs[index]
            }
        }
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        if var lh = lhs as? AnimatableVector, var rh = rhs as? AnimatableVector {
            Swift.print("aaa")
            let count = Swift.min(lh.count, rh.count)
            return vDSP.subtract(lh[0..<count], rh[0..<count]) as! Self
        }
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    public static func += (lhs: inout Self, rhs: Self) {
        if var lh = lhs as? AnimatableVector, var rh = rhs as? AnimatableVector {
            Swift.print("aaa")
            let count = Swift.min(lh.count, rh.count)
            vDSP.add(lh[0..<count], rh[0..<count], result: &lh[0..<count])
            lhs = lh as! Self
        } else {
            let range = (lhs.startIndex..<lhs.endIndex)
                .clamped(to: rhs.startIndex..<rhs.endIndex)
            for index in range {
                lhs[index] += rhs[index]
            }
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        if var lh = lhs as? AnimatableVector, var rh = rhs as? AnimatableVector {
            Swift.print("aaa")
            let count = Swift.min(lh.count, rh.count)
            return vDSP.add(lh[0..<count], rh[0..<count]) as! Self
        }
        var lhs = lhs
        lhs += rhs
        return lhs
    }

    mutating public func scale(by rhs: Double) {
        if var value = self as? AnimatableVector {
            Swift.print("aaa")
            self = vDSP.multiply(rhs, value) as! Self
        } else {
            for index in startIndex..<endIndex {
                self[index].scale(by: rhs)
            }
        }
    }

    public var magnitudeSquared: Double {
        if var value = self as? AnimatableVector {
           return vDSP.sum(vDSP.multiply(value, value))
        }
       return reduce(into: 0.0) { (result, new) in
            result += new.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
}

extension VectorArithmetic where Self == Array<Double> {
    public static func + (lhs: Self, rhs: Self) -> Self {
        Swift.print("hhh")
        let count = Swift.min(lhs.count, rhs.count)
        return vDSP.add(lhs[0..<count], rhs[0..<count])
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        Swift.print("hhh")
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.add(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Swift.print("hhh")
        let count = Swift.min(lhs.count, rhs.count)
        return vDSP.subtract(lhs[0..<count], rhs[0..<count])
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        Swift.print("hhh")

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

extension VectorArithmetic where Self == Array<Float> {
    public static func + (lhs: Self, rhs: Self) -> Self {
        let count = Swift.min(lhs.count, rhs.count)
        return vDSP.add(lhs[0..<count], rhs[0..<count])
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.add(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        let count = Swift.min(lhs.count, rhs.count)
        return vDSP.subtract(lhs[0..<count], rhs[0..<count])
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        let count = Swift.min(lhs.count, rhs.count)
        vDSP.subtract(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
    }


    public mutating func scale(by rhs: Float) {
        self = vDSP.multiply(rhs, self)
    }

    public var magnitudeSquared: Float {
        vDSP.sum(vDSP.multiply(self, self))
    }
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
        lhs.scale(by: 1.0 / rhs)
    }
    
    public static func / (lhs: Self, rhs: Double) -> Self {
        return lhs.scaled(by: 1.0 / rhs)
    }
    
    public static prefix func - (lhs: Self) -> Self {
        lhs * -1
    }
}

/*
 extension AnimatableVector {
     public static func * (lhs: Self, rhs: Self) -> Self {
         vDSP.multiply(lhs, rhs)
     }
     
     public static func *= (lhs: inout Self, rhs: Self) {
         let count = Swift.min(lhs.count, rhs.count)
         vDSP.multiply(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
     }
     
     public static func / (lhs: Self, rhs: Self) -> Self {
         vDSP.divide(lhs, rhs)
     }
     
     public static func /= (lhs: inout Self, rhs: Self) {
         let count = Swift.min(lhs.count, rhs.count)
         vDSP.divide(lhs[0..<count], rhs[0..<count], result: &lhs[0..<count])
     }
 }
 
 extension AnimatableData {
     public static func + (lhs: Self, rhs: Self) -> Self {
         Self(lhs.animatableData + rhs.animatableData)
     }
     
     public static func - (lhs: Self, rhs: Self) -> Self {
         Self(lhs.animatableData - rhs.animatableData)
     }
     
     public func scaled(by rhs: Double) -> Self {
         Self(self.animatableData.scaled(by: rhs))
     }
     
     public var magnitudeSquared: Double {
         self.animatableData.magnitudeSquared
     }
 }


 */
