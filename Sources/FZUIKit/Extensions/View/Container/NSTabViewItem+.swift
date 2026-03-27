//
//  NSTabViewItem+.swift
//  
//
//  Created by Florian Zand on 27.03.26.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSTabViewItem {
    /// Sets the label text of the tab view item.
    @discardableResult
    func label(_ label: String) -> Self {
        self.label = label
        return self
    }
    
    /// Sets the background color for content in the view.
    @discardableResult
    func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
    
    /// Sets the initial first responder for the view associated with the tab view item (the view that is displayed when a user clicks on the tab) to view.
    @discardableResult
    func initialFirstResponder(_ firstResponder: NSView?) -> Self {
        self.initialFirstResponder = firstResponder
        return self
    }
    
    /// Sets the image of the tab view item.
    @discardableResult
    func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
    
    /// Sets the tooltip displayed for the tab view item.
    func tooltip(_ tooltip: String?) -> Self {
        self.toolTip = tooltip
        return self
    }
    
    /// Creates a tab view item with the specified view and label.
    convenience init(view: NSView, label: String) {
        self.init(identifier: ObjectIdentifier(view).hashValue.string)
        self.view = view
        self.label = label
    }
    
    /// Creates a tab view item with the specified view controller and label.
    convenience init(viewController: NSViewController, label: String) {
        self.init(viewController: viewController)
        self.label = label
    }
    
    /// A Boolean value indicating whether the tab view item is selected.
    var isSelected: Bool {
        get {
            if let tabView = tabView {
                return tabView.selectedTabViewItem == self
            }
            return tabViewObservation != nil
        }
        set {
            if let tabView = tabView, tabView.tabViewItems.contains(where: { $0 === self }) {
                if newValue {
                    tabView.selectTabViewItem(self)
                } else if tabView.selectedTabViewItem == self {
                    tabView.selectNextTabViewItem(nil)
                }
            } else {
                tabViewObservation = newValue ? observeChanges(for: \.tabView) { [weak self] _, new in
                    guard let self = self, let new = new, new.tabViewItems.contains(where: {$0 === self }) else { return }
                    new.selectTabViewItem(self)
                } : nil
            }
        }
    }
    
    /// Sets the Boolean value indicating whether the tab view item is selected.
    func isSelected(_ isSelected: Bool) -> Self {
        self.isSelected = isSelected
        return self
    }
    
    private var tabViewObservation: KeyValueObservation? {
        get { getAssociatedValue("tabViewObservation") }
        set { setAssociatedValue(newValue, key: "tabViewObservation") }
    }
}

#endif
