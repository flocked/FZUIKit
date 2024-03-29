//
//  View+SkeumorphBorder.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func skeuomorphBorder(cornerRadius: CGFloat = 4.0, color: Color = .black, width: CGFloat = 1.0) -> some View {
        modifier(SkeuomorphBorder(cornerRadius: cornerRadius, color: color, width: width))
    }

    @ViewBuilder
    func skeuomorphBorder<S: InsettableShape>(_ shape: S, color: Color = .black, width: CGFloat = 1.0) -> some View {
        modifier(SkeuomorphShapeBorder(shape, color: color, width: width))
    }
}

struct SkeuomorphBorder: ViewModifier {
    private let cornerRadius: CGFloat
    private let color: Color
    private let width: CGFloat

    init(cornerRadius: CGFloat = 4.0, color: Color = .black, width: CGFloat = 1.0) {
        self.color = color
        self.width = width
        self.cornerRadius = cornerRadius
    }

    @ViewBuilder
    var overlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(color.opacity(0.5), lineWidth: width)
        RoundedRectangle(cornerRadius: cornerRadius)
            .inset(by: width)
            .strokeBorder(.white.opacity(0.5), lineWidth: width)
    }

    func body(content: Content) -> some View {
        content
            .cornerRadius(cornerRadius)
            .overlay(overlay)
    }
}

struct SkeuomorphShapeBorder<S: InsettableShape>: ViewModifier {
    private let color: Color
    private let width: CGFloat
    private let shape: S

    init(_ shape: S, color: Color = .black, width: CGFloat = 1.0) {
        self.color = color
        self.width = width
        self.shape = shape
    }

    @ViewBuilder
    var overlay: some View {
        shape.strokeBorder(color.opacity(0.5), lineWidth: width)
        shape
            .inset(by: width)
            .strokeBorder(.white.opacity(0.5), lineWidth: width)
        //  .padding(EdgeInsets(top: width, leading: width, bottom: width, trailing: width))
    }

    func body(content: Content) -> some View {
        content
            .clipShape(shape)
            .overlay(overlay)
    }
}
