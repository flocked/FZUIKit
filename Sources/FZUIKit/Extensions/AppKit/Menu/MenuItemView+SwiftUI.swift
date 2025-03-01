//
//  NSMenu+NSMenuItemHostingView.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

/// A custom menu item view that manages highlight state and renders an appropriate backdrop behind the view when highlighted.
public class NSMenuItemHostingView<Content: View>: NSMenuItemView {
    private let hostingView: NSHostingView<ItemView>
    
    private struct ItemView: View {
        let content: Content
        let isHighlighted: Bool
        let isEnabled: Bool
        
        init(_ content: Content, isHighlighted: Bool = false, isEnabled: Bool = true) {
            self.content = content
            self.isHighlighted = isHighlighted
            self.isEnabled = isEnabled
        }
        var body: some View {
            content.environment(\.menuItemIsHighlighted, isHighlighted).environment(\.menuItemIsEnabled, isEnabled)
        }
    }
    
    /// The root view of the `SwiftUI view hierarchy displayed by the menu item view.
    public var rootView: Content {
        get { hostingView.rootView.content }
        set { hostingView.rootView = ItemView(newValue, isHighlighted: isHighlighted && isEnabled && showsHighlight, isEnabled: isEnabled) }
    }
    
    /// Sets the root view of the `SwiftUI` view hierarchy displayed by the menu item view.
    @discardableResult
    public func rootView(_ rootView: Content) -> Self {
        self.rootView = rootView
        return self
    }
    
    /// The options for how the view creates and updates constraints based on the size of ``rootView``.
    @available(macOS 13.0, *)
    public var sizingOptions: NSHostingSizingOptions {
        get { hostingView.sizingOptions }
        set {
            hostingView.sizingOptions = newValue
            frame.size = hostingView.fittingSize
        }
    }
    
    /// Sets the options for how the view creates and updates constraints based on the size of ``rootView``.
    @discardableResult
    @available(macOS 13.0, *)
    public func sizingOptions(_ sizingOptions: NSHostingSizingOptions) -> Self {
        self.sizingOptions = sizingOptions
        return self
    }
    
    /**
     Creates a custom menu item view that displays the specified `SwiftUI` view and renders an appropriate backdrop behind the view when highlighted.
     
     - Parameters:
        - rootView: The view of the item.
        - showsHighlight: A Boolean value that indicates whether the menu item should show a highlight background color if it's highlighted by the user.
     */
    public init(rootView: Content, showsHighlight: Bool = true) {
        hostingView = NSHostingView(rootView: ItemView(rootView))
        super.init(frame: CGRect(origin: .zero, size: hostingView.fittingSize))
        self.showsHighlight = showsHighlight
        addSubview(hostingView, layoutAutomatically: true)
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
    
    /**
     Creates a custom menu item view that displays the specified `SwiftUI` view and renders an appropriate backdrop behind the view when highlighted.
     
     - Parameters:
        - rootView: The view of the item.
        - showsHighlight: A Boolean value that indicates whether the menu item should show a highlight background color if it's highlighted by the user.
        - sizingOptions: The options for how the view creates and updates constraints based on the size of `rootView`.
     */
    @available(macOS 13.0, *)
    public convenience init(rootView: Content, showsHighlight: Bool = true, sizingOptions: NSHostingSizingOptions) {
        self.init(rootView: rootView, showsHighlight: showsHighlight)
        self.sizingOptions = sizingOptions
    }
    
    /**
     Creates a custom menu item view that displays the specified `SwiftUI` content and renders an appropriate backdrop behind the view when highlighted.
     
     - Parameters:
        - content: The view of the item.
        - showsHighlight: A Boolean value that indicates whether the menu item should show a highlight background color if it's highlighted by the user.
        - sizingOptions: The options for how the view creates and updates constraints based on the size of `rootView`.
     */
    @available(macOS 13.0, *)
    public convenience init(@ViewBuilder _ content: () -> Content, showsHighlight: Bool = true, sizingOptions: NSHostingSizingOptions) {
        self.init(rootView: content(), showsHighlight: showsHighlight)
        self.sizingOptions = sizingOptions
    }
    
    public override func updateHighlight() {
        super.updateHighlight()
        hostingView.rootView = ItemView(rootView, isHighlighted: isHighlighted && isEnabled && showsHighlight, isEnabled: isEnabled)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnvironmentValues {
    /**
     A Boolean value that indicates whether the menu item is highlighted.
     
     Use this to adjust your content to look good in front of the selection background.
     
     - Note: Only updated inside of a `NSMenuItemHostingView(...).view { ... }` closure.
     */
    public var menuItemIsHighlighted: Bool {
        get { self[MenuItemIsHighlightedKey.self] }
        set { self[MenuItemIsHighlightedKey.self] = newValue }
    }
    
    /**
     A Boolean value that indicates whether the menu item is isEnabled.
     
     Use this to adjust your content to look good in front of the selection background.
     
     - Note: Only updated inside of a `NSMenuItemHostingView(...).view { ... }` closure.
     */
    public var menuItemIsEnabled: Bool {
        get { self[MenuItemIsEnabledKey.self] }
        set { self[MenuItemIsEnabledKey.self] = newValue }
    }
    
    private struct MenuItemIsHighlightedKey: EnvironmentKey {
        static let defaultValue = false
    }
    
    private struct MenuItemIsEnabledKey: EnvironmentKey {
        static let defaultValue = false
    }
}
#endif
