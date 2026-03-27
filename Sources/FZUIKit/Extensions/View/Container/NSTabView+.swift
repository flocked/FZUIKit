//
//  NSTabView+.swift
//
//
//  Created by Florian Zand on 27.03.26.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSTabView {
    /// Create a new tab view with the specified tab view items.
    convenience init(items: [NSTabViewItem]) {
        self.init(frame: CGRect(.zero, items.compactMap({$0.view?.frame}).union().size))
        self.tabViewItems = items
    }
    
    /// Create a new tab view with the specified tab view items.
    convenience init(@Builder items: () -> [NSTabViewItem]) {
        self.init(items: items())
    }
    
    /// Selects the tab view item with the specified view.
    func selectTabViewItem(withView view: NSView) {
        guard let index = tabViewItems.firstIndex(where: {$0.view === view}) else { return }
        selectTabViewItem(at: index)
    }
    
    /// Selects the tab view item with the specified view controller.
    func selectTabViewItem(withViewController viewController: NSViewController) {
        guard let index = tabViewItems.firstIndex(where: {$0.viewController === viewController}) else { return }
        selectTabViewItem(at: index)
    }
    
    /// Sets the font used for the tab view’s label text.
    @discardableResult
    func font(_ font: NSFont) -> Self {
        self.font = font
        return self
    }
    
    /// Sets the position of the tabs.
    @discardableResult
    func tabPosition(_ position: TabPosition) -> Self {
        self.tabPosition = position
        return self
    }
    
    /// Sets the border type of the tab view.
    @discardableResult
    func borderType(_ borderType: TabViewBorderType) -> Self {
        self.tabViewBorderType = borderType
        return self
    }
    
    /// Sets the Boolean value that indicates if the tab view draws a background color when its type is `NSNoTabsNoBorder.
    @discardableResult
    func drawsBackground(_ drawsBackground: Bool) -> Self {
        self.drawsBackground = drawsBackground
        return self
    }
    
    /// Sets the Boolean value that indicates if the tab view allows truncating for labels that don’t fit on a tab.
    @discardableResult
    func allowsTruncatedLabels(_ allows: Bool) -> Self {
        self.allowsTruncatedLabels = allows
        return self
    }
    
    /// The handler of a tab view.
    struct Handler {
        /// The handler that gets called when a tab view item is about to be selected.
        var willSelect: ((NSTabViewItem?)->())?
        /// The handler that gets called when a tab view item has been selected.
        var didSelect: ((NSTabViewItem?)->())?
        /// The handler that determinates whether a tab view item should be selected.
        var shouldSelect: ((NSTabViewItem?)->(Bool))?
        /// The handler that gets called when the number of items has been changed.
        var didChangeNumberOfItems: ((Int)->())?
        
        var needsDelegate: Bool {
            willSelect != nil || didSelect != nil || shouldSelect != nil || didChangeNumberOfItems != nil
        }
    }
    
    /// The handlers of the tab view.
    var handler: Handler {
        get { getAssociatedValue("handler") ?? Handler() }
        set {
            setAssociatedValue(newValue, key: "handler")
            if newValue.needsDelegate {
                guard tabViewDelegate == nil else { return }
                tabViewDelegate = TabViewDelegate(for: self)
            } else if let tabViewDelegate = tabViewDelegate {
                self.tabViewDelegate = nil
                self.delegate = tabViewDelegate.delegate
            }
        }
    }
    
    private class TabViewDelegate: NSObject, NSTabViewDelegate {
        var delegate: NSTabViewDelegate?
        var observation: KeyValueObservation?
        weak var tabView: NSTabView?
        
        init(for tabView: NSTabView) {
            super.init()
            delegate = tabView.delegate
            tabView.delegate = self
            self.tabView = tabView
            observation = tabView.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.tabView?.delegate = self
            }
        }
        
        func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
            tabView.handler.didSelect?(tabViewItem)
            delegate?.tabView?(tabView, didSelect: tabViewItem)
        }
        
        func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
            tabView.handler.willSelect?(tabViewItem)
            delegate?.tabView?(tabView, willSelect: tabViewItem)
        }
        
        func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
            tabView.handler.shouldSelect?(tabViewItem) ?? delegate?.tabView?(tabView, shouldSelect: tabViewItem) ?? true
        }
        
        func tabViewDidChangeNumberOfTabViewItems(_ tabView: NSTabView) {
            tabView.handler.didChangeNumberOfItems?(tabView.tabViewItems.count)
            delegate?.tabViewDidChangeNumberOfTabViewItems?(tabView)
        }
    }
    
    private var tabViewDelegate: TabViewDelegate? {
        get { getAssociatedValue("tabViewDelegate") }
        set { setAssociatedValue(newValue, key: "tabViewDelegate") }
    }
    
    /// A function builder type that produces an array of tab view items.
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ block: [NSTabViewItem]...) -> [NSTabViewItem] {
            block.flatMap { $0 }
        }
        
        public static func buildOptional(_ item: [NSTabViewItem]?) -> [NSTabViewItem] {
            item ?? []
        }
        
        public static func buildEither(first: [NSTabViewItem]?) -> [NSTabViewItem] {
            first ?? []
        }
        
        public static func buildEither(second: [NSTabViewItem]?) -> [NSTabViewItem] {
            second ?? []
        }
        
        public static func buildArray(_ components: [[NSTabViewItem]]) -> [NSTabViewItem] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expr: [NSTabViewItem]?) -> [NSTabViewItem] {
            expr ?? []
        }
        
        public static func buildExpression(_ expr: NSTabViewItem?) -> [NSTabViewItem] {
            expr.map { [$0] } ?? []
        }
    }
}

#endif
