//
//  NSUIView+Constraints.swift
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

    public extension NSUIView {
        /// Constants how a view is constraint.
        enum ConstraintMode {
            public enum Position: Int {
                case top
                case topLeft
                case topRight
                case center
                case centerLeft
                case centerRight
                case bottom
                case bottomLeft
                case bottomRight
            }

            case relative
            /// The view's frame is constraint to the edges of the other view.
            case absolute
            /// The view's frame is constraint to the edges of the other view.
            case full
            /// The view's frame is constraint to the edges of the other view with the specified insets.
            case insets(NSUIEdgeInsets)
            case positioned(Position, padding: CGFloat = 0)
            var padding: CGFloat? {
                switch self {
                case let .positioned(_, padding): return padding
                default: return nil
                }
            }
        }

        /**
         Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.

         - Parameter view: The view to be added. After being added, this view appears on top of any other subviews.
         - Returns: The layout constraints in the following order: bottom, left, width and height.
         */
        @discardableResult
        func addSubview(withConstraint view: NSUIView) -> [NSLayoutConstraint] {
            addSubview(withConstraint: view, .full)
        }

        /**
         Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver using the specified mode.

         - Parameters:
            - view: The view to be added. After being added, this view appears on top of any other subviews.
            - mode: The mode for constraining the subview's frame.

         - Returns: The layout constraints in the following order: bottom, left, width and height.
         */
        @discardableResult
        func addSubview(withConstraint view: NSUIView, _ mode: ConstraintMode) -> [NSLayoutConstraint] {
            addSubview(view)
            return view.constraint(to: self, mode)
        }

        /**
         Inserts the view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.

         - Parameters:
            - view: The view to insert.
            - index: The index of insertation.

         - Returns: The layout constraints in the following order: bottom, left, width and height.
         */
        @discardableResult

        func insertSubview(withConstraint view: NSUIView, at index: Int) -> [NSLayoutConstraint] {
            insertSubview(withConstraint: view, .full, at: index)
        }

        /**
         Inserts the view to the end of the receiver’s list of subviews and constraits it's frame to the receiver using the specified mode.

         - Parameters:
            - view: The view to insert.
            - index: The index of insertation.
            - mode: The mode for constraining the subview's frame.

         - Returns: The layout constraints in the following order: bottom, left, width and height.
         */
        @discardableResult
        func insertSubview(withConstraint view: NSUIView, _ mode: ConstraintMode, at index: Int) -> [NSLayoutConstraint] {
            guard index >= 0 else { return [] }
            insertSubview(view, at: index)
            return view.constraint(to: self, mode)
        }

        /**
         Constraits the view's frame to the superview.

         - Parameter view: The mode for constraining the subview's frame.
         - Returns: The layout constraints in the following order: bottom, left, width and height.
         */
        @discardableResult
        func constraintToSuperview(_ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
            guard let superview = superview else { return [] }
            return constraint(to: superview, mode)
        }

        /**
         Constraits the view's frame to the specified view.

         - Parameters:
            - view: The view to be constraint to.
            - mode: The mode for constraining the subview's frame.

         - Returns: The layout constraints in the following order: bottom, left, width and height.
         */
        @discardableResult
        func constraint(to view: NSUIView, _ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
            let constants: [CGFloat]

            switch mode {
            case .absolute:
                constants = calculateConstants(view)
            case let .insets(insets):
                constants = [insets.left, insets.bottom, 0.0 - insets.right, 0.0 - insets.top]
            default:
                constants = [0, 0, 0, 0]
            }
            let multipliers: [CGFloat]
            switch mode {
            case .relative: multipliers = calculateMultipliers(self)
            default: multipliers = [1.0, 1.0, 1.0, 1.0]
            }

            switch mode {
            case .full: frame = view.bounds
            default: break
            }

            translatesAutoresizingMaskIntoConstraints = false

            var constraints: [NSLayoutConstraint] = []
            switch mode {
            case let .positioned(position, padding):
                switch position {
                case .top, .topLeft, .topRight:
                    constraints.append(topAnchor.constraint(equalTo: view.topAnchor, constant: padding))
                case .center, .centerLeft, .centerRight:
                    constraints.append(centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0))
                case .bottomLeft, .bottom, .bottomRight:
                    constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding))
                }
                constraints.append(widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(padding * 2.0)))
                constraints.append(heightAnchor.constraint(equalToConstant: view.frame.size.height))
            default:
                constraints.append(contentsOf: [
                    .init(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: multipliers[0], constant: constants[0]),
                    .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: multipliers[1], constant: constants[1]),
                    .init(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: multipliers[2], constant: constants[2]),
                    .init(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: multipliers[3], constant: constants[3]),
                ])
            }

            NSLayoutConstraint.activate(constraints)
            return constraints
        }

        #if os(macOS)
            /**
             Adds a view to the end of the receiver’s list of subviews and autoresizes it.

             - Parameter view: The view to be added. After being added, this view appears on top of any other subviews.
             */
            func addSubview(withAutoresizing view: NSView) {
                addSubview(withAutoresizing: view, mode: .full)
            }

            /**
             Adds a view to the end of the receiver’s list of subviews and autoresizes it to the receiver.

             - Parameters:
                - view: The view to be added. After being added, this view appears on top of any other subviews.
                - mode: The mode for autoresizing the subview..
             */
            func addSubview(withAutoresizing view: NSUIView, mode: ConstraintMode) {
                view.translatesAutoresizingMaskIntoConstraints = true
                addSubview(view)
                view.autoresize(to: view, using: mode)
            }

            /**
             Inserts the view to the end of the receiver’s list of subviews and autoresizes it to the receiver.

             - Parameters:
                - view: The view to insert.
                - index: The index of insertation.
                - mode: The mode for autoresizing the subview..
             */
            func insertSubview(withAutoresizing view: NSUIView, _ mode: ConstraintMode, to index: Int) {
                guard index >= 0 else { return }
                addSubview(withAutoresizing: view, mode: mode)
                moveSubview(view, to: index)
            }

            func autoresize(to view: NSView, using mode: ConstraintMode) {
                translatesAutoresizingMaskIntoConstraints = true
                switch mode {
                case .full:
                    frame = view.bounds
                case let .insets(insets):
                    let width = insets.right - insets.left
                    let height = insets.top - insets.bottom
                    frame = CGRect(x: insets.bottom, y: insets.left, width: width, height: height)
                default:
                    break
                }

                if case .relative = mode {
                    autoresizingMask = [.height, .width]
                } else {
                    autoresizingMask = .all
                }
            }
        #endif

        internal func calculateMultipliers(_ view: NSUIView) -> [CGFloat] {
            let x = view.frame.x / bounds.width
            let y = view.frame.y / bounds.height
            let width = view.frame.width / bounds.width
            let height = view.frame.height / bounds.height
            return [x, y, width, height]
        }

        internal func calculateConstants(_ view: NSUIView) -> [CGFloat] {
            let x = view.frame.minX
            let y = -view.frame.minY
            let width = view.frame.width - bounds.width
            let height = view.frame.height - bounds.height
            return [x, y, width, height]
        }
    }

#endif
