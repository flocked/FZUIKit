//
//  ToolbarItem+Separator.swift
//  FZUIKit
//
//  Created by Florian Zand on 21.06.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension Toolbar {
    /// A toolbar separator item that displays a vertical line.
    static func separator() -> ToolbarItem {
        let margin = 4.0
        let lineWidth = 1.0
        let height = 16.0
        let containerWidth = margin * 2 + lineWidth
        let containerView = NSView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: height))
        let line = NSBox(frame: CGRect(margin, 0, lineWidth, height)).type(.separator).fillColor(.separatorColor)
        containerView.addSubview(line)
        return Toolbar.View("separator", view: containerView)
    }
}

#endif
