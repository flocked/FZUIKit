//
//  IrregularGradient+ColorBlob.swift
//
//
//  Created by Julian Schiavo on 5/4/2021.
//  Updated by Florian Zand on 14/09/2022

import Combine
import SwiftUI

extension IrregularGradient {
    public struct ColorBlob: Identifiable, Equatable {
        public let id = UUID()

        let color: Color
        var position: UnitPoint
        var scale: CGSize
        var opacity: CGFloat

        /**
         Creates a color blob with the specified color, position, scale and opacity.

         - Parameters:
            - color: The color of the blob.
            - position:  The position of the blob. If `nil` a random position will be generated.
            - scale: The scale of the blob. If `nil` a random scale will be generated.
            - opacity: The opacity of blob. If `nil` a random opacity will be generated.
         */
        public init(color: Color, position: UnitPoint? = nil, scale: CGSize? = nil, opacity: CGFloat? = nil) {
            self.color = color
            self.position = position ?? Self.randomPosition()
            self.scale = scale ?? Self.randomScale()
            self.opacity = opacity ?? Self.randomOpacity()
        }

        static func randomPosition() -> UnitPoint {
            UnitPoint(x: CGFloat.random(in: 0 ... 1),
                      y: CGFloat.random(in: 0 ... 1))
        }

        static func randomScale() -> CGSize {
            CGSize(width: CGFloat.random(in: 0.25 ... 1),
                   height: CGFloat.random(in: 0.25 ... 1))
        }

        static func randomOpacity() -> CGFloat {
            CGFloat.random(in: 0.75 ... 1)
        }
    }

    struct ColorBlobView: View {
        var blob: ColorBlob
        var geometry: GeometryProxy

        private var transformedPosition: CGPoint {
            let blobPosition = CGPoint(x: blob.position.x, y: blob.position.y)
            let transform = CGAffineTransform(scaleX: geometry.size.width, y: geometry.size.height)
            return blobPosition.applying(transform)
        }

        var body: some View {
            Ellipse()
                .foregroundColor(blob.color)
                .position(transformedPosition)
                .scaleEffect(blob.scale)
                .opacity(blob.opacity)
        }
    }
}

extension UnitPoint {
    func applying(_ t: CGAffineTransform) -> CGPoint {
        let cgPoint = CGPoint(x: x, y: y)
        return cgPoint.applying(t)
    }
}
