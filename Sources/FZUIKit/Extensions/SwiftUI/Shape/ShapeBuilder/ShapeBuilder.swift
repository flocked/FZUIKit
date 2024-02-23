//
//  ShapeBuilder.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

#if swift(>=5.4)
/// A function builder type that produces a shape.
    @resultBuilder
    public enum ShapeBuilder {
        public static func buildBlock<S: Shape>(_ builder: S) -> some Shape {
            builder
        }
    }
#else
/// A function builder type that produces a shape.
    @_functionBuilder
    public enum ShapeBuilder {
        public static func buildBlock<S: Shape>(_ builder: S) -> some Shape {
            builder
        }
    }
#endif

public extension ShapeBuilder {
    static func buildOptional<S: Shape>(_ component: S?) -> EitherShape<S, EmptyShape> {
        component.flatMap(EitherShape.first) ?? EitherShape.second(EmptyShape())
    }

    static func buildEither<First: Shape, Second: Shape>(first component: First) -> EitherShape<First, Second> {
        .first(component)
    }

    static func buildEither<First: Shape, Second: Shape>(second component: Second) -> EitherShape<First, Second> {
        .second(component)
    }
}
