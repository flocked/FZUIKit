//
//  NSMenu+MenuItemHostingView.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

/// A custom menu item view that manages highlight state and renders
/// an appropriate backdrop behind the view when highlighted
public class MenuItemHostingView<Content: View>: MenuItemView {
    public var contentView: Content
    private let hostView: NSHostingView<AnyView>
    
    public init(contentView: Content, showsHighlight: Bool = true) {
        self.contentView = contentView
        hostView = NSHostingView(rootView: AnyView(contentView))
        super.init(frame: CGRect(origin: .zero, size: hostView.fittingSize))
        self.showsHighlight = showsHighlight
       // setBackgroundStyle(.)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(withConstraint: hostView)
    }
    
    override var isHighlighted: Bool {
        didSet {
            hostView.rootView = AnyView(contentView.environment(\.menuItemIsHighlighted, isHighlighted))
        }
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
    
    /// Only updated inside of a `MenuItem(...).view { ... }` closure.
    /// Use this to adjust your content to look good in front of the selection background
    public var menuItemIsHighlighted: Bool {
        get {
            self[HighlightedKey.self]
        }
        set {
            self[HighlightedKey.self] = newValue
        }
    }
}
#endif
