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
        public var text: String? {
            didSet {
                if text != nil { 
                    attributedText = nil
                }
            }
        }

        /// An attributed variant of the primary text.
        public var attributedText: NSAttributedString? {
            didSet {
                if attributedText != nil {
                    text = nil
                }
            }
        }

        /// The secondary text to display.
        public var secondaryText: String? {
            didSet {
                if secondaryText != nil {
                    secondaryAttributedText = nil
                }
            }
        }

        /// An attributed variant of the secondary text.
        public var secondaryAttributedText: NSAttributedString? {
            didSet {
                if secondaryAttributedText != nil {
                    secondaryText = nil
                }
            }
        }

        /// The button configuration.
        public var button: ButtonConfiguration?

        /// The secondary button configuration.
        public var secondaryButton: ButtonConfiguration?

        /// Properties for configuring the primary text.
        public var textProperties: TextProperties = .primary()

        /// Properties for configuring the secondary text.
        public var secondaryTextProperties: TextProperties = .secondary()
        
        /// The configuration for the image.
        public var imageProperties: ImageProperties = .init()

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

        /// The properties of a loading indicator.
        public struct LoadingIndicator: Hashable {
            
            /// A spinning loading indicator.
            public static var spinning: LoadingIndicator { LoadingIndicator(.spinning) }
            
            /**
             A linear loading indicator.
             
             - Parameters:
                - value: The current value of the indicator.
                - total: The total value of the indicator.
             */
            public static func linear(value: CGFloat = 0.0, total: CGFloat = 1.0) -> LoadingIndicator {
                LoadingIndicator(.linear, value: value, total: total)
            }
            
            /**
             A circular loading indicator.
             
             - Parameters:
                - value: The current value of the indicator.
                - total: The total value of the indicator.
             */
            public static func circular(value: CGFloat = 0.0, total: CGFloat = 1.0) -> LoadingIndicator {
                LoadingIndicator(.circular, value: value, total: total)
            }
            
            /// The current value of the indicator.
            public var value: CGFloat = 0.0
            
            /// The total value of the indicator.
            public var total: CGFloat = 1.0
            
            /// The control size of the indicator.
            public var size: NSControl.ControlSize = .regular
            
            /// The width of a `linear` loading indicator.
            public var width: CGFloat = 200.0
            
            /// The text displayed next to a `linear` and `circular` loading indicator.
            public var text: String?
            
            /// The text font.
            public var textFont: NSFont?
            
            var resolvedFont: NSFont {
                textFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize(for: size))
            }
            
            /// The text color.
            public var textColor: NSColor?
            
            var style: Style = .linear

            enum Style: Int, Hashable {
                case circular
                case linear
                case spinning
            }
            
            init(_ style: Style, value: CGFloat = 0.0, total: CGFloat = 1.0, size: NSControl.ControlSize = .regular, text: String? = nil, textFont: NSFont? = nil, textColor: NSColor? = nil) {
                self.style = style
                self.total = total
                self.value = value
                self.size = size
                self.text = text
                self.textFont = textFont
                self.textColor = textColor
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
            configuration.loadingIndicator = .spinning
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
                configuration.button = .init(title: "Select files…", style: .bordered, action: buttonHandler)
                configuration.button?.symbolConfiguration = .font(.subheadline)
            }
            return configuration
        }
    }

#endif
