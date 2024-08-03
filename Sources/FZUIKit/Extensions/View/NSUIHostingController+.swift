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
         Creates a hosting controller object with the given contents.

         - Parameter content: The contents of the SwiftUI hierarchy to be shown inside the view.
         */
        convenience init(@ViewBuilder content: () -> Content) {
            self.init(rootView: content())
        }
        
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

extension NSUIHostingController {
    var _previousWidth: CGFloat {
        get { getAssociatedValue("previousWidth", initialValue: 0.0) }
        set { setAssociatedValue(newValue, key: "previousWidth") }
    }
    
    var _heightAnchor: NSLayoutConstraint {
        get { getAssociatedValue("heightAnchor", initialValue: view.heightAnchor.constraint(equalToConstant: 1000)) }
        set { setAssociatedValue(newValue, key: "heightAnchor") }
    }
    
    var autoAdjustsHeight: Bool {
        get { getAssociatedValue("autoAdjustsHeight", initialValue: false) }
        set {
            guard newValue != autoAdjustsHeight else { return }
            _heightAnchor.isActive = newValue
            setAssociatedValue(newValue, key: "autoAdjustsHeight")
            #if os(macOS)
            let selector = #selector(Self.viewDidLayout)
            #else
            let selector = #selector(Self.viewDidLayoutSubviews)
            #endif
            if newValue {
                guard !isMethodReplaced(selector) else { return }
                do {
                   try replaceMethod(
                    selector,
                   methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                   hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                       object in
                       if let controller = object as? Self {
                           if controller.view.frame.size.width != controller._previousWidth {
                               controller._previousWidth = controller.view.frame.size.width
                               let fittingSize = controller.sizeThatFits(in: CGSize(width: controller._previousWidth, height: 40000))
                               controller._heightAnchor.constant = fittingSize.height
                           }
                       }
                       // handle replaced `mouseDown`
                
                       // calls `super.mouseDown`
                       store.original(object, selector)
                       }
                   }
                } catch {
                   // handle error
                   debugPrint(error)
                }
            } else {
                resetMethod(selector)
            }
        }
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
    #if canImport(AppKit)
        public extension NSHostingView {
            /**
             Calculates and returns the most appropriate size for the current view.
             
             - Parameter size: The proposed new size for the view.
             - Returns: The size that offers the best fit for the root view and its contents.
             */
            func sizeThatFits(in size: CGSize) -> CGSize {
                hostingController.view = self
                return hostingController.sizeThatFits(in: size)
            }
            
            /// A Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
            @available(macOS 11.0, *)
            var ignoresSafeArea: Bool {
                get { isMethodReplaced(#selector(getter: NSUIView.safeAreaInsets)) }
                set { setSafeAreaInsets(newValue ? .zero : nil) }
            }
            
            /**
             Creates a hosting view object with the given contents.

             - Parameter content: The contents of the SwiftUI hierarchy to be shown inside the view.
             */
            convenience init(@ViewBuilder content: () -> Content) {
                self.init(rootView: content())
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
            
            internal var hostingController: NSHostingController<Content> {
                getAssociatedValue("hostingController", initialValue: NSHostingController(rootView: rootView))
            }
        }
    #endif
#endif
