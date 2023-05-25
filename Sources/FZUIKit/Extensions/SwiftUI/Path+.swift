//
//  File.swift
//
//
//  Created by Florian Zand on 14.10.22.
//

import SwiftUI

public extension SwiftUI.Path {
    init(_ bezierpath: NSUIBezierPath) {
        self.init(bezierpath.cgPath)
    }
}
