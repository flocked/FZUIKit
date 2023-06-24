//
//  UIContentUnavailableView.swift
//  NSContentUnavailableConfiguration
//
//  Created by Florian Zand on 24.06.23.
//

/*
#if os(macOS)
import AppKit
import FZUIKit
import SwiftUI

public class NSContentUnavailableView: NSView, NSContentView {
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSContentUnavailableConfiguration {
                _configuration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSContentUnavailableConfiguration
    }
    
    /// Creates a background content view with the specified content configuration.
    public init(configuration: NSContentUnavailableConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        
        self.addSubview(withConstraint: backgroundView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextField.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
        

        
        
    //    stackViewConstraints = self.addSubview(withConstraint: stackView)
        self.updateConfiguration()
    }
    
    var stackViewConstraints: [NSLayoutConstraint] = []
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var _configuration: NSContentUnavailableConfiguration {
        didSet { if oldValue != _configuration {
            self.updateConfiguration() } } }
    
    internal func updateConfiguration() {
        stackView.setCustomSpacing(_configuration.imageToTextPadding, after: imageView)
        stackView.setCustomSpacing(_configuration.textToSecondaryTextPadding, after: textField)
        imageView.properties = _configuration.imageProperties
        textField.properties = _configuration.textProperties
        secondaryTextField.properties = _configuration.secondaryTextProperties
        
        imageView.image = _configuration.image
        textField.text(_configuration.text, attributedString: _configuration.attributedText)
        secondaryTextField.text(_configuration.secondaryText, attributedString: _configuration.secondaryAttributedText)
        
        backgroundView.configuration = _configuration.background
        if _configuration.isLoadingConfiguration {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
                
        progressIndicator.isHidden = !_configuration.isLoadingConfiguration
        
        stackView.invalidateIntrinsicContentSize()

        /*
        stackViewConstraints[0].constant = _configuration.directionalLayoutMargins.leading
        stackViewConstraints[1].constant = _configuration.directionalLayoutMargins.bottom
        stackViewConstraints[2].constant = _configuration.directionalLayoutMargins.trailing
        stackViewConstraints[3].constant = _configuration.directionalLayoutMargins.top
*/
    }
    
    internal lazy var textField = ContentTextField(properties: self._configuration.textProperties)
    internal lazy var secondaryTextField = ContentTextField(properties: self._configuration.secondaryTextProperties)
    internal lazy var imageView = ContentImageView(properties: self._configuration.imageProperties)
    internal lazy var progressIndicator: NSProgressIndicator = {
        var progressIndicator = NSProgressIndicator()
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .large
        progressIndicator.isDisplayedWhenStopped = false
        return progressIndicator
    }()
    
    internal lazy var backgroundView: (NSView & NSContentView) = _configuration.background.makeContentView()

    
    internal lazy var stackView: NSStackView = {
        var stackView = NSStackView(views: [imageView, textField, secondaryTextField])
        stackView.orientation = .vertical
        stackView.spacing = 0
        
        stackView.setCustomSpacing(_configuration.imageToTextPadding, after: imageView)
       stackView.setCustomSpacing(_configuration.textToSecondaryTextPadding, after: textField)

        stackView.alignment = .centerX
        stackView.distribution = .fillEqually
        return stackView
    }()
    
}


internal extension NSContentUnavailableView {
    class ContentButton: NSButton {
        
    }
    
    class ContentTextField: NSTextField {
        var properties: NSContentUnavailableConfiguration.TextProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func text(_ text: String?, attributedString: AttributedString?) {
            if let attributedString = attributedString {
                self.isHidden = false
                self.attributedStringValue = NSAttributedString(attributedString)
            } else if let text = text {
                self.stringValue = text
                self.isHidden = false
            } else {
                self.stringValue = ""
                self.isHidden = true
            }
        }
        
        func update() {
            self.maximumNumberOfLines = properties.maxNumberOfLines
            self.textColor = properties.color
            self.lineBreakMode = properties.lineBreakMode
            self.font = properties.font
            self.alignment = .center
           
        }
        
        init(properties: NSContentUnavailableConfiguration.TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.isSelectable = false
            self.isEditable = false
            self.drawsBackground = false
            self.backgroundColor = nil
            self.isBordered = false
            self.textLayout = .wraps
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    class ContentImageView: NSImageView {
        var properties: NSContentUnavailableConfiguration.ImageProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        override var image: NSImage? {
            didSet {
                self.isHidden = (self.image == nil)
                if let image = image {
                    let width = image.alignmentRect.size.height*2.0
                    var origin = self.frame.origin
                    origin.x = width - image.alignmentRect.size.width
                    self.frame.origin = origin
                    Swift.print(image.alignmentRect)
                }
            }
        }
    
        
        func update() {
            self.imageScaling = properties.scaling
            self.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            self.contentTintColor = properties.tintColor
            self.cornerRadius = properties.cornerRadius
            
            var width: CGFloat? =  image?.size.width
            var height: CGFloat? =  image?.size.height
            if let maxWidth = properties.maxWidth, let _width = width {
                width = max(_width, maxWidth)
            }
            
            if let maxHeight = properties.maxHeight, let _height = height {
                height = max(_height, maxHeight)
            }
            
            /*
            if let pointSize = self.properties.symbolConfiguration?.font?.pointSize {
              //  width = pointSize * 2
            }
             */
            
            if let width = width {
                widthA = self.widthAnchor.constraint(equalToConstant: width)
                widthA?.isActive = true
            } else {
                widthA?.isActive = false
            }

            if let height = height {
                heightA = self.heightAnchor.constraint(equalToConstant: height)
                heightA?.isActive = true
            } else {
                heightA?.isActive = false
            }
            
        }
        
        var widthA: NSLayoutConstraint? = nil
        var heightA: NSLayoutConstraint? = nil

        init(properties: NSContentUnavailableConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.imageAlignment = .alignCenter
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
#endif
*/
