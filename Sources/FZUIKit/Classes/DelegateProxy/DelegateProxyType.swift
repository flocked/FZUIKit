//
//  DelegateProxyType.swift
//  CombineCocoa
//
//  Created by Joan Disho on 25/09/2019.
//  Copyright © 2020 Combine Community. All rights reserved.
//


import Foundation
import FZSwiftUtils

public protocol DelegateProxyType {
    associatedtype Object: NSObject

    func setDelegate(to object: Object)
}

public extension DelegateProxyType where Self: DelegateProxy {
    static func create(for object: Object) -> Self {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let delegateProxy = object.getAssociatedValue("_delegateProxy", initialValue: Self.init())
        delegateProxy.setDelegate(to: object)
        return delegateProxy
    }
}

