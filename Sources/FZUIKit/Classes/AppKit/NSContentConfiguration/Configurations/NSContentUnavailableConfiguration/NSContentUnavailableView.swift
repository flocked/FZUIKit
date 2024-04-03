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
     A view that indicates there’s no content to display.
 
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
        
        public override func layout() {
            super.layout()
            
            hostingView.frame.size.height = bounds.height - appliedConfiguration.directionalLayoutMargins.height
            hostingView.frame.size.width = bounds.width - appliedConfiguration.directionalLayoutMargins.width
            backgroundView.frame = hostingView.frame
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

        lazy var backgroundView: (NSView & NSContentView) = appliedConfiguration.background.makeContentView()        
        
        var appliedConfiguration: NSContentUnavailableConfiguration {
            didSet {
                if oldValue != appliedConfiguration {
                    updateConfiguration()
                }
            }
        }

        func updateConfiguration() {
            backgroundView.configuration = appliedConfiguration.background
            hostingView.rootView = ContentView(configuration: appliedConfiguration)
            
            hostingView.frame.origin.x = appliedConfiguration.directionalLayoutMargins.leading
            hostingView.frame.origin.y = appliedConfiguration.directionalLayoutMargins.bottom
            hostingView.frame.size.height = bounds.height - appliedConfiguration.directionalLayoutMargins.height
            hostingView.frame.size.width = bounds.width - appliedConfiguration.directionalLayoutMargins.width
            backgroundView.frame = hostingView.frame
        }

        lazy var hostingView = NSHostingView(rootView: ContentView(configuration: self.appliedConfiguration))

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    @available(macOS 12.0, *)
    extension NSContentUnavailableView {
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
                if let loadingIndicator = configuration.loadingIndicator {
                    switch loadingIndicator {
                    case .spinning(let size):
                        ProgressView()
                            .controlSize(size.swiftUI)
                    case .bar(let value, let total, let text, let textStyle, let textColor, let size, let width):
                        if let text = text {
                            ProgressView(value: value, total: total) {
                                Text(text)
                                    .font(.system(textStyle.swiftUI))
                                    .foregroundStyle(Color(textColor))
                            }
                            .progressViewStyle(.linear)
                            .controlSize(size.swiftUI)
                            .frame(width: width)
                        } else {
                            ProgressView(value: value, total: total)
                                .progressViewStyle(.linear)
                                .controlSize(size.swiftUI)
                                .frame(maxWidth: width)
                        }
                    case .circular(let value, let total, let text, let textStyle, let textColor, let size):
                        if let text = text {
                            ProgressView(value: value, total: total) {
                                Text(text)
                                    .font(.system(textStyle.swiftUI))
                                    .foregroundStyle(Color(textColor))
                            }
                            .progressViewStyle(.circular)
                                .controlSize(size.swiftUI)
                        } else {
                            ProgressView(value: value, total: total)
                                .progressViewStyle(.circular)
                                .controlSize(size.swiftUI)
                        }
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

        struct ButtonItem: View {
            let configuration: NSContentUnavailableConfiguration.ButtonConfiguration

            var body: some View {
                Button {
                    configuration.action?()
                } label: {
                    if let atributedTitle = configuration.atributedTitle {
                        if let image = configuration.image {
                            Label { Text(atributedTitle) } icon: { 
                                Image(image)
                                    .resizable()
                                   // .frame(width: configuration.size.size?.width, height: configuration.size.size?.height)
                            }
                        } else {
                            Text(atributedTitle)
                        }
                    } else if let title = configuration.title {
                        if let image = configuration.image {
                            Label { Text(title) } icon: {
                                Image(image)
                                    .resizable()
                                 //   .frame(width: configuration.size.size?.width, height: configuration.size.size?.height)
                            }
                        } else {
                            Text(title)
                        }
                    } else if let image = configuration.image {
                        Image(image)
                            .resizable()
                           // .frame(width: configuration.size.size?.width, height: configuration.size.size?.height)
                    }
                }.buttonStyling(configuration.style)
                    .foregroundColor(configuration.contentTintColor?.swiftUI)
                    .symbolConfiguration(configuration.symbolConfiguration)
                    .controlSize(configuration.size.swiftUI)
                    .frame(width: configuration.image != nil && configuration.style == .borderless ? configuration.size.size?.width : nil, height: configuration.image != nil && configuration.style == .borderless ? configuration.size.size?.height : nil)
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
                    .lineLimit(properties._maxNumberOfLines)
                    .foregroundColor(properties.color.swiftUI)
                    .minimumScaleFactor(properties.minimumScaleFactor)
            }
        }
    }
#endif
