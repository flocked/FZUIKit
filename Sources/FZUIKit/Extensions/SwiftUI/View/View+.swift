//
//  View+.swift
//
//
//  Created by Florian Zand on 24.09.22.
//

import Foundation
import SwiftUI

public extension View {
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
        AnyView(self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension View {
    /**
     Masks this view using the inverse alpha channel of a given view.
     
     - Parameters:
        - alignment: The alignment for `mask` in relation to this view. Default is `.center`.
        - mask: The view whose alpha the rendering system inversely applies to the specified view.
     */
    @ViewBuilder func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}
