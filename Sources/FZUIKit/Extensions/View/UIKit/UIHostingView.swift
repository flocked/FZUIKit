//
//  UIHostingView.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

#if os(iOS) || os(tvOS)
import UIKit
import SwiftUI

/// An UIKit view that hosts a SwiftUI view hierarchy.
public final class UIHostingView<Content: View>: UIView {
    // MARK: - Creating a hosting view
    /**
     Creates a hosting view object that wraps the specified SwiftUI view.
     
     - Parameter rootView: The root view of the SwiftUI view hierarchy that you want to manage using the hosting view controller.
     - Returns: The hosting view object.
     */
    public init(rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init?(coder:) unavailable")
    }
    
    // MARK: - Getting the root view

    /// The root view of the SwiftUI view hierarchy managed by this view controller.
    public var rootView: Content {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    // MARK: - Private Properties

    private let hostingController: UIHostingController<Content>
    private var hostingView: UIView { hostingController.view }

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
