//
//  File.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

@available(macOS 11.0, iOS 13.0, *)
public extension NSUIHostingController {
    convenience init(ignoreSafeArea: Bool, rootView: Content) {
        self.init(rootView: rootView)

        if ignoreSafeArea {
            disableSafeAreaInsets(true)
        }
    }
    
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
    convenience init(isTransparent: Bool, rootView: Content) {
        self.init(rootView: rootView)
        if isTransparent {
            self.isOpaque = false
            self.backgroundColor = .clear
        }
    }
}
#endif

#if canImport(UIKit)
@available(iOS 13.0, *)
public final class UIHostingView<Content: View>: UIView {
    // MARK: - Public Properties

    public var rootView: Content {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    // MARK: - Private Properties

    private let hostingController: UIHostingController<Content>
    private var hostingView: UIView { hostingController.view }

    // MARK: - Initialization

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init?(coder:) unavailable")
    }

    public init(rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(frame: .zero)
        setup()
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return hostingView.sizeThatFits(size)
    }

    override public func didMoveToWindow() {
        if let parentController = parentController {
            parentController.addChild(hostingController)
            hostingController.didMove(toParent: parentController)
        } else {
            hostingController.willMove(toParent: nil)
            hostingController.removeFromParent()
        }
    }

    private func setup() {
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.rightAnchor.constraint(equalTo: rightAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingView.leftAnchor.constraint(equalTo: leftAnchor),
        ])
    }
}
#endif


/*
 internal class HitHostingView<Content: View>: NSHostingView<Content> {
     override func hitTest(_ point: NSPoint) -> NSView? {
         guard let hitTest = super.hitTest(point) else {
             return self.firstSuperview(for: NSCollectionView.self) }
         return hitTest
     }
 }


 */
