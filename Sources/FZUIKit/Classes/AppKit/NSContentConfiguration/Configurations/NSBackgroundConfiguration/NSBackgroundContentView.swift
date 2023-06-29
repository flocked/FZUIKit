//
//  File.swift
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
        get { _configuration }
        set {
            if let newValue = newValue as? NSBackgroundConfiguration {
                _configuration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSBackgroundConfiguration
    }
    
    /// Creates a background content view with the specified content configuration.
    public init(configuration: NSBackgroundConfiguration) {
        self._configuration = configuration
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
                self.imageView?.imageScaling = _configuration.imageScaling
            } else {
                self.imageView?.removeFromSuperview()
                self.imageView = nil
            }
        }
    }
    
    internal var _configuration: NSBackgroundConfiguration {
        didSet { if oldValue != _configuration {
            self.updateConfiguration() } } }
    
    internal func updateConfiguration() {
        self.view = _configuration.view
        self.image = _configuration.image
        
        imageView?.imageScaling = _configuration.imageScaling
        
        contentView.backgroundColor =  _configuration._resolvedColor
        contentView.visualEffect = _configuration.visualEffect
        contentView.cornerRadius = _configuration.cornerRadius
        
        contentView.configurate(using: _configuration.shadow)
        contentView.configurate(using: _configuration.border)
                
        contentViewConstraints[1].constant = -_configuration.insets.bottom
        contentViewConstraints[0].constant = _configuration.insets.leading
        contentViewConstraints[2].constant = -_configuration.insets.width
        contentViewConstraints[3].constant = -_configuration.insets.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif

