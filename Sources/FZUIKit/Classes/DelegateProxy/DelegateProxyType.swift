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

    /// Intercepts the delegate of the specified object.
    func setDelegate(to object: Object)
}

public extension DelegateProxyType where Self: DelegateProxy {
    /**
     Creates a delegate proxy for the specified object and keypath.
     
     - Parameters:
        - object: The object.
        - keyPath: The keypath to the delegate.
     */
    static func create<Delegate>(for object: Object, keyPath: WritableKeyPath<Object, Delegate?>) -> Self {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let delegateProxy = object.getAssociatedValue("_delegateProxy", initialValue: Self.init())
        delegateProxy.setDelegate(to: object)
        guard let keyPath = keyPath._kvcKeyPathString else { return delegateProxy }
        let delegateObserver = object.getAssociatedValue("_delegateProxyObserver", initialValue: KeyValueObserver<Object>(object))
        guard !delegateObserver.isObserving(keyPath) else { return delegateProxy }
        delegateObserver.add(keyPath) { old, new, _ in
            if let old = old as? NSObject, let new = new as? NSObject {
                guard old != new, new != delegateProxy else { return }
                delegateProxy.setDelegate(to: object)
            } else if new as? NSObject != delegateProxy {
                delegateProxy.setDelegate(to: object)
            }
        }
        return delegateProxy
    }
    
    /**
     Creates a delegate proxy for the specified object.
     
     - Parameter object: The object.
     */
    static func create(for object: Object) -> Self {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        let delegateProxy = object.getAssociatedValue("_delegateProxy", initialValue: Self.init())
        delegateProxy.setDelegate(to: object)
        return delegateProxy
    }
}

