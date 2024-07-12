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

        /// The array of views arranged by the stack view.
        @objc open var arrangedViews: [NSUIView] {
            get { arrangedSubviews }
            set {
                guard arrangedSubviews != newValue else { return }
                removeAllArrangedSubviews()
                newValue.forEach { self.addArrangedSubview($0) }
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
