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
    public func removeFromView() {
        #if os(macOS)
        guard let view = view, view.gestureRecognizers.contains(self) else { return }
        #else
        guard let view = view, view.gestureRecognizers?.contains(self) == true else { return }
        #endif
        view.removeGestureRecognizer(self)
    }
}

/// A gesture recognizer that automatically re-attachs itself to the view it's removed from.
class ReattachingGestureRecognizer: NSUIGestureRecognizer {
    var viewObservation: KeyValueObservation?
    
    /// A Boolean value that indicates whether the gesture recognizer re-attachs itself to the view it's removed from.
    var reattachsWhenRemoved: Bool = true {
        didSet { setupViewObservation() }
    }
    
    func setupViewObservation() {
        if reattachsWhenRemoved {
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
        } else {
            viewObservation = nil
        }
    }
    
    /// Removes the gesture recognizer from the view it’s attached to.
    func removeFromView(disablingReadding: Bool) {
        if disablingReadding {
            viewObservation = nil
        }
        self.removeFromView()
    }

    convenience init() {
        self.init(target: nil, action: nil)
    }

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        setupViewObservation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
