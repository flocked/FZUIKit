//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A protocol for views and cells with background style.
public protocol ViewBackgroundStyleCustomizable {
    var backgroundStyle: NSView.BackgroundStyle { get set }
}

extension NSTableCellView: ViewBackgroundStyleCustomizable { }
extension NSCell: ViewBackgroundStyleCustomizable { }
extension NSControl: ViewBackgroundStyleCustomizable {
    /// The background style of the control.`
    public var backgroundStyle: NSView.BackgroundStyle {
        get { self.cell?.backgroundStyle ?? .normal }
        set { self.cell?.backgroundStyle = newValue }
    }
}

public extension NSView {
    /// Returns the background style of the view.
    func backgroundStyle() -> NSView.BackgroundStyle {
        if let view = self as? ViewBackgroundStyleCustomizable {
            return view.backgroundStyle
        }
        return self.firstSubview(type: ViewBackgroundStyleCustomizable.self, depth: .max)?.backgroundStyle ?? .normal
    }
    
    /**
     Updates the background style of all subviews to the specified style.
     - Parameters backgroundStyle: The style to apply.
     */
    func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        var stylableViews = self.subviews(type: ViewBackgroundStyleCustomizable.self, depth: .max)
        stylableViews.editEach {
            $0.backgroundStyle = backgroundStyle
        }
    }
}
#endif
