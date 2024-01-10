//
//  NSButton+ModernConfiguration+View.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)

    import AppKit
    import FZSwiftUtils
    import SwiftUI

    @available(macOS 13.0, *)
    extension NSButton.AdvanceConfiguration.ButtonView {
        struct ContentView: View {
            let configuration: NSButton.AdvanceConfiguration

            public init(configuration: NSButton.AdvanceConfiguration) {
                self.configuration = configuration
            }

            var titleFont: Font {
                switch configuration.size {
                case .large: return .system(.title3) // 13
                case .regular: return .system(.body) // 13
                case .small: return .system(.subheadline) //
                case .mini: return .system(.caption2)
                @unknown default: return .system(.body)
                }
            }

            var subtitleFont: Font {
                switch configuration.size {
                case .large: return .system(.body) // 13
                case .regular: return .system(.subheadline) // 13
                case .small: return .system(.caption2) //
                case .mini: return .system(.caption2)
                @unknown default: return .system(.subheadline)
                }
            }

            @ViewBuilder
            var textItems: some View {
                VStack(alignment: configuration._resolvedTitleAlignment.alignment, spacing: configuration.titlePadding) {
                    titleItem
                        .font(titleFont)
                        .foregroundColor(configuration._resolvedForegroundColor?.swiftUI)
                    subtitleItem
                        .font(subtitleFont)
                        .foregroundColor(configuration._resolvedForegroundColor?.swiftUI)
                }
            }

            @ViewBuilder
            var titleItem: some View {
                if let title = configuration.title {
                    Text(title)
                } else if let attributedTitle = configuration.attributedTitle {
                    Text(AttributedString(attributedTitle))
                }
            }

            @ViewBuilder
            var subtitleItem: some View {
                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                } else if let attributedSubtitle = configuration.attributedSubtitle {
                    Text(AttributedString(attributedSubtitle))
                }
            }

            @ViewBuilder
            var imageItem: some View {
                if let image = configuration.image {
                    Image(image)
                        .foregroundColor(configuration._resolvedForegroundColor?.swiftUI)
                        .symbolConfiguration(configuration.imageSymbolConfiguration)
                }
            }

            @ViewBuilder
            var stackItem: some View {
                switch configuration.imagePlacement {
                case .leading, .trailing:
                    HStack(alignment: .center, spacing: configuration.imagePadding) {
                        if configuration.imagePlacement == .leading {
                            imageItem
                            textItems
                        } else {
                            textItems
                            imageItem
                        }
                    }
                default:
                    VStack(alignment: .center, spacing: configuration.imagePadding) {
                        if configuration.imagePlacement == .top {
                            imageItem
                            textItems
                        } else {
                            textItems
                            imageItem
                        }
                    }
                }
            }

            var body: some View {
                stackItem
                    .padding(configuration.contentInsets.edgeInsets)
                    .scaleEffect(configuration.scaleTransform)
                    .background(configuration._resolvedBackgroundColor?.swiftUI)
                    .clipShape(configuration.cornerStyle.shape)
                    .overlay(configuration.cornerStyle.shape.stroke(lineWidth: configuration.borderWidth).foregroundColor(configuration._resolvedForegroundColor?.swiftUI))
                    .opacity(configuration.opacity)
            }
        }
    }

    @available(macOS 13, *)
    extension NSButton.AdvanceConfiguration {
        class ButtonView: NSView {
            /// The current configuration of the view.
            public var configuration: NSButton.AdvanceConfiguration {
                didSet {
                    if oldValue != configuration {
                        updateConfiguration()
                    }
                }
            }

            var button: NSButton? {
                superview as? NSButton
            }

            override func mouseDown(with _: NSEvent) {
                button?.isPressed = true
            }

            override func mouseUp(with event: NSEvent) {
                button?.isPressed = false
                if frame.contains(event.location(in: self)) {
                    button?.sendAction()
                }
            }

            /// Creates a item content view with the specified content configuration.
            public init(configuration: NSButton.AdvanceConfiguration) {
                self.configuration = configuration
                super.init(frame: .zero)
                hostingViewConstraints = addSubview(withConstraint: hostingController.view)
                updateConfiguration()
            }

            var hostingViewConstraints: [NSLayoutConstraint] = []

            func updateConfiguration() {
                hostingController.rootView = ContentView(configuration: configuration)
                sizeToFit()
            }

            var margins: NSDirectionalEdgeInsets {
                get {
                    var edgeInsets = NSDirectionalEdgeInsets(top: hostingViewConstraints[0].constant, leading: hostingViewConstraints[1].constant, bottom: 0, trailing: 0)
                    edgeInsets.width = -hostingViewConstraints[2].constant
                    edgeInsets.height = -hostingViewConstraints[3].constant
                    return edgeInsets
                }
                set {
                    hostingViewConstraints[0].constant = newValue.bottom
                    hostingViewConstraints[1].constant = newValue.leading
                    hostingViewConstraints[2].constant = -newValue.width
                    hostingViewConstraints[3].constant = -newValue.height
                }
            }

            lazy var hostingController: NSHostingController<ContentView> = {
                let contentView = ContentView(configuration: self.configuration)
                let hostingController = NSHostingController(rootView: contentView)
                hostingController.view.backgroundColor = .clear
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                hostingController.view.clipsToBounds = false
                return hostingController
            }()

            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }

#endif
