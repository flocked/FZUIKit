//
//  ContentTransformer.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

/// A  protocol for a transformer that generates a modified output from an input.
public protocol ContentTransformer<Content>: Hashable, Identifiable {
    associatedtype Content
    var transform: (Content) -> Content { get }
    var id: String { get }
    init(_ id: String, _ transform: @escaping ((Content) -> Content))
}

public extension ContentTransformer {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        return Self { input in
            var result = lhs(input)
            result = rhs(result)
            return result
        }
    }
        
    init(_ transform: @escaping ((Content) -> Content)) {
        self.init(UUID().uuidString, transform)
    }
    
    init(_ transformers: Self...) {
        self.init(transformers)
    }
    
    init(_ transformers: [Self]) {
        let id = transformers.compactMap({$0.id}).joined(separator: ", ")
        self.init(id) { content in
            var content = content
            for transformer in transformers {
                content = transformer.transform(content)
            }
            return content
        }
    }
    
    func callAsFunction(_ input: Content) -> Content {
        return transform(input)
    }

    func callAsFunction<S>(_ inputs: S) -> [Content] where S: Sequence<Content> {
        var results: [Content] = []
        for input in inputs {
            let result = self(input)
            results.append(result)
        }
        return results
    }

    func callAsFunction(_ input: Content, completionHandler: @escaping ((Content) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.transform(input)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }

    func callAsFunction<S>(_ inputs: S, completionHandler: @escaping (([Content]) -> Void)) where S: Sequence<Content> {
        DispatchQueue.global(qos: .userInitiated).async {
            for input in inputs {
                self(input) { _ in
                }
            }
            let results = self(inputs)
            DispatchQueue.main.async {
                completionHandler(results)
            }
        }
    }

    func callAsFunction(_ input: Content) async -> Content {
        return await withCheckedContinuation { continuation in
            self(input) { result in
                continuation.resume(returning: result)
            }
        }
    }

    func callAsFunction<S>(_ inputs: S) async -> [Content] where S: Sequence<Content> {
        let results = await inputs.asyncMap { await self($0) }
        return results
    }
}

public extension ContentTransformer where Self: AnyObject {
    var id: String { return ObjectIdentifier(self).debugDescription }
}
