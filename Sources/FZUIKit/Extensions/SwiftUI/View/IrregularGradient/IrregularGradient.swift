//
//  IrregularGradient.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 01/12/20.
//  Updated by Florian Zand on 14/09/2022

import Combine
import SwiftUI

/// A view that displays an irregular gradient.
public struct IrregularGradient<Background: View>: View {
    /**
     Creates a irregular gradient view with the specified colors, background and animation speed.

     - Parameters:
        - colors: The colors of the blobs in the gradient.
        - background:  The background view of the gradient.
        - speed: The speed at which the blobs move, if they're moving.
     */
    public init(colors: [Color],
                background: @autoclosure @escaping () -> Background,
                speed: Double = 0)
    {
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
    public init(colorBlobs: [ColorBlob],
                background: @autoclosure @escaping () -> Background,
                speed: Double = 0)
    {
        _colorBlobs = State(initialValue: colorBlobs)
        self.background = background()
        self.speed = speed

        let interval = 1.0 / self.speed
        timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        if speed <= 0.0 {
            timer.upstream.connect().cancel()
        }
    }

    @State var colorBlobs: [ColorBlob]
    var background: Background
    var speed: Double
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    private var animation: SwiftUI.Animation {
        .spring(response: 3.0 / speed, blendDuration: 1.0 / speed)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                background
                ZStack {
                    ForEach(colorBlobs) { blob in
                        ColorBlobView(blob: blob,
                                      geometry: geometry)
                    }
                }.compositingGroup()
                    .blur(radius: pow(min(geometry.size.width, geometry.size.height), 0.65))
            }
            .clipped()
        }.onAppear(perform: update)
            .onReceive(timer) { _ in
                update()
            }
            .animation(animation, value: colorBlobs)
    }

    func update() {
        for index in colorBlobs.indices {
            colorBlobs[index].position = ColorBlob.randomPosition()
            colorBlobs[index].scale = ColorBlob.randomScale()
            colorBlobs[index].opacity = ColorBlob.randomOpacity()
        }
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
    init(colors: [Color],
         backgroundColor: Color = .clear,
         speed: Double = 0)
    {
        self.init(colors: colors,
                  background: backgroundColor,
                  speed: speed)
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
                    #if os(macOS) || os(iOS)
                        Slider(value: $speed, in: 0.0 ... 1.0)
                            .padding()
                    #endif
                }
            }
            .padding(25)
        }
    }
}
