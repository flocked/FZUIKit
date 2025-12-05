//
//  NSVisualEffectView+.swift
//
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)

import AppKit
import Foundation

public extension NSVisualEffectView {
    /**
     Applies a mask image with the specified corner radius.
     
     - Parameter cornerRadius: The corner radius to apply.
     */
    func roundCorners(withRadius cornerRadius: CGFloat) {
        maskImage = (cornerRadius != 0.0) ? .maskImage(cornerRadius: cornerRadius) : nil
    }
    
    /// Sets the material shown by the visual effect view.
    @discardableResult
    func material(_ material: Material) -> Self {
        self.material = material
        return self
    }
    
    /// Sets the value indicating how the view’s contents blend with the surrounding content.
    @discardableResult
    func blendingMode(_ blendingMode: BlendingMode) -> Self {
        self.blendingMode = blendingMode
        return self
    }
    
    /// Sets the Boolean value indicating whether to emphasize the look of the material.
    @discardableResult
    func isEmphasized(_ isEmphasized: Bool) -> Self {
        self.isEmphasized = isEmphasized
        return self
    }
    
    /// Sets the value indicating whether a view has a visual effect applied.
    @discardableResult
    func state(_ state: State) -> Self {
        self.state = state
        return self
    }
    
    /// Sets the image whose alpha channel masks the visual effect view's material.
    @discardableResult
    func maskImage(_ maskImage: NSImage?) -> Self {
        self.maskImage = maskImage
        return self
    }
}

extension NSVisualEffectView.Material: Swift.Encodable, Swift.Decodable { }
extension NSVisualEffectView.State: Swift.Encodable, Swift.Decodable { }
extension NSVisualEffectView.BlendingMode: Swift.Encodable, Swift.Decodable { }

extension NSVisualEffectView.State: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .followsWindowActiveState: return "followsWindowActiveState"
        case .active: return "active"
        case .inactive: return "inactive"
        }
    }
}

extension NSVisualEffectView.BlendingMode: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .behindWindow: return "behindWindow"
        case .withinWindow: return "withinWindow"
        }
    }
}

extension NSVisualEffectView.Material: Swift.CustomStringConvertible {
    public var description: String {
        switch self {
        case .titlebar: return "titlebar"
        case .selection: return "selection"
        case .menu: return "menu"
        case .popover: return "popover"
        case .sidebar: return "sidebar"
        case .headerView: return "headerView"
        case .sheet: return "sheet"
        case .windowBackground: return "windowBackground"
        case .hudWindow: return "hudWindow"
        case .fullScreenUI: return "fullScreenUI"
        case .toolTip: return "toolTip"
        case .contentBackground: return "contentBackground"
        case .underWindowBackground: return "underWindowBackground"
        case .underPageBackground: return "underPageBackground"
        case .appearanceBased: return "appearanceBased"
        case .light: return "light"
        case .dark: return "dark"
        case .mediumLight: return "mediumLight"
        case .ultraDark: return "ultraDark"
        default: return "\(rawValue)"
        }
    }
}

#endif
