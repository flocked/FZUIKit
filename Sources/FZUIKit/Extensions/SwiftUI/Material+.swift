//
//  Material+.swift
//  
//
//  Created by Florian Zand on 08.12.24.
//

import SwiftUI

extension Material: Swift.Equatable {
    public static func == (lhs: Material, rhs: Material) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        String(describing: self)
    }
}
