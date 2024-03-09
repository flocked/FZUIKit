//
//  SimpleStackView.swift
//
//
//  Created by Florian Zand on 18.06.23.
//

#if os(macOS)
    import AppKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif
import FZSwiftUtils

#if os(macOS) || os(iOS) || os(tvOS)
    /**
     A view that arranges an array of views horizontally or vertically and updates their placement and sizing when the window size changes.

     It's a simplified stack view compared to NSStackView.
     */
    public class SimpleStackView: NSUIView {
        /// The distribution for an arranged subview.
        public enum ViewDistribution: Int {
            /// The view fills the total stack view orientation (default).
            case fill
            /// The view is centered at the stack view orientation.
            case center
            /// The view is leading at the stack view orientation.
            case leading
            /// The view is trailing the stack view orientation.
            case trailing
            /// The view is distributed to the first baseline, This distribution only works when the stack view orientation is set to horizontal.
            case firstBaseline
        }

        /// The array of views arranged by the stack view.
        public var arrangedSubviews: [NSUIView] = [] {
            didSet {
                if oldValue != arrangedSubviews {
                    setupManagedViews(previous: oldValue)
                }
            }
        }

        /// The horizontal or vertical layout direction of the stack view.
        public var orientation: NSUIUserInterfaceLayoutOrientation = .vertical {
            didSet {
                if oldValue != orientation {
                    updateViewConstraints()
                }
            }
        }

        /// The spacing between views in the stack view.
        public var spacing: CGFloat = 2.0 {
            didSet {
                if oldValue != spacing {
                    updateSpacing()
                }
            }
        }

        /// Sets the distribution for all arranged subviews. The default value is fill.
        public func setDistribution(_ distribution: ViewDistribution) {
            for subview in arrangedSubviews {
                setDistribution(distribution, for: subview)
            }
        }

        /// Sets the distribution for an arranged subview. The default value is fill.
        public func setDistribution(_ distribution: ViewDistribution, for arrangedSubview: NSUIView) {
            guard arrangedSubviews.contains(arrangedSubview) else { return }
            let id = ObjectIdentifier(arrangedSubview).hashValue
            guard viewDistributions[id] != distribution else { return }
            viewDistributions[id] = distribution
            updateViewConstraints()
        }

        /**
         Creates and returns a stack view with a specified array of views.

         - Parameter views: The array of views for the new stack view.
         - Returns: A stack view initialized with the specified array of views.
         */
        public init(views: [NSUIView]) {
            super.init(frame: .zero)
            arrangedSubviews = views
            setupManagedViews()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var viewObservers: [Int: KeyValueObservation] = [:]
        var viewDistributions: [Int: ViewDistribution] = [:]

        func setupManagedViews(previous: [NSUIView] = []) {
            var removedViews: [NSUIView] = []
            var newViews: [NSUIView] = []
            for oldView in previous {
                if arrangedSubviews.contains(oldView) == false {
                    removedViews.append(oldView)
                }
            }
            for managedView in arrangedSubviews {
                if previous.contains(managedView) == false {
                    newViews.append(managedView)
                }
            }
            removedViews.forEach {
                $0.removeFromSuperview()
                self.removeObserver(for: $0)
                self.viewDistributions[ObjectIdentifier($0).hashValue] = nil
            }

            newViews.forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                self.addObserver(for: $0)
                self.viewDistributions[ObjectIdentifier($0).hashValue] = .fill
                self.addSubview($0)
            }

            updateViewConstraints()
        }

        func addObserver(for view: NSUIView) {
            let id = ObjectIdentifier(view).hashValue
            viewObservers[id] = view.observeChanges(for: \.isHidden, handler: { [weak self] old, new in
                guard let self = self else { return }
                if old != new {
                    self.updateViewConstraints()
                }
            })
        }

        func removeObserver(for view: NSUIView) {
            let id = ObjectIdentifier(view).hashValue
            viewObservers[id] = nil
        }

        var viewConstraints: [NSLayoutConstraint] = []

        func updateSpacing() {
            viewConstraints.filter {
                if self.orientation == .vertical {
                    return $0.firstAttribute == .top
                } else {
                    return $0.firstAttribute == .leading
                }
            }.forEach { $0.constant = spacing }

            viewConstraints.filter {
                if self.orientation == .vertical {
                    return $0.firstAttribute == .bottom
                } else {
                    return $0.firstAttribute == .trailing
                }
            }.forEach { $0.constant = -spacing }
        }

        override public var intrinsicContentSize: CGSize {
            sizeThatFits(CGSize(width: NSUIView.noIntrinsicMetric, height: NSUIView.noIntrinsicMetric))
        }

        func _sizeThatFits(_ size: CGSize) -> CGSize {
            var fittingSize: CGSize?
            if orientation == .vertical, size.width != .zero {
                let originalWidthConstraint: NSLayoutConstraint? = constraints.first(where: { $0.firstAttribute == .width
                        || $0.secondAttribute == .width
                })
                originalWidthConstraint?.isActive = false
                let widthConstraint = widthAnchor.constraint(equalToConstant: (size.width == .infinity || size.width == NSUIView.noIntrinsicMetric) ? 10000 : size.width)
                widthConstraint.isActive = true
                fittingSize = self.fittingSize
                widthConstraint.isActive = false
                originalWidthConstraint?.isActive = true
            } else if orientation == .horizontal, size.height != .zero {
                let originalHeightConstraint: NSLayoutConstraint? = constraints.first(where: { $0.firstAttribute == .height
                        || $0.secondAttribute == .height
                })
                originalHeightConstraint?.isActive = false
                let heightConstraint = heightAnchor.constraint(equalToConstant: (size.height == .infinity || size.height == NSUIView.noIntrinsicMetric) ? 10000 : size.height)
                heightConstraint.isActive = true
                fittingSize = self.fittingSize
                heightConstraint.isActive = false
                originalHeightConstraint?.isActive = true
            }
            return fittingSize ?? self.fittingSize
        }

        #if os(macOS)
            public func sizeThatFits(_ size: CGSize) -> CGSize {
                _sizeThatFits(size)
            }

        #elseif canImport(UIKit)
            override public func sizeThatFits(_ size: CGSize) -> CGSize {
                _sizeThatFits(size)
            }
        #endif

        func updateViewConstraints() {
            NSLayoutConstraint.deactivate(viewConstraints)
            viewConstraints.removeAll()
            var nextAnchorView: NSUIView = self
            let nonHiddenViews = arrangedSubviews.filter { $0.isHidden == false }
            for (index, managedView) in nonHiddenViews.enumerated() {
                let distribution = viewDistributions[ObjectIdentifier(managedView).hashValue] ?? .fill
                if orientation == .vertical {
                    var constraints = [
                        managedView.topAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.topAnchor : nextAnchorView.bottomAnchor, constant: spacing),
                    ]
                    switch distribution {
                    case .fill:
                        constraints.append(managedView.leadingAnchor.constraint(equalTo: leadingAnchor))
                        constraints.append(managedView.widthAnchor.constraint(equalTo: widthAnchor))
                    case .leading:
                        constraints.append(managedView.leadingAnchor.constraint(equalTo: leadingAnchor))
                        constraints.append(managedView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor))
                    case .trailing:
                        constraints.append(managedView.trailingAnchor.constraint(equalTo: trailingAnchor))
                        constraints.append(managedView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor))
                    case .center:
                        constraints.append(managedView.centerXAnchor.constraint(equalTo: centerXAnchor))
                        constraints.append(managedView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor))
                    default:
                        break
                    }
                    if index == nonHiddenViews.count - 1 {
                        constraints.append(managedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacing))
                    }
                    nextAnchorView = managedView
                    viewConstraints.append(contentsOf: constraints)
                } else {
                    var constraints = [
                        managedView.leadingAnchor.constraint(equalTo: (nextAnchorView == self) ? nextAnchorView.leadingAnchor : nextAnchorView.trailingAnchor, constant: spacing),
                    ]
                    switch distribution {
                    case .fill:
                        constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        constraints.append(managedView.heightAnchor.constraint(equalTo: heightAnchor))
                    case .leading:
                        constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .trailing:
                        constraints.append(managedView.bottomAnchor.constraint(equalTo: bottomAnchor))
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .center:
                        constraints.append(managedView.centerYAnchor.constraint(equalTo: centerYAnchor))
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    case .firstBaseline:
                        if index < nonHiddenViews.count - 1 {
                            let otherManagedView = nonHiddenViews[index + 1]
                            constraints.append(managedView.firstBaselineAnchor.constraint(equalTo: otherManagedView.firstBaselineAnchor))
                        } else if index > 0 {
                            let otherManagedView = nonHiddenViews[index - 1]
                            constraints.append(managedView.firstBaselineAnchor.constraint(equalTo: otherManagedView.firstBaselineAnchor))
                        } else {
                            constraints.append(managedView.topAnchor.constraint(equalTo: topAnchor))
                        }
                        constraints.append(managedView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor))
                    }
                    if index == nonHiddenViews.count - 1 {
                        constraints.append(managedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing))
                    }
                    nextAnchorView = managedView
                    viewConstraints.append(contentsOf: constraints)
                }
            }
            NSLayoutConstraint.activate(viewConstraints)
        }
    }
#endif
