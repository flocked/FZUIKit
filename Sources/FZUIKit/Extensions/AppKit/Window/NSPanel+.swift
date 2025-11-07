//
//  NSPanel+.swift
//
//
//  Created by Florian Zand on 04.08.25.
//

#if os(macOS)
import AppKit

extension NSPanel {
    /**
     Represents the type of an panel.
     
     The panel type determines the visual style and behavior of a panel, such as floating above other windows or having a heads-up display appearance.
    */
    public enum PanelType {
        /// A standard panel.
        case regular
        /// A utility panel that floats above standard windows, typically used for tool palettes or inspectors.
        case utility
        /// A heads-up display (`HUD`) panel with a dark translucent style, often used for overlay controls.
        case hud
    }
    
    /**
     The panel type (either `regular`, `utility` or `hud`).
     
     The panel type determines the visual style and behavior of the panel, such as floating above other windows or having a heads-up display appearance.
     */
    public var type: PanelType {
        get { styleMask.contains(.utilityWindow) ? styleMask.contains(.hudWindow) ? .hud : .utility : .regular }
        set {
            switch newValue {
            case .hud: styleMask.insert([.utilityWindow, .hudWindow])
            case .utility:
                styleMask.insert(.utilityWindow)
                styleMask.remove(.hudWindow)
            case .regular: styleMask.remove([.utilityWindow, .hudWindow])
            }
        }
    }
    
    /// Sets the panel type.
    @discardableResult
    public func type(_ type: PanelType) -> Self {
        self.type = type
        return self
    }
    
    /// A Boolean value indicating whether the panel does activate its owning application.
    @objc open var activatesApp: Bool {
        get { !styleMask.contains(.nonactivatingPanel) }
        set { styleMask[.nonactivatingPanel] = !newValue }
    }
    
    /// Sets the Boolean value indicating whether the panel does activate its owning application.
    @discardableResult
    @objc open func activatesApp(_ activates: Bool) -> Self {
        self.activatesApp = activates
        return self
    }
}
#endif
