//
//  NSUIView+VisualEffect.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS) || os(iOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    extension NSUIView {
        /**
         The visual effect of the view.

         The property adds a `VisualEffectView` as background to the view. The default value is `nil`.
         */
        @objc open var visualEffect: VisualEffectConfiguration? {
            get {
                #if os(macOS)
                return (self as? NSVisualEffectView)?.configuration ?? visualEffectBackgroundView?.configuration
                #else
                return visualEffectBackgroundView?.contentProperties
                #endif
            }
            set {
                if let newValue = newValue {
                    #if os(macOS)
                    if let view = self as? NSVisualEffectView {
                        view.configuration = newValue
                    } else {
                        let shadow = outerShadow
                        if visualEffectBackgroundView == nil {
                            visualEffectBackgroundView = TaggedVisualEffectView()
                        }
                        visualEffectBackgroundView?.configuration = newValue
                        if let appearance = newValue.appearance {
                            self.appearance = appearance
                        }
                        visualEffectBackgroundView?.cornerRadius = cornerRadius
                        visualEffectBackgroundView?.roundedCorners = roundedCorners
                     //   visualEffectBackgroundView?.cornerShape = cornerShape
                        outerShadow = shadow

                    }
                    #else
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = TaggedVisualEffectView()
                    }
                    visualEffectBackgroundView?.contentProperties = newValue
                    #endif
                } else {
                    visualEffectBackgroundView = nil
                }
            }
        }
        
        /// Sets the visual effect of the view.
        @discardableResult
        @objc open func visualEffect(_ visualEffect: VisualEffectConfiguration?) -> Self {
            self.visualEffect = visualEffect
            return self
        }

        var visualEffectBackgroundView: TaggedVisualEffectView? {
            get { viewWithTag(TaggedVisualEffectView.Tag) as? TaggedVisualEffectView }
            set {
                if visualEffectBackgroundView != newValue {
                    visualEffectBackgroundView?.removeFromSuperview()
                }
                if let newValue = newValue {
                    insertSubview(newValue, at: 0)
                    newValue.constraint(to: self)
                }
            }
        }
    }

    #if os(macOS)
        extension NSView {
            class TaggedVisualEffectView: NSVisualEffectView {
                public static var Tag: Int { 3_443_024 }

                override var tag: Int { Self.Tag }
            }
        }

    #elseif canImport(UIKit)
        extension UIView {
            class TaggedVisualEffectView: UIVisualEffectView {
                public var contentProperties: VisualEffectConfiguration = .init() {
                    didSet { updateEffect() }
                }

                func updateEffect() {
                    #if os(iOS)
                    effect = contentProperties.effect
                    #elseif os(tvOS)
                        if let blur = contentProperties.blur {
                            effect = UIBlurEffect(style: blur)
                        } else {
                            effect = nil
                        }
                    #endif
                }

                public static var Tag: Int { 3_443_024 }

                override var tag: Int {
                    get { Self.Tag }
                    set { }
                }
            }
        }
    #endif
#endif
