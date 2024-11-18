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
    
    /**
     A value that indicates the amount of mouse clicks on the view's background to resign the view as first responder in its window.
     
     Tne default value is `0` and indicates that a mouse click on the view's background isn't resigning the view as first responder in its window.
     */
    public var firstResponderResignBackgroundClickCount: Int {
        get { firstResponderResignGestureRecognizer?.clickCount ?? 0 }
        set {
            guard newValue != firstResponderResignBackgroundClickCount else { return }
            if newValue > 0 {
                if firstResponderResignGestureRecognizer == nil {
                    firstResponderResignGestureRecognizer = .init()
                    addGestureRecognizer(firstResponderResignGestureRecognizer!)
                }
                firstResponderResignGestureRecognizer?.clickCount = newValue
            } else {
                firstResponderResignGestureRecognizer?.removeFromView()
                firstResponderResignGestureRecognizer = nil
            }
        }
    }
    
    var firstResponderResignGestureRecognizer: FirstResponderResignGestureRecognizer? {
        get { getAssociatedValue("firstResponderResignGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "firstResponderResignGestureRecognizer") }
    }
    
    class FirstResponderResignGestureRecognizer: NSGestureRecognizer {
        var clickCount = 1
        
        init() {
            super.init(target: nil, action: nil)
            delaysPrimaryMouseButtonEvents = true
        }
        
        override func mouseDown(with event: NSEvent) {
            state = .began
            if event.clickCount == clickCount, let view = view, view.isFirstResponder, view == view.hitTest(event.location(in: view)) {
                view.resignFirstResponding()
                state = !view.isFirstResponder ? .ended : .failed
            } else {
                state = .failed
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
