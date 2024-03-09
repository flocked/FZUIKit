//
//  NSUIView+isEnabled.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    /// A type that can be enabled.
    public protocol Enablable: NSUIView {
        /// A Boolean value that indicates whether the view is enabled.
        var isEnabled: Bool { get set }
    }

    extension NSUIView: Enablable { }

    public extension Enablable where Self: NSUIView {
        /// A Boolean value that indicates whether the view is enabled.
        var isEnabled: Bool {
            get { !subviews.compactMap(\.isEnabled).contains(false) }
            set { subviews.forEach { $0.isEnabled = newValue } }
        }
    }

    #if os(macOS)
        public extension NSTextView {
            /**
             A Boolean value that indicates whether the text view is enabled.

             If `true`, the text view's `isEditable`will be `true` and it's text color will be `labelColor`, else `isEditable`will be `true` and it's text color will be `secondaryLabelColor`.
             */
            var isEnabled: Bool {
                get { isEditable }
                set {
                    isEditable = newValue
                    textColor = newValue ? .labelColor : .secondaryLabelColor
                }
            }
        }

    #elseif os(iOS)
        public extension UITextView {
            /**
             A Boolean value that indicates whether the text view is enabled.

             If `true`, the text view's `isEditable`will be `true` and it's text color will be `label`, else `isEditable`will be `true` and it's text color will be `secondaryLabel`.
             */
            var isEnabled: Bool {
                get { isEditable }
                set {
                    isEditable = newValue
                    textColor = newValue ? .label : .secondaryLabel
                }
            }
        }
    #endif

#endif
