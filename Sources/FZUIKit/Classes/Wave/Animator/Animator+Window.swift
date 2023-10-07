//
//  File.swift
//  
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS)
import AppKit

extension NSWindow: Animatable { }

extension Animator where Object: NSWindow {
    /// The background color of the window.
    public var backgroundColor: NSUIColor {
        get { value(for: \.backgroundColor) }
        set { setValue(newValue, for: \.backgroundColor) }
    }
    
    /// The alpha of the window.
    public var alpha: CGFloat {
        get { value(for: \.alphaValue) }
        set { setValue(newValue, for: \.alphaValue) }
    }
    
    /// The frame of the window.
    public var frame: CGRect {
        get { value(for: \._frame) }
        set { setValue(newValue, for: \._frame) }
    }
    
    /// The size of the window.
    public var size: CGSize {
        get { frame.size }
        set { frame.size = newValue }
    }
}

fileprivate extension NSWindow {
   @objc dynamic var _frame: CGRect {
        get { frame }
        set { setFrame(newValue, display: false) }
    }
}

#endif
