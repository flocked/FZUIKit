//
//  File.swift
//  
//
//  Created by Florian Zand on 07.10.23.
//

import AppKit
import FZSwiftUtils

extension NSAnimationContext {
    public var spring: CASpringAnimation? {
        get { getAssociatedValue(key: "spring", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "spring", object: self)
            if let newValue = newValue {
                self.duration = newValue.settlingDuration
            }
        }
    }
}
