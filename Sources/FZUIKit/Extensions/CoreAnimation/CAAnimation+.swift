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
            var delegate: CAAnimationDelegate?
            init(_ animation: CAAnimation, delegate: CAAnimationDelegate? = nil) {
                self.animation = animation
                super.init()
                self.delegate = delegate
                animation.delegate = self
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

#endif
