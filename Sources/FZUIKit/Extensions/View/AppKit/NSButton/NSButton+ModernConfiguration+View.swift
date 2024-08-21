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
    extension NSButton.AdvanceButtonView {
        struct ContentView: View {
            let configuration: NSButton.AdvanceButtonConfiguration
            let showBorder: Bool

            public init(configuration: NSButton.AdvanceButtonConfiguration, showBorder: Bool) {
                self.configuration = configuration
                self.showBorder = showBorder
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
                        .multilineTextAlignment(configuration._resolvedTextAlignment)
                        .foregroundColor(configuration.resolvedForegroundColor()?.swiftUI)
                    subtitleItem
                        .font(subtitleFont)
                        .multilineTextAlignment(configuration._resolvedTextAlignment)
                        .foregroundColor(configuration.resolvedForegroundColor()?.swiftUI)
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
                        .foregroundColor(configuration.resolvedForegroundColor()?.swiftUI)
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
                    .background(configuration.resolvedBackgroundColor()?.swiftUI)
                    .clipShape(configuration.cornerStyle.shape)
                    .overlay( configuration.cornerStyle.shape.stroke(lineWidth: showBorder ? configuration.borderWidth : 0.0).foregroundColor(configuration.resolvedForegroundColor()?.swiftUI).scaleEffect(configuration.scaleTransform))
                    .opacity(configuration.opacity)
            }
        }
    }

    @available(macOS 13, *)
    extension NSButton {
        public class AdvanceButtonView: NSView, NSContentView {
            
            lazy var trackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect])
            var hostingView: NSHostingView<ContentView>!
            var mouseIsInside = false
            var isPressed: Bool = false
            
            var showBorder: Bool {
                appliedConfiguration.showsBorderOnlyWhileMouseInside ? mouseIsInside : true
            }
            
            public override func updateTrackingAreas() {
                super.updateTrackingAreas()
                trackingArea.update()
            }
            
            public var configuration: NSContentConfiguration {
                get { appliedConfiguration }
                set { 
                    guard let configuration = newValue as? NSButton.AdvanceButtonConfiguration else { return }
                    appliedConfiguration = configuration
                }
            }
            
            /// The handler that is called when the button is pressed.
            public var action: (()->())? = nil
            
            /// The current configuration of the view.
            var appliedConfiguration: NSButton.AdvanceButtonConfiguration {
                didSet {
                    guard oldValue != appliedConfiguration else { return }
                    updateConfiguration()
                }
            }
            
            public override func mouseEntered(with event: NSEvent) {
                mouseIsInside = true
                if appliedConfiguration.showsBorderOnlyWhileMouseInside {
                    updateConfiguration()
                }
                super.mouseEntered(with: event)
            }
            
            public override func mouseExited(with event: NSEvent) {
                mouseIsInside = false
                if appliedConfiguration.showsBorderOnlyWhileMouseInside {
                    updateConfiguration()
                }
                super.mouseExited(with: event)
            }

            var button: NSButton? {
                superview as? NSButton
            }

            public override func mouseDown(with _: NSEvent) {
                isPressed = true
                if let button = button {
                    if button.automaticallyUpdatesConfiguration {
                        button.updateConfiguration()
                    }
                    button.configurationUpdateHandler?(button, button.configurationState)
                }
            }

            public override func mouseUp(with event: NSEvent) {
                isPressed = false
                if let button = button {
                    if button.automaticallyUpdatesConfiguration {
                        button.updateConfiguration()
                    }
                    button.configurationUpdateHandler?(button, button.configurationState)
                }
                
                if frame.contains(event.location(in: self)) {
                    button?.performAction()
                    button?.sound?.play()
                    action?()
                }
            }

            /// Creates a item content view with the specified content configuration.
            public init(configuration: NSButton.AdvanceButtonConfiguration) {
                self.appliedConfiguration = configuration
                super.init(frame: .zero)
                
                hostingView = NSHostingView(rootView: ContentView(configuration: self.appliedConfiguration, showBorder: showBorder))
                hostingView.backgroundColor = .clear
                hostingView.translatesAutoresizingMaskIntoConstraints = false
                hostingView.clipsToBounds = false
                addSubview(withConstraint: hostingView)
                updateTrackingAreas()
                frame.size = fittingSize
            }

            func updateConfiguration() {
                hostingView.rootView = ContentView(configuration: appliedConfiguration, showBorder: showBorder)
                frame.size = fittingSize
            }
            
            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }

#endif
