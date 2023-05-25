//
//  View+Optional.swift
//  NSButtonConfiguration
//
//  Created by Florian Zand on 05.02.23.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func borderOptional<S>(_ content: S?, width: CGFloat = 1) -> some View where S: ShapeStyle {
        if let content = content, width > 0.0 {
            border(content, width: width)
        } else {
            self
        }
    }

    @available(macOS 11.0, iOS 13.0, *)
    @ViewBuilder
    func imageScaleOptional(_ scale: Image.Scale?) -> some View {
        if let scale = scale {
            imageScale(scale)
        } else {
            self
        }
    }

    @available(macOS 12.0, iOS 15.0, *)
    @ViewBuilder
    func foregroundStyleOptional(_ primary: Color?, _ secondary: Color?, _ tertiary: Color?) -> some View {
        if let primary = primary {
            if let secondary = secondary {
                if let tertiary = tertiary {
                    foregroundStyle(primary, secondary, tertiary)
                } else {
                    foregroundStyle(primary, secondary)
                }
            } else {
                foregroundStyle(primary)
            }
        } else {
            self
        }
    }
}
