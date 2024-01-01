//
//  DynamicPropertyAnimator.swift
//  
//
//  Created by Florian Zand on 16.12.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import QuartzCore
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif


@dynamicMemberLookup
public class DynamicPropertyAnimator<Object: AnimatablePropertyProvider>: PropertyAnimator<Object> {
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Anima`` animation block animates to the new value.
     
     - Parameter keyPath: The keypath to the animatable property.
     */
    public subscript<Value>(dynamicMember member: WritableKeyPath<Object, Value>) -> Value where Value: AnimatableProperty  {
        get { value(for: member) }
        set { setValue(newValue, for: member) }
    }
}



#endif
