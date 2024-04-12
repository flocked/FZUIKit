//
//  DelegateProxy.swift
//  CombineCocoa
//
//  Created by Joan Disho on 25/09/2019.
//  Copyright © 2020 Combine Community. All rights reserved.
//


import Foundation
import Combine
import _DelegateProxyObjC

/**
 A `NSObject` delegate proxy.
 
 Example usage:
 ```swift
 extension NSCollectionView {
    var delegateProxy: DelegateProxy {
        CollectionViewDelegateProxy.create(for: self)
    }
  
    func didSelectItemsAtPublisher() -> AnyPublisher<[IndexPath], Never> {
        let selector = #selector(NSCollectionViewDelegate.collectionView(_:didSelectItemsAt:))
        return delegateProxy.interceptSelectorPublisher(selector)
            .map { return ($0[1] as? NSSet)?.allObjects as? [IndexPath] }
            .replaceNil(with: [])
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
  
    class CollectionViewDelegateProxy: DelegateProxy, NSCollectionViewDelegate, DelegateProxyType {
        func setDelegate(to object: NSCollectionView) {
            object.delegate = self
        }
    }
 }
 ```
 */
open class DelegateProxy: _DelegateProxyObjC {
    private var dict: [Selector: [([Any]) -> Void]] = [:]
    private var subscribers = [AnySubscriber<[Any], Never>?]()

    public required override init() {
        super.init()
    }

    public override func interceptedSelector(_ selector: Selector, arguments: [Any]) {
        dict[selector]?.forEach { handler in
            handler(arguments)
        }
    }

    /**
     Intercepts the specified selector and calls the given handler whenever the selector is called.
     
     - Parameters:
        - selector: The selector to intercept.
        - handler: The handler to be called whenever the selector is called.
     */
    public func intercept(_ selector: Selector, handler: (([Any]) -> Void)?) {
        if let handler = handler {
            if dict[selector] != nil {
                dict[selector]?.append(handler)
            } else {
                dict[selector] = [handler]
            }
        } else {
            dict[selector] = nil
        }
    }

    public func interceptSelectorPublisher(_ selector: Selector) -> AnyPublisher<[Any], Never> {
        DelegateProxyPublisher<[Any]> { subscriber in
            self.subscribers.append(subscriber)
            return self.intercept(selector) { args in
                _ = subscriber.receive(args)
            }
        }.eraseToAnyPublisher()
    }

    deinit {
        subscribers.forEach { $0?.receive(completion: .finished) }
        subscribers = []
    }
}

