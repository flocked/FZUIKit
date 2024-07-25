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
                newValue.difference(from: arrangedSubviews).forEach {
                    switch $0 {
                    case .insert(offset: let index, element: let view, associatedWith: _):
                        insertArrangedSubview(view, at: index)
                    case .remove(offset: let offset, element: let view, associatedWith: _):
                        removeArrangedSubview(view)
                    }
                }
            }
        }
        
        /// Sets the views arranged by the stack view.
        @discardableResult
        @objc open func arrangedSubviews(_ views: [NSUIView]) -> Self {
            self.arrangedViews = views
            return self
        }
    }
#endif
