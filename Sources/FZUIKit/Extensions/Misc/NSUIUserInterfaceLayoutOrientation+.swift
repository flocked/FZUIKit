//
//  NSUIUserInterfaceLayoutOrientation+.swift
//  
//
//  Created by Florian Zand on 03.07.26.
//

#if !os(watchOS)
import Foundation

extension NSUIUserInterfaceLayoutOrientation {
    mutating func toggle() {
        self = self == .vertical ? .vertical : .horizontal
    }
}
#endif
