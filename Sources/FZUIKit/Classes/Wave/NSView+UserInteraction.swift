//
//  File.swift
//  
//
//  Created by Florian Zand on 09.11.23.
//

import AppKit
import FZSwiftUtils

public extension NSView {
    /**
     A Boolean value that determines whether user events are ignored and removed from the event queue.
     
     When set to false`, mouse and keyboard events intended for the view are ignored and removed from the event queue. When set to `true`, events are delivered to the view normally. The default value of this property is `true`.
     */
    var isUserInteractionEnabled: Bool {
        get { getAssociatedValue(key: "isUserInteractionEnabled", object: self, initialValue: true) }
        set {
            guard newValue != isUserInteractionEnabled else { return }
            set(associatedValue: newValue, key: "isUserInteractionEnabled", object: self)
            if newValue == false {
                UserInteractionMonitor.shared.addView(self)
                if self.window?.firstResponder == self {
                    self.resignFirstResponder()
                }
            } else {
                UserInteractionMonitor.shared.removeView(self)
            }
        }
    }
    /*
    static func swizzleUserInteraction() {
        guard didSwizzleUserInteraction == false else { return }
        didSwizzleUserInteraction = true
        do {
            _ = try Swizzle(NSView.self) {
                #selector(keyDown(with:)) <-> #selector(swizzled_keyDown(with:))
                #selector(keyUp(with:)) <-> #selector(swizzled_keyUp(with:))
                #selector(flagsChanged(with:)) <-> #selector(swizzled_flagsChanged(with:))
                #selector(mouseDown(with:)) <-> #selector(swizzled_mouseDown(with:))
                #selector(mouseUp(with:)) <-> #selector(swizzled_mouseUp(with:))
                #selector(mouseDragged(with:)) <-> #selector(swizzled_mouseDragged(with:))
                #selector(rightMouseDown(with:)) <-> #selector(swizzled_rightMouseDown(with:))
                #selector(rightMouseUp(with:)) <-> #selector(swizzled_rightMouseUp(with:))
                #selector(rightMouseDragged(with:)) <-> #selector(swizzled_rightMouseDragged(with:))
            }
        } catch {
            Swift.print(error)
        }
    }
    
    static var didSwizzleUserInteraction: Bool {
        get { getAssociatedValue(key: "didSwizzleUserInteraction", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didSwizzleUserInteraction", object: self) }
    }
    
    @objc func swizzled_keyDown(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_keyDown(with: event)
    }
    
    @objc func swizzled_keyUp(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_keyUp(with: event)
    }
    
    @objc func swizzled_flagsChanged(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_flagsChanged(with: event)
    }
    
    @objc func swizzled_mouseDown(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_mouseDown(with: event)
    }
    
    @objc func swizzled_mouseUp(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_mouseUp(with: event)
    }
    
    @objc func swizzled_mouseDragged(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_mouseDragged(with: event)
    }
    
    @objc func swizzled_rightMouseDown(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_rightMouseDown(with: event)
    }
    
    @objc func swizzled_rightMouseUp(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_rightMouseUp(with: event)
    }
    
    @objc func swizzled_rightMouseDragged(with event: NSEvent) {
        guard isUserInteractionEnabled else { return }
        self.swizzled_rightMouseDragged(with: event)
    }
    
    func test() {
        mouseUp(with: <#T##NSEvent#>)
        mouseDown(with: <#T##NSEvent#>)
        mouseDragged(with: <#T##NSEvent#>)
        rightMouseDown(with: <#T##NSEvent#>)
        rightMouseUp(with: <#T##NSEvent#>)
        rightMouseDragged(with: <#T##NSEvent#>)
        
    }
    */
}

internal class UserInteractionMonitor {
    static let shared = UserInteractionMonitor()
    
    var views: [Weak<NSView>] = []
    
    func addView(_ view: NSUIView) {
        guard allViews.contains(view) == false else { return }
        views.append(Weak(view))
        setupMonitor()
    }
    
    func removeView(_ view: NSUIView) {
        if let index = views.firstIndex(where: { $0.object == view }) {
            views.remove(at: index)
            setupMonitor()
        }
    }
    
    var eventMonitor: NSEvent.Monitor? = nil
        
    func setupMonitor() {
        Swift.print("setupMonitor")
        if allViews.isEmpty == false {
            if eventMonitor == nil {
                eventMonitor = NSEvent.Monitor.local(for: .allUserInteractions) { event in
                    
                    if let firstResponder = NSApp.keyWindow?.firstResponder as? NSUIView {
                        for view in self.allViews {
                            if firstResponder == view || firstResponder.isDescendant(of: view) {
                                return nil
                            }
                        }
                    }
                    
                    if NSEvent.EventTypeMask.mouse.intersects(event) {
                        if let contentView = NSApp.keyWindow?.contentView {
                            let mousePoint = event.location(in: contentView)
                            if let hitView = contentView.hitTest(mousePoint) {
                                for view in self.allViews {
                                    if hitView == view || hitView.isDescendant(of: view) {
                                        return nil
                                    }
                                }
                            }
                        }
                    }
                    return event
                }
            }
        } else {
            eventMonitor = nil
        }
    }
    
    var allViews: [NSUIView] {
        views.compactMap({$0.object})
    }
}

