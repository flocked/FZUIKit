//
//  InsettableShapeBuilder.swift
//
//
//  Created by Florian Zand on 06.10.22.
//

import SwiftUI

#if swift(>=5.4)
/// A function builder type that produces an insettable shape.
    @resultBuilder
    public enum InsettableShapeBuilder {
        public static func buildBlock<S: InsettableShape>(_ builder: S) -> some InsettableShape {
            builder
        }
    }
#else
/// A function builder type that produces an insettable shape.
    @_functionBuilder
    public enum InsettableShapeBuilder {
        public static func buildBlock<S: InsettableShape>(_ builder: S) -> some InsettableShape {
            builder
        }
    }
#endif

public extension InsettableShapeBuilder {
    static func buildOptional<S: InsettableShape>(_ component: S?) -> EitherInsettableShape<S, EmptyShape> {
        component.flatMap(EitherInsettableShape.first) ?? .second(EmptyShape())
    }

    static func buildEither<First: InsettableShape, Second: InsettableShape>(
        first component: First
    ) -> EitherInsettableShape<First, Second> {
        .first(component)
    }

    static func buildEither<First: InsettableShape, Second: InsettableShape>(
        second component: Second
    ) -> EitherInsettableShape<First, Second> {
        .second(component)
    }
}
