//
//  AXError.swift
//
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation

/// Error codes returned by accessibility functions (`AXError.h`).
public enum AXError: Error {
    /// Received an unknown error code.
    case unknown(ApplicationServices.AXError)

    /// Received a value with an unexpected type.
    case unexpectedValue(AnyObject)

    /// Received an unexpected amount of values.
    case unexpectedValueCount([Any])

    /// Failed to pack the given value to send to AX APIs.
    case packFailure(Any)

    /// Invalid process id.
    case invalidPid(pid_t)

    /// A system error occurred, such as the failure to allocate an object.
    case failure

    /// An illegal argument was passed to the function.
    case illegalArgument

    /// The AXUIElementRef passed to the function is invalid.
    case invalidUIElement

    /// The AXObserverRef passed to the function is not a valid observer.
    case invalidUIElementObserver

    /// The function cannot complete because messaging failed in some way or
    /// because the application with which the function is communicating is busy
    /// or unresponsive.
    case cannotComplete

    /// The attribute is not supported by the AXUIElementRef.
    case attributeUnsupported

    /// The action is not supported by the AXUIElementRef.
    case actionUnsupported

    /// The notification is not supported by the AXUIElementRef.
    case notificationUnsupported

    /// Indicates that the function or method is not implemented (this can be
    /// returned if a process does not support the accessibility API).
    case notImplemented

    /// This notification has already been registered for.
    case notificationAlreadyRegistered

    /// Indicates that a notification is not registered yet.
    case notificationNotRegistered

    /// The accessibility API is disabled (as when, for example, the user
    /// deselects "Enable access for assistive devices" in Universal Access
    /// Preferences).
    case apiDisabled

    /// The requested value or `AXUIElementRef` does not exist.
    case noValue

    /// The parameterized attribute is not supported by the `AXUIElementRef`.
    case parameterizedAttributeUnsupported

    /// Not enough precision.
    case notEnoughPrecision

    init?(code: ApplicationServices.AXError) {
        switch code {
        case .success:
            return nil
        case .failure:
            self = .failure
        case .illegalArgument:
            self = .illegalArgument
        case .invalidUIElement:
            self = .invalidUIElement
        case .invalidUIElementObserver:
            self = .invalidUIElementObserver
        case .cannotComplete:
            self = .cannotComplete
        case .attributeUnsupported:
            self = .attributeUnsupported
        case .actionUnsupported:
            self = .actionUnsupported
        case .notificationUnsupported:
            self = .notificationUnsupported
        case .notImplemented:
            self = .notImplemented
        case .notificationAlreadyRegistered:
            self = .notificationAlreadyRegistered
        case .notificationNotRegistered:
            self = .notificationNotRegistered
        case .apiDisabled:
            self = .apiDisabled
        case .noValue:
            self = .noValue
        case .parameterizedAttributeUnsupported:
            self = .parameterizedAttributeUnsupported
        case .notEnoughPrecision:
            self = .notEnoughPrecision
        @unknown default:
            self = .unknown(code)
        }
    }
    
    var rawValue: Int32? {
        switch self {
        case .failure: return -25200
        case .illegalArgument: return -25201
        case .invalidUIElement: return -25202
        case .invalidUIElementObserver: return -25203
        case .cannotComplete: return -25204
        case .attributeUnsupported: return -25205
        case .actionUnsupported: return -25206
        case .notificationUnsupported: return -25207
        case .notImplemented: return -25208
        case .notificationAlreadyRegistered: return -25209
        case .notificationNotRegistered: return  -25210
        case .apiDisabled: return -25211
        case .noValue: return  -25212
        case .parameterizedAttributeUnsupported: return -25213
        case .notEnoughPrecision: return -25214
        case .unknown(let aXError): return aXError.rawValue
        default: return nil
        }
    }
    
    var valueIsNil: Bool {
        switch self {
        case .attributeUnsupported, .parameterizedAttributeUnsupported, .noValue, .cannotComplete: return true
        default: return false
        }
    }
}

extension ApplicationServices.AXError {
    public func throwIfError(_ items: Any...) throws {
        guard let error = AXError(code: self) else { return }
        AXLogger.print(items: [error as Any] + items)
        throw error
    }
    
    public func throwIfError() throws {
        guard let error = AXError(code: self) else { return }
        AXLogger.print(error)
        throw error
    }
}

#endif
