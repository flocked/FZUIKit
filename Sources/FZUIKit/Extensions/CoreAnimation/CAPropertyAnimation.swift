//
//  CAPropertyAnimation.swift
//  FZCollection
//
//  Created by Florian Zand on 13.05.22.
//

import QuartzCore

public extension CAPropertyAnimation {
    convenience init<Value>(keyPath: WritableKeyPath<CALayer, Value>) {
        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        self.init(keyPath: keyPathString)
    }
}

public extension CALayer {
    func propertyAnimation<Value>(for keyPath: WritableKeyPath<CALayer, Value>) -> CAPropertyAnimation? {
        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        return animation(forKey: keyPathString) as? CAPropertyAnimation
    }

    func add(_ animation: CAPropertyAnimation) {
        add(animation, forKey: animation.keyPath)
    }

    func remove(_ animation: CAPropertyAnimation) {
        if let keyPath = animation.keyPath {
            removeAnimation(forKey: keyPath)
        }
    }
}
