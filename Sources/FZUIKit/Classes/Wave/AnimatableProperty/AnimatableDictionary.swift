//
//  AnimatableDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation
import SwiftUI
import Accelerate

/// A dictionary that can serve as the animatable data of an animatable type (see ``AnimatableData``).
public struct AnimatableDictionary< Key: Hashable, Value: VectorArithmetic & AdditiveArithmetic>: Collection, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: Key, value: Value)

    public init(dictionaryLiteral elements: (Value, Key)...) {
        self.dictionary = [:]
        for element in elements {
            self.dictionary[element.1] = element.0
        }
    }
    
    public init(dict: [Key: Value] = [Key:Value]()) {
        self.dictionary = dict
    }
    
    public init() {
        self.dictionary = [:]
    }
    
    public init(minimumCapacity: Int) {
        self.dictionary = .init(minimumCapacity: minimumCapacity)
    }
    
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        self.dictionary = .init(uniqueKeysWithValues: keysAndValues)
    }
    
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.dictionary = try .init(keysAndValues, uniquingKeysWith: combine)
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
    
    var capacity: Int {
        self.dictionary.capacity
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
    
    @discardableResult
    mutating func remove(at index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        self.dictionary.remove(at: index)
    }
    
    var first: AnimatableDictionary.Element? {
        self.dictionary.first
    }
    
    func randomElement() -> Self.Element? {
        self.dictionary.randomElement()
    }
    func randomElement<T>(using generator: inout T) -> Self.Element? where T : RandomNumberGenerator {
        self.dictionary.randomElement(using: &generator)
    }
    
    @discardableResult
    mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        dictionary.updateValue(value, forKey: key)
    }
    
    mutating func merge(_ other: [Key : Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }
    
    mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        try dictionary.merge(other, uniquingKeysWith: combine)
    }
    
    func merging(_ other: [Key : Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key : Value] {
        try dictionary.merging(other, uniquingKeysWith: combine)
    }
    
    func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key : Value] where S : Sequence, S.Element == (Key, Value) {
        try dictionary.merging(other, uniquingKeysWith: combine)
    }
    
    mutating func reserveCapacity(_ minimumCapacity: Int) {
        dictionary.reserveCapacity(minimumCapacity)
    }
}

extension AnimatableDictionary: @unchecked Sendable where Element: Sendable { }

extension AnimatableDictionary: Comparable where Value: Comparable {
    public static func < (lhs: AnimatableDictionary<Key, Value>, rhs: AnimatableDictionary<Key, Value>) -> Bool {
        lhs.values < rhs.values
    }
}

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
                if let lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    lhs[keyValue.key] = AnimatableArray<Double>(lhsValues - rhsValues) as? Value
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
                if let lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    lhs[keyValue.key] = AnimatableArray<Double>(lhsValues - rhsValues) as? Value
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
                if let lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    lhs[keyValue.key] = AnimatableArray<Double>(lhsValues + rhsValues) as? Value
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
                if let lhsValues = keyValue.value as? AnimatableVector, let rhsValues = rhsValues as? AnimatableVector {
                    lhs[keyValue.key] = AnimatableArray<Double>(lhsValues + rhsValues) as? Value
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
                self[keyValue.key] = value.scaled(by: rhs) as? Value
            } else {
                self[keyValue.key] = keyValue.value.scaled(by: rhs)
            }
        }
    }
    
    public var magnitudeSquared: Double {
        if let values = self.values as? [AnimatableVector] {
            return AnimatableVector(values.flatMap({$0.elements})).magnitudeSquared
        }
       return reduce(into: 0.0) { (result, new) in
           result += new.value.magnitudeSquared
        }
    }
    
    public static var zero: Self { .init() }
}
