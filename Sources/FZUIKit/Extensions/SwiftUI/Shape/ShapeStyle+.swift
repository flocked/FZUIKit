//
//  ShapeStyle+.swift
//
//
//  Created by Florian Zand on 07.10.22.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    static var random: Color {
        Color(red: .random(in: 0 ... 1),
              green: .random(in: 0 ... 1),
              blue: .random(in: 0 ... 1))
    }
}

// let _ = Self._printChanges()
