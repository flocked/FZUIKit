//
//  NSMenu+MenuItemHostingView.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

/// A custom menu item view that manages highlight state and renders an appropriate backdrop behind the view when highlighted.
public class MenuItemHostingView<Content: View>: MenuItemView {
    private let hostView: NSHostingView<AnyView>
    
    /// The root view of the SwiftUI view hierarchy displayed by the menu item view.
    public var rootView: Content {
        didSet { hostView.rootView = isHighlighted ? AnyView(rootView.environment(\.menuItemIsHighlighted, isHighlighted)) : AnyView(rootView) }
    }
    
    /**
     Creates a custom menu item view that displays the specified `SwiftUI` view and renders an appropriate backdrop behind the view when highlighted.
     
     - Parameters:
        - rootView: The view of the item.
        - showsHighlight: A Boolean value that indicates whether the menu item should show a highlight background color if it's highlighted by the user.
     */
    public init(rootView: Content, showsHighlight: Bool = true) {
        self.rootView = rootView
        hostView = NSHostingView(rootView: AnyView(rootView))
        super.init(frame: CGRect(origin: .zero, size: hostView.fittingSize))
        self.showsHighlight = showsHighlight
        addSubview(hostView, layoutAutomatically: true)
    }
    
    /**
     Creates a custom menu item view that displays the specified `SwiftUI` content and renders an appropriate backdrop behind the view when highlighted.
     
     - Parameters:
        - content: The view of the item.
        - showsHighlight: A Boolean value that indicates whether the menu item should show a highlight background color if it's highlighted by the user.
     */
    public convenience init(@ViewBuilder _ content: () -> Content, showsHighlight: Bool = true) {
        self.init(rootView: content(), showsHighlight: showsHighlight)
    }
    
    override var isHighlighted: Bool {
        didSet { hostView.rootView = AnyView(rootView.environment(\.menuItemIsHighlighted, isHighlighted)) }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnvironmentValues {
    private struct HighlightedKey: EnvironmentKey {
        static let defaultValue = false
    }
    
    /**
     A Boolean value that indicates whether the menu item is highlighted.
     
     Use this to adjust your content to look good in front of the selection background.
     
     - Note: Only updated inside of a `MenuItemHostingView(...).view { ... }` closure.
     */
    public var menuItemIsHighlighted: Bool {
        get { self[HighlightedKey.self] }
        set { self[HighlightedKey.self] = newValue }
    }
}
#endif
