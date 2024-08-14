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
            contentViewConstraits = addSubview(withConstraint: contentView)
            contentView.addSubview(withConstraint: imageView)
            imageView.clipsToBounds = true
            updateConfiguration()
        }
        
        var appliedConfiguration: NSBackgroundConfiguration {
            didSet {
                guard oldValue != appliedConfiguration else { return }
                updateConfiguration()
            }
        }
        
        let contentView = NSView()
        let imageView = ImageView()
        var contentViewConstraits: [NSLayoutConstraint] = []

        var view: NSView? {
            didSet {
                guard oldValue != view else { return }
                oldValue?.removeFromSuperview()
                if let view = view {
                    view.clipsToBounds = true
                    contentView.addSubview(withConstraint: view)
                }
            }
        }

        var image: NSImage? {
            get { imageView.image }
            set {
                imageView.image = newValue
                imageView.isHidden = newValue == nil
            }
        }

        func updateConfiguration() {
            view = appliedConfiguration.view
            image = appliedConfiguration.image

            imageView.imageScaling = appliedConfiguration.imageScaling

            contentView.backgroundColor = appliedConfiguration._resolvedColor
            contentView.visualEffect = appliedConfiguration.visualEffect
            contentView.cornerRadius = appliedConfiguration.cornerRadius

            contentView.outerShadow = appliedConfiguration.resolvedShadow
            contentView.innerShadow = appliedConfiguration.innerShadow
            contentView.border = appliedConfiguration.resolvedBorder
            
            contentViewConstraits.constant(appliedConfiguration.insets)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

#endif
