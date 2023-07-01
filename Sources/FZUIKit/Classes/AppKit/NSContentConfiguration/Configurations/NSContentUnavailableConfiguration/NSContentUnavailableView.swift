//
//  NSContentUnavailableView.swift
//  
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
        get { appliedConfiguration }
        set {
            if let newValue = newValue as? NSContentUnavailableConfiguration {
                appliedConfiguration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSContentUnavailableConfiguration
    }
        
    /// Creates a item content view with the specified content configuration.
    public init(configuration: NSContentUnavailableConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        self.backgroundConstraints = addSubview(withConstraint: backgroundView)
        self.hostingConstraints = addSubview(withConstraint: hostingView)
        self.updateConfiguration()
    }
    
    internal var backgroundConstraints: [NSLayoutConstraint] = []
    internal var hostingConstraints: [NSLayoutConstraint] = []
    
    internal lazy var backgroundView: (NSView & NSContentView) = appliedConfiguration.background.makeContentView()
    
    internal var appliedConfiguration: NSContentUnavailableConfiguration {
        didSet {
            if oldValue != appliedConfiguration {
                updateConfiguration()
            }
        }
    }
    
    internal func updateConfiguration() {
        backgroundView.configuration = appliedConfiguration.background
        hostingView.rootView =  ContentView(configuration: self.appliedConfiguration)
        
        backgroundConstraints[1].constant = -appliedConfiguration.directionalLayoutMargins.bottom
        backgroundConstraints[0].constant = appliedConfiguration.directionalLayoutMargins.leading
        backgroundConstraints[2].constant = -appliedConfiguration.directionalLayoutMargins.width
        backgroundConstraints[3].constant = -appliedConfiguration.directionalLayoutMargins.height

        hostingConstraints[1].constant = -appliedConfiguration.directionalLayoutMargins.bottom
        hostingConstraints[0].constant = appliedConfiguration.directionalLayoutMargins.leading
        hostingConstraints[2].constant = -appliedConfiguration.directionalLayoutMargins.width
        hostingConstraints[3].constant = -appliedConfiguration.directionalLayoutMargins.height
    }
    
    internal lazy var hostingView: NSHostingView<ContentView> = {
        let contentView = ContentView(configuration: self.appliedConfiguration)
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
        var buttonItem: some View {
            if let configuration = configuration.button, configuration.hasContent {
                ButtonItem(configuration: configuration)
            }
        }
        
        @ViewBuilder
        var secondaryButton: some View {
            if let configuration = configuration.secondaryButton, configuration.hasContent {
                ButtonItem(configuration: configuration)
            }
        }
        
        @ViewBuilder
        var buttonItems: some View {
            if configuration.buttonOrientation == .vertical {
                VStack(spacing: configuration.buttonToSecondaryButtonPadding) {
                    buttonItem
                    secondaryButton
                }
            } else {
                HStack(spacing: configuration.buttonToSecondaryButtonPadding) {
                    buttonItem
                    secondaryButton
                }
            }
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = configuration.image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: configuration.imageProperties.maximumWidth, maxHeight: configuration.imageProperties.maximumHeight)
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
        
        @ViewBuilder
        var loadingIndicatorItem: some View {
            if configuration.displayLoadingIndicator {
                ProgressView()
                    .controlSize(.small)
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        
        @ViewBuilder
        var imageTextStack: some View {
            VStack(spacing: configuration.imageToTextPadding) {
                loadingIndicatorItem
                imageItem
                textItems
            }
        }
        
        @ViewBuilder
        var stack: some View {
            VStack(spacing: configuration.textToButtonPadding) {
                imageTextStack
                buttonItems
            }
        }
        
        var body: some View {
            stack
                .frame(maxWidth: .infinity,  maxHeight: .infinity, alignment: .center)
        }
    }
    
    struct ButtonItem: View {
        let configuration: NSContentUnavailableConfiguration.ButtonConfiguration
        
        var body: some View {
            Button {
                configuration.action()
            } label: {
                if let atributedTitle = configuration.atributedTitle {
                    if let image = configuration.image {
                        Label { Text(atributedTitle) } icon: {  Image(image) }
                    } else {
                        Text(atributedTitle)
                    }
                } else if let title = configuration.title {
                    if let image = configuration.image {
                        Label { Text(title) } icon: {  Image(image) }
                    } else {
                        Text(title)
                    }
                } else if let image = configuration.image {
                    Image(image)
                }
            }.buttonStyling(configuration.style)
                .foregroundColor(configuration.contentTintColor?.swiftUI)
                .symbolConfiguration(configuration.symbolConfiguration)
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
