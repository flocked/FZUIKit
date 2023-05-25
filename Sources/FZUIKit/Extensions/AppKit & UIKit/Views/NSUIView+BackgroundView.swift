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

public protocol BackgroundViewSettable {
    var backgroundView: NSUIView? { get set }
}

extension NSUIView: BackgroundViewSettable {}

public extension BackgroundViewSettable where Self: NSUIView {
    internal var taggedBackgroundView: TaggedBackgroundView? {
        viewWithTag(TaggedBackgroundView.Tag) as? TaggedBackgroundView
    }

    var backgroundView: NSUIView? {
        get { taggedBackgroundView?.backgroundView }
        set {
            if let backgroundView = newValue {
                if let taggedBackgroundView = taggedBackgroundView {
                    if taggedBackgroundView.managedBackgroundView != backgroundView {
                        taggedBackgroundView.managedBackgroundView = backgroundView
                    }
                } else {
                    let taggedBackgroundView = TaggedBackgroundView(backgroundView)
                    insertSubview(taggedBackgroundView, at: 0)
                    //    self.addSubview(taggedBackgroundView, positioned: .below, relativeTo: nil)
                    taggedBackgroundView.constraint(to: self)
                }
            } else {
                taggedBackgroundView?.removeFromSuperview()
            }
        }
    }
}

#if os(macOS)
internal extension NSView {
    class TaggedBackgroundView: NSView {
        static var Tag: Int {
            return 16_034_522
        }

        override var tag: Int {
            return Self.Tag
        }

        var managedBackgroundView: NSView {
            didSet {
                oldValue.removeFromSuperview()
                addSubview(withConstraint: managedBackgroundView)
            }
        }

        init(_ backgroundView: NSView) {
            managedBackgroundView = backgroundView
            super.init(frame: .zero)
            addSubview(withConstraint: managedBackgroundView)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#elseif canImport(UIKit)
internal extension UIView {
    class TaggedBackgroundView: UIView {
        static var Tag: Int {
            return 16_034_522
        }

        override var tag: Int {
            get { return Self.Tag }
            set {}
        }

        var managedBackgroundView: UIView {
            didSet {
                oldValue.removeFromSuperview()
                addSubview(withConstraint: managedBackgroundView)
            }
        }

        init(_ backgroundView: UIView) {
            managedBackgroundView = backgroundView
            super.init(frame: .zero)
            addSubview(withConstraint: managedBackgroundView)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
#endif
