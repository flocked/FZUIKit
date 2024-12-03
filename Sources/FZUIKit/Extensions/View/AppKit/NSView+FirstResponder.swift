//
//  NSView+FirstResponder.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSViewProtocol where Self: NSView {
    /**
     A Boolean value that indicates whether the view is the first responder.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.
     */
    var isFirstResponder: Bool {
        if let view = self as? NSTextField {
            return view.window?.firstResponder == view.currentEditor() || view.window?.firstResponder == view
        }
        return window?.firstResponder == self
     }
    
    /// A Boolean value that indicates whether the view or any of it's subviews is the first responder.
    var isDescendantFirstResponder: Bool {
        if let view = window?.firstResponder as? NSView {
            return view.isDescendant(of: self)
        } else if let view = (window?.firstResponder as? NSText)?.delegate as? NSView {
            return view.isDescendant(of: self)
        }
        return false
    }
    
    /**
     Attempts to make the view the first responder in its window.
     
     Call this method when you want the v toiew be the first responder.
     
     - Returns: `true` if the view is now the first responder; otherwise, `false`.
     */
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            window?.makeFirstResponder(self)
            if isFirstResponder, let textView = self as? NSTextView {
                textView.selectedRanges = textView.selectedRanges
            }
        }
        return isFirstResponder
    }
    
    /**
     Attempts to resign the view as first responder in its window.
     
     Call this method when you want the view to resign the first responder.
     
     - Returns: `true` if the view isn't the first responder; otherwise, `false`.
     */
    @discardableResult
    func resignFirstResponding() -> Bool {
        if isFirstResponder {
            window?.makeFirstResponder(nil)
        }
        return !isFirstResponder
    }
}

extension NSView {
    /**
     A value that indicates the amount of mouse clicks outside the view to resign the view as first responder in its window.
     
     Tne default value is `0` and indicates that a mouse click outside the view isn't resigning the view as first responder in its window.
     */
    public var firstResponderResignClickCount: Int {
        get { getAssociatedValue("firstResponderResignClickCount") ?? 0 }
        set {
            guard newValue != firstResponderResignClickCount else { return }
            setAssociatedValue(newValue, key: "firstResponderResignClickCount")
            if newValue > 0 {
                resignFirstResponderObservation = observeChanges(for: \.window?.firstResponder) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.setupResignMouseDownMonitor()
                }
                setupResignMouseDownMonitor()
            } else {
                resignFirstResponderObservation = nil
                resignMouseDownMonitor = nil
            }
        }
    }
    
    func setupResignMouseDownMonitor() {
        if isFirstResponder {
            guard resignMouseDownMonitor == nil else { return }
            resignMouseDownMonitor = NSEvent.localMonitor(for: .leftMouseDown) { [weak self] event in
                guard let self = self else { return event }
                let location = event.location(in: self)
                if self.isFirstResponder, !self.bounds.contains(location), event.clickCount >= self.firstResponderResignClickCount {
                    self.resignFirstResponding()
                }
                return event
            }
        } else {
            resignMouseDownMonitor = nil
        }
    }
    
    var resignFirstResponderObservation: KeyValueObservation? {
        get { getAssociatedValue("resignFirstResponderObservation") }
        set { setAssociatedValue(newValue, key: "resignFirstResponderObservation") }
    }
    
    var resignMouseDownMonitor: NSEvent.Monitor? {
        get { getAssociatedValue("resignMouseDownMonitor") }
        set { setAssociatedValue(newValue, key: "resignMouseDownMonitor") }
    }
}

#endif
