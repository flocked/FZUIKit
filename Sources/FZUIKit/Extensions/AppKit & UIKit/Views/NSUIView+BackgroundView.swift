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

internal extension NSUIView {
    var taggedBackgroundView: TaggedBackgroundView? {
        viewWithTag(TaggedBackgroundView.Tag) as? TaggedBackgroundView
    }
}

public extension NSUIView {
    /**
     Creates a view with the specified background color.
     
     - Parameters color: The background color of the view.
     - Returns: An initialized view object.
     */
    convenience init(color: NSUIColor) {
        self.init(frame: .zero)
        self.backgroundColor = color
    }
    
    /**
     Creates a view with the specified background color and frame rectangle.
     
     - Parameters color: The background color of the view.
     - Parameters frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
     - Returns: An initialized view object.
     */
    convenience init(color: NSUIColor, frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = color
    }
}

public extension BackgroundViewSettable where Self: NSUIView {
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
                    self.insertSubview(withConstraint: taggedBackgroundView, at: 0)
                }
            } else {
                taggedBackgroundView?.removeFromSuperview()
            }
        }
    }
}

internal extension NSUIView {
    class TaggedBackgroundView: NSUIView, BackgroundViewSettable {
        static var Tag: Int {
            return 16034522
        }

        #if os(macOS)
        override var tag: Int {
            return Self.Tag
        }
        #else
        override var tag: Int {
            get { return Self.Tag }
            set {}
        }
        #endif

        var managedBackgroundView: NSUIView {
            didSet {
                if (oldValue != managedBackgroundView) {
                    oldValue.removeFromSuperview()
                    addSubview(withConstraint: managedBackgroundView)
                }
            }
        }

        init(_ backgroundView: NSUIView) {
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
