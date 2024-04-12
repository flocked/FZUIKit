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
    static func create<Delegate>(for object: Object, keyPath: WritableKeyPath<Object, Delegate?>) -> Self {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let delegateProxy = object.getAssociatedValue("_delegateProxy", initialValue: Self.init())
        delegateProxy.setDelegate(to: object)
        
        let observer = object.getAssociatedValue("_delegateProxyObserver", initialValue: KeyValueObserver<Object>(object))
        if let keyPath = keyPath._kvcKeyPathString, !observer.isObserving(keyPath) {
            observer.add(keyPath) { old, new, _ in
                if let old = old as? NSObject, let new = new as? NSObject {
                    guard old != new, new != delegateProxy else { return }
                    delegateProxy.setDelegate(to: object)
                } else if (new as? NSObject) != delegateProxy {
                    delegateProxy.setDelegate(to: object)
                }
            }
        }
        
        return delegateProxy
    }
    
    static func create(for object: Object) -> Self {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let delegateProxy = object.getAssociatedValue("_delegateProxy", initialValue: Self.init())
        delegateProxy.setDelegate(to: object)
        return delegateProxy
    }
}

