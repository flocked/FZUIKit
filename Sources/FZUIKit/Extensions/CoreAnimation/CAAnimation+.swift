//
//  CAAnimation+.swift
//
//
//  Created by Florian Zand on 23.11.23.
//

#if canImport(QuartzCore)
    import FZSwiftUtils
    import QuartzCore

    extension CAAnimation {
        /// A handler that gets called when the animation starts.
        public var onStart: (() -> Void)? {
            get { getAssociatedValue("didStart", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "didStart")
                updateAnimationDelegate()
            }
        }

        /// A handler that gets called when the animation stops.
        public var onStop: (() -> Void)? {
            get { getAssociatedValue("didFinish", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "didFinish")
                updateAnimationDelegate()
            }
        }

        var delegateProxy: DelegateProxy? {
            get { getAssociatedValue("delegateProxy", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "delegateProxy") }
        }

        func updateAnimationDelegate() {
            if onStart != nil || onStop != nil {
                if delegateProxy == nil || !(delegate is DelegateProxy) {
                    delegateProxy = DelegateProxy(self, delegate: delegate)
                }
            } else {
                if delegate is DelegateProxy {
                    delegate = nil
                }
                delegateProxy = nil
            }
        }

        class DelegateProxy: NSObject, CAAnimationDelegate {
            weak var animation: CAAnimation?
            weak var delegate: CAAnimationDelegate?
            var delegateObservation: KeyValueObservation?
            init(_ animation: CAAnimation, delegate: CAAnimationDelegate? = nil) {
                self.animation = animation
                super.init()
                self.delegate = delegate
                animation.delegate = self
                delegateObservation = animation.observeChanges(for: \.delegate) { [weak self] old, new in
                    guard let self = self, (new as? NSObject) != self else { return }
                    self.delegate = new
                    self.animation?.delegate = self
                }
            }

            func animationDidStart(_ anim: CAAnimation) {
                animation?.onStart?()
                delegate?.animationDidStart?(anim)
            }

            func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
                animation?.onStop?()
                delegate?.animationDidStop?(anim, finished: flag)
            }
        }
    }

/*
 extension CAAnimation {
     
     /// A handler that gets called when the animation starts.
     public var onStart: (() -> Void)? {
         get { getAssociatedValue("didStart", initialValue: nil) }
         set {
             setAssociatedValue(newValue, key: "didStart")
             if let onStart = newValue {
                 delegateProxy.intercept(#selector(CAAnimationDelegate.animationDidStart(_:))) { _ in
                     onStart()
                 }
             } else {
                 delegateProxy.intercept(#selector(CAAnimationDelegate.animationDidStart(_:)), handler: nil)
             }
         }
     }

     /// A handler that gets called when the animation stops.
     public var onStop: (() -> Void)? {
         get { getAssociatedValue("didFinish", initialValue: nil) }
         set {
             setAssociatedValue(newValue, key: "didFinish")
             if let onStop = newValue {
                 delegateProxy.intercept(#selector(CAAnimationDelegate.animationDidStop(_:finished:))) { _ in
                     onStop()
                 }
             } else {
                 delegateProxy.intercept(#selector(CAAnimationDelegate.animationDidStop(_:finished:)), handler: nil)
             }
         }
     }
     
     var delegateProxy: DelegateProxy {
         AnimationDelegateProxy.create(for: self, keyPath: \.delegate)
     }
   
     class AnimationDelegateProxy: DelegateProxy, CAAnimationDelegate, DelegateProxyType {
         func setDelegate(to object: CAAnimation) {
             object.delegate = self
         }
     }
 }
 */

#endif
