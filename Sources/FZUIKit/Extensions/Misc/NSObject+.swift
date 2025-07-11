//
//  NSObject+.swift
//  FZUIKit
//
//  Created by Florian Zand on 11.07.25.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
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
