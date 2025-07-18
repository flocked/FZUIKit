//
//  Path+.swift
//
//
//  Created by Florian Zand on 14.10.22.
//

import SwiftUI

public extension NSUIBezierPath {
    /// A SwiftUI representation of the path.
    var swiftUI: SwiftUI.Path {
        SwiftUI.Path(self)
    }
    
    /// Creates a bezier path with the specified rectangle and shape.
    convenience init<S: Shape>(rect: CGRect, shape: S) {
        self.init(cgPath: shape.path(in: rect).cgPath)
    }
}

public extension SwiftUI.Path {
    /// Creates a path from the specified bezier path.
    init(_ bezierpath: NSUIBezierPath) {
        #if os(macOS)
        self.init(bezierpath.cgPath)
        #else
        self.init(bezierpath.cgPath)
        #endif
    }
}
