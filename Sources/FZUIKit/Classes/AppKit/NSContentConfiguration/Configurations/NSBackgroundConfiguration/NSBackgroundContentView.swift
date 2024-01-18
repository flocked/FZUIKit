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
            addSubview(contentView)
            contentView.addSubview(imageView)
            updateConfiguration()
        }
        
        public override func layout() {
            super.layout()
            contentView.frame.size.width = appliedConfiguration.insets.width
            contentView.frame.size.height = appliedConfiguration.insets.height
            view?.frame.size = contentView.bounds.size
            imageView.frame.size = contentView.bounds.size
            imageView.clipsToBounds = true
        }

        let contentView = NSView()

        var view: NSView? {
            didSet {
                if oldValue != view {
                    oldValue?.removeFromSuperview()
                    if let view = view {
                        view.frame.size = contentView.bounds.size
                        view.clipsToBounds = true
                        contentView.addSubview(view)
                    }
                }
            }
        }

        let imageView = ImageView()
        var image: NSImage? {
            get { imageView.image }
            set {
                imageView.image = newValue
                imageView.isHidden = newValue == nil
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

            imageView.imageScaling = appliedConfiguration.imageScaling

            contentView.backgroundColor = appliedConfiguration._resolvedColor
            contentView.visualEffect = appliedConfiguration.visualEffect
            contentView.cornerRadius = appliedConfiguration.cornerRadius

            contentView.outerShadow = appliedConfiguration.shadow
            contentView.innerShadow = appliedConfiguration.innerShadow
            contentView.border = appliedConfiguration.border
            
            contentView.frame.origin.x = appliedConfiguration.insets.leading
            contentView.frame.origin.y = appliedConfiguration.insets.bottom
            contentView.frame.size.width = appliedConfiguration.insets.width
            contentView.frame.size.height = appliedConfiguration.insets.height
            view?.frame.size = contentView.bounds.size
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

#endif
