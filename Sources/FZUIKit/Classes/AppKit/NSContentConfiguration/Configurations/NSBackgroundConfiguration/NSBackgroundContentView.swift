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
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        self.contentViewConstraints = self.addSubview(withConstraint: contentView)
        self.updateConfiguration()
    }
    
    let contentView = NSView()
    var contentViewConstraints: [NSLayoutConstraint] = []
    
    var view: NSView? = nil {
        didSet {
            if oldValue != self.view {
                oldValue?.removeFromSuperview()
                if let view = self.view {
                    contentView.addSubview(withConstraint: view)
                }
            }
        }
    }
    var imageView: ImageView? = nil
    var image: NSImage? {
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
    
    var appliedConfiguration: NSBackgroundConfiguration {
        didSet { if oldValue != appliedConfiguration {
            self.updateConfiguration() } } }
    
    func updateConfiguration() {
        self.view = appliedConfiguration.view
        self.image = appliedConfiguration.image
        
        imageView?.imageScaling = appliedConfiguration.imageScaling
        
        contentView.backgroundColor =  appliedConfiguration._resolvedColor
        contentView.visualEffect = appliedConfiguration.visualEffect
        contentView.cornerRadius = appliedConfiguration.cornerRadius
        
        contentView.configurate(using: appliedConfiguration.shadow, type: .outer)
        contentView.configurate(using: appliedConfiguration.innerShadow, type: .inner)
        contentView.configurate(using: appliedConfiguration.border)

        contentViewConstraints.constant(appliedConfiguration.insets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif

