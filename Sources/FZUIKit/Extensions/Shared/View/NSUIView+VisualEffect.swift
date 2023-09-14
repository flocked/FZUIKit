//
//  NSUIView+VisualEffect.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
import AppKit
#elseif canImport(FZUIKit)
import UIKit
#endif

public extension NSUIView {
    /**
     The visual effect background of the view.
     
     The property adds a visual effect view as background to the view. The default value is nil.
     */
    var visualEffect: ContentConfiguration.VisualEffect? {
        get {
            return visualEffectBackgroundView?.contentProperties
        }
        set {
            if let newValue = newValue {
                if let visualEffectView = visualEffectBackgroundView {
                    visualEffectView.contentProperties = newValue
                } else {
                    visualEffectBackgroundView = TaggedVisualEffectView()
                    visualEffectBackgroundView?.constraint(to: self)
                    visualEffectBackgroundView?.contentProperties = newValue
                }
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
                return ContentConfiguration.VisualEffect(material: material, blendingMode: blendingMode, appearance: appearance, state: state, isEmphasized: isEmphasized, maskImage: maskImage)
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
                #if os(iOS)
                switch newStyle {
                case let .vibrancy(vibrancy, blur: blurStyle):
                    let blurEffect = UIBlurEffect(style: blurStyle)
                    effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancy)
                case let .blur(blurStyle):
                    effect = UIBlurEffect(style: blurStyle)
                }
                #elseif os(tvOS)
                effect = UIBlurEffect(style: newStyle)
                #endif
            } else {
                effect = nil
            }
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
