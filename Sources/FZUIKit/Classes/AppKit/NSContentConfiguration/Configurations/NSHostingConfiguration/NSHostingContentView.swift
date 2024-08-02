//
//  NSHostingContentView.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
    import SwiftUI

    class NSHostingContentView<Content, Background>: NSView, NSContentView where Content: View, Background: View {
        /// The current configuration of the view.
        public var configuration: NSContentConfiguration {
            get { appliedConfiguration }
            set {
                if let newValue = newValue as? NSHostingConfiguration<Content, Background> {
                    appliedConfiguration = newValue
                }
            }
        }

        /// Determines whether the view is compatible with the provided configuration.
        public func supports(_ configuration: NSContentConfiguration) -> Bool {
            configuration is NSHostingConfiguration<Content, Background>
        }

        public func sizeThatFits(_ size: CGSize) -> CGSize {
            hostingController.sizeThatFits(in: size)
        }

        override var fittingSize: NSSize {
            hostingController.view.fittingSize
        }

        /// Creates a hosting content view with the specified content configuration.
        public init(configuration: NSHostingConfiguration<Content, Background>) {
            appliedConfiguration = configuration
            super.init(frame: .zero)
            hostingViewConstraints = addSubview(withConstraint: hostingController.view)
            updateConfiguration()
        }

        var appliedConfiguration: NSHostingConfiguration<Content, Background> {
            didSet { updateConfiguration() }
        }

        func updateConfiguration() {
            hostingController.rootView = HostingView(configuration: appliedConfiguration)
            if #available(macOS 13.0, *) {
                hostingController.sizingOptions = appliedConfiguration.sizingOptions
            }
            hostingViewConstraints.constant(appliedConfiguration.margins)
        }

        lazy var hostingController: NSUIHostingController<HostingView<Content, Background>> = {
            let contentView = HostingView(configuration: appliedConfiguration)
            let hostingController = NSUIHostingController(rootView: contentView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            return hostingController
        }()

        var hostingViewConstraints: [NSLayoutConstraint] = []

        override var intrinsicContentSize: CGSize {
            var intrinsicContentSize = hostingController.view.intrinsicContentSize
            if let width = appliedConfiguration.minWidth {
                intrinsicContentSize.width = max(intrinsicContentSize.width, width)
            }
            if let height = appliedConfiguration.minHeight {
                intrinsicContentSize.height = max(intrinsicContentSize.height, height)
            }
            return intrinsicContentSize
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    extension NSHostingContentView {
        struct HostingView<V: View, B: View>: View {
            let configuration: NSHostingConfiguration<V, B>

            init(configuration: NSHostingConfiguration<V, B>) {
                self.configuration = configuration
            }

            public var body: some View {
                ZStack {
                    configuration.background
                    configuration.content
                }.frame(minWidth: configuration.minWidth, minHeight: configuration.minHeight)
            }
        }
    }

    public struct _NSHostingConfigurationBackgroundView<S>: View where S: ShapeStyle {
        let style: S

        public var body: some View {
            Rectangle().fill(style)
        }
    }

#endif
