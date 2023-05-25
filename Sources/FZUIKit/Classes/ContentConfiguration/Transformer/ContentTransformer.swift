//
//  ContentTransformer.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

import Foundation

protocol P<Content> {
    associatedtype Content
    var transform: (Content) -> Content { get }
    var id: String { get }
    init(_ id: String, _ transform: @escaping ((Content) -> Content))
}

extension P {
    init(_ transform: @escaping ((Content) -> Content)) {
        self.init(UUID().uuidString, transform)
    }
}

struct StringConv: P {
    let id: String
    let transform: (String) -> String

    init(_ id: String, _ transform: @escaping ((String) -> String)) {
        self.id = id
        self.transform = transform
    }
}

/// A  protocol for a transformer that generates a modified output from an input.
public protocol ContentTransformer<Content>: Hashable, Identifiable {
    associatedtype Content
    var transform: (Content) -> Content { get }
    init(_ transform: @escaping ((Content) -> Content))
}

public extension ContentTransformer where Self: AnyObject {
    var id: ObjectIdentifier! { return ObjectIdentifier(self) }
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
        /*
         let result = await Task {
             self.transform(input)
         }.value
         return result
         */
    }

    func callAsFunction<S>(_ inputs: S) async -> [Content] where S: Sequence<Content> {
        let results = await inputs.asyncMap { await self($0) }
        return results
    }
}

@available(macOS 13.0.0, iOS 16.0, *)
struct ContentTransformerGroup<Content> {
    let transformers: [any ContentTransformer<Content>]

    public func callAsFunction(_ input: Content) -> Content {
        var result = input
        for transformer in transformers {
            result = transformer(result)
        }
        return result
    }

    public func callAsFunction<S>(_ inputs: S) -> [Content] where S: Sequence<Content> {
        var results: [Content] = []
        for input in inputs {
            var result = input
            for transformer in transformers {
                result = transformer(result)
            }
            results.append(result)
        }
        return results
    }

    public func callAsFunction(_ input: Content, completionHandler: @escaping ((Content) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self(input)
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }

    public func callAsFunction<S>(_ inputs: S, completionHandler: @escaping (([Content]) -> Void)) where S: Sequence<Content> {
        DispatchQueue.global(qos: .userInitiated).async {
            let results = self(inputs)
            DispatchQueue.main.async {
                completionHandler(results)
            }
        }
    }

    public func callAsFunction(_ input: Content) async -> Content {
        return await withCheckedContinuation { continuation in
            self(input) { result in
                continuation.resume(returning: result)
            }
        }
    }

    public func callAsFunction<S>(_ inputs: S) async -> [Content] where S: Sequence<Content> {
        let results = await inputs.concurrentMap { await self($0) }
        return results
    }

    init(transformers: [any ContentTransformer<Content>]) {
        self.transformers = transformers
    }

    init(_ transformers: [any ContentTransformer<Content>]) {
        self.transformers = transformers
    }
}

/*
 public struct ContentTransformerNewn<Content>: ContentTransformerNew<Content> {
     let transform: ((Content)->Content)
     init(_ transform: @escaping (Content) -> Content) {
         self.transform = transform
     }
 }

 public extension ContentTransformerNewn {
     func callAsFunction(_ input: Content) -> Content {
         return self.transform(input)
     }
 }

 public protocol ContentTransformerNew<Content>: Hashable, Identifiable {
     associatedtype Content
     func callAsFunction(_ input: Content) -> Content
     func callAsFunction(_ input: Content) async -> Content
     func callAsFunction(_ input: Content, completionHandler: @escaping ((Content)->()))

     func callAsFunction<S>(_ input: S) -> [Content] where S: Sequence<Content>
     func callAsFunction<S>(_ input: S) async -> [Content] where S: Sequence<Content>
     func callAsFunction<S>(_ input: S, completionHandler: @escaping (([Content])->())) where S: Sequence<Content>
 }

 public extension ContentTransformerNew {
     func callAsFunction(_ input: Content) async -> Content {
         return await withCheckedContinuation { continuation in
             self(input) { result in
                 continuation.resume(returning: result)
             }
          }
     }

     public func callAsFunction(_ input: Content, completionHandler: @escaping ((Content)->())) {
         DispatchQueue.global(qos: .userInitiated).async {
             let result = self.transform(input)
             DispatchQueue.main.async {
                 completionHandler(result)
             }
         }
     }

     public func callAsFunction<S>(_ inputs: S) -> [Content] where S: Sequence<Content> {
         var results: [Content] = []
         for input in inputs {
             let result = self(input)
             results.append(result)
         }
         return results
     }

     public func callAsFunction<S>(_ inputs: S) async -> [Content] where S: Sequence<Content> {
         let results = await inputs.asyncMap({ await self($0) })
         return results
     }

     public func callAsFunction<S>(_ inputs: S, completionHandler: @escaping (([Content])->())) where S: Sequence<Content> {
         DispatchQueue.global(qos: .userInitiated).async {
             for input in inputs {
                 self(input) { result in

                 }
             }
             let results = self(inputs)
             DispatchQueue.main.async {
                 completionHandler(results)
             }
         }
     }
 }
 */
