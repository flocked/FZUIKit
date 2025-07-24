//
//  AnimationManager.swift
//  
//
//  Created by Florian Zand on 24.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

class AnimationManager {
    static var runningAnimationGroups: Set<NSAnimationGroup> = []
}

#endif
