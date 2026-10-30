//
//  ContentTransform.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation
import FZSwiftUtils

/// A transformer that takes content and produces a transformed result.
public protocol ContentTransform<Content, Result>: Hashable, Identifiable, Sendable {
    /// The content type.
    associatedtype Content
    
    /// The transformed result type.
    associatedtype Result
    
    /// The block that transforms the content.
    var transform: @Sendable (Content) -> Result { get }
    
    /// The identifier of the transformer.
    var id: String { get }
    
    /**
     Creates a transformer with the specified identifier and transform block.
     
     - Parameters:
       - identifier: The identifier of the transformer.
       - transform: The block that transforms the content.
     */
    init(_ identifier: String, _ transform: @escaping @Sendable (Content) -> Result)
}

// MARK: - Transforming

public extension ContentTransform {
    /// Creates a transformer with the specified transform block.
    init(_ transform: @escaping @Sendable (Content) -> Result) {
        self.init(UUID().uuidString, transform)
    }
    
    /// Performs the transformation on the specified content.
    func callAsFunction(_ input: Content) -> Result {
        transform(input)
    }
    
    /// Performs the transformation on the specified content, or returns `nil` if the content is `nil`.
    @_disfavoredOverload
    func callAsFunction(_ input: Content?) -> Result? {
        input.map(transform)
    }
    
    /// Performs the transformation on each element of the specified sequence.
    func callAsFunction<S: Sequence<Content>>(_ inputs: S) -> [Result] {
        inputs.map(transform)
    }
}

// MARK: - Hashable

public extension ContentTransform {
    /// Returns a Boolean value indicating whether the two transformers have the same identifier.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Hashes the essential components of the transformer by feeding its identifier into the specified hasher.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Same-Type Transformations

public extension ContentTransform where Content == Result {
    /**
     Creates a transformer that applies the specified transformers in order.
     
     - Parameter transformers: The transformers to apply in order.
     */
    init(_ transformers: [Self]) {
        let transformers = transformers.uniqued()
        self.init(transformers.map(\.id).joined(separator: ",")) {
            transformers.reduce($0) { $1($0) }
        }
    }
    
    /**
     Creates a transformer that applies the specified transformers in order.
     
     - Parameter transformers: The transformers to apply in order.
     */
    init(_ transformers: Self...) {
        self.init(transformers)
    }
    
    /// Returns a transformer that applies the left-hand transformer followed by the right-hand transformer.
    static func + (lhs: Self, rhs: Self) -> Self {
        Self([lhs, rhs])
    }
}

// MARK: - Fallback Transformations

public extension ContentTransform where Content == Result, Content: Equatable {
    /// Returns a transformer that applies the right-hand transformer when the left-hand transformer doesn't change the input.
    static func || (lhs: Self, rhs: Self) -> Self {
        Self("\(lhs.id)||\(rhs.id)") { input in
            let result = lhs(input)
            return result != input ? result : rhs(input)
        }
    }
    
    /**
     Creates a transformer that returns the result of the first transformer that changes the input.
     
     - Parameter transformers: The transformers to apply in order.
     */
    init(fallback transformers: [Self]) {
        self.init(transformers.map(\.id).joined(separator: "||")) { input in
            transformers.lazy.map { $0(input) }.first { $0 != input } ?? input
        }
    }
    
    /**
     Creates a transformer that returns the result of the first transformer that changes the input.
     
     - Parameter transformers: The transformers to apply in order.
     */
    init(fallback transformers: Self...) {
        self.init(fallback: transformers)
    }
}

// MARK: - Asynchronous Transformations

public extension ContentTransform where Content: Sendable, Result: Sendable {
    /**
     Performs the transformation asynchronously on the specified queue.
     
     The completion handler is executed on the same queue after the transformation completes.
     
     - Parameters:
       - input: The content to transform.
       - queue: The queue on which to perform the transformation and execute the completion handler.
       - completionHandler: The block to execute with the transformed result.
     */
    func callAsFunction(_ input: Content, on queue: DispatchQueue = .userInitiated, completionHandler: @escaping @Sendable (Result) -> Void) {
        queue.async {
            completionHandler(transform(input))
        }
    }
    
    /**
     Performs the transformation asynchronously on each element of the specified sequence on the specified queue.
     
     The completion handler is executed on the same queue after all transformations complete.
     
     - Parameters:
       - inputs: The content to transform.
       - queue: The queue on which to perform the transformations and execute the completion handler.
       - completionHandler: The block to execute with the transformed results.
     */
    func callAsFunction<S: Sequence<Content> & Sendable>(_ inputs: S, on queue: DispatchQueue = .userInitiated, completionHandler: @escaping @Sendable ([Result]) -> Void) {
        queue.async {
            completionHandler(inputs.map(transform))
        }
    }
    
    /// Performs the transformation asynchronously on the specified content.
    func callAsFunction(_ input: Content) async -> Result {
        await Task.detached(priority: .userInitiated) {
            transform(input)
        }.value
    }
    
    /// Performs the transformation asynchronously on each element of the specified sequence.
    func callAsFunction<S: Sequence<Content> & Sendable>(_ inputs: S) async -> [Result] {
        await Task.detached(priority: .userInitiated) {
            inputs.map(transform)
        }.value
    }
}

struct AnyContentTransform {
    
}

/*
public extension ContentTransform {
    /// Returns a transformer that applies the left-hand transformer followed by the right-hand transformer.
    static func + <C: ContentTransform>(lhs: Self, rhs: C) -> Content {
        Self([lhs, rhs])
    }
}
*/

public extension ContentTransform where Result: OptionalProtocol {
    /// Returns a transformer that applies the right-hand transformer when the left-hand transformer returns `nil`.
    static func || (lhs: Self, rhs: Self) -> Self {
        Self([lhs, rhs])
    }
    
    /// Creates a transformer that returns the first non-nil transformed result.
    init(_ transformers: [Self]) {
        self.init(transformers.uniqued().map(\.id).joined(separator: "||")) { input in
            for transformer in transformers {
                let result = transformer(input)
                if result.optional != nil { return result }
            }
            return nil
        }
    }
    
    /// Creates a transformer that returns the first non-nil transformed result.
    init(_ transformers: Self...) {
        self.init(transformers)
    }
}
