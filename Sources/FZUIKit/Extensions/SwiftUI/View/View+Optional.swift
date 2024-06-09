//
//  View+Optional.swift
//
//
//  Created by Florian Zand on 05.02.23.
//

import SwiftUI

public extension View {
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @ViewBuilder
    func background<S: ShapeStyle>(_ style: S?, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View {
        if let style = style {
            background(style, ignoresSafeAreaEdges: edges)
        } else {
            self
        }
    }

    @ViewBuilder
    func shadow(color: Color?, radius: CGFloat, offset: CGPoint) -> some View {
        if let color = color {
            shadow(color: color, radius: radius, x: offset.x, y: offset.y)
        } else {
            self
        }
    }

    @ViewBuilder
    func border<S>(_ content: S?, width: CGFloat = 1) -> some View where S: ShapeStyle {
        if let content = content, width > 0.0 {
            border(content, width: width)
        } else {
            self
        }
    }

    @ViewBuilder
    func border<S, A: Shape>(_ content: S?, width: CGFloat = 1, shape: A) -> some View where S: ShapeStyle {
        if let content = content, width > 0.0 {
            border(content, width: width, shape: shape)
        } else {
            self
        }
    }

    @available(macOS 11.0, iOS 13.0, *)
    @ViewBuilder
    func imageScale(_ scale: Image.Scale?) -> some View {
        if let scale = scale {
            imageScale(scale)
        } else {
            self
        }
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @ViewBuilder
    func foregroundStyle(_ primary: Color?, _ secondary: Color?, _ tertiary: Color?) -> some View {
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
    
    @ViewBuilder
    @available(macOS 11.0, *)
    func help(_ helpKey: LocalizedStringKey?) -> some View {
        if let helpKey = helpKey {
            help(helpKey)
        } else {
            self
        }
    }
}
