//
//  File.swift
//
//
//  Created by Florian Zand on 24.09.22.
//

import Foundation
import SwiftUI

public extension View {
    /// If
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

public extension View {
    @ViewBuilder
    func border<S: ShapeStyle>(_ content: S, width: CGFloat = 1.0, cornerRadius: CGFloat) -> some View {
        self.cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(content, lineWidth: width)
            )
    }

    @ViewBuilder
    func border<C: ShapeStyle, S: Shape>(_ content: C, width: CGFloat = 1.0, shape: S) -> some View {
        clipShape(shape)
            .overlay(
                shape
                    .stroke(content, lineWidth: width)
            )
    }

    func asAnyView() -> AnyView {
        return AnyView(self)
    }
}
