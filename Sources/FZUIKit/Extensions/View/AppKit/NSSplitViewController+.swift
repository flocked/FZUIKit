//
//  NSSplitViewController+.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import _ObjectProxy

extension NSSplitViewController {
    /**
     A Boolean value that indicates whether the sidebar is visible.
     
     If the split view doesn't contain a sidebar, it returns `false`.
     
     Changing the property is animatable by using `animator().isSidebarVisible`.
     */
    @objc public dynamic var isSidebarVisible: Bool {
        get {
            guard let item = splitViewItems.first(where: { $0.behavior == .sidebar }) else { return false }
            return !item.isCollapsed
        }
        set {
            guard let item = splitViewItems.first(where: { $0.behavior == .sidebar }), newValue != !item.isCollapsed else { return }
            if isAnimatingItem {
                isAnimatingItem = false
                toggleSidebar(nil)
            } else {
                item.isCollapsed = !newValue
            }
        }
    }
    
    /**
     A Boolean value indicating whether the inspector is visible.
     
     If the split view doesn't contain a inspector, it returns `false`.
     
     Changing the property is animatable by using `animator().isInspectorVisible`.
     */
    @available(macOS 11.0, *)
    @objc public dynamic var isInspectorVisible: Bool {
        get {
            guard let item = splitViewItems.first(where: { $0.behavior == .inspector }) else { return false }
            return !item.isCollapsed
        }
        set {
            guard let item = splitViewItems.first(where: { $0.behavior == .inspector }), newValue != !item.isCollapsed else { return }
            if isAnimatingItem {
                isAnimatingItem = false
                if #available(macOS 14.0, *) {
                    toggleInspector(nil)
                } else {
                    item.animator().isCollapsed = !newValue
                }
            } else {
                item.isCollapsed = !newValue
            }
        }
    }
    
    var isAnimatingItem: Bool {
        get { getAssociatedValue("isAnimatingItem") ?? false }
        set { setAssociatedValue(newValue, key: "isAnimatingItem") }
    }
}

extension NSSplitViewController: NSAnimatablePropertyContainer {
    public func animator() -> Self {
        return _objectProxy { [weak self] invocation in
            guard let invocation = invocation else { return }
            if #available(macOS 11.0, *) {
                self?.isAnimatingItem = invocation.selector == #selector(setter: NSSplitViewController.isSidebarVisible) || invocation.selector == #selector(setter: NSSplitViewController.isInspectorVisible)
            } else {
                self?.isAnimatingItem = invocation.selector == #selector(setter: NSSplitViewController.isSidebarVisible)
            }
            invocation.invoke()
        }
    }
    
    public var animations: [NSAnimatablePropertyKey : Any] {
        get { [:] }
        set { }
    }
    
    public func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
        nil
    }
    
    public static func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        nil
    }
}

#endif
