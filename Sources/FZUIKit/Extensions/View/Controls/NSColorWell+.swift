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
    
    /// Sets the handler that gets called when the color changes.
    @discardableResult
    public func colorHandler(_ handler: ((NSColor)->())?) -> Self {
        self.colorHandler = handler
        return self
    }
    
    var colorObservation: KeyValueObservation? {
        get { getAssociatedValue("colorObservation") }
        set { setAssociatedValue(newValue, key: "colorObservation") }
    }
    
    /// The pull down action handler.
    @available(macOS 13.0, *)
    public var pulldownActionBlock: ActionBlock? {
        set {
            setAssociatedValue(newValue, key: "pulldownActionBlock")
            if newValue != nil {
                pulldownTarget = self
                pulldownAction = #selector(performPulldownAction)
            } else {
                if pulldownTarget === self {
                    pulldownTarget = nil
                }
                if pulldownAction == #selector(performPulldownAction) {
                    pulldownAction = nil
                }
            }
        }
        get { getAssociatedValue("pulldownActionBlock") }
    }
    
    /// Sets the pull down action handler.
    @available(macOS 13.0, *)
    @discardableResult
    public func pulldownAction(_ action: ActionBlock?) -> Self {
        pulldownActionBlock = action
        return self
    }
    
    @available(macOS 13.0, *)
    @objc func performPulldownAction() {
        pulldownActionBlock?(self)
    }
}

#endif
