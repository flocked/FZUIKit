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

extension NSUIGestureRecognizer {
    /// Adds the gesture recognizer to the specified view.
    public func addToView(_ view: NSUIView) {
        view.addGestureRecognizer(self)
    }
    
    /// Removes the gesture recognizer from the view it's attached to.
    public func removeFromView() {
        #if os(macOS)
        guard let view = view, view.gestureRecognizers.contains(self) else { return }
        #else
        guard let view = view, view.gestureRecognizers?.contains(self) == true else { return }
        #endif
        view.removeGestureRecognizer(self)
    }
}

/// A gesture recognizer that automatically adds
class AutoGestureRecognizer: NSUIGestureRecognizer {
    
    convenience init() {
        self.init(target: nil, action: nil)
    }

    var viewObservation: NSKeyValueObservation? = nil
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        viewObservation = observeChanges(for: \.view) { [weak self] old, new in
            guard let self = self else { return }
            if new == nil, let old = old {
                let task = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    old.addGestureRecognizer(self)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
            }
        }
    }
    
    func removeFromView(disablingObservation: Bool) {
        if disablingObservation {
            viewObservation = nil
        }
        view?.removeGestureRecognizer(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
