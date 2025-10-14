//
//  NSContentUnavailableView.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
import AppKit
import SwiftUI
/**
 A view indicating there’s no content to display.
 
 Use a content-unavailable view to indicate that your app can’t display content. For example, content may not be available if a search returns no results or your app is loading data over the network.
 */
@available(macOS 12.0, *)
public class NSContentUnavailableView: NSView, NSContentView {
    /// The content-unavailable configuration.
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
    
    /// Creates a new content-unavailable view with the specified configuration.
    public init(configuration: NSContentUnavailableConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        addSubview(backgroundView)
        addSubview(hostingView)
        updateConfiguration()
    }
    
    lazy var hostingView = NSHostingView(rootView: ContentView(configuration: self.appliedConfiguration))
    lazy var backgroundView: (NSView & NSContentView) = appliedConfiguration.background.makeContentView()
    
    var appliedConfiguration: NSContentUnavailableConfiguration {
        didSet {
            guard oldValue != appliedConfiguration else { return }
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        backgroundView.configuration = appliedConfiguration.background
        hostingView.rootView = ContentView(configuration: appliedConfiguration)
        updateFrames()
    }
    
    open override func layout() {
        super.layout()
        updateFrames()
    }
    
    func updateFrames() {
        backgroundView.frame = CGRect(x: appliedConfiguration.directionalLayoutMargins.bottom, y: appliedConfiguration.directionalLayoutMargins.leading, width: bounds.width - appliedConfiguration.directionalLayoutMargins.width, height: bounds.height - appliedConfiguration.directionalLayoutMargins.height)
        hostingView.frame = backgroundView.frame
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct ContentView: View {
        let configuration: NSContentUnavailableConfiguration
        
        @ViewBuilder
        var buttonItem: some View {
            if let configuration = configuration.button {
                ButtonView(configuration)
            }
        }
        
        @ViewBuilder
        var secondaryButton: some View {
            if let configuration = configuration.secondaryButton {
                ButtonView(configuration)
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
                    .scaling(configuration.imageProperties.scaling)
                    .frame(maxWidth: configuration.imageProperties.maximumWidth, maxHeight: configuration.imageProperties.maximumHeight)
                    .foregroundColor(configuration.imageProperties.tintColor?.swiftUI)
                    .symbolConfiguration(configuration.imageProperties.symbolConfiguration)
                    .cornerRadius(configuration.imageProperties.cornerRadius)
                    .shadow(configuration.imageProperties.shadow)
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
            if let indicator = configuration.loadingIndicator {
                switch indicator.style {
                case .circular, .linear:
                    if let text = indicator.text {
                        ProgressView(value: indicator.value, total: indicator.total) {
                            Text(text)
                                .font(indicator.resolvedFont.swiftUI)
                                .foregroundStyle(indicator.textColor?.swiftUI ?? configuration.textProperties.color.swiftUI)
                        }
                        .progressStyle(indicator.style)
                        .controlSize(indicator.size.swiftUI)
                    } else {
                        ProgressView(value: indicator.value, total: indicator.total)
                            .progressStyle(indicator.style)
                            .controlSize(indicator.size.swiftUI)
                    }
                case .spinning:
                    ProgressView()
                        .controlSize(indicator.size.swiftUI)
                }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
                .lineLimit(properties.maxNumberOfLines == 0 ? nil : properties.maxNumberOfLines)
                .foregroundColor(properties.resolvedColor().swiftUI)
                .minimumScaleFactor(properties.minimumScaleFactor)
        }
    }
    
    struct ButtonView: NSViewRepresentable {
        let configuration: NSContentUnavailableConfiguration.ButtonConfiguration
        
        init(_ configuration: NSContentUnavailableConfiguration.ButtonConfiguration) {
            self.configuration = configuration
        }
        
        public func makeNSView(context: Context) -> NSButton {
            let button = NSButton()
            if let attributedTitle = configuration.atributedTitle {
                button.attributedTitle = attributedTitle.nsAttributedString
            } else if let title = configuration.title {
                button.title = title
            }
            button.image = configuration.image
            button.symbolConfiguration = configuration.symbolConfiguration?.nsUI()
            button.controlSize = configuration.size
            button.contentTintColor = configuration.resolvedTintColor()
            button.state = configuration.state
            button.actionBlock = { _ in configuration.action?() }
            button.bezelStyle = configuration.type.bezel
            button.setButtonType(configuration.type.buttonType)
            button.isEnabled = configuration.isEnabled
            button.sizeToFit()
            return button
        }
        
        public func updateNSView(_ button: NSButton, context: Context) {
            
        }
    }
}

@available(macOS 11.0, *)
extension NSControl.ControlSize {
    var swiftUI: ControlSize {
        switch self {
        case .regular: return .regular
        case .small: return .small
        case .mini: return .mini
        case .large: return .large
        case .extraLarge:
            if #available(macOS 14.0, *) {
                return .extraLarge
            }
            return .large
        @unknown default: return .regular
        }
    }
}

@available(macOS 12.0, *)
fileprivate extension View {
    @ViewBuilder
    func progressStyle(_ style: NSContentUnavailableConfiguration.LoadingIndicator.Style) -> some View {
        if style == .circular {
            progressViewStyle(.circular)
        } else {
            progressViewStyle(.linear)
        }
    }
}
#endif
