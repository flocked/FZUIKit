//
//  File.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

import QuartzCore.CoreAnimation

public extension CACornerMask {
    static let all: CACornerMask = [.bottomLeft, .bottomRight, .topLeft, .topRight]
    static let none: CACornerMask = []

    #if os(macOS)
        static let bottomLeft = CACornerMask.layerMinXMinYCorner
        static let bottomRight = CACornerMask.layerMaxXMinYCorner
        static let topLeft = CACornerMask.layerMinXMaxYCorner
        static let topRight = CACornerMask.layerMaxXMaxYCorner

        static let bottomCorners: CACornerMask = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner,
        ]

        static let topCorners: CACornerMask = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner,
        ]
    #elseif os(iOS)
        static let bottomLeft = CACornerMask.layerMinXMaxYCorner
        static let bottomRight = CACornerMask.layerMaxXMaxYCorner
        static let topLeft = CACornerMask.layerMinXMinYCorner
        static let topRight = CACornerMask.layerMaxXMinYCorner

        static let bottomCorners: CACornerMask = [
            .layerMaxXMaxYCorner,
            .layerMinXMaxYCorner,
        ]

        static let topCorners: CACornerMask = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
        ]
    #endif

    static let leftCorners: CACornerMask = [
        .layerMinXMinYCorner,
        .layerMinXMaxYCorner,
    ]

    static let rightCorners: CACornerMask = [
        .layerMaxXMinYCorner,
        .layerMaxXMaxYCorner,
    ]
}

extension CACornerMask: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
