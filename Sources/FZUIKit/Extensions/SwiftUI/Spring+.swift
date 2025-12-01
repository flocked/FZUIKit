//
//  Spring+.swift
//
//
//  Created by Florian Zand on 30.11.23.
//

import SwiftUI

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Spring: Swift.CustomStringConvertible {
    public var description: String {
        """
        Spring(
            response: \(response)
            dampingRatio: \(dampingRatio)
            mass: \(mass)

            settlingDuration: \(String(format: "%.3f", settlingDuration))
            duration: \(String(format: "%.3f", duration))
            damping: \(damping)
            stiffness: \(String(format: "%.3f", stiffness))
        )
        """
    }
}
