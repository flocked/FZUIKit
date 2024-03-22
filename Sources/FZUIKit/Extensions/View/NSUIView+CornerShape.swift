//
//  NSUIView+CornerShape.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

    extension NSUIView {
        /// The corner shape of a view.
        public enum CornerShape: Hashable {
            /// A rounded shape with corner radius equal to the specified value.
            case rounded(CGFloat)

            /// A rounded shape with corner radius relative to half the length of the view's smallest edge.
            case roundedRelative(CGFloat)

            /// A circular shape with corner radius equal to half the length of the view's smallest edge.
            case circular

            /// A capsule shape with corner radius equal to half the length of the view's smallest edge.
            case capsule

            var needsViewObservation: Bool {
                switch self {
                case .rounded: return false
                default: return true
                }
            }

            var clamped: Self {
                switch self {
                case let .roundedRelative(value): return .roundedRelative(value.clamped(to: 0.0...1.0))
                default: return self
                }
            }
        }

        /// The corner shape of the view.
        public var cornerShape: CornerShape? {
            get { getAssociatedValue("_cornerShape", initialValue: nil) }
            set {
                let newValue = newValue?.clamped
                setAssociatedValue(newValue, key: "_cornerShape")
                updateCornerShape()
                if newValue?.needsViewObservation == true {
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

        var cornerShapeBoundsObserver: KeyValueObservation? {
            get { getAssociatedValue("_cornerShapeBoundsObserver") }
            set { setAssociatedValue(newValue, key: "_cornerShapeBoundsObserver") }
        }

        func updateCornerShape() {
            guard let cornerShape = cornerShape else { return }
            switch cornerShape {
            case let .rounded(radius):
                cornerRadius = radius
            case let .roundedRelative(value):
                cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0 * value
            case .capsule:
                cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0
            case .circular:
                cornerRadius = min(bounds.size.height, bounds.size.width) / 2.0
            }
        }
    }
#endif
