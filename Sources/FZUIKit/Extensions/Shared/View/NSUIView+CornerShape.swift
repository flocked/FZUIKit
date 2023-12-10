//
//  NSUIView+CornerShape.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import AppKit
import FZSwiftUtils

public extension NSUIView {
    enum CornerShape: Hashable {
        /// A view with rounded shape.
        case rounded(CGFloat)
        /// A view with relative rounded shape.
        case roundedRelative(CGFloat)
        /// A view with circular shape.
        case circular
        /// A view with capsule shape.
        case capsule
        
        internal var clamped: Self {
            switch self {
            case .roundedRelative(let value): return .roundedRelative(value.clamped(max: 1.0))
            default: return self
            }
        }
    }
    
    /// The corner shape of the view.
    var cornerShape: CornerShape? {
        get { getAssociatedValue(key: "_cornerShape", object: self, initialValue: nil) }
        set {
            let newValue = newValue?.clamped
            set(associatedValue: newValue, key: "_cornerShape", object: self)
            if newValue != nil {
                updateCornerShape()
                if cornerShapeBoundsObserver == nil {
                    cornerShapeBoundsObserver = observeChanges(for: \.frame) { [weak self] old, new in
                        guard let self = self, old.size != new.size else { return }
                        self.updateCornerShape()
                    }
                }
            } else {
                cornerShapeBoundsObserver = nil
            }
        }
    }

    internal var cornerShapeBoundsObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_cornerShapeBoundsObserver", object: self) }
        set { set(associatedValue: newValue, key: "_cornerShapeBoundsObserver", object: self) }
    }
    
    internal func updateCornerShape() {
        guard let cornerShape = self.cornerShape else { return }
        switch cornerShape {
        case let .rounded(radius):
            cornerRadius = radius
        case let .roundedRelative(value):
            if bounds.height >= bounds.width {
                cornerRadius = (bounds.size.height / 2.0) * value
            } else {
                cornerRadius = (bounds.size.width / 2.0) * value
            }
        case .capsule:
            cornerRadius = bounds.size.height / 2.0
        case .circular:
            if bounds.height >= bounds.width {
                cornerRadius = bounds.size.height / 2.0
            } else {
                cornerRadius = bounds.size.width / 2.0
            }
        }
    }
}
#endif

/*
 /**
  The relative corner radius of the view between `0.0` and `1.0`.
  
  The corner radius gets automatically updated relative to the view's size.
  
  A relative corner radius of 0.25 in a view of size 100x100 translates to a corner radius of 12.5.
  
  A relative corner radius of 1.0 will present
  
  */
 var relativeCornerRadius: CGFloat? {
     get { getAssociatedValue(key: "relativeCornerRadius", object: self, initialValue: nil) }
     set {
         let newValue = newValue?.clamped(max: 1.0)
         set(associatedValue: newValue, key: "_cornerShape", object: self)
         if let relativeCornerRadius = newValue {
             relativeCornerRadiusObserver = observeChanges(for: \.frame) { [weak self] _, bounds in
                 guard let self = self else { return }
                 if bounds.height >= bounds.width {
                     cornerRadius = (bounds.size.height / 2.0) * relativeCornerRadius
                 } else {
                     cornerRadius = (bounds.size.width / 2.0) * relativeCornerRadius
                 }
             }
         } else {
             relativeCornerRadiusObserver = nil
         }
     }
 }
 
 internal var relativeCornerRadiusObserver: NSKeyValueObservation? {
     get { getAssociatedValue(key: "relativeCornerRadiusObserver", object: self) }
     set { set(associatedValue: newValue, key: "relativeCornerRadiusObserver", object: self) }
 }
 */
