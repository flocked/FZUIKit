//
//  ArrayBase.swift
//
//
//  Created by Florian Zand on 15.10.21.
//

/*
import Foundation
import SwiftUI
import Accelerate
import FZSwiftUtils

/// An array that can serve as the animatable data of an animatable type (see ``AnimatableData``).
public struct AnimatableDataArray<Element: AnimatableData> {
    internal var elements: [Element] = []

    public init() {}

    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
    
    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.elements = .init(elements)
    }

    public init(repeating repeatedValue: Element, count: Int) {
        elements = .init(repeating: repeatedValue, count: count)
    }
    
    public subscript(index: Int) -> Element {
        get {  return elements[index] }
        set {  elements[index] = newValue }
    }
    
    public subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { return elements[range] }
        set { elements[range] = newValue }
    }
    
    public subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { return elements[range] }
        set { elements[range] = newValue }
    }

    public var count: Int {
        return elements.count
    }

    public var underestimatedCount: Int {
        return elements.underestimatedCount
    }

    public mutating func set(contents: [Element]) {
        elements = contents
    }

    public mutating func removeAll() {
        elements.removeAll()
    }

    @discardableResult
    public mutating func remove(at i: Int) -> Element {
        elements.remove(at: i)
    }

    @discardableResult
    public mutating func removeFirst() -> Element {
        elements.removeFirst()
    }

    public mutating func removeFirst(_ k: Int) {
        elements.removeFirst(k)
    }

    public mutating func removeSubrange(_ bounds: Range<Int>) {
        elements.removeSubrange(bounds)
    }

    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try elements.removeAll(where: shouldBeRemoved)
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        elements.removeAll(keepingCapacity: keepCapacity)
    }

    public mutating func removeLast(_ k: Int) {
        elements.removeLast(k)
    }

    public mutating func removeLast() {
        elements.removeLast()
    }

    public mutating func append(_ newElement: Element) {
        elements.append(newElement)
    }

    public mutating func append<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
        elements.append(contentsOf: newElements)
    }

    public var indices: Range<Int> {
        return elements.indices
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public func distance(from start: Int, to end: Int) -> Int {
        return elements.distance(from: start, to: end)
    }

    public mutating func swapAt(_ i: Int, _ j: Int) {
        elements.swapAt(i, j)
    }

    public mutating func reserveCapacity(_ n: Int) {
        elements.reserveCapacity(n)
    }

    public mutating func insert(_ newElement: Element, at i: Int) {
        elements.insert(newElement, at: i)
    }

    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S: Collection, Element == S.Element {
        elements.insert(contentsOf: newElements, at: i)
    }

    public func formIndex(after i: inout Int) {
        elements.formIndex(after: &i)
    }

    public func formIndex(before i: inout Int) {
        elements.formIndex(before: &i)
    }

    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        try elements.partition(by: belongsInSecondPartition)
    }

    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        try elements.withContiguousStorageIfAvailable(body)
    }

    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R? {
        try elements.withContiguousMutableStorageIfAvailable(body)
    }

    private func isInBounds(index: Int) -> Bool {
        return indices ~= index
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public func index(before i: Int) -> Int {
        return elements.index(before: i)
    }

    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return elements.index(i, offsetBy: distance)
    }

    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        return elements.index(i, offsetBy: distance, limitedBy: limit)
    }

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound
    {
        elements.replaceSubrange(subrange, with: newElements)
    }
}

extension AnimatableDataArray: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection { }

extension AnimatableDataArray: Sendable where Element: Sendable { }

extension AnimatableDataArray: Encodable where Element: Encodable {}

extension AnimatableDataArray: Decodable where Element: Decodable {}

extension AnimatableDataArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        return elements._cVarArgEncoding
    }
}

extension AnimatableDataArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        return elements.customMirror
    }

    public var debugDescription: String {
        return elements.debugDescription
    }

    public var description: String {
        return elements.description
    }
}

extension AnimatableDataArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

extension AnimatableDataArray: ContiguousBytes {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try elements.withUnsafeBytes(body)
    }
}

extension AnimatableDataArray: ExpressibleByArrayLiteral {}

extension AnimatableDataArray: AnimatableData, Comparable, Equatable { }

extension AnimatableDataArray: VectorArithmetic & AdditiveArithmetic {
    public static func -= (lhs: inout Self, rhs: Self) {
        if var _lhs = lhs as? AnimatableDataArray<Double>, let _rhs = rhs as? AnimatableDataArray<Double> {
            let count = Swift.min(_lhs.count, _rhs.count)
            vDSP.subtract(_lhs[0..<count], _rhs[0..<count], result: &_lhs[0..<count])
            lhs = _lhs as! Self
        } else {
            let range = (lhs.startIndex..<lhs.endIndex)
                .clamped(to: rhs.startIndex..<rhs.endIndex)
            for index in range {
                var value = lhs[index].animatableData
                lhs[index] = Element(lhs[index].animatableData - rhs[index].animatableData)
            }
        }
    }
    
    public static func - (lhs: AnimatableDataArray, rhs: AnimatableDataArray) -> AnimatableDataArray {
        if let _lhs = lhs as? AnimatableDataArray<Double>, let _rhs = rhs as? AnimatableDataArray<Double> {
            let count = Swift.min(_lhs.count, _rhs.count)
            return AnimatableDataArray<Double>(vDSP.subtract(_lhs[0..<count], _rhs[0..<count])) as! Self
        }
        var lhs = lhs
        lhs -= rhs
        return lhs
    }
    
    public static func += (lhs: inout AnimatableDataArray, rhs: AnimatableDataArray) {
        if var _lhs = lhs as? AnimatableDataArray<Double>, let _rhs = rhs as? AnimatableDataArray<Double> {
            let count = Swift.min(_lhs.count, _rhs.count)
            vDSP.add(_lhs[0..<count], _rhs[0..<count], result: &_lhs[0..<count])
            lhs = _lhs as! Self
        } else {
            let range = (lhs.startIndex..<lhs.endIndex)
                .clamped(to: rhs.startIndex..<rhs.endIndex)
            for index in range {
                lhs[index] = Element(lhs[index].animatableData + rhs[index].animatableData)
            }
        }
    }
    
    public static func + (lhs: AnimatableDataArray, rhs: AnimatableDataArray) -> AnimatableDataArray {
        if let _lhs = lhs as? AnimatableDataArray<Double>, let _rhs = rhs as? AnimatableDataArray<Double> {
            let count = Swift.min(_lhs.count, _rhs.count)
            return AnimatableDataArray<Double>(vDSP.add(_lhs[0..<count], _rhs[0..<count])) as! Self
        }
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    public mutating func scale(by rhs: Double) {
        if let _self = self as? AnimatableDataArray<Double> {
            self.elements = vDSP.multiply(rhs, _self.elements) as! [Element]
        } else {
            for index in startIndex..<endIndex {
                self[index] = Element(self[index].animatableData.scaled(by: rhs))
            }
        }
    }
    
    public var magnitudeSquared: Double {
        if let _self = self as? AnimatableDataArray<Double> {
            return vDSP.sum(vDSP.multiply(_self.elements, _self.elements))
        }
       return reduce(into: 0.0) { (result, new) in
           result += new.animatableData.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
}

internal extension Array where Element: AnimatableData {
    var animatableDataArray: AnimatableDataArray<Element> {
        AnimatableDataArray(self)
    }
}

*/
