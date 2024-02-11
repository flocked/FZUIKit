//
//  CAPropertyAnimation+.swift
//
//
//  Created by Florian Zand on 13.05.22.
//

#if canImport(QuartzCore)
    import QuartzCore

    public extension CAPropertyAnimation {
        /**
         Creates and returns an CAPropertyAnimation instance for the specified key path.
         - Parameter keyPath: The key path of the property to be animated.
         - Returns: A new instance of CAPropertyAnimation with the key path set to keyPath.
         */
        convenience init<Value>(keyPath: WritableKeyPath<CALayer, Value>) {
            let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
            self.init(keyPath: keyPathString)
        }
    }

    public extension CALayer {
        /**
         Returns the animation object with the specified keypath.
         - Parameter keyPath: The key path of the property.
         - Returns: The property animation object matching the key path, or `nil` if no such animation exists.
         */
        func propertyAnimation<Value>(for keyPath: WritableKeyPath<CALayer, Value>) -> CAPropertyAnimation? {
            let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
            return animation(forKey: keyPathString) as? CAPropertyAnimation
        }

        /// Adds the specified property animation to the layer’s render tree.
        func add(_ animation: CAPropertyAnimation) {
            add(animation, forKey: animation.keyPath)
        }

        /// Removes the specified property animation.
        func remove(_ animation: CAPropertyAnimation) {
            if let keyPath = animation.keyPath {
                removeAnimation(forKey: keyPath)
            }
        }
    }
#endif
