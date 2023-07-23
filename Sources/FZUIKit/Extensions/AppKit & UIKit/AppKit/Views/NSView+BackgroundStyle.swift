//
//  NSView+BackgroundStyle.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils



/**
 A protocol for views and cells with background style.
 
 The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A view may draw differently based on background characteristics. For example, a table view drawing a cell in a selected row might set the value to dark. A text cell might decide to render its text white as a result. A rating-style level indicator might draw its stars white instead of gray.
 */
public protocol ViewBackgroundStyleCustomizable {
    var backgroundStyle: NSView.BackgroundStyle { get set }
}

extension NSTableCellView: ViewBackgroundStyleCustomizable { }
extension NSCell: ViewBackgroundStyleCustomizable { }
extension NSControl: ViewBackgroundStyleCustomizable {
    /**
     The background style of the view.
     
     The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A view may draw differently based on background characteristics. For example, a table view drawing a cell in a selected row might set the value to dark. A text cell might decide to render its text white as a result. A rating-style level indicator might draw its stars white instead of gray.
     */
    public var backgroundStyle: NSView.BackgroundStyle {
        get { self.cell?.backgroundStyle ?? .normal }
        set { self.cell?.backgroundStyle = newValue }
    }
}

public extension NSView {
    /**
     Updates the background style of all nested subviews to the specified style.
     
     The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A view may draw differently based on background characteristics. For example, a table view drawing a cell in a selected row might set the value to dark. A text cell might decide to render its text white as a result. A rating-style level indicator might draw its stars white instead of gray.

     - Parameters backgroundStyle: The style to apply.
     */
    func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        if var self = (self as? ViewBackgroundStyleCustomizable) {
            self.backgroundStyle = backgroundStyle
        }
        
        for subview in subviews {
            subview.setBackgroundStyle(backgroundStyle)
        }
    }
}

public extension NSCollectionViewItem {
    /**
     Updates the background style of all nested subviews to the specified style.
     
     The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A view may draw differently based on background characteristics. For example, a table view drawing a cell in a selected row might set the value to dark. A text cell might decide to render its text white as a result. A rating-style level indicator might draw its stars white instead of gray.

     - Parameters backgroundStyle: The style to apply.
     */
    func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        self.view.setBackgroundStyle(backgroundStyle)
    }
}
#endif
