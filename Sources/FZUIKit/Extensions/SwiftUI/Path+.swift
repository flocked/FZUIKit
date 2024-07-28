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
}

public extension SwiftUI.Path {
    /// Creates a path from the specified bezier path.
    init(_ bezierpath: NSUIBezierPath) {
        #if os(macOS)
        self.init(bezierpath.cgpath)
        #else
        self.init(bezierpath.cgPath)
        #endif
    }
}
