//
//  NSImageScaling+.swift
//
//
//  Created by Florian Zand on 03.09.22.
//

#if os(macOS)

import AppKit
import Foundation

extension NSImageScaling: CaseIterable {
    public static var allCases: [NSImageScaling] = [.scaleProportionallyDown, .scaleAxesIndependently, .scaleNone, .scaleProportionallyUpOrDown]
}

public extension NSImageScaling {
    var contentsGravity: CALayerContentsGravity {
        switch self {
        case .scaleNone:
            return .center
        case .scaleProportionallyDown:
            return .resizeAspectFill
        case  .scaleProportionallyUpOrDown:
            return .resize
        case.scaleAxesIndependently:
            return .resizeAspect
        @unknown default:
            return .center
        }
    }

    init(contentsGravity: CALayerContentsGravity) {
        let rawValue = NSImageScaling.allCases.first(where: { $0.contentsGravity == contentsGravity })?.rawValue ?? NSImageScaling.scaleProportionallyUpOrDown.rawValue
        self.init(rawValue: rawValue)!
    }
}
#endif
