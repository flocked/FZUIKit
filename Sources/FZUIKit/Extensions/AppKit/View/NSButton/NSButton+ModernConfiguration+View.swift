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
extension NSButton.ModernConfiguration.ButtonView {
    internal struct ContentView: View {
        let configuration: NSButton.ModernConfiguration
        
        public init(configuration: NSButton.ModernConfiguration) {
            self.configuration = configuration
        }
        
        var fontSize: CGFloat {
            NSFont.systemFontSize(for: configuration.size)
        }
        
        var subtitleFontSize: CGFloat {
            (self.fontSize * 0.75).rounded()
        }
        
        var titleFont: Font {
            switch configuration.size {
            case .large, .regular: return .system(.body) // 13
            case .small: return .system(.subheadline) //
            case .mini: return .system(.caption2)
            @unknown default: return .system(.body)
            }
        }
        
        var subtitleFont: Font {
            switch configuration.size {
            case .large, .regular: return .system(.subheadline) // 13
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
                Image( image)
                    .foregroundColor(configuration._resolvedForegroundColor?.swiftUI)
                    .symbolConfiguration(configuration.imageSymbolConfiguration)
            }
        }
        
        @ViewBuilder
        var stackItem: some View {
            switch configuration.imagePlacement {
            case .leading, .trailing:
                HStack(alignment: .center, spacing: configuration.imagePadding) {
                    if (configuration.imagePlacement == .leading) {
                        imageItem
                        textItems
                    } else {
                        textItems
                        imageItem
                    }
                }
            default:
                VStack(alignment: .center, spacing: configuration.imagePadding) {
                    if (configuration.imagePlacement == .top) {
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
internal extension NSButton.ModernConfiguration {
    class ButtonView: NSView {
        /// The current configuration of the view.
        public var configuration: NSButton.ModernConfiguration {
            didSet {
                if oldValue != self.configuration {
                    self.updateConfiguration()
                }
            }
        }
        
        lazy var trackinArea = TrackingArea(for: self, options: [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect])
        
        public override func updateTrackingAreas() {
            
            super.updateTrackingAreas()
        }
        
        /// Creates a item content view with the specified content configuration.
        public init(configuration: NSButton.ModernConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            self.hostingViewConstraints = addSubview(withConstraint: hostingController.view)
            self.updateConfiguration()
        }
        
        internal var hostingViewConstraints: [NSLayoutConstraint] = []
        
        internal func updateConfiguration() {
            hostingController.rootView =  ContentView(configuration: self.configuration)
            self.sizeToFit()
        }
        
        internal var margins: NSDirectionalEdgeInsets {
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
        
        internal lazy var hostingController: NSHostingController<ContentView> = {
            let contentView = ContentView(configuration: self.configuration)
            let hostingController = NSHostingController(rootView: contentView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.maskToBounds = false
            return hostingController
        }()
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

/*
struct NSButton_ContentView_Previews: PreviewProvider {
    static let titleImage = NSButtonContentConfiguration(title: "Button", image: NSImage(systemSymbolName: "photo"), baseBackgroundColor: .systemBlue, baseForegroundColor: .white)
    static let titleSubtitleImage = NSButtonContentConfiguration(title: "Button", subtitle: "Subtitle", image: NSImage(systemSymbolName: "photo"), baseBackgroundColor: .systemBlue, baseForegroundColor: .white, cornerStyle: .small)

    static let subtitle = NSButtonContentConfiguration(title: "Button", subtitle: "Subtitle", baseBackgroundColor: .systemBlue, baseForegroundColor: .white, cornerStyle: .large)
    
    static let capsule = NSButtonContentConfiguration(title: "Button", contentInsets: .init(width: 26, height: 10.0), baseBackgroundColor: NSColor.systemBlue.tinted(by: 0.7), baseForegroundColor: .systemBlue, cornerStyle: .capsule)
    
    static let borderClear = NSButtonContentConfiguration(title: "Button", contentInsets: .init(width: 26, height: 10.0), baseBackgroundColor: nil, baseForegroundColor: .systemBlue, cornerStyle: .capsule, borderWidth: 1.0)

    
    static var previews: some View {
        VStack {
            NSButtonContentView.ContentView(configuration: titleImage)
            NSButtonContentView.ContentView(configuration: titleSubtitleImage)
            NSButtonContentView.ContentView(configuration: subtitle)
            NSButtonContentView.ContentView(configuration: capsule)
            NSButtonContentView.ContentView(configuration: borderClear)

        }.padding()
    }
}
*/

#endif
