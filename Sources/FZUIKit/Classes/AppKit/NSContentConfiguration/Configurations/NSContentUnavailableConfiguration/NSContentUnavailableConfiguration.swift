//
//  NSContentUnavailableConfiguration.swift
//  NSContentUnavailableConfiguration
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
    
    /// The configuration for the image.
    public var imageProperties: ImageProperties = ImageProperties()
    
    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = TextProperties()
    
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: TextProperties = TextProperties()
    
    /// The configuration for the background.
    public var background: NSBackgroundConfiguration = NSBackgroundConfiguration()
    
    /// The margins between the content and the edges of the content view.
    public var directionalLayoutMargins: NSDirectionalEdgeInsets = .init(6.0)
    
    /// The padding between the image and the primary text.
    public var imageToTextPadding: CGFloat = 2.0
    
    /// The padding between the primary and secondary text.
    public var textToSecondaryTextPadding: CGFloat = 2.0
    
    /// The padding between the text and buttons.
    public var textToButtonPadding: CGFloat = 2.0
    
    /// The padding between the primary button and secondary button.
    public var buttonToSecondaryButtonPadding: CGFloat = 2.0
    
    internal var isLoadingConfiguration: Bool = false
    
    public func makeContentView() -> NSView & FZUIKit.NSContentView {
        NSContentUnavailableView(configuration: self)
    }
    
    public func updated(for state: FZUIKit.NSConfigurationState) -> NSContentUnavailableConfiguration {
        return self
    }
    
    internal var hasText: Bool {
        self.text != nil || self.attributedText != nil
    }
    
    internal var hasSecondaryText: Bool {
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
        configuration.text = "Loading…"
        configuration.textProperties = .body()
        configuration.textProperties.color = .secondaryLabelColor
        configuration.imageToTextPadding = 6.0
        configuration.isLoadingConfiguration = true
        return configuration
    }
    
    /// Creates the default configuration for searches that return no results.
    static func search() -> NSContentUnavailableConfiguration {
        var configuration = NSContentUnavailableConfiguration()
        configuration.imageProperties.symbolConfiguration = .font(.largeTitle)
        configuration.image = NSImage(systemSymbolName: "magnifyingglass")
        configuration.text = "No Results"
        configuration.textProperties.font = .system(.headline).weight(.bold)
        configuration.secondaryTextProperties = .subheadline()
        configuration.imageToTextPadding = 6.0
        configuration.secondaryTextProperties.color = .secondaryLabelColor
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
