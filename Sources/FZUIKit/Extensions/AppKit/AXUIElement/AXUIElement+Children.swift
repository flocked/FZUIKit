//
//  AXUIElement+Children.swift
//
//
//  Created by Florian Zand on 08.11.25.
//

#if canImport(ApplicationServices) && os(macOS)
import AppKit
import ApplicationServices
import Combine
import FZSwiftUtils

public extension AXUIElement {
    /// A sequence of the children of the object.
    var children: ChildrenSequence {
        .init(self)
    }

    /// A sequence of children.
    struct ChildrenSequence: Sequence {
        let element: AXUIElement
        var roles: [AXRole] = []
        var subroles: [AXSubrole] = []
        var attributes: [AXAttribute] = []
        var maxDepth: Int = 0
        var filter: ((AXUIElement)->(Bool))?
        
        init(_ element: AXUIElement, filter: ((AXUIElement)->(Bool))? = nil) {
            self.element = element
            self.filter = filter
        }

        public func makeIterator() -> Iterator {
            Iterator(self)
        }
        
        /// The roles of the children.
        public func roles(_ roles: [AXRole]) -> Self {
            var sequence = self
            sequence.roles = roles
            return sequence
        }
        
        /// The roles of the children.
        public func roles(_ roles: AXRole...) -> Self {
            self.roles(roles)
        }
        
        /// The subroles of the children.
        public func subroles(_ subroles: [AXSubrole]) -> Self {
            var sequence = self
            sequence.subroles = subroles
            return sequence
        }
        
        /// The subroles of the children.
        public func subroles(_ subroles: AXSubrole...) -> Self {
            self.subroles(subroles)
        }
        
        /// The attributes of the children.
        public func attributes(_ attributes: AXAttribute...) -> Self {
            self.attributes(attributes)
        }
        
        /// The attributes of the children.
        public func attributes(_ attributes: [AXAttribute]) -> Self {
            var sequence = self
            sequence.attributes = attributes
            return sequence
        }
        
        /// Includes the children of each child.
        public var recursive: Self {
            recursive(maxDepth: .max)
        }
        
        /**
         Includes the children of each child upto the specified maximum depth.
         
         - Parameter maxDepth: The maximum depth of enumeration. A value of `0` enumerates only the children of the object.
         */
        public func recursive(maxDepth: Int) -> Self {
            var sequence = self
            sequence.maxDepth = maxDepth.clamped(min: 0)
            return sequence
        }
        
        /// The number of children in the sequence.
        public var count: Int {
            reduce(0) { count, _ in count + 1 }
        }
        
        /// Iterator of a children sequence.
        public struct Iterator: IteratorProtocol {
            let children: [(element: AXUIElement, level: Int)]
            var index = -1
            
            init(_ sequence: ChildrenSequence) {
                children = sequence.element._children(maxDepth: sequence.maxDepth, roles: sequence.roles, subroles: sequence.subroles, filter: sequence.filter)
            }

            public mutating func next() -> AXUIElement? {
                guard let child = children[safe: index+1] else { return nil }
                index += 1
                return child.element
            }
            
            /// The number of levels deep the iterator is in the children hierarchy being enumerated.
            public var level: Int {
                children[safe: index]?.level ?? 0
            }
        }
    }
    
    func _children(level: Int = 0, maxDepth: Int, roles: [AXRole], subroles: [AXSubrole], filter: ((AXUIElement)->(Bool))?) -> [(element: AXUIElement, level: Int)] {
        let next = level+1 <= maxDepth
        var children: [AXUIElement] = (try? get(.children)) ?? []
        var results: [(element: AXUIElement, level: Int)] = []
        for child in children {
            results.append((child, level))
            if next {
                results.append(contentsOf: child._children(level: level+1, maxDepth: maxDepth, roles: roles, subroles: subroles, filter: filter))
            }
        }
        if !roles.isEmpty {
            results = results.filter({ if let role = $0.element.role { return roles.contains(role) } else { return false } } )
            children = children.filter({ if let role = $0.role { return roles.contains(role) } else { return false } })
        }
        if !subroles.isEmpty {
            results = results.filter({ if let subrole = $0.element.subrole { return subroles.contains(subrole) } else { return false } } )
        }
        if !attributes.isEmpty {
            results = results.filter({ $0.element.attributes.contains(any: attributes) })
        }
        
        if let filter = filter {
            results = results.filter({ filter($0.element)  })
        }
        return results
    }
}
#endif
