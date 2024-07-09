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
        /// A Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
        var ignoresSafeArea: Bool {
            get { view.isMethodReplaced(#selector(getter: NSUIView.safeAreaInsets)) }
            set { view.setSafeAreaInsets(newValue ? .zero : nil) }
        }
        
        /// Sets the Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
        @discardableResult
        func ignoresSafeArea(_ ignores: Bool) -> Self {
            ignoresSafeArea = ignores
            return self
        }
        
        /// The minimum size of the view that satisfies the constraints it holds.
        var fittingSize: CGSize {
            view.intrinsicContentSize
        }
        
        /// Resizes the view’s frame so that it’s the size satisfies the constraints it holds.
        func sizeToFit() {
            view.frame.size = view.intrinsicContentSize
        }
    }

    #if canImport(AppKit)
        public extension NSHostingView {
            /// A Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
            @available(macOS 11.0, *)
            var ignoresSafeArea: Bool {
                get { isMethodReplaced(#selector(getter: NSUIView.safeAreaInsets)) }
                set { setSafeAreaInsets(newValue ? .zero : nil) }
            }
            
            /// Sets the Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
            @discardableResult
            @available(macOS 11.0, *)
            func ignoresSafeArea(_ ignores: Bool) -> Self {
                ignoresSafeArea = ignores
                return self
            }
            
            /// Resizes the view’s frame so that it’s the size satisfies the constraints it holds.
            func sizeToFit() {
                frame.size = fittingSize
            }
        }
fileprivate extension NSUIView {
    @available(macOS 11.0, iOS 11.0, tvOS 11.0, *)
    func setSafeAreaInsets(_ newSafeAreaInsets: NSUIEdgeInsets?) {
        resetMethod(#selector(getter: NSUIView.safeAreaInsets))
        if let newSafeAreaInsets = newSafeAreaInsets {
            do {
                try replaceMethod(
                    #selector(getter: NSUIView.safeAreaInsets),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> (NSUIEdgeInsets)).self,
                    hookSignature: (@convention(block)  (AnyObject) -> (NSUIEdgeInsets)).self) { store in {
                       object in
                       return newSafeAreaInsets
                    }
               }
            } catch {
                Swift.debugPrint(error)
            }
        }
    }
}
    #endif
#endif
