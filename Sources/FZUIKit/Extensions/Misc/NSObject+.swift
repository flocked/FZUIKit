//
//  NSObject+.swift
//
//
//  Created by Florian Zand on 22.04.24.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
    @discardableResult
    func set<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, to value: Value) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
    
    /// Returns the real `self`, if the object is a proxy.
    var realSelf: Self {
        guard isProxy() else { return self }
        return Self.toRealSelf(self)
    }
}

fileprivate extension NSObject {
    @objc func _realSelf() -> NSObject { self }
    static func toRealSelf<Object: NSObject>(_ v: Object) -> Object {
        v.perform(#selector(_realSelf))!.takeUnretainedValue() as! Object
    }
}
