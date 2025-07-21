//
//  CAAnimation+.swift
//
//
//  Created by Florian Zand on 23.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import FZSwiftUtils
    import QuartzCore

    extension CAAnimation {
        /// A handler that gets called after the animation started.
        public var onStart: (() -> Void)? {
            get { getAssociatedValue("didStart") }
            set {
                setAssociatedValue(newValue, key: "didStart")
                updateAnimationDelegate()
            }
        }

        /// A handler that gets called after the animation stoped.
        public var onStop: (() -> Void)? {
            get { getAssociatedValue("didFinish") }
            set {
                setAssociatedValue(newValue, key: "didFinish")
                updateAnimationDelegate()
            }
        }

        fileprivate func updateAnimationDelegate() {
            if onStart != nil || onStop != nil, !(delegate is DelegateProxy) {
                delegate = DelegateProxy(self, delegate: delegate)
            } else if delegate is DelegateProxy {
                delegate = nil
            }
        }

        fileprivate class DelegateProxy: NSObject, CAAnimationDelegate {
            weak var animation: CAAnimation?
            weak var delegate: CAAnimationDelegate?
            var delegateObservation: KeyValueObservation?
            init(_ animation: CAAnimation, delegate: CAAnimationDelegate? = nil) {
                self.animation = animation
                super.init()
                self.delegate = delegate
                animation.delegate = self
                delegateObservation = animation.observeChanges(for: \.delegate) { [weak self] _, new in
                    guard let self = self, new !== self else { return }
                    self.delegate = new
                    self.animation?.delegate = self
                }
            }

            deinit {
                animation?.delegate = delegate
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
