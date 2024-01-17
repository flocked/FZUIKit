//
//  NSProgressIndicator+.swift
//
//
//  Created by Florian Zand on 17.01.24.
//

#if os(macOS)
import AppKit

extension NSProgressIndicator {
    /// Creates a spinning progress indicator.
    public static var spinning: NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.style = .spinning
        progressIndicator.stopAnimation(nil)
        return progressIndicator
    }
}

#endif
