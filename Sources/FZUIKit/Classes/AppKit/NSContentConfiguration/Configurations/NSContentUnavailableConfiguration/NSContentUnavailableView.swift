//
//  NSContentUnavailableView.swift
//  NSContentUnavailableConfiguration
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
import AppKit
import SwiftUI

@available(macOS 12.0, *)
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
        
    /// Creates a item content view with the specified content configuration.
    public init(configuration: NSContentUnavailableConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        self.backgroundConstraints = addSubview(withConstraint: backgroundView)
        self.hostingConstraints = addSubview(withConstraint: hostingView)
        self.updateConfiguration()
    }
    
    internal var backgroundConstraints: [NSLayoutConstraint] = []
    internal var hostingConstraints: [NSLayoutConstraint] = []
    
    internal lazy var backgroundView: (NSView & NSContentView) = _configuration.background.makeContentView()
    
    internal var _configuration: NSContentUnavailableConfiguration {
        didSet {
            if oldValue != _configuration {
                updateConfiguration()
            }
        }
    }
    
    internal func updateConfiguration() {
        backgroundView.configuration = _configuration.background
        hostingView.rootView =  ContentView(configuration: self._configuration)
        
        backgroundConstraints[1].constant = -_configuration.directionalLayoutMargins.bottom
        backgroundConstraints[0].constant = _configuration.directionalLayoutMargins.leading
        backgroundConstraints[2].constant = -_configuration.directionalLayoutMargins.width
        backgroundConstraints[3].constant = -_configuration.directionalLayoutMargins.height

        hostingConstraints[1].constant = -_configuration.directionalLayoutMargins.bottom
        hostingConstraints[0].constant = _configuration.directionalLayoutMargins.leading
        hostingConstraints[2].constant = -_configuration.directionalLayoutMargins.width
        hostingConstraints[3].constant = -_configuration.directionalLayoutMargins.height
    }
    
    internal lazy var hostingView: NSHostingView<ContentView> = {
        let contentView = ContentView(configuration: self._configuration)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.maskToBounds = false
        return hostingView
    }()
 
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(macOS 12.0, *)
internal extension NSContentUnavailableView {
    struct ContentView: View {
        let configuration: NSContentUnavailableConfiguration
        
        @ViewBuilder
        var imageItem: some View {
            if let image = configuration.image {
                Image(image)
                    .foregroundColor(configuration.imageProperties.tintColor?.swiftUI)
                    .symbolConfiguration(configuration.imageProperties.symbolConfiguration)
                    .cornerRadius(configuration.imageProperties.cornerRadius)
            }
        }
        
        @ViewBuilder
        var textItems: some View {
            VStack(spacing: configuration.textToSecondaryTextPadding) {
                TextItem(text: configuration.text, attributedText: configuration.attributedText, properties: configuration.textProperties)
                TextItem(text: configuration.secondaryText, attributedText: configuration.secondaryAttributedText, properties: configuration.secondaryTextProperties)
            }
        }
        
        var stack: some View {
            VStack(spacing: configuration.imageToTextPadding) {
                if configuration.isLoadingConfiguration {
                    ProgressView()
                        .controlSize(.small)
                        .progressViewStyle(CircularProgressViewStyle())
                }
                imageItem
                textItems
            }
        }
        
        var body: some View {
            stack
                .frame(maxWidth: .infinity,  maxHeight: .infinity, alignment: .center)
        }
    }
    
    struct TextItem: View {
        let text: String?
        let attributedText: NSAttributedString?
        let properties: NSContentUnavailableConfiguration.TextProperties
        
        init(text: String?, attributedText: NSAttributedString?, properties: NSContentUnavailableConfiguration.TextProperties) {
            self.text = text
            self.attributedText = attributedText
            self.properties = properties
        }
        
        @ViewBuilder
        var item: some View {
            if let attributedText = attributedText {
                Text(AttributedString(attributedText))
            } else if let text = text {
                Text(text)
            }
        }
        
        var body: some View {
            item
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(properties.font.swiftUI)
                .lineLimit(properties.maxNumberOfLines)
                .foregroundColor(properties.color.swiftUI)
        }
    }
    
}
#endif
