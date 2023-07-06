//
//  File.swift
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
   @objc public var backgroundStyle: NSView.BackgroundStyle {
        get { self.cell?.backgroundStyle ?? .normal }
        set { self.cell?.backgroundStyle = newValue
            self.subviews.compactMap({$0 as? ViewBackgroundStyleCustomizable}).backgroundStyle = newValue
        }
    }
}

public extension NSView {
    public var backgroundStyle: NSView.BackgroundStyle {
        get {
            if let view = self as? ViewBackgroundStyleCustomizable {
                return view.backgroundStyle
            }
            return self.firstSubview(type: ViewBackgroundStyleCustomizable.self, depth: .max)?.backgroundStyle ?? .normal
            set {
                if let self = self as? ViewBackgroundStyleCustomizable {
                    self.backgroundStyle = newValue
                }
                
                self.subviews.forEach({$0.backgroundStyle = newValue })
                
            }
        }
    }
    
    
    
    /// Returns the background style of the view.
    func backgroundStyle() -> NSView.BackgroundStyle {
        if let view = self as? ViewBackgroundStyleCustomizable {
            return view.backgroundStyle
        }
        
        return self.firstSubview(type: ViewBackgroundStyleCustomizable.self, depth: .max)?.backgroundStyle ?? .normal
    }
    
    /**
     Updates the background style of all subviews to the specified style.
     
     The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A view may draw differently based on background characteristics. For example, a table view drawing a cell in a selected row might set the value to dark. A text cell might decide to render its text white as a result. A rating-style level indicator might draw its stars white instead of gray.

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
