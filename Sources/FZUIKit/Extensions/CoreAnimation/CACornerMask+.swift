//
//  CACornerMask+.swift
//
//
//  Created by Florian Zand on 23.02.23.
//

#if canImport(QuartzCore)
    import QuartzCore.CoreAnimation

    public extension CACornerMask {
        /// All corners.
        static var all: CACornerMask = [.bottomLeft, .bottomRight, .topLeft, .topRight]
        /// No ocrners.
        static var none: CACornerMask = []

        #if os(macOS)
            /// The bottom-left corner.
            static var bottomLeft = CACornerMask.layerMinXMinYCorner
            /// The bottom-right corner.
            static var bottomRight = CACornerMask.layerMaxXMinYCorner
            /// The top-left corner.
            static var topLeft = CACornerMask.layerMinXMaxYCorner
            /// The top-right corner.
            static var topRight = CACornerMask.layerMaxXMaxYCorner

            /// The Bottom-left and bottom-right corner.
            static var bottomCorners: CACornerMask = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner,
            ]

        /// The top-left and top-right corner.
            static var topCorners: CACornerMask = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner,
            ]
        #elseif canImport(UIKit)
            /// The bottom-left corner.
            static var bottomLeft = CACornerMask.layerMinXMaxYCorner
            /// The bottom-right corner.
            static var bottomRight = CACornerMask.layerMaxXMaxYCorner
            /// The top-left corner.
            static var topLeft = CACornerMask.layerMinXMinYCorner
            /// The top-right corner.
            static var topRight = CACornerMask.layerMaxXMinYCorner

            /// The Bottom-left and bottom-right corner.
            static var bottomCorners: CACornerMask = [
                .layerMaxXMaxYCorner,
                .layerMinXMaxYCorner,
            ]

            /// The top-left and top-right corner.
            static var topCorners: CACornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
            ]
        #endif

        /// The Bottom-left and top-left corner.
        static var leftCorners: CACornerMask = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
        ]

        /// The Bottom-right and top-right corner.
        static var rightCorners: CACornerMask = [
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner,
        ]
    }

    extension CACornerMask: Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
#endif
