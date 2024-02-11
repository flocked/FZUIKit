//
//  NSUIHostingController+.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import SwiftUI
    import FZSwiftUtils

    @available(macOS 11.0, iOS 13.0, *)
    public extension NSUIHostingController {
        /**
         Creates a hosting controller object that wraps the specified SwiftUI view.

         - Parameters:
            - ignoreSafeArea: A Boolean value that indicates whether the hosting controller view should ignore save area insets.
            - rootView: The root view of the SwiftUI view hierarchy that you want to manage using the hosting view controller.

         - Returns: The hosting controller object.
         */
        convenience init(ignoreSafeArea: Bool, rootView: Content) {
            self.init(rootView: rootView)

            if ignoreSafeArea {
                isSafeAreaInsetsDisabled = true
            }
        }

        /**
         Creates a hosting controller object that wraps the specified SwiftUI view.

         - Parameters:
            - isTransparent: A Boolean value that indicates whether the hosting controller view is transparent.
            - ignoreSafeArea: A Boolean value that indicates whether the hosting controller view should ignore save area insets.
            - rootView: The root view of the SwiftUI view hierarchy that you want to manage using the hosting view controller.

         - Returns: The hosting controller object.
         */
        convenience init(isTransparent: Bool, ignoreSafeArea: Bool = false, rootView: Content) {
            self.init(rootView: rootView)

            if ignoreSafeArea {
                isSafeAreaInsetsDisabled = true
            }

            if isTransparent {
                view.isOpaque = false
                view.backgroundColor = .clear
            }
        }
        
        /// A Boolean value that indicates whether the view should ignore save area insets.
        var isSafeAreaInsetsDisabled: Bool {
            get { view.isMethodReplaced(#selector(getter: NSUIView.safeAreaInsets)) }
            set { setSafeAreaInsets((newValue == true) ? .zero : nil) }
        }

        internal func setSafeAreaInsets(_ newSafeAreaInsets: NSUIEdgeInsets?) {
            view.resetMethod(#selector(getter: NSUIView.safeAreaInsets))
            if let newSafeAreaInsets = newSafeAreaInsets {
                do {
                    try view.replaceMethod(
                        #selector(getter: NSUIView.safeAreaInsets),
                        methodSignature: (@convention(c)  (AnyObject, Selector) -> (NSUIEdgeInsets)).self,
                        hookSignature: (@convention(block)  (AnyObject) -> (NSUIEdgeInsets)).self) { store in {
                           object in
                           return newSafeAreaInsets
                        }
                   }
                } catch {
                // handle error
                }
            }
        }
    }

    #if canImport(AppKit)
        public extension NSHostingView {
            /**
             Creates a hosting view object that wraps the specified SwiftUI view.

             - Parameters:
                - isTransparent: A Boolean value that indicates whether the view is transparent.
                - rootView: The root view of the SwiftUI view hierarchy that you want to manage using the hosting view controller.

             - Returns: The hosting view object.
             */
            convenience init(isTransparent: Bool, rootView: Content) {
                self.init(rootView: rootView)
                if isTransparent {
                    isOpaque = false
                    backgroundColor = .clear
                }
            }
        }
    #endif
#endif
