//
//  NSBackgroundContentView.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    /// A view for displaying a background configuration.
    public class NSBackgroundView: NSView, NSContentView {
        
        /// The background configuration.
        public var configuration: NSContentConfiguration {
            get { appliedConfiguration }
            set {
                if let newValue = newValue as? NSBackgroundConfiguration {
                    appliedConfiguration = newValue
                }
            }
        }

        /// Determines whether the view is compatible with the provided configuration.
        public func supports(_ configuration: NSContentConfiguration) -> Bool {
            configuration is NSBackgroundConfiguration
        }

        /// Creates a background content view with the specified content configuration.
        public init(configuration: NSBackgroundConfiguration) {
            appliedConfiguration = configuration
            super.init(frame: .zero)
            clipsToBounds = false
            contentView.clipsToBounds = false
            contentViewConstraints = addSubview(withConstraint: contentView)
            updateConfiguration()
        }

        let contentView = NSView()
        var contentViewConstraints: [NSLayoutConstraint] = []

        var view: NSView? {
            didSet {
                if oldValue != view {
                    oldValue?.removeFromSuperview()
                    if let view = view {
                        contentView.addSubview(withConstraint: view)
                    }
                }
            }
        }

        var imageView: ImageView?
        var image: NSImage? {
            get { imageView?.image }
            set {
                guard newValue != imageView?.image else { return }
                if let image = newValue {
                    if imageView == nil {
                        let imageView = ImageView()
                        self.imageView = imageView
                        contentView.addSubview(withConstraint: imageView)
                    }
                    imageView?.image = image
                    imageView?.imageScaling = appliedConfiguration.imageScaling
                } else {
                    imageView?.removeFromSuperview()
                    imageView = nil
                }
            }
        }

        var appliedConfiguration: NSBackgroundConfiguration {
            didSet { if oldValue != appliedConfiguration {
                updateConfiguration()
            } }
        }

        func updateConfiguration() {
            view = appliedConfiguration.view
            image = appliedConfiguration.image

            imageView?.imageScaling = appliedConfiguration.imageScaling

            contentView.backgroundColor = appliedConfiguration._resolvedColor
            contentView.visualEffect = appliedConfiguration.visualEffect
            contentView.cornerRadius = appliedConfiguration.cornerRadius

            contentView.configurate(using: appliedConfiguration.shadow, type: .outer)
            contentView.configurate(using: appliedConfiguration.innerShadow, type: .inner)
            contentView.configurate(using: appliedConfiguration.border)

            contentViewConstraints.constant(appliedConfiguration.insets)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

#endif
