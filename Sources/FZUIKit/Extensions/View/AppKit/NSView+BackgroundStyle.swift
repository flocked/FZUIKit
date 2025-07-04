//
//  NSView+BackgroundStyle.swift
//
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

public extension NSControl {
    /**
     The background style of the control.
     
     The background style describes the surface the view is drawn onto in the draw(withFrame:in:) method. A control may draw differently based on background characteristics. For example, a text cell might decide to render its text white, if the backgroundStyle is `emphasized`. A rating-style level indicator might draw its stars white instead of gray.
     */
    var backgroundStyle: NSView.BackgroundStyle {
        get { cell?.backgroundStyle ?? .normal }
        set { cell?.backgroundStyle = newValue }
    }
}

extension NSView {
    /**
     Updates the background style of the view and all nested subviews to the specified style.
     
     It updates the background style of `NSControl`, `NSTableCellView` and all views that implement ``setBackgroundStyle(_:)``.
          
     - Parameter backgroundStyle: The background style to apply.
     */
    @objc open func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        if let view = self as? NSTableCellView {
            view.backgroundStyle = backgroundStyle
        } else {
            (self as? NSControl)?.backgroundStyle = backgroundStyle
            if #available(macOS 12.0, *), let view = self as? NSImageView {
                view.updateSymbolConfiguration()
            }
            subviews.forEach({  $0.setBackgroundStyle(backgroundStyle)  })
            /*
            let selector = NSSelectorFromString("_setBackgroundStyleForSubtree:")
            guard let method = Self.instanceMethod(for: selector) else { return }
            subviews.forEach({
                if $0.responds(to: selector) {
                    unsafeBitCast(method, to: (@convention(c) (AnyObject, Selector, BackgroundStyle) -> ()).self)($0, selector, backgroundStyle)
                }
            })
             */
        }
    }
}

@available(macOS 12.0, *)
fileprivate extension NSImageView {
    func updateSymbolConfiguration() {
        configurationObservation = nil
        if backgroundStyle == .emphasized {
            previousConfiguration = symbolConfiguration
            if let configuration = symbolConfiguration {
                let copy = NSImage.SymbolConfiguration()
                copy.pointSize = configuration.pointSize
                copy.setValue(safely: configuration.value(forKeySafely: "weight"), forKey: "weight")
                copy.setValue(safely: configuration.value(forKeySafely: "scale"), forKey: "scale")
                symbolConfiguration = copy
            }
            configurationObservation = observeChanges(for: \.symbolConfiguration) { [weak self] old, new in
                guard let self = self else { return }
                self.updateSymbolConfiguration()
            }
        } else if backgroundStyle != .emphasized, let configuration = previousConfiguration {
            symbolConfiguration = configuration
            previousConfiguration = nil
        }
    }
    
    var configurationObservation: KeyValueObservation? {
        get { getAssociatedValue("configurationObservation") }
        set { setAssociatedValue(newValue, key: "configurationObservation") }
    }
    
    var previousConfiguration: NSImage.SymbolConfiguration? {
        get { getAssociatedValue("previousConfiguration") }
        set { setAssociatedValue(newValue, key: "previousConfiguration") }
    }
}

#endif
