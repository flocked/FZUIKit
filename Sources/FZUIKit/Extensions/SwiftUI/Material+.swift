//
//  Material+.swift
//  
//
//  Created by Florian Zand on 08.12.24.
//

import SwiftUI

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Material: Swift.Equatable {
    public static func == (lhs: Material, rhs: Material) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        String(describing: self)
    }
}
