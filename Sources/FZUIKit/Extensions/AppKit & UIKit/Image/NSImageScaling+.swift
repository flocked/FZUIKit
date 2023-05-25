//
//  File.swift
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
        static var reize: Self { return .scaleAxesIndependently }
        static var reizeAspect: Self { return .scaleProportionallyDown }
        static var reizeAspectFill: Self { return .scaleProportionallyUpOrDown }
        static var center: Self { return .scaleNone }

        var contentsGravity: CALayerContentsGravity {
            switch self {
            case .center, .scaleNone:
                return .center
            case .reizeAspect, .scaleProportionallyDown:
                return .resizeAspectFill
            case .reizeAspectFill, .scaleProportionallyUpOrDown:
                return .resize
            case .reize, .scaleAxesIndependently:
                return .resizeAspect
            @unknown default:
                return .center
            }
        }

        init(contentsGravity: CALayerContentsGravity) {
            let rawValue = NSImageScaling.allCases.first(where: { $0.contentsGravity == contentsGravity })?.rawValue ?? NSImageScaling.reizeAspectFill.rawValue
            self.init(rawValue: rawValue)!
        }
    }
#endif
