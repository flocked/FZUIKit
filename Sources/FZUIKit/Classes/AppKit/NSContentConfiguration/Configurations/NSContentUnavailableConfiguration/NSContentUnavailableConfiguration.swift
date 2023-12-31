//
//  NSContentUnavailableConfiguration.swift
//  
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
import AppKit

/**
 A content configuration for a content-unavailable view.
 
 A content-unavailable configuration is a composable description of a view that indicates your app can’t display content. Using a content-unavailable configuration, you can obtain system default styling for a variety of different empty states. Fill the configuration with placeholder content, and then assign it to a view’s contentUnavailableConfiguration, or to a NSContentUnavailableView.
 */
@available(macOS 12.0, *)
public struct NSContentUnavailableConfiguration: NSContentConfiguration, Hashable {    
    /// The image to display.
    public var image: NSImage? = nil
    
    /// The primary text to display.
    public var text: String? = nil

    /// An attributed variant of the primary text.
    public var attributedText: NSAttributedString? = nil
    
    /// The secondary text to display.
    public var secondaryText: String? = nil
    
    /// An attributed variant of the secondary text.
    public var secondaryAttributedText: NSAttributedString? = nil
    
    /// The button configuration.
    public var button: ButtonConfiguration? = nil
    
    /// The secondary button configuration.
    public var secondaryButton: ButtonConfiguration? = nil
    
    /// The configuration for the image.
    public var imageProperties: ImageProperties = ImageProperties()
    
    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = .primary()
    
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: TextProperties = .secondary()
    
    /// The configuration for the background.
    public var background: NSBackgroundConfiguration = .clear()
    
    /// The margins between the content and the edges of the content view.
    public var directionalLayoutMargins: NSDirectionalEdgeInsets = .init(6.0)
    
    /// The padding between the image and the primary text.
    public var imageToTextPadding: CGFloat = 6.0
    
    /// The padding between the primary and secondary text.
    public var textToSecondaryTextPadding: CGFloat = 2.0
    
    /// The padding between the text and buttons.
    public var textToButtonPadding: CGFloat = 4.0
    
    /// The padding between the primary button and secondary button.
    public var buttonToSecondaryButtonPadding: CGFloat = 4.0
    
    /**
     The orientation of the buttons.
     
     If `vertical` the secondary button is placed  next to the primary button, if `horizontal` it's placed below the primary button.
     */
    public var buttonOrientation: NSUIUserInterfaceLayoutOrientation = .vertical
    
    var displayLoadingIndicator: Bool = false
    
    public func makeContentView() -> NSView & NSContentView {
        NSContentUnavailableView(configuration: self)
    }
    
    public func updated(for state: FZUIKit.NSConfigurationState) -> NSContentUnavailableConfiguration {
        return self
    }
    
    var hasText: Bool {
        self.text != nil || self.attributedText != nil
    }
    
    var hasSecondaryText: Bool {
        self.secondaryText != nil || self.secondaryAttributedText != nil
    }
}

@available(macOS 12.0, *)
public extension NSContentUnavailableConfiguration {
    /// Creates the default configuration for unavailable content.
    static func empty() -> NSContentUnavailableConfiguration {
        NSContentUnavailableConfiguration()
    }
    
    /// Creates the default configuration for content that’s loading.
    static func loading() -> NSContentUnavailableConfiguration {
        var configuration = NSContentUnavailableConfiguration()
        configuration.textProperties = .body()
        configuration.secondaryTextProperties = configuration.textProperties
        configuration.displayLoadingIndicator = true
        return configuration
    }
    
    /// Creates the default configuration for searches that return no results.
    static func search() -> NSContentUnavailableConfiguration {
        var configuration = NSContentUnavailableConfiguration()
        configuration.textProperties.font = .headline.weight(.semibold)
        configuration.secondaryTextProperties.font = .subheadline
        configuration.imageProperties.symbolConfiguration = .font(.largeTitle)
        configuration.image = NSImage(systemSymbolName: "magnifyingglass")
        return configuration
    }
    
    /// Creates the default configuration for drag and drop of files.
    static func dropFiles(fileExtensions: [String]?, buttonHandler:(()->())?) -> NSContentUnavailableConfiguration {
        var configuration = NSContentUnavailableConfiguration()
        configuration.textProperties.font = .headline.weight(.semibold)
        configuration.textProperties.font = .title3
        configuration.imageProperties.symbolConfiguration = .font(size: 40)
        configuration.imageToTextPadding = 8
        configuration.image = NSImage(systemSymbolName: "arrow.down.doc")
        configuration.text = "Drop files here"
        if var fileExtensions {
            fileExtensions = fileExtensions.compactMap({"." + $0})
            let fileExtensionString = fileExtensions.joined(by: .commaOr)
            configuration.secondaryText = "\(fileExtensionString) files…"
        }
        if let buttonHandler = buttonHandler {
            configuration.button = .init(title: "Select files…", action: buttonHandler)
            configuration.button?.symbolConfiguration = .font(.subheadline)
        }
        return configuration
    }
    
}

#endif


/*
/// The configuration for the primary button.
public var button: UIButton.Configuration

/// Additional configuration for the primary button.
public var buttonProperties: UIContentUnavailableConfiguration.ButtonProperties
 
 
 /// The configuration for the secondary button.
 public var secondaryButton: UIButton.Configuration
 
 /// Additional configuration for the secondary button.
 public var secondaryButtonProperties: UIContentUnavailableConfiguration.ButtonProperties
*/

///// Configures which margins use the layout margins inherited from the superview.
//  public var axesPreservingSuperviewLayoutMargins: NSAxis
