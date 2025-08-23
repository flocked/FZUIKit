//
//  NSColorPanel+.swift
//
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSColorPanel {
    /// Sets the color of the color panel.
    @discardableResult
    public func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
    
    /// Sets the mode of the receiver the mode is one of the modes allowed by the color mask.
    @discardableResult
    public func mode(_ mode: Mode) -> Self {
        self.mode = mode
        return self
    }
    
    /// Sets the Boolean value indicating whether the receiver continuously sends the action message to the target.
    @discardableResult
    public func isContinuous(_ isContinuous: Bool) -> Self {
        self.isContinuous = isContinuous
        return self
    }
    
    /// Sets the accessory view.
    @discardableResult
    public func accessoryView(_ view: NSView?) -> Self {
        self.accessoryView = view
        return self
    }
    
    /// Sets the Boolean value indicating whether the receiver shows alpha values and an opacity slider.
    @discardableResult
    public func showsAlpha(_ shows: Bool) -> Self {
        self.showsAlpha = shows
        return self
    }
    
    /// The default action-message selector associated with the color panel.
    public var action: Selector? {
        get { nil }
        set { setAction(newValue) }
    }
    
    /// The target object that receives action messages from the color panel.
    public var target: AnyObject? {
        get { value(forKeySafely: "target") as? AnyObject  }
        set { setTarget(newValue) }
    }
    
    /// The handler that is called when the color changes.
    public var colorHandler: ((NSColor)->())? {
        get { getAssociatedValue("colorHandler") }
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
    
    /// Sets the handler that is called when the color changes.
    @discardableResult
    public func colorHandler(_ handler: ((NSColor)->())?) -> Self {
        self.colorHandler = handler
        return self
    }
    
    var colorObservation: KeyValueObservation? {
        get { getAssociatedValue("colorObservation") }
        set { setAssociatedValue(newValue, key: "colorObservation") }
    }
}

#endif
