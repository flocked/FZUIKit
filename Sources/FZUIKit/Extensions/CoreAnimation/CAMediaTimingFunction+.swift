//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

import QuartzCore

public extension CAMediaTimingFunction {
    static var linear: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear)
    static var `default`: CAMediaTimingFunction = CAMediaTimingFunction(name: .default)
    static var easeIn: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeIn)
    static var easeOut: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeOut)
    static var easeInEaseOut: CAMediaTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
}
