//
//  NSGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 15.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSGestureRecognizer {
    /// The mouse button (or buttons) required to recognize a gesture.
    public struct ButtonMask: OptionSet, Sendable {
        /// Left mouse button.
        public static var left = ButtonMask(rawValue: 1 << 0)
        /// Right mouse button.
        public static var right = ButtonMask(rawValue: 1 << 1)
        /// Third mouse button.
        public static var other = ButtonMask(rawValue: 1 << 2)
        /// Left, right and other mouse button.
        public static let all: ButtonMask = [.left, .right, .other]

        /// Creates a structure that represents the mouse button (or buttons) required to recognize a gesture.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public let rawValue: Int
    }
}

extension NSPanGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this gesture.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
    
    /// Sets the mouse button (or buttons) required to recognize this gesture.
    @discardableResult
    public func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
}

extension NSClickGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this click.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
    
    /// Sets the mouse button (or buttons) required to recognize this click.
    @discardableResult
    public func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
    
    /// Sets the number of clicks required to match.
    @discardableResult
    public func numberOfClicksRequired(_ clicks: Int) -> Self {
        numberOfClicksRequired = clicks
        return self
    }
}

extension NSPressGestureRecognizer {
    /// The mouse button (or buttons) required to recognize this press.
    public var requiredButtons: ButtonMask {
        get { ButtonMask(rawValue: buttonMask) }
        set { buttonMask = newValue.rawValue }
    }
    
    
    /// Sets the mouse button (or buttons) required to recognize this press.
    @discardableResult
    public func requiredButtons(_ requiredButtons: ButtonMask) -> Self {
        self.requiredButtons = requiredButtons
        return self
    }
}

extension NSGestureRecognizer {
    /// Handlers of the gesture recognizer.
    public struct Handlers {
        /// The handler that determines whether the gesture recognizer should begin.
        public var shouldBegin: (()->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should process an event.
        public var shouldAttemptToRecognizeEvent: ((NSEvent)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should receive a touchbar touch.
        public var shouldReceiveTouch: ((NSTouch)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer must wait to recognize it's gesture until the other gesture recognizer fails.
        public var shouldRequireFailure: ((NSGestureRecognizer)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer must fail before the other gesture recognizer is allowed to recognize its gesture.
        public var shouldBeRequiredToFail: ((NSGestureRecognizer)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should be allowed to recognize it's gesture simultaneously with the other one.
        public var shouldRecognizeSimultaneously: ((NSGestureRecognizer)->(Bool))?
        
        var needsDelegate: Bool {
            shouldAttemptToRecognizeEvent != nil || shouldBegin != nil || shouldReceiveTouch != nil || shouldRequireFailure != nil || shouldBeRequiredToFail != nil || shouldRecognizeSimultaneously != nil
        }
    }
    
    /// The handlers of the gesture recognizer.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers", initialValue: Handlers()) }
        set {
            setAssociatedValue(newValue, key: "handlers")
            setupDelegate()
        }
    }
    
    /// The gesture recognizers that require failure of this gesture recognizer before they recognize their gestures.
    public var recognizersThatRequireFail: Set<NSGestureRecognizer> {
        get {  Set(_recognizersThatRequireFail.nonNil)  }
        set {
            _recognizersThatRequireFail = Set(newValue.map({ Weak($0) }))
            setupDelegate()
        }
    }

    
    /// The gesture recogniters that must fail before this gesture recognizer begins recognizing its gesture.
    public var recognizersThatNeedToFail: Set<NSGestureRecognizer> {
        get {  Set(_recognizersThatNeedToFail.nonNil)  }
        set {
            _recognizersThatNeedToFail = Set(newValue.map({ Weak($0) }))
            setupDelegate()
        }
    }
    
    private func setupDelegate() {
        if !handlers.needsDelegate && recognizersThatRequireFail.isEmpty && recognizersThatNeedToFail.isEmpty {
            guard delegateProxy != nil else { return }
            delegateProxy?.delegateObservation = nil
            delegate = delegateProxy?.delegate
            delegateProxy = nil
        } else {
            if delegateProxy == nil {
                delegateProxy = Delegate(for: self)
            }
        }
    }
    
    private var delegateProxy: Delegate? {
        get { getAssociatedValue("delegateProxy") }
        set { setAssociatedValue(newValue, key: "delegateProxy") }
    }
    
    private class Delegate: NSObject, NSGestureRecognizerDelegate {
        weak var gestureRecognizer: NSGestureRecognizer?
        weak var delegate: NSGestureRecognizerDelegate?
        var delegateObservation: KeyValueObservation?
        var handlers: Handlers { gestureRecognizer?.handlers ?? .init() }

        init(for gestureRecognizer: NSGestureRecognizer) {
            super.init()
            delegate = gestureRecognizer.delegate
            self.gestureRecognizer = gestureRecognizer
            gestureRecognizer.delegate = self
            delegateObservation = gestureRecognizer.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, let gestureRecognizer = self.gestureRecognizer, new !== self else { return }
                self.delegate = new
                gestureRecognizer.delegate = self
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) ?? handlers.shouldRequireFailure?(otherGestureRecognizer) ??  gestureRecognizer.recognizersThatNeedToFail.contains(otherGestureRecognizer)
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) ?? handlers.shouldBeRequiredToFail?(otherGestureRecognizer) ??  gestureRecognizer.recognizersThatRequireFail.contains(otherGestureRecognizer)
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldAttemptToRecognizeWith: event) ?? handlers.shouldAttemptToRecognizeEvent?(event) ?? true
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
            delegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? handlers.shouldBegin?() ?? true
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? handlers.shouldRecognizeSimultaneously?(otherGestureRecognizer) ?? false
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldReceive touch: NSTouch) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? handlers.shouldReceiveTouch?(touch) ?? true
        }
    }
    
    private var _recognizersThatNeedToFail: Set<Weak<NSGestureRecognizer>> {
        get { getAssociatedValue("recognizersThatNeedToFail") ?? [] }
        set { setAssociatedValue(newValue, key: "recognizersThatNeedToFail") }
    }
    
    private var _recognizersThatRequireFail: Set<Weak<NSGestureRecognizer>> {
        get { getAssociatedValue("_recognizersThatRequireFail") ?? [] }
        set { setAssociatedValue(newValue, key: "_recognizersThatRequireFail") }
    }
}

#endif
