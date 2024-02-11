//
//  NSMenuItem+HighlightableView.swift
//
// Parts taken from:
// Copyright © 2022 Darren Ford
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit
extension NSMenuItem {
    
    /**
     A `NSView` instance that can be used as the base NSView type for an NSMenuItem that will react to mouse hover _similarly_ to how a regular menuitem does.
     
     If you attach an NSView to an NSMenuItem, you are responsible for handling ALL the drawing events for the menu item, including hoveer coloring etc. This class can be used as the base view to provide the menu item background drawing.
     */
    class HighlightableView: NSVisualEffectView {
        var isHighlighted = false {
            didSet {
                if isHighlighted {
                    material = .selection
                } else {
                    material = .menu
                }
            }
        }
        
        // If true, shows the highlight bar under the view when the mouse is over the view
        var showsHighlight: Bool = true
        
        // Enable or disable the view
        var isEnabled: Bool = true
        
        private lazy var trackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeInActiveApp])
        
        override init(frame: NSRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder decoder: NSCoder) {
            super.init(coder: decoder)
            setup()
        }
        
        private func setup() {
            state = .active
            material = .menu
            blendingMode = .behindWindow
            trackingArea.update()
            isEmphasized = true
        }
        
        override open func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        override public func mouseEntered(with event: NSEvent) {
            material = (showsHighlight && isEnabled) ? .selection : .menu
            super.mouseEntered(with: event)
        }
        
        override public func mouseDragged(with event: NSEvent) {
            material = (showsHighlight && isEnabled) ? .selection : .menu
            super.mouseDragged(with: event)
        }
        
        override public func mouseExited(with event: NSEvent) {
            material = .menu
            super.mouseExited(with: event)
        }
        
        override public func mouseUp(with event: NSEvent) {
            super.mouseUp(with: event)
            
            guard let m = enclosingMenuItem?.menu else {
                return
            }
            
            material = .menu
            
            m.cancelTracking()
            m.performActionForItem(at: m.index(of: enclosingMenuItem!))
        }
    }
}
#endif
