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
}

extension NSUIGestureRecognizer {
    /**
     Initializes the gesture recognizer with the specified specfied reattching configuration.
     
     - Parameter reattachesAutomatically: A Boolean value that indicates whether the gesture recognizer is automatically added again to it's view when it's removed.
     - Returns: The initialized gesture recognizer object.
     */
    public convenience init(reattachesAutomatically: Bool) {
        self.init(target: nil, action: nil)
        self.reattachesAutomatically = reattachesAutomatically
    }
    
    /// A Boolean value that indicates whether the gesture recognizer is automatically added again to it's view when it's removed.
   @objc open var reattachesAutomatically: Bool {
        get { reattachViewObservation != nil }
        set {
            guard newValue != reattachesAutomatically else { return }
            if newValue {
                reattachViewObservation = observeChanges(for: \.view) { [weak self] old, new in
                    guard let self = self else { return }
                    if new == nil, let old = old {
                        let task = DispatchWorkItem { [weak self] in
                            guard let self = self else { return }
                            old.addGestureRecognizer(self)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
                    }
                }
            } else {
                reattachViewObservation = nil
            }
        }
    }
    
    /// Sets the Boolean value that indicates whether the gesture recognizer is automatically added again to it's view when it's removed.
    @discardableResult
    @objc open func reattachesAutomatically(_ reattaches: Bool) -> Self {
        self.reattachesAutomatically = reattaches
        return self
    }
    
    var reattachViewObservation: KeyValueObservation? {
        get { getAssociatedValue("reattachViewObservation", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "reattachViewObservation") }
    }
}

#endif
