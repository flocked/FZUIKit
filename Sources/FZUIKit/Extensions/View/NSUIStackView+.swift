//
//  NSUIStackView+.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import FZSwiftUtils
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    extension NSUIStackView {
        /// Reverses the order of the arranged subviews.
        @objc open func reverseArrangedSubviews() {
            let arrangedViews = arrangedSubviews.reversed()
            for arrangedView in arrangedViews {
                removeArrangedSubview(arrangedView)
                addArrangedSubview(arrangedView)
            }
        }

        /// Removes all arranged subviews.
        @objc open func removeAllArrangedSubviews() {
            arrangedSubviews.forEach { self.removeArrangedSubview($0) }
        }
        
        /**
         Adds the specified views to the end of the arranged subviews list.
         
         - Parameter views: The views to add to the end of the arrangedSubviews array.
         */
        @objc open func addArrangedSubviews(_ views: [NSUIView]) {
            views.forEach({ addArrangedSubview($0) })
        }
        
        /**
         Adds the provided views to the array of arranged subviews at the specified index.
         
         - Parameters:
            - views: The views to be added to the array of arranged views managed by the stack.
            - index: The index where the stack inserts the new view in its `arrangedSubviews` array.
         */
        @objc open func insertArrangedSubviews(_ views: [NSUIView], at index: Int) {
            guard index >= 0, index < arrangedSubviews.count else { return }
            views.reversed().forEach({ insertArrangedSubview($0, at: index) })
        }
        
        /**
         Removes the provided views from the stack’s array of arranged subviews.
         
         - Parameter views: The views to be removed from the array of views arranged by the stack.
         */
        @objc open func removeArrangedSubviews(_ views: [NSUIView]) {
            views.filter({arrangedSubviews.contains($0)}).forEach({ removeArrangedSubview($0) })
        }

        /// The array of views arranged by the stack view.
        @objc open var arrangedViews: [NSUIView] {
            get { arrangedSubviews }
            set {
                guard newValue != arrangedSubviews else { return }
                newValue.difference(from: arrangedSubviews).forEach {
                    switch $0 {
                    case .insert(offset: let index, element: let view, associatedWith: _):
                        insertArrangedSubview(view, at: index)
                    case .remove(offset: _, element: let view, associatedWith: _):
                        removeArrangedSubview(view)
                    }
                }
            }
        }
        
        /// Sets the views arranged by the stack view.
        @discardableResult
        @objc open func arrangedSubviews(_ views: [NSUIView]) -> Self {
            arrangedViews = views
            return self
        }
        
        /// Sets the views arranged by the stack view.
        @discardableResult
        @objc open func arrangedSubviews(@Builder views: () -> [NSUIView]) -> Self {
            arrangedViews = views()
            return self
        }
    }

extension NSUIStackView {
    #if os(macOS)
    /**
     Creates and returns a stack view with the specified views.
     
     - Parameter views: The views for the new stack view.
     */
    public convenience init(@Builder views: () -> [NSUIView]) {
        self.init(views: views())
    }
    #else
    /**
     Returns a new stack view object that manages the provided views.
     
     - Parameter views: The views to be arranged by the stack view.
     */
    public convenience init(@Builder arrangedSubviews views: () -> [NSUIView]) {
        self.init(arrangedSubviews: views())
    }
    #endif
    
    /// A function builder type that produces an array of views.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ block: [NSUIView]...) -> [NSUIView] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [NSUIView]?) -> [NSUIView] {
            item ?? []
        }

        public static func buildEither(first: [NSUIView]?) -> [NSUIView] {
            first ?? []
        }

        public static func buildEither(second: [NSUIView]?) -> [NSUIView] {
            second ?? []
        }

        public static func buildArray(_ components: [[NSUIView]]) -> [NSUIView] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [NSUIView]?) -> [NSUIView] {
            expr ?? []
        }

        public static func buildExpression(_ expr: NSUIView?) -> [NSUIView] {
            expr.map { [$0] } ?? []
        }
    }
}
#endif
