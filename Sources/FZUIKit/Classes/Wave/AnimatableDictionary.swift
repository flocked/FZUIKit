//
//  AnimatableDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation
import SwiftUI
import Accelerate

/// A synchronized dictionary.
public struct AnimatableDictionary< Key: Hashable, Value: VectorArithmetic & AdditiveArithmetic>: Collection, ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Value, Key)...) {
        self.dictionary = [:]
        for element in elements {
            self.dictionary[element.1] = element.0
        }
    }
    
    public init(dict: [Key: Value] = [Key:Value]()) {
        self.dictionary = dict
    }
    
    private var dictionary: [Key:Value]
}

public extension AnimatableDictionary {
    mutating func edit(_ edit: @escaping (inout [Key:Value])->()) {
        edit(&self.dictionary)
    }
    
    var startIndex: Dictionary<Key, Value>.Index {
        return self.dictionary.startIndex
    }
    
    var endIndex: Dictionary<Key, Value>.Index {
        return self.dictionary.endIndex
    }
    
    var isEmpty: Bool {
        return self.dictionary.isEmpty
    }
    
    var count: Int {
        return self.dictionary.count
    }
    
    func forEach(_ body: ((key: Key, value: Value)) throws -> Void) rethrows {
        try self.dictionary.forEach(body)
    }
    
    func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        return self.dictionary.index(after: i)
    }
    
    func filter(_ isIncluded: ((_ key: Key, _ value: Value) throws -> Bool)) rethrows -> [Key: Value] {
        return try self.dictionary.filter(isIncluded)
    }
    
    func map(_ transform: ((_ key: Key, _ value: Value) throws -> Value)) rethrows -> [Value] {
        return try self.dictionary.map(transform)
    }
    
    var keys: [Key] {
        Array(self.dictionary.keys)
    }
    
    var values: [Value] {
        Array(self.dictionary.values)
    }

    subscript(key: Key) -> Value? {
        set(newValue) {
            self.dictionary[key] = newValue
        }
        get {
            return self.dictionary[key]
        }
    }

    subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
            return self.dictionary[index]
    }
    
    mutating func removeValue(forKey key: Key) {
        self.dictionary.removeValue(forKey: key)
    }

    mutating func removeAll(keepingCapacity: Bool = false) {
        self.dictionary.removeAll(keepingCapacity: keepingCapacity)
    }
}

extension AnimatableDictionary: @unchecked Sendable where Element: Sendable { }


extension AnimatableDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        return dictionary.customMirror
    }

    public var debugDescription: String {
        return dictionary.debugDescription
    }
    
    public var description: String {
        return dictionary.description
    }
}

extension AnimatableDictionary: VectorArithmetic & AdditiveArithmetic {
    public static func -= (lhs: inout Self, rhs: Self) {
        for keyValue in lhs {
            if let rhsValues = rhs[keyValue.key] {
                if var lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    let count = Swift.min(lhsValues.count, rhsValues.count)
                    vDSP.subtract(lhsValues[0..<count], rhsValues[0..<count], result: &lhsValues[0..<count])
                    lhs[keyValue.key] = lhsValues as? Value
                } else {
                    lhs[keyValue.key] = keyValue.value - rhsValues
                }
            }
        }
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        for keyValue in lhs {
            if let rhsValues = rhs[keyValue.key] {
                if var lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    let count = Swift.min(lhsValues.count, rhsValues.count)
                    lhsValues =  AnimatableArray<Double>(vDSP.subtract(lhsValues[0..<count], rhsValues[0..<count]))
                    lhs[keyValue.key] = AnimatableArray<Double>(vDSP.subtract(lhsValues[0..<count], rhsValues[0..<count])) as? Value
                } else {
                    lhs[keyValue.key] = keyValue.value - rhsValues
                }
            }
        }
        return lhs
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        for keyValue in lhs {
            if let rhsValues = rhs[keyValue.key] {
                if var lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    let count = Swift.min(lhsValues.count, rhsValues.count)
                    vDSP.add(lhsValues[0..<count], rhsValues[0..<count], result: &lhsValues[0..<count])
                    lhs[keyValue.key] = lhsValues as? Value
                } else {
                    lhs[keyValue.key] = keyValue.value + rhsValues
                }
            }
        }
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        for keyValue in lhs {
            if let rhsValues = rhs[keyValue.key] {
                if var lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    let count = Swift.min(lhsValues.count, rhsValues.count)
                    lhsValues =  AnimatableArray<Double>(vDSP.subtract(lhsValues[0..<count], rhsValues[0..<count]))
                    lhs[keyValue.key] = AnimatableArray<Double>(vDSP.add(lhsValues[0..<count], rhsValues[0..<count])) as? Value
                } else {
                    lhs[keyValue.key] = keyValue.value + rhsValues
                }
            }
        }
        return lhs
    }
    
    public mutating func scale(by rhs: Double) {
        for keyValue in self {
            if let value = keyValue.value as? AnimatableArray<Double> {                
                self[keyValue.key] = vDSP.multiply(rhs, value.elements) as? Value
            } else {
                self[keyValue.key] = keyValue.value.scaled(by: rhs)
            }
        }
    }
    
    public var magnitudeSquared: Double {
        if let values = self.values as? [AnimatableVector] {
           let elements = values.flatMap({$0.elements})
            return vDSP.sum(vDSP.multiply(elements, elements))
        }
       return reduce(into: 0.0) { (result, new) in
           result += new.value.magnitudeSquared
        }
    }
    
    public static var zero: Self { .init() }
}

extension AnimatableDictionary: Comparable where Value: Comparable {
    public static func < (lhs: AnimatableDictionary<Key, Value>, rhs: AnimatableDictionary<Key, Value>) -> Bool {
        let lhsValues = lhs.values
        let rhsValues = rhs.values
        let count = Swift.min(lhsValues.count, rhsValues.count)
        for value in zip(lhsValues[0..<count], rhsValues[0..<count]) {
            if value.0 > value.1 {
                return false
            }
        }
        return true
    }
    
    
}
