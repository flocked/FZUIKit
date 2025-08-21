//
//  NSUIGestureRecognizer+.swift
//
//
//  Created by Florian Zand on 01.03.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif
import FZSwiftUtils

extension NSUIGestureRecognizer {
    /// Adds the gesture recognizer to the specified view.
    public func addToView(_ view: NSUIView) {
        view.addGestureRecognizer(self)
    }
    
    /// Removes the gesture recognizer from the view it's attached to.
    @objc open func removeFromView() {
        reattachViewObservation = nil
        #if os(macOS)
        guard let view = view, view.gestureRecognizers.contains(self) else { return }
        #else
        guard let view = view, view.gestureRecognizers?.contains(self) == true else { return }
        #endif
        view.removeGestureRecognizer(self)
    }
    
    /// Moves the gesture recognizer to the front of its view’s gesture recognizers, making it the first to receive event handling.
    func moveToFront() {
        guard let view = view else { return }
        #if os(macOS)
        var gestureRecognizers = view.gestureRecognizers
        #else
        var gestureRecognizers = view.gestureRecognizers ?? []
        #endif
        guard gestureRecognizers.first != self, let index = gestureRecognizers.firstIndex(where: { $0 === self }) else { return }
        let reattaches = reattachesAutomatically
        reattachesAutomatically = false
        defer { reattachesAutomatically = reattaches }
        gestureRecognizers.remove(at: index)
        view.gestureRecognizers = self + gestureRecognizers
    }
    
    /// Moves the gesture recognizer to the back of its view’s gesture recognizers, making it the last to receive event handling.
    func moveToBack() {
        guard let view = view else { return }
        #if os(macOS)
        var gestureRecognizers = view.gestureRecognizers
        #else
        var gestureRecognizers = view.gestureRecognizers ?? []
        #endif
        guard gestureRecognizers.last != self, let index = gestureRecognizers.firstIndex(where: { $0 === self }) else { return }
        let reattaches = reattachesAutomatically
        reattachesAutomatically = false
        defer { reattachesAutomatically = reattaches }
        gestureRecognizers.remove(at: index)
        view.gestureRecognizers = gestureRecognizers + self
    }
}

extension NSUIGestureRecognizer {
    /**
     Initializes the gesture recognizer with the specified specfied reattching configuration.
     
     - Parameters:
        - reattachesAutomatically: A Boolean value indicating whether the gesture recognizer is automatically added again to it's view when it's removed.
        - action: The action handler.
     - Returns: The initialized gesture recognizer object.
     */
    public convenience init(reattachesAutomatically: Bool, action: ActionBlock? = nil) {
        self.init(target: nil, action: nil)
        actionBlock = action
        self.reattachesAutomatically = reattachesAutomatically
        
    }
    
    /// A Boolean value indicating whether the gesture recognizer is automatically added again to it's view when it's removed.
   @objc open var reattachesAutomatically: Bool {
        get { reattachViewObservation != nil }
        set {
            guard newValue != reattachesAutomatically else { return }
            if newValue {
                reattachViewObservation = observeChanges(for: \.view) { [weak self] old, new in
                    guard let self = self else { return }
                    if new == nil, let old = old {
                        DispatchQueue.background.async(after: 0.2) { [weak self] in
                            guard let self = self else { return }
                            old.addGestureRecognizer(self)
                        }
                    }
                }
            } else {
                reattachViewObservation = nil
            }
        }
    }
    
    /// Sets the Boolean value indicating whether the gesture recognizer is automatically added again to it's view when it's removed.
    @discardableResult
    @objc open func reattaches(_ reattaches: Bool) -> Self {
        self.reattachesAutomatically = reattaches
        return self
    }
    
    fileprivate var reattachViewObservation: KeyValueObservation? {
        get { getAssociatedValue("reattachViewObservation") }
        set { setAssociatedValue(newValue, key: "reattachViewObservation") }
    }
}
#endif
