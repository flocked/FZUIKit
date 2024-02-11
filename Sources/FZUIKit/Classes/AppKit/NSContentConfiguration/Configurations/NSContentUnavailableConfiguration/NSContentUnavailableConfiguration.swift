//
//  NSContentUnavailableConfiguration.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
    import AppKit
    import SwiftUI

    /**
     A content configuration for a content-unavailable view.

     A content-unavailable configuration is a composable description of a view that indicates your app can’t display content. Using a content-unavailable configuration, you can obtain system default styling for a variety of different empty states. Fill the configuration with placeholder content, and then assign it to a view’s contentUnavailableConfiguration, or to a NSContentUnavailableView.
     */
    @available(macOS 12.0, *)
    public struct NSContentUnavailableConfiguration: NSContentConfiguration, Hashable {
        /// The image to display.
        public var image: NSImage?

        /// The primary text to display.
        public var text: String?

        /// An attributed variant of the primary text.
        public var attributedText: NSAttributedString?

        /// The secondary text to display.
        public var secondaryText: String?

        /// An attributed variant of the secondary text.
        public var secondaryAttributedText: NSAttributedString?

        /// The button configuration.
        public var button: ButtonConfiguration?

        /// The secondary button configuration.
        public var secondaryButton: ButtonConfiguration?

        /// The configuration for the image.
        public var imageProperties: ImageProperties = .init()

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
        public var buttonToSecondaryButtonPadding: CGFloat = 10.0

        /**
         The orientation of the buttons.

         If `vertical` the secondary button is placed  next to the primary button, if `horizontal` it's placed below the primary button.
         */
        public var buttonOrientation: NSUIUserInterfaceLayoutOrientation = .horizontal
        
        /// The loading indicator.
        public var loadingIndicator: LoadingIndicator? = nil
        
        /// The loading indicator type.
        public enum LoadingIndicator: Hashable {
            /// A spinning loading indicator.
            case spinning(size: Size = .regular)
            /// A bar progress indicator.
            case bar(value: Double = 0.0, total: Double = 0.0, text: String? = nil, textStyle: NSFont.TextStyle = .body, textColor: NSColor = .labelColor, size: Size = .regular, width: CGFloat = 200.0)
            /// A circular progress indicator.
            case circular(value: Double = 0.0, total: Double = 0.0, text: String? = nil, textStyle: NSFont.TextStyle = .body, textColor: NSColor = .labelColor, size: Size = .regular)
            
            /// The size of the loading indicator.
            public enum Size: Int, Hashable {
                /// A loading indicator that is minimally sized.
                case mini
                /// A loading indicator that is proportionally smaller size for space-constrained views.
                case small
                /// A loading indicator that is the default size.
                case regular
                /// A loading indicator that is prominently sized.
                case large
                @available(macOS 14.0, *)
                /// A loading indicator that is sized extra large.
                case extraLarge
                var swiftUI: SwiftUI.ControlSize {
                    switch self {
                    case .mini: return .mini
                    case .small: return .small
                    case .regular: return .regular
                    case .large: return .large
                    case .extraLarge: if #available(macOS 14.0, *) {
                        return .extraLarge
                    } else {
                        return .regular
                    }
                    }
                }
            }
        }

        public func makeContentView() -> NSView & NSContentView {
            NSContentUnavailableView(configuration: self)
        }

        public func updated(for state: NSConfigurationState) -> NSContentUnavailableConfiguration {
            self
        }

        var hasText: Bool {
            text != nil || attributedText != nil
        }

        var hasSecondaryText: Bool {
            secondaryText != nil || secondaryAttributedText != nil
        }
    }

    @available(macOS 12.0, *)
    public extension NSContentUnavailableConfiguration {
        /// Creates the default configuration for unavailable content.
        static func empty() -> NSContentUnavailableConfiguration {
            var configuration = NSContentUnavailableConfiguration()
            configuration.imageProperties.scaling = .none
            configuration.imageProperties.symbolConfiguration = .font(.title1, weight: .bold)
            return configuration
        }

        /// Creates the default configuration for content that’s loading.
        static func loading() -> NSContentUnavailableConfiguration {
            var configuration = NSContentUnavailableConfiguration()
            configuration.textProperties = .body()
            configuration.secondaryTextProperties = configuration.textProperties
            configuration.loadingIndicator = .spinning()
            configuration.imageProperties.scaling = .none
            configuration.imageProperties.symbolConfiguration = .font(.title1, weight: .bold)
            return configuration
        }

        /// Creates the default configuration for search content.
        static func search() -> NSContentUnavailableConfiguration {
            var configuration = NSContentUnavailableConfiguration()
            configuration.textProperties.font = .headline.weight(.semibold)
            configuration.secondaryTextProperties.font = .subheadline
            configuration.image = NSImage(systemSymbolName: "magnifyingglass")
            configuration.imageProperties.scaling = .none
            configuration.imageProperties.symbolConfiguration = .font(.title1, weight: .bold)
            return configuration
        }

        /// Creates the default configuration for dropping files.
        static func dropFiles(fileExtensions: [String]?, selectFilesButtonHandler: (() -> Void)?) -> NSContentUnavailableConfiguration {
            var configuration = NSContentUnavailableConfiguration()
            configuration.text = "Drop files here"
            configuration.textProperties.font = .headline.weight(.semibold)
            configuration.image = NSImage(systemSymbolName: "arrow.down.doc")
            configuration.imageToTextPadding = 8
            configuration.imageProperties.symbolConfiguration = .font(.title1, weight: .bold)
            configuration.imageProperties.scaling = .none

            if var fileExtensions = fileExtensions, !fileExtensions.isEmpty {
                if fileExtensions.count == 1 {
                    configuration.secondaryText = ".\(fileExtensions.first!) file…"
                } else {
                    fileExtensions = fileExtensions.compactMap { "." + $0 }
                    let fileExtensionString = fileExtensions.joined(by: .commaOr)
                    configuration.secondaryText = "\(fileExtensionString) files…"
                }
            }
            if let buttonHandler = selectFilesButtonHandler {
                /*
                let openPanel = NSOpenPanel()
                openPanel.allowedFileTypes = NSImage.imageTypes
                openPanel.allowedContentTypes = [.png, .jpeg]
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.canChooseFiles = true
                openPanel.begin { result in
                    if result == .OK {
                    }
                }
                */
                configuration.button = .init(title: "Select files…", action: buttonHandler)
                configuration.button?.symbolConfiguration = .font(.subheadline)
            }
            return configuration
        }
    }

#endif
