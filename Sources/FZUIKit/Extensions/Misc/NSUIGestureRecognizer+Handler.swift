//
//  NSUIGestureRecognizer+Handler.swift
//  
//
//  Created by Florian Zand on 14.11.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils

extension NSUIGestureRecognizer {
    /// Handlers of the gesture recognizer.
    public struct Handlers {
        /// The handler that determines whether the gesture recognizer should begin.
        public var shouldBegin: (()->(Bool))?
        
        #if os(macOS)
        /// The handler that determines whether the gesture recognizer should process an event.
        public var shouldAttemptToRecognizeEvent: ((NSEvent)->(Bool))?
        #else
        /// The handler that determines whether the gesture recognizer should receive a touchbar touch.
        public var shouldReceivePress: ((UIPress)->(Bool))?
        /// The handler that determines whether the gesture recognizer should receive a touchbar touch.
        public var shouldReceiveEvent: ((UIEvent)->(Bool))?
        #endif
        
        /// The handler that determines whether the gesture recognizer should receive a touchbar touch.
        public var shouldReceiveTouch: ((NSUITouch)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer must wait to recognize it's gesture until the other gesture recognizer fails.
        public var shouldRequireFailure: ((NSUIGestureRecognizer)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer must fail before the other gesture recognizer is allowed to recognize its gesture.
        public var shouldBeRequiredToFail: ((NSUIGestureRecognizer)->(Bool))?
        
        /// The handler that determines whether the gesture recognizer should be allowed to recognize it's gesture simultaneously with the other one.
        public var shouldRecognizeSimultaneously: ((NSUIGestureRecognizer)->(Bool))?
        
        var needsDelegate: Bool {
            #if os(macOS)
            shouldAttemptToRecognizeEvent != nil || shouldBegin != nil || shouldReceiveTouch != nil || shouldRequireFailure != nil || shouldBeRequiredToFail != nil || shouldRecognizeSimultaneously != nil
            #else
            shouldBegin != nil || shouldReceiveTouch != nil || shouldReceivePress != nil || shouldReceiveEvent != nil || shouldRequireFailure != nil || shouldBeRequiredToFail != nil || shouldRecognizeSimultaneously != nil
            #endif
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
    public var recognizersThatRequireFail: Set<NSUIGestureRecognizer> {
        get {  Set(_recognizersThatRequireFail.nonNil)  }
        set {
            _recognizersThatRequireFail = Set(newValue.map({ Weak($0) }))
            setupDelegate()
        }
    }

    
    /// The gesture recogniters that must fail before this gesture recognizer begins recognizing its gesture.
    public var recognizersThatNeedToFail: Set<NSUIGestureRecognizer> {
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
    
    private class Delegate: NSObject, NSUIGestureRecognizerDelegate {
        weak var gestureRecognizer: NSUIGestureRecognizer?
        weak var delegate: NSUIGestureRecognizerDelegate?
        var delegateObservation: KeyValueObservation?
        var handlers: Handlers { gestureRecognizer?.handlers ?? .init() }

        init(for gestureRecognizer: NSUIGestureRecognizer) {
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
        
        func gestureRecognizer(_ gestureRecognizer: NSUIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: NSUIGestureRecognizer) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) ?? handlers.shouldRequireFailure?(otherGestureRecognizer) ??  gestureRecognizer.recognizersThatNeedToFail.contains(otherGestureRecognizer)
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSUIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: NSUIGestureRecognizer) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) ?? handlers.shouldBeRequiredToFail?(otherGestureRecognizer) ??  gestureRecognizer.recognizersThatRequireFail.contains(otherGestureRecognizer)
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: NSUIGestureRecognizer) -> Bool {
            delegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? handlers.shouldBegin?() ?? true
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSUIGestureRecognizer, shouldReceive touch: NSUITouch) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) ?? handlers.shouldReceiveTouch?(touch) ?? true
        }
        
        func gestureRecognizer(_ gestureRecognizer: NSUIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSUIGestureRecognizer) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? handlers.shouldRecognizeSimultaneously?(otherGestureRecognizer) ?? false
        }
        
        #if os(macOS)
        func gestureRecognizer(_ gestureRecognizer: NSUIGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldAttemptToRecognizeWith: event) ?? handlers.shouldAttemptToRecognizeEvent?(event) ?? true
        }
        #else
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: press) ?? handlers.shouldReceivePress?(press) ?? true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
            delegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: event) ?? handlers.shouldReceiveEvent?(event) ?? true
        }
        #endif
    }
    
    private var _recognizersThatNeedToFail: Set<Weak<NSUIGestureRecognizer>> {
        get { getAssociatedValue("recognizersThatNeedToFail") ?? [] }
        set { setAssociatedValue(newValue, key: "recognizersThatNeedToFail") }
    }
    
    private var _recognizersThatRequireFail: Set<Weak<NSUIGestureRecognizer>> {
        get { getAssociatedValue("_recognizersThatRequireFail") ?? [] }
        set { setAssociatedValue(newValue, key: "_recognizersThatRequireFail") }
    }
}
#endif
