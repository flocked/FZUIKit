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
        get { getAssociatedValue("colorHandler", initialValue: nil) }
        set {
            setAssociatedValue(newValue, key: "colorHandler")
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
    
    var colorObservation: KeyValueObservation? {
        get { getAssociatedValue("colorObservation", initialValue: nil) }
        set {  setAssociatedValue(newValue, key: "colorObservation") }
    }
}

#endif
