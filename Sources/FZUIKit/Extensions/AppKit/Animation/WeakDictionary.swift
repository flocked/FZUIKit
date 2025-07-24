//
//  WeakDictionary.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation
import SwiftUI
import FZSwiftUtils

struct WeakDictionary<Key: AnyObject & Hashable, Value>: Collection, Sequence, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: Key, value: Value)

    var dictionary: [Weak<Key>: Value]

    public init(dictionaryLiteral elements: (Value, Key)...) {
        dictionary = [:]
        for element in elements {
            dictionary[Weak(element.1)] = element.0
        }
    }

    public init(dict: [Key: Value] = [Key: Value]()) {
        dictionary = dict.mapKeys({ Weak($0)})
    }

    public init() {
        dictionary = [:]
    }

    public init(minimumCapacity: Int) {
        dictionary = .init(minimumCapacity: minimumCapacity)
    }

    public init<S>(uniqueKeysWithValues keysAndValues: S) where S: Sequence, S.Element == (Key, Value) {
        dictionary = Dictionary(uniqueKeysWithValues: keysAndValues).mapKeys({ Weak($0)})
    }

    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        dictionary = try Dictionary(keysAndValues, uniquingKeysWith: combine).mapKeys({ Weak($0)})
    }

    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S: Sequence {
        dictionary = (try Dictionary(grouping: values, by: keyForValue)).mapKeys({ Weak($0)})
    }

    public mutating func edit(_ edit: @escaping (inout [Key: Value]) -> Void) {
        var dic = dictionary.nonNil
        edit(&dic)
        dictionary = dic.mapKeys({Weak($0)})
    }
    
    mutating func upateNonNil() {
        dictionary = dictionary.filter({$0.key.object != nil })
    }

    public var isEmpty: Bool {
        dictionary.isEmpty
    }

    public var count: Int {
        dictionary.count
    }

    public var capacity: Int {
        dictionary.capacity
    }
    
    public var startIndex: Dictionary<Key, Value>.Index {
        dictionary.nonNil.startIndex
    }

    public var endIndex: Dictionary<Key, Value>.Index {
        dictionary.nonNil.endIndex
    }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        dictionary.nonNil.index(after: i)
    }

    public func index(forKey key: Key) -> Dictionary<Key, Value>.Index? {
        dictionary.nonNil.index(forKey: key)
    }

    public subscript(position: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        dictionary.nonNil[position]
    }

    public subscript(key: Key) -> Value? {
        set(newValue) {
            if let key = dicKey(for: key) {
                dictionary[key] = newValue
            } else {
                dictionary[Weak(key)] = newValue
            }
        }
        get {
            guard let key = dicKey(for: key) else { return nil }
            return dictionary[key]
        }
    }

    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            if let key = dicKey(for: key) {
                return dictionary[key, default: defaultValue()]
            } else {
                return dictionary[Weak(key), default: defaultValue()]
            }
        }
        set {
            if let key = dicKey(for: key) {
                dictionary[key, default: defaultValue()] = newValue
            } else {
                dictionary[Weak(key), default: defaultValue()] = newValue
            }
        }
    }
    
    func dicKey(for key: Key) -> Weak<Key>? {
        dictionary.keys.first(where: {$0.object === key })
    }

    public var keys: [Key] {
        Array(dictionary.keys.compactMap({$0.object}))
    }

    public var values: [Value] {
        Array(dictionary.values)
    }

    public var first: WeakDictionary.Element? {
        guard let first = dictionary.first, let key = first.key.object else { return nil }
        return (key, first.value)
    }

    public mutating func removeValue(forKey key: Key) {
        guard let key = dicKey(for: key) else { return }
        dictionary.removeValue(forKey: key)
    }

    public mutating func removeAll(keepingCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepingCapacity)
    }

    @discardableResult
    public mutating func remove(at index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        var dic = dictionary.nonNil
        let removed = dic.remove(at: index)
        dictionary = dic.mapKeys({Weak($0)})
        return removed
    }

    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        guard let key = dicKey(for: key) else { return nil }
        return dictionary.updateValue(value, forKey: key)
    }

    public mutating func merge(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        var dic = dictionary.nonNil
        try dic.merge(other, uniquingKeysWith: combine)
        dictionary = dic.mapKeys({Weak($0)})
    }

    public mutating func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S: Sequence, S.Element == (Key, Value) {
        var dic = dictionary.nonNil
        try dic.merge(other, uniquingKeysWith: combine)
        dictionary = dic.mapKeys({Weak($0)})
    }

    public func merging(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] {
        try dictionary.nonNil.merging(other, uniquingKeysWith: combine)
    }

    public func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key: Value] where S: Sequence, S.Element == (Key, Value) {
        try dictionary.nonNil.merging(other, uniquingKeysWith: combine)
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        dictionary.reserveCapacity(minimumCapacity)
    }
}

extension WeakDictionary: @unchecked Sendable where Element: Sendable {}
extension WeakDictionary: Equatable where Value: Equatable {}
extension WeakDictionary: Hashable where Value: Hashable {}
// extension WeakDictionary: Encodable where Key: Encodable, Value: Encodable {}
// extension WeakDictionary: Decodable where Key: Decodable, Value: Decodable {}

extension WeakDictionary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        dictionary.customMirror
    }

    public var debugDescription: String {
        dictionary.debugDescription
    }

    public var description: String {
        dictionary.description
    }
}

extension WeakDictionary: CVarArg {
    public var _cVarArgEncoding: [Int] {
        dictionary._cVarArgEncoding
    }
}
