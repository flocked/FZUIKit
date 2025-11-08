//
//  AXUIElement+Value.swift
//  FZUIKit
//
//  Created by Florian Zand on 08.11.25.
//

#if canImport(ApplicationServices) && os(macOS)
import AppKit
import ApplicationServices
import Combine
import FZSwiftUtils

public extension AXUIElement {
    /// Gets/sets the value for the specified attribute.
    subscript<Value>(_ attribute: AXAttribute) -> Value? {
        get { try? get(attribute) }
        set(value) { try? set(attribute, to: value) }
    }

    /// Gets/sets the value for the specified attribute.
    subscript<Value: RawRepresentable>(_ attribute: AXAttribute) -> Value? {
        get { try? get(attribute) }
        set(value) { try? set(attribute, to: value) }
    }
}

public extension AXUIElement {
    /// Returns the value for the specified attribute.
    func get(_ attribute: AXAttribute) throws -> Any? {
        try DispatchQueue.main.syncSafely {
            var value: AnyObject?
            let code = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
            if let error = AXError(code: code) {
                if error.valueIsNil { return nil }
                AXLogger.print("get(\(attribute))", error)
                throw error
            }
            let val = unpack(value!)
            if attribute.isBool, let val = val as? Int {
                return val == 1
            }
            return val
        }
    }

    /// Returns the value for the specified attribute.
    @_disfavoredOverload
    func get<Value>(_ attribute: AXAttribute) throws -> Value? {
        try get(attribute) as? Value
    }

    /// Returns the value for the specified attribute.
    func get<Value: RawRepresentable>(_ attribute: AXAttribute) throws -> Value? {
        let rawValue = try get(attribute) as Value.RawValue?
        return rawValue.flatMap(Value.init(rawValue:))
    }
    
    /// Returns the value for the specified parameterized attribute and parameter.
    func get(_ attribute: AXParameterizedAttribute, for parameter: Any) throws -> Any? {
        try DispatchQueue.main.syncSafely {
            let param = try pack(parameter, log: "get(\(attribute), for: \(parameter))")
            var value: AnyObject?
            let code = AXUIElementCopyParameterizedAttributeValue(self, attribute.rawValue as CFString, param, &value)
            if let error = AXError(code: code) {
                if error.valueIsNil { return nil }
                AXLogger.print("get(\(attribute), for: \(param))", error)
                throw error
            }
            return unpack(value!)
        }
    }

    /// Returns the value for the specified parameterized attribute and parameter.
    @_disfavoredOverload
    func get<Value>(_ attribute: AXParameterizedAttribute, for parameter: Any) throws -> Value? {
       try get(attribute, for: parameter) as? Value
    }

    internal func get(_ attributes: [AXAttribute]) throws -> [Any] {
        try DispatchQueue.main.syncSafely {
            let cfAttributes = attributes.map(\.rawValue) as CFArray
            var values: CFArray?
            try AXUIElementCopyMultipleAttributeValues(self, cfAttributes, AXCopyMultipleAttributeOptions(), &values).throwIfError("get(\(attributes))")
            return (values! as [AnyObject]).map(unpack)
        }
    }
    
    /**
     Returns the array for the specificed attribute.
     
     This function is useful for dealing with large arrays, for example, a table view with a large number of children.
     
     - Parameters:
        - attribute: The attribute of the array.
        - index: The starting index into the array.
        - maxValues: The maximum number of values to return.

     - Throws: If the attribute doesn't represent an array.
     */
    func getArray(_ attribute: AXAttribute, startingAt index: Int, maxValues: Int) throws -> [Any] {
        try DispatchQueue.main.syncSafely {
            guard let count = count(of: attribute) else { throw AXError.failure }
           let maxValues = maxValues.clamped(max: count - index)
            guard maxValues > 0 else { return [] }
            var values: CFArray?
            try AXUIElementCopyAttributeValues(self, attribute.rawValue as CFString, index as CFIndex, maxValues as CFIndex, &values).throwIfError("get(\(attribute), at: \(index), maxValues: \(maxValues))")
            return (values! as [AnyObject]).map(unpack)
        }
    }

    private func unpack(_ value: AnyObject) -> Any {
          switch CFGetTypeID(value) {
          case AXUIElementGetTypeID():
              return value as! AXUIElement
          case CFArrayGetTypeID():
              return (value as! [AnyObject]).map(unpack)
          case CFDictionaryGetTypeID():
              return (value as! [AnyHashable: AnyObject]).mapValues(unpack)
          case AXValueGetTypeID():
              return (value as! AXValue).unpack()
          default:
              return value
          }
      }
}

public extension AXUIElement {
    /// Sets the specified attribute to the specified value.
    func set<Value>(_ attribute: AXAttribute, to value: Value) throws {
        try DispatchQueue.main.syncSafely {
            let value = try pack(value, log: "set(\(attribute), to: \(value)")
            try AXUIElementSetAttributeValue(self, attribute.rawValue as CFString, value).throwIfError("set(\(attribute), to: \(value)")
        }
    }

    /// Sets the specified attribute to the specified value.
    func set<Value: RawRepresentable>(_ attribute: AXAttribute, to value: Value) throws {
        try set(attribute, to: value.rawValue)
    }
    
    private func pack(_  value: Any, log: String) throws -> AnyObject {
        guard let value = _pack(value) else {
            let error = AXError.packFailure(value)
            AXLogger.print(log, error)
            throw error
        }
        return value
    }

    private func _pack(_ value: Any) -> AnyObject? {
        switch value {
        case var value as CGPoint:
            return AXValueCreate(AXValueType.cgPoint, &value)
        case var value as CGSize:
            return AXValueCreate(AXValueType.cgSize, &value)
        case var value as CGRect:
            return AXValueCreate(AXValueType.cgRect, &value)
        case var value as CFRange:
            return AXValueCreate(AXValueType.cfRange, &value)
        case var value as ApplicationServices.AXError:
            return AXValueCreate(AXValueType.axError, &value)
        case let value as [Any]:
            return value.compactMap(_pack) as CFArray
        case let value as [AnyHashable: Any]:
            return value.mapValues(_pack) as CFDictionary
        case let value as AXUIElement:
            return value
        case let value as Bool:
            return (value ? 1 : 0) as AnyObject
        default:
            return value as AnyObject
        }
    }
}

extension AXValue {
    func unpack() -> Any {
        let type = AXValueGetType(self)
        func getValue<T>(_ value: T) -> T {
            var result = value
            withUnsafeMutablePointer(to: &result) {
                let success = AXValueGetValue(self, type, $0)
                assert(success, "Failed to unpack AXValue for type: \(type)")
            }
            return result
        }
        switch type {
        case .cgPoint: return getValue(CGPoint.zero)
        case .cgSize:  return getValue(CGSize.zero)
        case .cgRect:  return getValue(CGRect.zero)
        case .cfRange: return getValue(CFRange())
        case .axError:
            let error = getValue(ApplicationServices.AXError.success)
            return error == .noValue ? AXNilValue.shared : error
        case .illegal: return self
        @unknown default: return self
        }
    }
}

/// A type that represnts `nil`
public final class AXNilValue: CustomStringConvertible, @unchecked Sendable {
    static let shared = AXNilValue()
    private init() {}
    public var description: String { "nil" }
}
#endif
