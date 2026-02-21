//
//  NSUIView+Drag.swift
//  Tester
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils


public extension NSUIView {

    /// A value indicating whether a view is movable by clicking and dragging anywhere in its background.
    enum BackgroundDragOption: Hashable, ExpressibleByBooleanLiteral {
        /// The view is movable.
        case enabled
        /// The view isn't movable.
        case disabled
        /// The view is movable, but constrained to the superview edges with the specified margins.
        case constrainedToSuperview(margins: NSDirectionalEdgeInsets)
        /// The view is movable, but constrained to the superview edges.
        public static let constrainedToSuperview = Self.constrainedToSuperview(margins: .zero)

        var margins: NSDirectionalEdgeInsets? {
            switch self {
            case .constrainedToSuperview(let margins): margins
            default: nil
            }
        }
        
        public init(booleanLiteral value: Bool) {
            self = value == true ? .enabled : .disabled
        }
    }

    /// A value indicating whether the view is movable by clicking and dragging anywhere in its background.
    var isMovableByViewBackground: BackgroundDragOption {
        get { getAssociatedValue("isMovableByViewBackground") ?? .disabled }
        set {
            guard newValue != isMovableByViewBackground else { return }
            setAssociatedValue(newValue, key: "isMovableByViewBackground")
            setupDragResizeGesture()
        }
    }

    /// A handler that provides the velocity of the dragging of the view by it's background when ``isMovableByViewBackground`` is enabled.
    var backgroundDragVelocity: ((_ state: NSUIGestureRecognizer.State, _ velocity: CGPoint) -> Void)? {
        get { getAssociatedValue("movableByBackgroundVelocity") }
        set { setAssociatedValue(newValue, key: "movableByBackgroundVelocity") }
    }

    internal func setupDragResizeGesture() {
        if isMovableByViewBackground != .disabled {
            if panGesture == nil {
                let gesture = NSUIPanGestureRecognizer { [weak self] gesture in
                    guard let self = self else { return }
                    let velocity = gesture.velocity(in: self)
                    switch gesture.state {
                    case .began:                        
                        self.backgroundDragVelocity?(.began, velocity)
                        self.dragPoint = self.frame.origin
                    case .ended:
                        self.backgroundDragVelocity?(.ended, velocity)
                        self.dragPoint = self.frame.origin
                    case .changed:
                        self.backgroundDragVelocity?(.changed, velocity)
                        let translation = gesture.translation(in: self)
                        var dragPoint = self.dragPoint
                        dragPoint.x += translation.x
                        #if os(macOS)
                        dragPoint.y += translation.y
                        #else
                        dragPoint.y += translation.y
                        #endif
                        self.frame.origin = dragPoint
                        if var margins = self.isMovableByViewBackground.margins {
                            margins.leading += self.border.width
                            margins.trailing += self.border.width
                            margins.bottom += border.width
                            margins.top += border.width
                            if self.frame.origin.x < 0 + margins.leading {
                                self.frame.origin.x = 0 + margins.leading
                            }
                            if self.frame.origin.y < 0 + margins.bottom {
                                self.frame.origin.y = 0 + margins.bottom
                            }
                            if let superview = self.superview {
                                if self.frame.origin.x > superview.bounds.width - self.frame.width - margins.trailing {
                                    self.frame.origin.x = superview.bounds.width - self.frame.width - margins.trailing
                                }
                                if self.frame.origin.y > superview.bounds.height - self.frame.height - margins.top {
                                    self.frame.origin.y = superview.bounds.height - self.frame.height - margins.top
                                }
                            }
                        }
                    default:
                        break
                    }
                }
                gesture.handlers.shouldBegin = { [weak self] in
                    guard let self = self, let superview = self.superview else { return false }
                    let location = gesture.location(in: superview)
                    return self.hitTest(location)?.isInteractive ?? false == false
                }
                panGesture = gesture
                addGestureRecognizer(gesture)
            }
        } else {
            if let panGesture = panGesture {
                removeGestureRecognizer(panGesture)
                self.panGesture = nil
            }
        }
    }

    private var isInteractive: Bool {
        if self is NSUIControl { return true }
        if self is NSUIScrollView { return true }
        if self is NSUITextView { return true }
        if self is NSUITableView { return true }
        if self is NSUICollectionView { return true }
        return false
    }

    private var dragPoint: CGPoint {
        get { getAssociatedValue("dragPoint", initialValue: .zero) }
        set { setAssociatedValue(newValue, key: "dragPoint") }
    }

    private var panGesture: NSUIPanGestureRecognizer? {
        get { getAssociatedValue("panGesture") }
        set { setAssociatedValue(newValue, key: "panGesture") }
    }
}

#endif
