//
//  NSBackgroundContentView.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//


#if os(macOS)
import AppKit
import FZSwiftUtils

public class NSBackgroundView: NSView, NSContentView {
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            if let newValue = newValue as? NSBackgroundConfiguration {
                appliedConfiguration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSBackgroundConfiguration
    }
    
    /// Creates a background content view with the specified content configuration.
    public init(configuration: NSBackgroundConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        self.maskToBounds = false
        self.contentView.maskToBounds = false
        self.contentViewConstraints = self.addSubview(withConstraint: contentView)
        self.updateConfiguration()
    }
    
    internal let contentView = NSView()
    internal var contentViewConstraints: [NSLayoutConstraint] = []
    
    internal var view: NSView? = nil {
        didSet {
            if oldValue != self.view {
                oldValue?.removeFromSuperview()
                if let view = self.view {
                    contentView.addSubview(withConstraint: view)
                }
            }
        }
    }
    internal var imageView: ImageView? = nil
    internal var image: NSImage? {
        get { imageView?.image }
        set {
            guard newValue != imageView?.image else { return }
            if let image = newValue {
                if (self.imageView == nil) {
                    let imageView = ImageView()
                    self.imageView = imageView
                    contentView.addSubview(withConstraint: imageView)
                }
                self.imageView?.image = image
                self.imageView?.imageScaling = appliedConfiguration.imageScaling
            } else {
                self.imageView?.removeFromSuperview()
                self.imageView = nil
            }
        }
    }
    
    internal var appliedConfiguration: NSBackgroundConfiguration {
        didSet { if oldValue != appliedConfiguration {
            self.updateConfiguration() } } }
    
    internal func updateConfiguration() {
        self.view = appliedConfiguration.view
        self.image = appliedConfiguration.image
        
        imageView?.imageScaling = appliedConfiguration.imageScaling
        
        contentView.backgroundColor =  appliedConfiguration._resolvedColor
        contentView.visualEffect = appliedConfiguration.visualEffect
        contentView.cornerRadius = appliedConfiguration.cornerRadius
        
        contentView.configurate(using: appliedConfiguration.shadow)
        contentView.configurate(using: appliedConfiguration.innerShadow)
        contentView.configurate(using: appliedConfiguration.border)
        
        contentViewConstraints.padding = appliedConfiguration.insets
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension Collection where Element: NSLayoutConstraint, Index == Int  {
    var padding: NSDirectionalEdgeInsets {
        get {
            var insets = NSDirectionalEdgeInsets(top: 0, leading: leftAnchor?.constant ?? 0, bottom: bottomAnchor?.constant ?? 0, trailing: 0)
            insets.width = widthAnchor?.constant ?? 0
            insets.height = heightAnchor?.constant ?? 0
            return insets
        }
        set {
            leftAnchor?.constant = newValue.leading
            bottomAnchor?.constant = newValue.bottom
            widthAnchor?.constant = -newValue.width
            heightAnchor?.constant = -newValue.height
        }
    }
    
    var leftAnchor: NSLayoutConstraint? {
        guard let constraint = self[safe: 0], constraint.firstAttribute == .left else { return nil }
        return constraint
    }
    
    var bottomAnchor: NSLayoutConstraint? {
        guard let constraint = self[safe: 1], constraint.firstAttribute == .bottom else { return nil }
        return constraint
    }
    
    var widthAnchor: NSLayoutConstraint? {
        guard let constraint = self[safe: 2], constraint.firstAttribute == .width else { return nil }
        return constraint
    }
    
    var heightAnchor: NSLayoutConstraint? {
        guard let constraint = self[safe: 3], constraint.firstAttribute == .height else { return nil }
        return constraint
    }
}

/*
 let left: NSLayoutConstraint = .init(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: multipliers[0], constant: constants[0])
 let bottom: NSLayoutConstraint = .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: multipliers[1], constant: constants[1])
 let width: NSLayoutConstraint = .init(item: self, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: multipliers[2], constant: constants[2])
 let height: NSLayoutConstraint = .init(item: self, attribute: .height, relatedBy: .equal, toItem: view, attribut
 */

#endif

