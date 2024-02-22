//
//  UIContentView+.swift
//
//
//  Created by Florian Zand on 21.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UIContentView {
    /**
     Determines whether the view is compatible with the provided configuration.
     
     - Parameter configuration: The new configuration to test for compatibility.
     - Returns: `true` if the view supports this configuration being set to its configuration property and is capable of updating itself for the configuration; otherwise, `false.
     */
    @MainActor
    public func supports(_ configuration: UIContentConfiguration) -> Bool {
        type(of: configuration) == type(of: self.configuration)
    }
}


#endif
