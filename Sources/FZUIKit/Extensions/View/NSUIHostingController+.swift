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
            disableSafeAreaInsets(true)
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
            disableSafeAreaInsets(true)
        }

        if isTransparent {
            self.view.isOpaque = false
            self.view.backgroundColor = .clear
        }
    }

    /**
     Disables the safe area insets of the view.
     
     - Parameter disable: A Boolean value that indicates whether the view should ignore save area insets.
     */
    func disableSafeAreaInsets(_ disable: Bool) {
        setSafeAreaInsets((disable == true) ? .zero : nil)
    }

    internal func setSafeAreaInsets(_ newSafeAreaInsets: NSUIEdgeInsets?) {
        guard let viewClass = object_getClass(view) else { return }

        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }

            if let method = class_getInstanceMethod(NSUIView.self, #selector(getter: NSUIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> NSUIEdgeInsets = { _ in
                    newSafeAreaInsets ?? .zero
                }

                if newSafeAreaInsets != nil {
                    class_addMethod(viewSubclass, #selector(getter: NSUIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
                } else {
                    class_replaceMethod(viewSubclass, #selector(getter: NSUIView.safeAreaInsets), method_getImplementation(method), method_getTypeEncoding(method))
                }
            }

            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
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
            self.isOpaque = false
            self.backgroundColor = .clear
        }
    }
}
#endif
#endif
