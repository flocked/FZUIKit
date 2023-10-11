//
//  CATransform3D+.swift
//  
//
//  Created by Florian Zand on 07.10.23.
//

import Foundation
import QuartzCore

extension CATransform3D: Equatable {
    public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
        CATransform3DEqualToTransform(lhs, rhs)
    }
}
