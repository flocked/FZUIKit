//
//  IrregularGradient.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 01/12/20.
//  Updated by Florian Zand on 14/09/2022

import SwiftUI

/// A view that displays an irregular gradient.
 public struct IrregularGradient<Background: View>: View {
     @State private var colorBlobs: [ColorBlob]

     private let background: Background
     private let speed: Double

     /**
      Creates a irregular gradient view with the specified colors, background and animation speed.

      - Parameters:
         - colors: The colors of the blobs in the gradient.
         - background:  The background view of the gradient.
         - speed: The speed at which the blobs move, if they're moving.
      */
     public init(colors: [Color], background: @autoclosure @escaping () -> Background, speed: Double = 0) {
         let blobs = colors.map { ColorBlob(color: $0) }
         self.init(colorBlobs: blobs, background: background(), speed: speed)
     }

     /**
      Creates a irregular gradient view with the specified color blobs, background and animation speed.

      - Parameters:
         - colorBlobs: The color blobs in the gradient.
         - background:  The background view of the gradient.
         - speed: The speed at which the blobs move, if they're moving.
      */
     public init(colorBlobs: [ColorBlob], background: @autoclosure @escaping () -> Background, speed: Double = 0) {
         _colorBlobs = State(initialValue: colorBlobs)
         self.background = background()
         self.speed = speed
     }

     private var animation: SwiftUI.Animation? {
         guard speed > 0 else { return nil }

         return .spring(
             response: 3.0 / speed,
             blendDuration: 1.0 / speed
         )
     }

     public var body: some View {
         GeometryReader { geometry in
             ZStack {
                 background

                 ZStack {
                     ForEach(colorBlobs) { blob in
                         ColorBlobView(
                             blob: blob,
                             geometry: geometry
                         )
                     }
                 }
                 .compositingGroup()
                 .blur(
                     radius: pow(
                         min(geometry.size.width, geometry.size.height),
                         0.65
                     )
                 )
             }
             .clipped()
         }
         .onAppear {
             update()
         }
         .task(id: speed) {
             guard speed > 0 else { return }
             let delay = UInt64(1_000_000_000 / speed)
             while !Task.isCancelled {
                 try? await Task.sleep(nanoseconds: delay)

                 guard !Task.isCancelled else { return }

                 update()
             }
         }
         .animation(animation, value: colorBlobs)
     }

     @MainActor
     private func update() {
         for index in colorBlobs.indices {
             colorBlobs[index].position = ColorBlob.randomPosition()
             colorBlobs[index].scale = ColorBlob.randomScale()
             colorBlobs[index].opacity = ColorBlob.randomOpacity()
         }
     }
 }

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

fileprivate extension UnitPoint {
    func applying(_ t: CGAffineTransform) -> CGPoint {
        let cgPoint = CGPoint(x: x, y: y)
        return cgPoint.applying(t)
    }
}


 public extension IrregularGradient where Background == Color {
     /**
      Creates a irregular gradient view with the specified colors, background color and animation speed.

      - Parameters:
         - colors: The colors of the blobs in the gradient.
         - backgroundColor:  The background color of the gradient.
         - speed: The speed at which the blobs move, if they're moving.
      */
     init(colors: [Color], backgroundColor: Color = .clear, speed: Double = 0) {
         self.init(colors: colors, background: backgroundColor, speed: speed)
     }
 }

public extension View {
    /**
     Replace view's contents with a gradient.

     - Parameters:
       - colors: The colors of the blobs in the gradient.
       - background: The background view of the gradient.
       - speed: The speed at which the blobs move, if they're moving.
       - animate: Whether or not the blobs should move.
     */
    func irregularGradient<Background: View>(colors: [Color], background: @autoclosure @escaping () -> Background, speed: Double = 0) -> some View {
        overlay(IrregularGradient(colors: colors, background: background(), speed: speed))
            .mask(self)
    }
}

public extension Shape {
    /**
     Fill a shape with a gradient.

     - Parameters:
       - colors: The colors of the blobs in the gradient.
       - background: The background view of the gradient.
       - speed: The speed at which the blobs move, if they're moving.
       - animate: Whether or not the blobs should move.
     */
    @MainActor
    func irregularGradient<Background: View>(colors: [Color], background: @autoclosure @escaping () -> Background, speed: Double = 0) -> some View {
        overlay(IrregularGradient(colors: colors, background: background(), speed: speed))
            .clipShape(self)
    }
}


 struct IrregularGradient_Previews: PreviewProvider {
     static var previews: some View {
         PreviewWrapper()
     }

     struct PreviewWrapper: View {
         @State var animate = false
         @State var speed: CGFloat = 1.0

         var body: some View {
             VStack {
                 RoundedRectangle(cornerRadius: 30.0, style: .continuous)
                     .irregularGradient(colors: [.orange, .pink, .yellow, .orange, .pink, .yellow],
                                        background: Color.orange,
                                        speed: speed)
                 HStack {
                     Toggle("Animate", isOn: $animate)
                         .padding()
                     #if os(macOS) || os(iOS) || os(visionOS)
                         Slider(value: $speed, in: 0.0 ... 1.0)
                             .padding()
                     #endif
                 }
             }
             .padding(25)
         }
     }
 }
