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

    public extension NSUIView {
        /**
         The visual effect background of the view.

         The property adds a `NSVisualEffectView` as background to the view. The default value is `nil`.
         */
        var visualEffect: VisualEffectConfiguration? {
            get {
                visualEffectBackgroundView?.contentProperties
            }
            set {
                if let newValue = newValue {
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = TaggedVisualEffectView()
                    }
                    visualEffectBackgroundView?.contentProperties = newValue
                    #if os(macOS)
                        if let appearance = newValue.appearance {
                            self.appearance = appearance
                        }
                    #endif
                } else {
                    visualEffectBackgroundView = nil
                }
            }
        }

        internal var visualEffectBackgroundView: TaggedVisualEffectView? {
            get { viewWithTag(TaggedVisualEffectView.Tag) as? TaggedVisualEffectView
            }
            set {
                if self.visualEffectBackgroundView != newValue {
                    self.visualEffectBackgroundView?.removeFromSuperview()
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
                public static var Tag: Int {
                    3_443_024
                }

                override var tag: Int {
                    Self.Tag
                }

                public var contentProperties: VisualEffectConfiguration {
                    get {
                        VisualEffectConfiguration(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: isEmphasized, maskImage: maskImage)
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
        extension UIView {
            class TaggedVisualEffectView: UIVisualEffectView {
                public var contentProperties: VisualEffectConfiguration = .init() {
                    didSet { updateEffect() }
                }

                func updateEffect() {
                    #if os(iOS)
                        if let newStyle = contentProperties.style {
                            switch newStyle {
                            case let .vibrancy(vibrancy, blur: blurStyle):
                                let blurEffect = UIBlurEffect(style: blurStyle)
                                effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancy)
                            case let .blur(blurStyle):
                                effect = UIBlurEffect(style: blurStyle)
                            }
                        } else {
                            effect = nil
                        }
                    #elseif os(tvOS)
                        if let blur = contentProperties.blur {
                            effect = UIBlurEffect(style: blur)
                        } else {
                            effect = nil
                        }
                    #endif
                }

                public static var Tag: Int {
                    3_443_024
                }

                override var tag: Int {
                    get { Self.Tag }
                    set {}
                }
            }
        }
    #endif
#endif
