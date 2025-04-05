//
//  CATransform3D+.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Foundation
    import FZSwiftUtils
    import QuartzCore

    extension CATransform3D: Equatable {
        public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
            CATransform3DEqualToTransform(lhs, rhs)
        }
    }
#endif
