//
//  NSTextFieldCell+.swift
//
//
//  Created by Florian Zand on 08.02.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSTextFieldCell {
    /// The focus ring type.
    public enum FocusType: Hashable {
        /// No focus ring.
        case none
        /// A capsule focus ring.
        case capsule
        /// A focus ring with rounded corners.
        case roundedCorners(CGFloat)
        /// A focus ring with relative rounded corners.
        case roundedCornersRelative(CGFloat)
        /// The default focus ring.
        case `default`
        
        var needsSwizzle: Bool {
            switch self {
            case .default: return false
            default: return true
            }
        }
    }
    
    /// The focus ring type.
    public var focusType: FocusType {
        get { getAssociatedValue(key: "focusType", object: self, initialValue: .default) }
        set {
            guard newValue != focusType else { return }
            set(associatedValue: newValue, key: "focusType", object: self)
            swizzleFocusCell()
        }
    }
    
    /// The vertical alignment of the text.
    public enum VerticalAlignment: Int, Hashable {
        /// The text is vertically centered.
        case center
        /// The default vertical text alignment.
        case `default`
    }

    /// The vertical alignment of the text.
    public var verticalAlignment: VerticalAlignment {
        get { getAssociatedValue(key: "verticalAlignment", object: self, initialValue: .default) }
        set {
            guard newValue != verticalAlignment else { return }
            set(associatedValue: newValue, key: "verticalAlignment", object: self)
            swizzleTextCell()
        }
    }

    /// The leading padding of the cell.
    public var leadingPadding: CGFloat {
        get { getAssociatedValue(key: "leadingPadding", object: self, initialValue: 0) }
        set {
            guard newValue != leadingPadding else { return }
            set(associatedValue: newValue, key: "leadingPadding", object: self)
            swizzleTextCell()
        }
    }
    /// The trailing padding of the cell.
    public var trailingPadding: CGFloat {
        get { getAssociatedValue(key: "trailingPadding", object: self, initialValue: 0) }
        set {
            guard newValue != trailingPadding else { return }
            set(associatedValue: newValue, key: "trailingPadding", object: self)
            swizzleTextCell()
        }
    }
    
    var needsSwizzling: Bool {
        leadingPadding != 0 || trailingPadding != 0 || verticalAlignment != .default
    }

    var isEditingOrSelecting: Bool {
        get { getAssociatedValue(key: "isEditingOrSelecting", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "isEditingOrSelecting", object: self) }
    }
    
    func titleRectWithPadding(for rect: NSRect) -> NSRect {
        let isLTR = userInterfaceLayoutDirection == .leftToRight
        let newRect = NSRect(x: rect.origin.x + (isLTR ? leadingPadding : trailingPadding),
                             y: rect.origin.y,
                             width: rect.width - leadingPadding - trailingPadding,
                             height: rect.height)
        return newRect
    }
    
    func swizzleTextCell() {
        if needsSwizzling {
            do {
                try replaceMethod(
                    #selector(titleRect(forBounds:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSRect) -> (NSRect)).self,
                    hookSignature: (@convention(block)  (AnyObject, NSRect) -> (NSRect)).self) { store in {
                        object, rect in
                        if let cell = object as? NSTextFieldCell {
                            switch cell.verticalAlignment {
                            case .center:
                                var titleRect = super.titleRect(forBounds: rect)
                                let minimumHeight = cell.cellSize(forBounds: rect).height
                                titleRect.origin.y += (titleRect.size.height - minimumHeight) / 2
                                titleRect.size.height = minimumHeight
                                titleRect = cell.titleRectWithPadding(for: titleRect)
                                return titleRect
                            case .default:
                                let paddedRect = cell.titleRectWithPadding(for: rect)
                                return store.original(object, #selector(NSTextFieldCell.titleRect(forBounds:)), paddedRect)
                            }
                        }
                        return store.original(object, #selector(NSTextFieldCell.titleRect(forBounds:)), rect)
                    }
               }
                try replaceMethod(
                    #selector(drawInterior(withFrame:in:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSRect, NSView) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSRect, NSView) -> ()).self) { store in {
                       object, cellFrame, controlView in
                        if let cell = object as? NSTextFieldCell {
                            store.original(object, #selector(NSTextFieldCell.drawInterior(withFrame:in:)), cell.titleRect(forBounds: cellFrame), controlView)
                        } else {
                            store.original(object, #selector(NSTextFieldCell.drawInterior(withFrame:in:)), cellFrame, controlView)
                        }
                    }
               }
                try replaceMethod(
                    #selector(edit(withFrame:in:editor:delegate:event:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSRect, NSView, NSText, Any?, NSEvent?) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSRect, NSView, NSText, Any?, NSEvent?) -> ()).self) { store in {
                        object, rect, controlView, textObj, delegate, event in
                        if let cell = object as? NSTextFieldCell {
                            cell.isEditingOrSelecting = true
                            store.original(object, #selector(NSTextFieldCell.edit(withFrame:in:editor:delegate:event:)), cell.titleRect(forBounds: rect), controlView, textObj, delegate, event)
                            cell.isEditingOrSelecting = false
                        } else {
                            store.original(object, #selector(NSTextFieldCell.edit(withFrame:in:editor:delegate:event:)), rect, controlView, textObj, delegate, event)
                        }
                    }
               }
                
                try replaceMethod(
                    #selector(select(withFrame:in:editor:delegate:start:length:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSRect, NSView, NSText, Any?, Int, Int) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSRect, NSView, NSText, Any?, Int, Int) -> ()).self) { store in {
                       object, rect, controlView, textObj, delegate, selStart, selLength in
                        if let cell = object as? NSTextFieldCell {
                            cell.isEditingOrSelecting = true
                            store.original(object, #selector(NSTextFieldCell.select(withFrame:in:editor:delegate:start:length:)), cell.titleRect(forBounds: rect), controlView, textObj, delegate, selStart, selLength)
                            cell.isEditingOrSelecting = false
                        } else {
                            store.original(object, #selector(NSTextFieldCell.select(withFrame:in:editor:delegate:start:length:)), rect, controlView, textObj, delegate, selStart, selLength)
                        }
                    }
               }
            } catch {
                Swift.debugPrint(error)
            }
        } else {
            resetMethod(#selector(titleRect(forBounds:)))
            resetMethod(#selector(drawInterior(withFrame:in:)))
            resetMethod(#selector(edit(withFrame:in:editor:delegate:event:)))
            resetMethod(#selector(select(withFrame:in:editor:delegate:start:length:)))

        }
    }
    
    func swizzleFocusCell() {
        if focusType.needsSwizzle {
            do {
                try replaceMethod(
                    #selector(NSTextFieldCell.drawFocusRingMask(withFrame:in:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSRect, NSView) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, NSRect, NSView) -> ()).self) { store in {
                        object, cellFrame, controlView in
                        let focusType = (object as? NSTextFieldCell)?.focusType ?? .default
                        
                        guard focusType != FocusType.none else {
                            return
                        }

                        var cornerRadius: CGFloat = 0
                        switch focusType {
                        case .capsule:
                            cornerRadius = cellFrame.size.height / 2.0
                        case let .roundedCorners(radius):
                            cornerRadius = radius
                        case let .roundedCornersRelative(relative):
                            cornerRadius = cellFrame.size.height / 2.0
                            cornerRadius = cornerRadius * relative.clamped(max: 1.0)
                        default:
                            break
                        }

                        // Draw default
                        guard focusType != FocusType.default, cornerRadius != 0 else {
                            store.original(object, #selector(NSTextFieldCell.drawFocusRingMask(withFrame:in:)), cellFrame, controlView)

                            super.drawFocusRingMask(withFrame: cellFrame, in: controlView)
                            return
                        }
          

                        // Custome
                        // Make forcus ring frame fit with cell size
                        // let newFrame = cellFrame.insetBy(dx: 2, dy: 1)
                        let newFrame = cellFrame

                        let path = NSBezierPath(roundedRect: newFrame, xRadius: cornerRadius, yRadius: cornerRadius)
                        path.fill()
                    }
                    }
            } catch {
                Swift.debugPrint(error)
            }
        } else {
            resetMethod(#selector(NSTextFieldCell.drawFocusRingMask(withFrame:in:)))
        }
    }
}

#endif
