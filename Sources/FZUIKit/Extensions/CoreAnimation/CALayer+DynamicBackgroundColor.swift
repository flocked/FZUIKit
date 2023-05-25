//
//  File.swift
//
//
//  Created by Florian Zand on 02.11.22.
//

import FZSwiftUtils
import QuartzCore

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

#if os(macOS)
internal protocol ObservableAppearanceObject: NSAppearanceCustomization {
    func observeEffectiveAppearance(changeHandler: @escaping (() -> Void)) -> NSKeyValueObservation
}

extension ObservableAppearanceObject where Self: NSObject & NSAppearanceCustomization {
    func observeEffectiveAppearance(changeHandler: @escaping (() -> Void)) -> NSKeyValueObservation {
        return observe(\.effectiveAppearance) { [weak self] _, _ in
            guard self != nil else { return }
            changeHandler()
        }
    }
}

extension NSView: ObservableAppearanceObject {}
extension NSApplication: ObservableAppearanceObject {}
extension NSWindow: ObservableAppearanceObject {}
extension NSMenu: ObservableAppearanceObject {}
extension NSPopover: ObservableAppearanceObject {}

public extension CALayer {
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

    var nsBackgroundColor: NSColor? {
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
                        effectiveAppearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] _, _ in
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

    internal var effectiveAppearanceObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_layerEffectiveAppearanceObserver", object: self) }
        set { set(associatedValue: newValue, key: "_layerEffectiveAppearanceObserver", object: self) }
    }

    internal func updateBackgroundColor() {
        let appearance = appearanceObject?.effectiveAppearance ?? NSApp.effectiveAppearance
        backgroundColor = nsBackgroundColor?.resolvedColor(for: appearance).cgColor
    }

    internal var appearanceObject: ObservableAppearanceObject? {
        if let appearanceObject = delegate as? ObservableAppearanceObject {
            return appearanceObject
        }
        return superlayer?.appearanceObject
    }
}
#endif

/*
 extension CALayer {
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

     internal func updateEffectiveAppearanceObserver() {
         effectiveAppearanceObserver?.invalidate()
         effectiveAppearanceObserver = nil
         if let appearanceObject = appearanceObject {
             self.effectiveAppearanceObserver = appearanceObject.observeEffectiveAppearance { [weak self] obj in
                 self?.updateBackgroundColor(obj)
             }
         } else {
             self.effectiveAppearanceObserver = NSApp.observe(\.effectiveAppearance) { [weak self] app, change in
                 self?.updateBackgroundColor(app)
             }
         }
     }

     var nsBackgroundColor: NSColor? {
         get { getAssociatedValue(key: "!backgroundColor", object: self) }
         set {
             set(associatedValue: newValue, key: "!backgroundColor", object: self)
             self.updateBackgroundColor()
             if newValue != nil {
                 if (self.effectiveAppearanceObserver == nil) {
                     self.updateEffectiveAppearanceObserver()
                 }
             } else {
                 self.effectiveAppearanceObserver?.invalidate()
                 self.effectiveAppearanceObserver = nil
             }
         }
     }

     internal var effectiveAppearanceObserver: NSKeyValueObservation? {
         get { getAssociatedValue(key: "_effectiveAppearanceObserver", object: self) }
         set { set(associatedValue: newValue, key: "_effectiveAppearanceObserver", object: self) } }

     internal func updateBackgroundColor(_ object: NSObject? = nil) {
         if let object = object {
             guard object == NSApp || object == self.appearanceObject else {
                 self.updateEffectiveAppearanceObserver()
                 return
             }
         }
         let appearance = appearanceObject?.effectiveAppearance ?? NSApp.effectiveAppearance
         self.backgroundColor = self.nsBackgroundColor?.resolvedColor(for: appearance).cgColor
     }

     internal var appearanceObject: (any ObservableAppearanceObject)? {
          var currentLayer: CALayer? = self
          while let layer = currentLayer {
              if let appearanceObject = (layer.delegate as? (any ObservableAppearanceObject)) {
                  return appearanceObject
              }
              currentLayer = currentLayer?.superlayer
          }
          return nil
      }
 }

 internal protocol ObservableAppearanceObject: NSObject, NSAppearanceCustomization {
     associatedtype Value: AnyObject
     func observeEffectiveAppearance(changeHandler: @escaping ((Value)->())) -> NSKeyValueObservation
 }

 extension ObservableAppearanceObject where Self: NSObject & NSAppearanceCustomization {
     func observeEffectiveAppearance( changeHandler: @escaping ((Self)->())) -> NSKeyValueObservation {
        return self.observe(\.effectiveAppearance) { [weak self] view, value in
             guard let self = self else { return }
             changeHandler(self)
         }
     }
 }

 extension NSView: ObservableAppearanceObject { }
 extension NSApplication: ObservableAppearanceObject { }
 extension NSWindow: ObservableAppearanceObject { }
 extension NSMenu: ObservableAppearanceObject { }
 extension NSPopover: ObservableAppearanceObject { }

 */
