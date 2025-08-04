//
//  NSPanel+.swift
//
//
//  Created by Florian Zand on 04.08.25.
//

#if os(macOS)
import AppKit

extension NSPanel {
    /// A Boolean value indicating whether the panel is a Utility panel.
    @objc open var isUtility: Bool {
        get { styleMask.contains(.utilityWindow) }
        set { styleMask[.utilityWindow] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the panel is a Utility panel.
    @discardableResult
    @objc open func isUtility(_ isUtility: Bool) -> Self {
        self.isUtility = isUtility
        return self
    }
    
    /// A Boolean value indicating whether the panel is non active.
    @objc open var isNonActive: Bool {
        get { styleMask.contains(.nonactivatingPanel) }
        set { styleMask[.nonactivatingPanel] = newValue }
    }
    
    /// Sets the Boolean value indicating whether the panel is non active.
    @discardableResult
    @objc open func isNonActive(_ isNonActive: Bool) -> Self {
        self.isNonActive = isNonActive
        return self
    }
    
    /// A Boolean value indicating whether the panel is a HUD panel.
    @objc open var isHUD: Bool {
        get { styleMask.contains(.hudWindow) }
        set {
            if newValue {
                styleMask.insert([.utilityWindow, .hudWindow])
            } else {
                styleMask.remove(.hudWindow)
            }
        }
    }
    
    /// Sets the Boolean value indicating whether the panel is a HUD panel.
    @discardableResult
    @objc open func isHUD(_ isHUD: Bool) -> Self {
        self.isHUD = isHUD
        return self
    }
}
#endif
