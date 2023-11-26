//
//  AnimatablePair+.swift
//  
//
//  Created by Florian Zand on 17.11.23.
//

import Foundation
import SwiftUI
import FZSwiftUtils
import simd

extension AnimatablePair: Comparable where First: Comparable, Second: Comparable {
    public static func < (lhs: AnimatablePair<First, Second>, rhs: AnimatablePair<First, Second>) -> Bool {
        lhs.first < rhs.first && lhs.second < rhs.second
    }
}

extension AnimatablePair: MultiplicativeArithmetic where First: MultiplicativeArithmetic, Second: MultiplicativeArithmetic {
    public static func / (lhs: Self, rhs: Self) -> Self {
        Self(lhs.first / rhs.first, lhs.second / rhs.second)
    }
    
    public static func * (lhs: Self, rhs: Self) -> Self {
        Self(lhs.first * rhs.first, lhs.second * rhs.second)
    }
}
