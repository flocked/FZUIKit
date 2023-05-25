//
//  File.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension NSUIView {
    /**
      The views’s visual effect background.

     The property adds a visual effect view as background to the view. The default value is nil.
      */
    var visualEffect: ContentConfiguration.VisualEffect? {
        get {
            return _visualEffectView?.contentProperties
        }
        set {
            if let newValue = newValue {
                if let visualEffectView = _visualEffectView {
                    visualEffectView.contentProperties = newValue
                } else {
                    _visualEffectView = TaggedVisualEffectView()
                    _visualEffectView?.constraint(to: self)
                    _visualEffectView?.contentProperties = newValue
                }
                #if os(macOS)
                    if let appearance = newValue.appearance {
                        self.appearance = appearance
                    }
                #endif
            } else {
                _visualEffectView = nil
            }
        }
    }

    internal var _visualEffectView: TaggedVisualEffectView? {
        get { viewWithTag(TaggedVisualEffectView.Tag) as? TaggedVisualEffectView
        }
        set {
            if self._visualEffectView != newValue {
                self._visualEffectView?.removeFromSuperview()
            }
            if let newValue = newValue {
                insertSubview(newValue, at: 0)
            }
        }
    }
}

#if os(macOS)
    internal extension NSView {
        class TaggedVisualEffectView: NSVisualEffectView {
            public static var Tag: Int {
                return 3_443_024
            }

            override var tag: Int {
                return Self.Tag
            }

            public var contentProperties: ContentConfiguration.VisualEffect {
                get {
                    return ContentConfiguration.VisualEffect(material: material, blendingMode: blendingMode, state: state, isEmphasized: isEmphasized, maskImage: maskImage, appearance: appearance)
                }
                set {
                    material = newValue.material
                    blendingMode = newValue.blendingMode
                    state = newValue.state
                    isEmphasized = newValue.isEmphasized
                    maskImage = newValue.maskImage
                    appearance = newValue.appearance
                }
            }
        }
    }

#elseif canImport(UIKit)
    internal extension UIView {
        class TaggedVisualEffectView: UIVisualEffectView {
            public var contentProperties: ContentConfiguration.VisualEffect = .init(style: nil) {
                didSet { updateEffect() }
            }

            internal func updateEffect() {
                if let newStyle = contentProperties.style {
                    switch newStyle {
                    case let .vibrancy(blur: blurStyle, vibrancy: vibrancy):
                        let blurEffect = UIBlurEffect(style: blurStyle)
                        if let vibrancy = vibrancy {
                            effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancy)
                        } else {
                            effect = UIVibrancyEffect(blurEffect: blurEffect)
                        }
                    case let .blur(blurStyle):
                        effect = UIBlurEffect(style: blurStyle)
                    }
                } else {
                    effect = nil
                }
            }

            public static var Tag: Int {
                return 3_443_024
            }

            override var tag: Int {
                get { return Self.Tag }
                set {}
            }
        }
    }
#endif
