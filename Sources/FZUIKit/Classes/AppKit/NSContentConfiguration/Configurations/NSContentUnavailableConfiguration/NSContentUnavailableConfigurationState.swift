//
//  NSContentUnavailableConfigurationState.swift
//  
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
import Foundation
import AppKit

@available(macOS 12.0, *)
public struct NSContentUnavailableConfigurationState: NSConfigurationState, Hashable {
    
    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { return customStates[key] }
        set { customStates[key] = newValue }
    }
    
    internal var customStates = [NSConfigurationStateCustomKey:AnyHashable]()
    
}
#endif
