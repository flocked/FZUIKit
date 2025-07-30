//
//  UIView+.swift
//
//
//  Created by Florian Zand on 12.08.22.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils
import SwiftUI

extension UIView {
    /// The parent view controller managing the view.
    public var parentController: UIViewController? {
        next as? UIViewController ?? (next as? UIView)?.parentController
    }
    
    /// Sets the background color of the view.
    @discardableResult
    public func backgroundColor(_ color: NSUIColor?) -> Self {
        backgroundColor = color
        return self
    }
    
    /**
     The anchor point for the view’s position along the z axis.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator().anchorPointZ`.
     
     The default value is `0.0`.
     */
    public var anchorPointZ: CGFloat {
        get { layer.anchorPointZ }
        set { layer.anchorPointZ = newValue     }
    }
    
    /**
     The rotation of the view as euler angles in degrees.
     
     The property can be animated. The default value is is `zero`, which results in a view with no rotation.
     */
    public var rotation: Rotation {
        get { self.transform3D.eulerAnglesDegrees.rotation }
        set { self.transform3D.eulerAnglesDegrees = newValue.vector }
    }
    
    /**
     The rotation of the view as euler angles in radians.
     
     The property can be animated. The default value is is `zero`, which results in a view with no rotation.
     */
    public var rotationInRadians: Rotation {
        get { self.transform3D.eulerAngles.rotation }
        set { self.transform3D.eulerAngles = newValue.vector }
    }
    
    /**
     The scale transform of the view.
     
     The property can be animated. The default value is is `none`, which results in a view displayed at it's original scale.
     */
    public var scale: Scale {
        get { self.layer.scale }
        set { self.layer.scale = newValue }
    }
    
    /**
     The translation of the view's transform.
     
     The property can be animated. The default value is `zero`, which results in a view with no transformed translation.
     */
    public var translation: Translation {
        get { transform3D.translation }
        set { transform3D.translation = newValue }
    }
    
    /**
     The perspective of the view's transform
     
     The property can be animated. The default value is `zero`, which results in a view with no transformed perspective.
     */
    public var perspective: Perspective {
        get { self.transform3D.perspective }
        set { self.transform3D.perspective = newValue }
    }
    
    /**
     The shearing of the view's transform.
     
     The property can be animated. The default value is `zero`, which results in a view with no transformed shearing.
     */
    public var skew: Skew {
        get { transform3D.skew }
        set { transform3D.skew = newValue }
    }
    
    /**
     The view’s position on the z axis.
     
     Changing the value of this property changes the front-to-back ordering of views onscreen. Higher values place the view visually closer to the viewer than views with lower values. This can affect the visibility of views whose frame rectangles overlap.
     */
    @objc open var zPosition: CGFloat {
        get { layer.zPosition }
        set { layer.zPosition = newValue }
    }
    
    /// The shape that is used for masking the view.
    public var maskShape: (any Shape)? {
        get { layer.maskShape }
        set { layer.maskShape = newValue }
    }
    
    /**
     The border of the view.
     
     The property can be animated. The default value is `none`, which results in a view with no border.
     */
    public var border: BorderConfiguration {
        get { layer.configurations.border }
        set { layer.configurations.border = newValue }
    }
    
    /**
     The rounded corners of the view.
     
     The default value is `all`, which results in a view with all corners rounded to the value specified at ``cornerRadius``.
     */
    @objc public var roundedCorners: CACornerMask {
        get { layer.maskedCorners.toAll }
        set {
            layer.maskedCorners = newValue
            dashedBorderView?.update()
        }
    }
    
    /**
     The corner radius of the view.
     
     The property can be animated. The default value is `0.0`, which results in a view with no corner radius.
     */
    @objc public var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    /// The corner curve of the view.
    @objc public var cornerCurve: CALayerCornerCurve {
        get { layer.cornerCurve }
        set { layer.cornerCurve = newValue }
    }
    
    /**
     The view whose inverse alpha channel is used to mask a view’s content.
     
     In contrast to ``mask`` transparent pixels allow the underlying content to show, while opaque pixels block the content.
     
     The property can be animated. The default value is `nil`, which results in a view with no inverse mask.
     */
    @objc public var inverseMask: NSUIView? {
        get { (layer.mask as? InverseMaskLayer)?.maskLayer?.parentView }
        set { layer.inverseMask = newValue?.layer }
    }
    
    /**
     The outer shadow of the view.
     
     If the shadow is visible, `clipsToBounds` is set to `false`.
     
     The property can be animated. The default value is `none`, which results in a view with no shadow.
     */
    public var shadow: ShadowConfiguration {
        get { layer.configurations.shadow }
        set { layer.configurations.shadow = newValue }
    }
    
    /**
     The inner shadow of the view.
     
     The property can be animated. The default value is `none`, which results in a view with no inner shadow.
     */
    public var innerShadow: ShadowConfiguration {
        get { layer.configurations.innerShadow }
        set { layer.configurations.innerShadow = newValue }
    }
    
    /**
     The inner shadow of the view.
     
     The property can be animated. The default value is `nil`, which results in a view with no shadow path.
     */
    @objc public var shadowPath: NSUIBezierPath? {
        get { layer.shadowPath?.bezierPath }
        set { layer.shadowPath = newValue?.cgPath }
    }
    
    /// The shape of the shadow.
    public var shadowShape: (any Shape)? {
        get { layer.shadowShape }
        set { layer.shadowShape = newValue }
    }
    
    /**
     The distance (in points) between the top of the view’s alignment rectangle and its topmost baseline.
     
     For views with multiple lines of text, this represents the baseline of the top row of text.
     
     - Note: For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or `nil` is returned.
     */
    public var firstBaselineOffsetFromTop: CGFloat? {
        if self is UITextField {
            return value(forKeySafely: "_firstBaselineOffsetFromTop") as? CGFloat
        } else if self is UITextView {
            return value(forKeySafely: "_firstBaselineOffsetFromTop") as? CGFloat
        } else if self is UILabel {
            return value(forKeySafely: "_firstBaselineOffsetFromTop") as? CGFloat
        }
        return nil
    }
    
    /**
     The distance (in points) between the bottom of the view’s alignment rectangle and its bottommost baseline.
     
     For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or `nil` is returned.
     */
    public var lastBaselineOffsetFromBottom: CGFloat? {
        if self is UITextField {
            return value(forKeySafely: "_lastBaselineOffsetFromBottom") as? CGFloat
        } else if self is UITextView {
            return value(forKeySafely: "_lastBaselineOffsetFromBottom") as? CGFloat
        } else if self is UILabel {
            return value(forKeySafely: "_baselineOffsetFromBottom") as? CGFloat
        }
        return nil
    }
    
    /**
     The coordinate of the baseline for the topmost line of text in the view.
     
     For views with multiple lines of text, this represents the baseline of the top row of text.
     
     - Note: For views of type `UITextField` or `UITextView`, auto layout has to be enabled, or else `0` is returned.
     */
    public var firstBaselineOffset: CGPoint {
        guard firstBaselineOffsetFromTop ?? 0.0 != 0 else { return frame.origin }
        return CGPoint(frame.x, frame.y + frame.height - (firstBaselineOffsetFromTop ?? 0.0) - 0.5)
    }
    
    /// Handlers for the view.
    public struct ViewHandlers {
        /// The handler that gets called when the trait collection changes.
        public var trait: ((UITraitCollection)->())?
        
        /// The handler that gets called when the user interface style changes.
        public var userInterfaceStyle: ((UIUserInterfaceStyle)->())?
        
        /// The handler that gets called when the active appearance changes.
        public var activeAppearance: ((UIUserInterfaceActiveAppearance)->())?
        
        var needsTraitObservation: Bool {
            trait != nil || userInterfaceStyle != nil || activeAppearance != nil
        }
    }
    
    /// The handlers for the view.
    public var viewHandlers: ViewHandlers {
        get { getAssociatedValue("handlers") ?? ViewHandlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            setupTraitObservation()
        }
    }
    
    func setupTraitObservation() {
        if !viewHandlers.needsTraitObservation && !dynamicColors.needsObserving {
            traitObserverView?.removeFromSuperview()
            traitObserverView = nil
        } else if traitObserverView == nil {
            traitObserverView = TraitObserverView(for: self)
        }
    }
    
    fileprivate var traitObserverView: TraitObserverView? {
        get { getAssociatedValue("traitObserverView") }
        set { setAssociatedValue(newValue, key: "traitObserverView") }
    }
    
    fileprivate class TraitObserverView: UIView {
        var previousTraitCollection: UITraitCollection?
        
        init(for view: UIView) {
            super.init(frame: .zero)
            view.addSubview(self)
            previousTraitCollection = traitCollection
            sendToBack()
            zPosition = -10000
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            guard let superview = superview, let previous = previousTraitCollection ?? self.previousTraitCollection else { return }
            self.previousTraitCollection = previousTraitCollection ?? self.previousTraitCollection
            superview.viewHandlers.trait?(traitCollection)
            if previous.activeAppearance != traitCollection.activeAppearance {
                superview.viewHandlers.activeAppearance?(traitCollection.activeAppearance)
            }
            if previous.userInterfaceStyle != traitCollection.userInterfaceStyle {
                superview.dynamicColors.update()
                superview.viewHandlers.userInterfaceStyle?(traitCollection.userInterfaceStyle)
            }
        }
    }
}

extension UIView.ContentMode: CaseIterable {
    /// All content modes.
    public static var allCases: [UIView.ContentMode] = [.scaleToFill, .scaleAspectFit, .scaleAspectFill, .redraw, .center, .top, .bottom, .left, .right, .topLeft, .topRight, .bottomLeft, .bottomRight]
}

extension UIView.ContentMode {
    var layerContentsGravity: CALayerContentsGravity {
        switch self {
        case .scaleToFill: return .resizeAspectFill
        case .scaleAspectFit: return .resizeAspectFill
        case .scaleAspectFill: return .resizeAspectFill
        case .redraw: return .resizeAspectFill
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .topLeft: return .left
        case .topRight: return .right
        case .bottomLeft: return .left
        case .bottomRight: return .right
        @unknown default: return .center
        }
    }
    
    init(contentsGravity: CALayerContentsGravity) {
        let rawValue = UIView.ContentMode.allCases.first(where: { $0.layerContentsGravity == contentsGravity })?.rawValue ?? UIView.ContentMode.scaleAspectFit.rawValue
        self.init(rawValue: rawValue)!
    }
}
#endif
