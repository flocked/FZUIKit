//
//  NSUIView+VisualEffect.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIView {
    /**
     The visual effect background of the view.
     
     The property adds a visual effect view as background to the view. The default value is `nil`.
     */
    dynamic var visualEffect: VisualEffectConfiguration? {
        get {
            return visualEffectBackgroundView?.contentProperties
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
internal extension NSView {
    class TaggedVisualEffectView: NSVisualEffectView {
        public static var Tag: Int {
            return 3_443_024
        }

        override var tag: Int {
            return Self.Tag
        }

        public var contentProperties: VisualEffectConfiguration {
            get {
                return VisualEffectConfiguration(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: isEmphasized, maskImage: maskImage)
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
        public var contentProperties: VisualEffectConfiguration = .init() {
            didSet { updateEffect() }
        }

        internal func updateEffect() {
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
            return 3_443_024
        }

        override var tag: Int {
            get { return Self.Tag }
            set { }
        }
    }
}
#endif
#endif
