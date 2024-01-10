//
//  PropertyAnimator+LayoutConstraint.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

    extension NSLayoutConstraint: AnimatablePropertyProvider {
        /// Provides animatable properties of the layout constraint.
        public var animator: LayoutAnimator { getAssociatedValue(key: "PropertyAnimator", object: self, initialValue: LayoutAnimator(self)) }
    }

    /// Provides animatable properties of a layout constraint.
    public class LayoutAnimator: PropertyAnimator<NSLayoutConstraint> {
        /// The constant of the layout constraint.
        public var constant: CGFloat {
            get { self[\.constant] }
            set { self[\.constant] = newValue }
        }
    }

    public extension Collection where Element == NSLayoutConstraint {
        /// Use the `animator` property to animate changes to the layout constraints of the collection.
        var animator: LayoutConstraintsAnimator<Self> {
            LayoutConstraintsAnimator(self)
        }
    }

    /// An object for animating layout constraints in a collection.
    public struct LayoutConstraintsAnimator<Object: Collection> where Object.Element == NSLayoutConstraint {
        var collection: Object
        init(_ collection: Object) {
            self.collection = collection
        }

        /// Updates the constant of the constraints and returns itself.
        public func constant(_ constant: CGFloat) {
            collection.forEach { $0.animator.constant = constant }
        }

        /// Updates the constant of the constraints and returns itself.
        public func constant(_ insets: NSDirectionalEdgeInsets) {
            collection.leading?.animator.constant = insets.leading
            collection.trailing?.animator.constant = -insets.trailing
            collection.bottom?.animator.constant = -insets.bottom
            collection.top?.animator.constant = insets.top
            collection.width?.animator.constant = -insets.width
            collection.height?.animator.constant = -insets.height
        }

        /// Updates the constant of the constraints and returns itself.
        public func constant(_ insets: NSUIEdgeInsets) {
            constant(insets.directional)
        }

        public var leading: PropertyAnimator<NSLayoutConstraint>? { collection.leading?.animator }

        public var trailing: PropertyAnimator<NSLayoutConstraint>? { collection.trailing?.animator }

        public var bottom: PropertyAnimator<NSLayoutConstraint>? { collection.bottom?.animator }

        public var top: PropertyAnimator<NSLayoutConstraint>? { collection.top?.animator }

        public var centerX: PropertyAnimator<NSLayoutConstraint>? { collection.centerX?.animator }

        public var centerY: PropertyAnimator<NSLayoutConstraint>? { collection.centerY?.animator }

        public var lastBaseline: PropertyAnimator<NSLayoutConstraint>? { collection.lastBaseline?.animator }

        public var firstBaseline: PropertyAnimator<NSLayoutConstraint>? { collection.firstBaseline?.animator }
    }

    public extension LayoutAnimator {
        /**
         The current animation for the property at the specified keypath.

         - Parameter keyPath: The keypath to an animatable property.
         */
        func animation<Value: AnimatableProperty>(for keyPath: WritableKeyPath<LayoutAnimator, Value>) -> AnimationProviding? {
            lastAnimationKey = ""
            _ = self[keyPath: keyPath]
            return animations[lastAnimationKey != "" ? lastAnimationKey : keyPath.stringValue]
        }

        /**
         The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.

         - Parameter keyPath: The keypath to an animatable property.
         */
        func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<LayoutAnimator, Value>) -> Value? {
            var velocity: Value?
            Anima.updateVelocity {
                velocity = self[keyPath: keyPath]
            }
            return velocity
        }
    }

#endif
