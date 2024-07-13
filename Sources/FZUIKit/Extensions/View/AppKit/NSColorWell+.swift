//
//  NSColorWell+.swift
//
//
//  Created by Florian Zand on 07.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSColorWell {
    /// Sets the currently selected color for the color well.
    @discardableResult
    public func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
    
    /// Sets the appearance and interaction style to apply to the color well.
    @available(macOS 13.0, *)
    @discardableResult
    public func style(_ style: Style) -> Self {
        self.colorWellStyle = style
        return self
    }
    
    /// Sets the Boolean value that determines whether the color picker supports alpha values.
    @available(macOS 14.0, *)
    @discardableResult
    public func supportsAlpha(_ supports: Bool) -> Self {
        self.supportsAlpha = supports
        return self
    }
    
    /// Sets the image to display on the button portion of a color well that adopts the expanded style.
    @available(macOS 13.0, *)
    @discardableResult
    public func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
        
    /// Handler that gets called when the color changes.
    public var colorHandler: ((_ color: NSColor)->())? {
        get { getAssociatedValue("colorHandler", initialValue: nil) }
        set {
            setAssociatedValue(newValue, key: "colorHandler")
            if let colorHandler = newValue {
                colorObservation = observeChanges(for: \.color) { old, new in
                    guard old != new else { return }
                    colorHandler(new)
                }
            } else {
                colorObservation = nil
            }
        }
    }
    
    /// Sets the handler that gets called when the color changes.
    @discardableResult
    public func colorHandler(_ handler: ((NSColor)->())?) -> Self {
        self.colorHandler = handler
        return self
    }
    
    var colorObservation: KeyValueObservation? {
        get { getAssociatedValue("colorObservation", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "colorObservation") }
    }
    
    /// The pull down action handler.
    @available(macOS 13.0, *)
    public var pulldownActionBlock: ActionBlock? {
        set {
            if let newValue = newValue {
                pullDownActionTrampoline = ActionTrampoline(action: newValue)
                pulldownTarget = pullDownActionTrampoline
                pulldownAction = #selector(ActionTrampoline<Self>.performAction(sender:))
            } else if pullDownActionTrampoline != nil {
                pullDownActionTrampoline = nil
                if pulldownAction == #selector(ActionTrampoline<Self>.performAction(sender:)) {
                    pulldownAction = nil
                }
            }
        }
        get { pullDownActionTrampoline?.action }
    }
    
    /// Sets the pull down action handler.
    @available(macOS 13.0, *)
    @discardableResult
    public func pulldownAction(_ action: ActionBlock?) -> Self {
        pulldownActionBlock = action
        return self
    }
    
    var pullDownActionTrampoline: ActionTrampoline<NSColorWell>? {
        get { getAssociatedValue("pullDownActionTrampoline") }
        set { setAssociatedValue(newValue, key: "pullDownActionTrampoline") }
    }
}

#endif
