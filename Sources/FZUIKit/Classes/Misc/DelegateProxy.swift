//
//  DelegateProxy.swift
//  FZUIKit
//
//  Created by Florian Zand on 11.07.25.
//

/*
import Foundation
import FZSwiftUtils
import _NSObjectProxy

class DelegateProxy_<Object: NSObject, Delegate: NSObject>: NSObject {
    public var object: Object? { _object }
    public let keyPath: ReferenceWritableKeyPath<Object, Delegate?>
    public var selectors: [Selector] = []
    
    private weak var _object: Object? {
        didSet { setupObject(oldValue) }
    }
    private var observation: KeyValueObservation?
    private var delegateProxy: Delegate?
    private var isWeak = false
    private var handler: (Invocation)->() = { _ in }
    private var customDelegate: Delegate?
    private var _delegate: Delegate?
    private weak var weakDelegate: Delegate?
    private var delegate: Delegate? {
        get { isWeak ? weakDelegate : _delegate }
        set {
            if isWeak {
                weakDelegate = newValue
            } else {
                _delegate = newValue
            }
        }
    }
    
    /**
     Creates a delegate proxy for the specified object and key path.
     
     - Parameters:
        - object: The object with the delegate.
        - keyPath. The key path to the delegate.
        - delegate. The delegate that provides additional methods and properties to the object's delegate.
     */
    public init(for object: Object, keyPath: ReferenceWritableKeyPath<Object, Delegate?>, delegate: Delegate) {
        self.keyPath = keyPath
        super.init()
        sharedInit(for: object, delegate: delegate)
    }
    
    /**
     Creates a delegate proxy for the specified object and key path.
     
     - Parameters:
        - object: The object with the delegate.
        - keyPath. The key path to the delegate.
        - invocationHandler. The handler that provides a delegate method invocation when a delegate method or property is called.
     */
    public init(for object: Object, keyPath: ReferenceWritableKeyPath<Object, Delegate?>, selectors: [Selector] = [], invocationHandler: @escaping (Invocation)->()) {
        self.keyPath = keyPath
        super.init()
        sharedInit(for: Object(), selectors: selectors, handler: invocationHandler)
    }
    
    /**
     Creates a delegate proxy for the specified object and key path.
     
     - Parameters:
        - object: The object with the delegate.
        - keyPath. The key path to the delegate.
        - invocationHandler. The handler that gets called when a delegate method or property is called.
     */
    public init(for object: Object, keyPath: ReferenceWritableKeyPath<Object, Delegate?>, invocationHandler: @escaping (_ selector: Selector, _ arguments: [Any], _ returnValue: Any?)->()) {
        self.keyPath = keyPath
        super.init()
        sharedInit(for: object) { invocation in
            invocation.invoke()
            invocationHandler(invocation.selector, invocation.arguments, invocation.returnValue)
        }
    }
    
    private func sharedInit(for object: Object, selectors: [Selector] = [], delegate: Delegate? = nil, handler: @escaping (Invocation)->() = { _ in }) {
        self._object = object
        self.isWeak = object.isWeakProperty(keyPath)
        self.selectors = selectors
        self.handler = handler
        self.customDelegate = delegate
        if let customDelegate = customDelegate {
            delegateProxy = customDelegate.proxy(invocationHandler: { [weak self] invocation in
                if let self = self {
                    if customDelegate.responds(to: invocation.selector) {
                        invocation.invoke()
                    } else if let delegate = self.delegate, delegate.responds(to: invocation.selector) {
                        invocation.target = delegate
                        invocation.invoke()
                    }
                }
            }) { [weak self] selector in
                self?.delegate?.responds(to: selector) == true
            }
        }
        setupProxy()
        self.observation = object.observeChanges(for: keyPath) { [weak self] old, new in
            guard let self = self, old !== new, new !== self, new !== self.delegateProxy else { return }
            self.setupProxy()
        }
    }
    
    deinit {
        observation = nil
        _object?[keyPath: keyPath] = delegate
    }
    
    fileprivate func setupObject(_ oldValue: Object?) {
        guard oldValue != object else { return }
        oldValue?[keyPath: keyPath] = delegate
        delegate = nil
        observation = nil
        setupProxy()
        observation = object?.observeChanges(for: keyPath) { [weak self] old, new in
            guard let self = self, old !== new, new !== self, new !== self.delegateProxy else { return }
            self.setupProxy()
        }
    }
    
    fileprivate func setupProxy() {
        if let object = _object {
            if customDelegate != nil {
                delegate = object[keyPath: keyPath]
                object[keyPath: keyPath] = delegateProxy
            } else if let value = object[keyPath: keyPath] {
                delegate = value
                delegateProxy = value.proxy(invocationHandler: { [weak self] invocation in
                    if let self = self {
                        if let delegate = self.customDelegate, delegate.responds(to: invocation.selector) {
                            invocation.target = delegate
                            invocation.invoke()
                        } else {
                            self.handler(invocation)
                        }
                    } else {
                        invocation.invoke()
                    }
                }, respondsHandler: { [weak self] selector, responds in
                    guard let self = self else { return responds }
                    return self.selectors.contains(selector) || responds
                })
                object[keyPath: keyPath] = delegateProxy
            } else {
                delegateProxy = nil
                delegate = nil
            }
        } else {
            delegateProxy = nil
            delegate = nil
        }
    }
}

extension NSObjectProtocol where Self: NSObject {
    fileprivate func isWeakProperty<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value?>) -> Bool {
        guard let propertyName = keyPath.kvcStringValue else { return false }

        var currentClass: AnyClass? = Self.self
        while let cls = currentClass {
            var count: UInt32 = 0
            guard let properties = class_copyPropertyList(cls, &count) else {
                currentClass = class_getSuperclass(cls)
                continue
            }
            defer { free(properties) }
            for i in 0..<count {
                let property = properties[Int(i)]
                let name = property_getName(property)
                if String(cString: name) == propertyName,
                   let attributes = property_getAttributes(property) {
                    let attrString = String(cString: attributes)
                    return attrString.contains(",W,") || attrString.hasSuffix(",W")
                }
            }
            currentClass = class_getSuperclass(cls)
        }
        return false
    }
}
*/
