//
//  File.swift
//
//
//  Created by Florian Zand on 02.11.22.
//


#if os(macOS)
import AppKit
import FZSwiftUtils
import QuartzCore

internal protocol ObservableAppearanceObject: NSAppearanceCustomization {
    func observeEffectiveAppearance(changeHandler: @escaping (() -> Void)) -> NSKeyValueObservation
}

extension NSView: ObservableAppearanceObject {}
extension NSApplication: ObservableAppearanceObject {}
extension NSWindow: ObservableAppearanceObject {}
extension NSMenu: ObservableAppearanceObject {}
extension NSPopover: ObservableAppearanceObject {}

extension ObservableAppearanceObject where Self: NSObject & NSAppearanceCustomization {
    func observeEffectiveAppearance(changeHandler: @escaping (() -> Void)) -> NSKeyValueObservation {
        return observeChange(\.effectiveAppearance) { [weak self] _,_, _ in
            guard self != nil else { return }
            changeHandler()
        }
    }
}

public extension CALayer {
    /// The background color of the layer that automatically updates whenever the appearance of the app changes (e.g. on dark & light mode).
    var dynamicBackgroundColor: NSColor? {
        get { getAssociatedValue(key: "_layerNSBackgroundColor", object: self) }
        set {
            set(associatedValue: newValue, key: "_layerNSBackgroundColor", object: self)
            updateBackgroundColor()
            if newValue != nil {
                if effectiveAppearanceObserver == nil {
                    if let appearanceObject = appearanceObject {
                        effectiveAppearanceObserver = appearanceObject.observeEffectiveAppearance { [weak self] in
                            self?.updateBackgroundColor()
                        }
                    } else {
                        effectiveAppearanceObserver = NSApp.observeChange(\.effectiveAppearance) { [weak self] _,_, _ in
                            self?.updateBackgroundColor()
                        }
                    }
                }
            } else {
                effectiveAppearanceObserver?.invalidate()
                effectiveAppearanceObserver = nil
            }
        }
    }
    
    var superview: NSView? {
        var currentLayer: CALayer? = self
        while let layer = currentLayer {
            if let view = (layer.delegate as? NSView) {
                return view
            }
            currentLayer = currentLayer?.superlayer
        }
        return nil
    }

    internal var effectiveAppearanceObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_layerEffectiveAppearanceObserver", object: self) }
        set { set(associatedValue: newValue, key: "_layerEffectiveAppearanceObserver", object: self) }
    }

    internal func updateBackgroundColor() {
        let appearance = appearanceObject?.effectiveAppearance ?? NSApp.effectiveAppearance
        backgroundColor = dynamicBackgroundColor?.resolvedColor(for: appearance).cgColor
    }

    internal var appearanceObject: ObservableAppearanceObject? {
        if let appearanceObject = delegate as? ObservableAppearanceObject {
            return appearanceObject
        }
        return superlayer?.appearanceObject
    }
}



#endif
