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
                guard let newValue = newValue as? NSBackgroundConfiguration, newValue != appliedConfiguration else { return }
                appliedConfiguration = newValue
                updateConfiguration()
            }
        }
        
        var appliedConfiguration: NSBackgroundConfiguration
        
        /**
         Determines whether the view is compatible with the provided configuration.
         
         - Parameter configuration: The new configuration to test for compatibility.
         - Returns: `true` if the configuration is ``NSBackgroundConfiguration``;  otherwise, `false`.
         */
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
            imageView.clipsToBounds = true
            updateConfiguration()
        }
                
        let contentView = NSView()
        let imageView = ImageView()

        var view: NSView? {
            didSet {
                guard oldValue != view else { return }
                oldValue?.removeFromSuperview()
                guard let view = view else { return }
                guard view.translatesAutoresizingMaskIntoConstraints else {
                    fatalError("NSBackgroundConfiguration's view must have translatesAutoresizingMaskIntoConstraints set to true")
                }
                contentView.addSubview(view)
            }
        }

        func updateConfiguration() {
            view = appliedConfiguration.view
            imageView.image = appliedConfiguration.image

            imageView.imageScaling = appliedConfiguration.imageScaling
            contentView.backgroundColor = appliedConfiguration._resolvedColor
            contentView.visualEffect = appliedConfiguration.visualEffect
            contentView.cornerRadius = appliedConfiguration.cornerRadius

            contentView.outerShadow = appliedConfiguration.resolvedShadow
            contentView.innerShadow = appliedConfiguration.innerShadow
            contentView.border = appliedConfiguration.resolvedBorder
            contentView.maskShape = appliedConfiguration.shape
            setNeedsLayout()
        }
        
        public override func layout() {
            super.layout()
            
            contentView.frame = bounds.inset(by: appliedConfiguration.insets)
            imageView.frame = contentView.bounds
            view?.frame = contentView.bounds
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

#endif
