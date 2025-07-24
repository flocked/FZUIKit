//
//  AnimationTargetValue.swift
//  
//
//  Created by Florian Zand on 24.07.25.
//

#if os(macOS)
import Foundation

struct AnimationTargetValue {
    let from: Any?
    let to: Any?
    let byValue: Any?
    var reversed: AnimationTargetValue {
        .init(from: to, to: from, byValue: byValue)
    }
}

#endif
