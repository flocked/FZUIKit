//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public protocol ViewBackgroundStyleCustomizable {
    var backgroundStyle: NSView.BackgroundStyle { get set }
}

extension NSTableCellView: ViewBackgroundStyleCustomizable { }
extension NSCell: ViewBackgroundStyleCustomizable { }
extension NSControl: ViewBackgroundStyleCustomizable {
    public var backgroundStyle: NSView.BackgroundStyle {
        get { self.cell?.backgroundStyle ?? .normal }
        set { self.cell?.backgroundStyle = newValue }
    }
}

public extension NSView {
    func backgroundStyle() -> NSView.BackgroundStyle {
        self.firstSubview(type: ViewBackgroundStyleCustomizable.self, depth: .max)?.backgroundStyle ?? .normal
    }
    
    func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        var stylableViews = self.subviews(type: ViewBackgroundStyleCustomizable.self, depth: .max)
        stylableViews.editEach {
            $0.backgroundStyle = backgroundStyle
        }
    }
}
#endif
