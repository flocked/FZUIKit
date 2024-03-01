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
#endif
