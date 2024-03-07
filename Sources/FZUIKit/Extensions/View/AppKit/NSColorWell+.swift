//
//  NSColorWell+.swift
//
//
//  Created by Florian Zand on 07.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSColorWell {
    /// Handler that gets called when the color changes.
    public var colorHandler: ((_ color: NSColor)->())? {
        get { getAssociatedValue(key: "colorHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "colorHandler", object: self)
            if let colorHandler = newValue {
                colorObservation = observeChanges(for: \.color) { old, new in
                    guard old != new else { return }
                    colorHandler(new)
                }
            } else {
                colorObservation = nil
            }
        }
    }
    
    var colorObservation: NSKeyValueObservation? {
        get { getAssociatedValue(key: "colorObservation", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "colorObservation", object: self) }
    }
}

#endif
