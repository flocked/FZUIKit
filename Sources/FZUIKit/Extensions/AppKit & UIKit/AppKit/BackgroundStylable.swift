//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public protocol BackgroundStylable {
    var backgroundStyle: NSView.BackgroundStyle { get set }
}

extension NSControl: BackgroundStylable {
    public var backgroundStyle: NSView.BackgroundStyle {
        get { self.cell?.backgroundStyle ?? .normal }
        set { self.cell?.backgroundStyle = newValue }
    }
}

extension NSTableCellView: BackgroundStylable { }

public extension NSView {
    func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        var stylableViews = self.subviews(type: BackgroundStylable.self, depth: .max)
        stylableViews.editEach {
            $0.backgroundStyle = backgroundStyle
        }
    }
}
#endif
