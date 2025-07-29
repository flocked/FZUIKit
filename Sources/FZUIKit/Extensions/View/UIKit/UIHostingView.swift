//
//  UIHostingView.swift
//
//
//  Created by Florian Zand on 24.07.23.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import SwiftUI
import UIKit

/// An UIKit view that hosts a SwiftUI view hierarchy.
open class UIHostingView<Content: View>: UIView {
        
    private let hostingController: UIHostingController<Content>
    private var hostingView: UIView { hostingController.view }
    private var isPresented: Bool = false

    // MARK: - Creating a hosting view

    /**
     Creates a hosting view object that wraps the specified SwiftUI view.

     - Parameter rootView: The root view of the SwiftUI view hierarchy that you want to manage using the hosting view controller.
     - Returns: The hosting view object.
     */
    public required init(rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(frame: .zero)
        setup()
    }
        
        
    /**
     Creates a hosting controller object from an archive and the specified SwiftUI view.
     - Parameters:
        - coder: The decoder to use during initialization.
        - rootView: The root view of the SwiftUI view hierarchy that you want to manage using this view controller.
         
     - Returns: A `UIViewController` object that you can present from your interface.
     */
    public init?(coder: NSCoder, rootView: Content) {
        guard let hostingController = UIHostingController(coder: coder, rootView: rootView) else { return nil }
        self.hostingController = hostingController
        super.init(frame: .zero)
        setup()
    }

    /**
     Creates a hosting controller object from the contents of the specified archive.
         
     The default implementation of this method throws an exception. To create your view controller from an archive, override this method and initialize the superclass using the ``init(rootView:)`` method instead.
         
     - Parameter coder: The decoder to use during initialization.
     */
    public required init?(coder: NSCoder) {
        guard let hostingController = UIHostingController<Content>(coder: coder) else { return nil }
        self.hostingController = hostingController
        super.init(frame: .zero)
        setup()
    }

    // MARK: - Getting the root view

    /// The root view of the SwiftUI view hierarchy managed by this view controller.
    open var rootView: Content {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }
        
    @available(iOS 16.0, tvOS 16.0, *)
    open var sizingOptions: UIHostingControllerSizingOptions {
        get { hostingController.sizingOptions }
        set { hostingController.sizingOptions = newValue }
    }
        
    /// A Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
    open var ignoresSafeArea: Bool {
        get { hostingController.ignoresSafeArea }
        set { hostingController.ignoresSafeArea = newValue }
    }
        
    /// Sets the Boolean value that indicates whether the SwiftUI view ignores the safe area insets.
    @discardableResult
    open func ignoreSafeArea(_ ignores: Bool) -> Self {
        ignoresSafeArea = ignores
        return self
    }

    // MARK: - Private Properties
        
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        hostingView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
        
    open override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        hostingView.systemLayoutSizeFitting(targetSize)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        hostingView.sizeThatFits(size)
    }
        
    open override func sizeToFit() {
        hostingView.sizeToFit()
        super.sizeToFit()
    }
        
    open override var intrinsicContentSize: CGSize {
        hostingView.intrinsicContentSize
    }
        
    open override func invalidateIntrinsicContentSize() {
        hostingView.invalidateIntrinsicContentSize()
        super.invalidateIntrinsicContentSize()
    }

    open override func didMoveToWindow() {
        if let parentController = parentController {
            parentController.addChild(hostingController)
            hostingView.frame = bounds
            addSubview(hostingView)
            hostingController.didMove(toParent: parentController)
            isPresented = true
        } else {
            hostingController.willMove(toParent: nil)
            hostingController.removeFromParent()
            hostingView.removeFromSuperview()
            isPresented = false
        }
        super.didMoveToWindow()
    }
        
    open override func layoutSubviews() {
        super.layoutSubviews()
        if isPresented {
            hostingView.frame = bounds
        }
    }

    private func setup() {
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
    }
}

#endif
