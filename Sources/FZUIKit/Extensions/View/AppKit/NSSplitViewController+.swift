//
//  NSSplitViewController+.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSSplitViewController {
    /**
     A Boolean value indicating whether the sidebar is visible.
     
     If the split view doesn't contain a sidebar, it returns `false`.
     
     Changing the property is animatable by using `animator().isSidebarVisible`.
     */
    public var isSidebarVisible: Bool {
        get {
            guard let item = splitViewItems.first(where: { $0.behavior == .sidebar }) else { return false }
            return !item.isCollapsed
        }
        set {
            guard let item = splitViewItems.first(where: { $0.behavior == .sidebar }), newValue != !item.isCollapsed else { return }
            item.animator(isProxy()).isCollapsed = !newValue
        }
    }
    
    /**
     A Boolean value indicating whether the inspector is visible.
     
     If the split view doesn't contain a inspector, it returns `false`.
     
     Changing the property is animatable by using `animator().isInspectorVisible`.
     */
    @available(macOS 11.0, *)
    public var isInspectorVisible: Bool {
        get {
            guard let item = splitViewItems.last(where: { $0.behavior == .inspector }) else { return false }
            return !item.isCollapsed
        }
        set {
            guard let item = splitViewItems.first(where: { $0.behavior == .inspector }), newValue != !item.isCollapsed else { return }
            item.animator(isProxy()).isCollapsed = !newValue
        }
    }
}

extension NSSplitViewController: NSAnimatablePropertyContainer {
    public func animator() -> Self {
        NSObjectProxy(object: self).asObject()
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
