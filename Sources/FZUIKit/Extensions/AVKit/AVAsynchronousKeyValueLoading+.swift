//
//  AVAsynchronousKeyValueLoading+.swift
//  
//
//  Created by Florian Zand on 20.06.24.
//

import Foundation
import AVFoundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AVAsynchronousKeyValueLoading {
    /**
     Loads a property synchronously and returns the value to the completion handler.
     
     - Parameter property: A property to load.
     - Returns: The loaded property value.
     */
    func load<T>(_ property: AVAsyncProperty<Self, T>) throws -> T {
        let syncValue = AVPropertyValue<T>()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                syncValue.value = try await load(property)
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return syncValue.value!
    }
    
    /**
     Loads a property asynchronously and returns the value to the completion handler.
     
     - Parameters:
        - property: A property to load.
        - completion: The completion handler that returns the value of the property or an error.
     */
    func load<T>(_ property: AVAsyncProperty<Self, T>, completion: (_ value: T?, _ error: Error?)->()) {
        let syncValue = AVPropertyValue<T>()
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            do {
                syncValue.value = try await load(property)
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        completion(syncValue.value, syncValue.error)
    }
    
    /**
     Loads two properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>) throws -> (A, B) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB)
                syncValue.values = [values.0, values.1]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B)
    }
    
    /**
     Loads two properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, completion: (_ values: (A, B)?, _ error: Error?)->()) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB)
                syncValue.values = [values.0, values.1]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B), nil)
        }
    }
    
    /**
     Loads three properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B, C>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>) throws -> (A, B, C) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC)
                syncValue.values = [values.0, values.1, values.2]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C)
    }
    
    /**
     Loads three properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B, C>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, completion: (_ values: (A, B, C)?, _ error: Error?)->()) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC)
                syncValue.values = [values.0, values.1, values.2]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C), nil)
        }
    }
    
    /**
     Loads four properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B, C, D>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>) throws -> (A, B, C, D) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD)
                syncValue.values = [values.0, values.1, values.2, values.3]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D)
    }
    
    /**
     Loads four properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B, C, D>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, completion: (_ values: (A, B, C, D)?, _ error: Error?)->()) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD)
                syncValue.values = [values.0, values.1, values.2, values.3]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D), nil)
        }
    }
    
    /**
     Loads five properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B, C, D, E>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>) throws -> (A, B, C, D, E) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E)
    }
    
    /**
     Loads five properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B, C, D, E>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, completion: (_ values: (A, B, C, D, E)?, _ error: Error?)->()) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E), nil)
        }
    }
    
    /**
     Loads six properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - propertyF: A sixth property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B, C, D, E, F>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, _ propertyF: AVAsyncProperty<Self, F>) throws -> (A, B, C, D, E, F) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4, values.5]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E, syncValue.values[5] as! F)
    }
    
    /**
     Loads six properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - propertyF: A sixth property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B, C, D, E, F>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, _ propertyF: AVAsyncProperty<Self, F>, completion: (_ values: (A, B, C, D, E, F)?, _ error: Error?)->()) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4, values.5]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E, syncValue.values[5] as! F), nil)
        }
    }
    
    /**
     Loads seven properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - propertyF: A sixth property to load.
        - propertyG: A seventh property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B, C, D, E, F, G>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, _ propertyF: AVAsyncProperty<Self, F>, _ propertyG: AVAsyncProperty<Self, G>) throws -> (A, B, C, D, E, F, G) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4, values.5, values.6]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E, syncValue.values[5] as! F, syncValue.values[6] as! G)
    }
    
    /**
     Loads seven properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - propertyF: A sixth property to load.
        - propertyG: A seventh property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B, C, D, E, F, G>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, _ propertyF: AVAsyncProperty<Self, F>, _ propertyG: AVAsyncProperty<Self, G>, completion: (_ values: (A, B, C, D, E, F, G)?, _ error: Error?)->()) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4, values.5, values.6]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E, syncValue.values[5] as! F, syncValue.values[6] as! G), nil)
        }
    }
    
    /**
     Loads eight properties synchronously and returns the values.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - propertyF: A sixth property to load.
        - propertyG: A seventh property to load.
        - propertyH: An eight property to load.
     - Returns: The loaded properties in a tuple.
     */
    func load<A, B, C, D, E, F, G, H>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, _ propertyF: AVAsyncProperty<Self, F>, _ propertyG: AVAsyncProperty<Self, G>, _ propertyH: AVAsyncProperty<Self, H>) throws -> (A, B, C, D, E, F, G, H) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG, propertyH)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4, values.5, values.6, values.7]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            throw error
        }
        return (syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E, syncValue.values[5] as! F, syncValue.values[6] as! G, syncValue.values[7] as! H)
    }
    
    /**
     Loads eight properties synchronously and returns the values to the completion handler.
     
     - Parameters:
        - propertyA: A property to load.
        - propertyB: A second property to load.
        - propertyC: A third property to load.
        - propertyD: A fourth property to load.
        - propertyE: A fifth property to load.
        - propertyF: A sixth property to load.
        - propertyG: A seventh property to load.
        - propertyH: An eight property to load.
        - completion: The completion handler that returns the values of the properties or an error.
     */
    func load<A, B, C, D, E, F, G, H>(_ propertyA: AVAsyncProperty<Self, A>, _ propertyB: AVAsyncProperty<Self, B>, _ propertyC: AVAsyncProperty<Self, C>, _ propertyD: AVAsyncProperty<Self, D>, _ propertyE: AVAsyncProperty<Self, E>, _ propertyF: AVAsyncProperty<Self, F>, _ propertyG: AVAsyncProperty<Self, G>, _ propertyH: AVAsyncProperty<Self, H>, completion: ((_ values: (A, B, C, D, E, F, G, H)?, _ error: Error?)->())) {
        let syncValue = AVPropertieValues()
        let semaphore = DispatchSemaphore(value: 0)

        Task {
            do {
                let values = try await load(propertyA, propertyB, propertyC, propertyD, propertyE, propertyF, propertyG, propertyH)
                syncValue.values = [values.0, values.1, values.2, values.3, values.4, values.5, values.6, values.7]
            } catch {
                syncValue.error = error
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = syncValue.error {
            completion(nil, error)
        } else {
            completion((syncValue.values[0] as! A, syncValue.values[1] as! B, syncValue.values[2] as! C, syncValue.values[3] as! D, syncValue.values[4] as! E, syncValue.values[5] as! F, syncValue.values[6] as! G, syncValue.values[7] as! H), nil)
        }
    }
}

fileprivate class AVPropertyValue<T>: @unchecked Sendable {
    private var _value: T? = nil
    private var _error: Error? = nil

    private let lock = NSLock()

    var value: T? {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
    
    var error: Error? {
        get { lock.withLock { _error } }
        set { lock.withLock { _error = newValue } }
    }
}

fileprivate class AVPropertieValues: @unchecked Sendable {
    private let lock = NSLock()
    private var _error: Error? = nil
    private var _values: [Any] = []
    
    var values: [Any] {
        get { lock.withLock { _values } }
        set { lock.withLock { _values = newValue } }
    }
    
    var error: Error? {
        get { lock.withLock { _error } }
        set { lock.withLock { _error = newValue } }
    }
}
