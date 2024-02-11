//
//  ImageView.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
    import AppKit
    import Foundation

    open class ImageView: NSControl {
        /// The image displayed in the image view.
        open var image: NSImage? {
            get { imageLayer.image }
            set {
                imageLayer.image = newValue
                self.invalidateIntrinsicContentSize()
            }
        }

        /**
         The images displayed in the image view.

         Setting this property to an array with multiple images will remove the image represented by the image property.
         */
        open var images: [NSImage] {
            get { imageLayer.images }
            set {
                imageLayer.images = newValue
                self.invalidateIntrinsicContentSize()
            }
        }

        /// The currently displayed image.
        open var displayingImage: NSUIImage? {
            self.imageLayer.displayingImage
        }

        /// The scaling of the image.
        open var imageScaling: CALayerContentsGravity {
            get { imageLayer.imageScaling }
            set {
                guard newValue != imageScaling else { return }
                imageLayer.imageScaling = newValue
                layerContentsPlacement = newValue.viewLayerContentsPlacement
                resizeOverlayView()
            }
        }

        override open func layout() {
            if imageLayer.frame.size != bounds.size {
                NSAnimationContext.runAnimationGroup {
                    context in
                    context.duration = 0.0
                    imageLayer.frame.size = self.bounds.size
                    resizeOverlayView()
                }
            }
        }

        /// A color used to tint template images.
        open var tintColor: NSColor? {
            get { _tintColor }
            set {
                _tintColor = newValue
                updateTintColor()
            }
        }

        func updateTintColor() {
            if _backgroundStyle == .emphasized {
                imageLayer.tintColor = .alternateSelectedControlTextColor
            } else {
                imageLayer.tintColor = _tintColor?.resolvedColor(for: self)
            }
        }

        var _backgroundStyle: NSView.BackgroundStyle = .normal

        override open func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
            guard backgroundStyle != _backgroundStyle else { return }
            _backgroundStyle = backgroundStyle
            updateTintColor()
            super.setBackgroundStyle(backgroundStyle)
        }

        private var _tintColor: NSColor?

        private var _symbolConfiguration: Any?
        @available(macOS 12.0, iOS 15.0, *)
        public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { _symbolConfiguration as? NSUIImage.SymbolConfiguration }
            set {
                guard newValue != symbolConfiguration else { return }
                _symbolConfiguration = newValue
                imageLayer.symbolConfiguration = newValue
            }
        }

        @available(macOS 12.0, iOS 13.0, *)
        var resolvedSymbolConfiguration: NSUIImage.SymbolConfiguration? {
            let symbolConfiguration = symbolConfiguration
            symbolConfiguration?.colors = symbolConfiguration?.colors?.compactMap { $0.resolvedColor(for: self) }
            return symbolConfiguration
        }

        /// Sets the displaying image to the specified option.
        open func setFrame(to option: ImageLayer.FramePosition) {
            imageLayer.setFrame(to: option)
            invalidateIntrinsicContentSize()
        }

        /// Starts animating the images.
        open func startAnimating() {
            imageLayer.startAnimating()
        }

        /// Pauses animating the images.
        open func pauseAnimating() {
            imageLayer.pauseAnimating()
        }

        /// Stops animating the images and displays the first image.
        open func stopAnimating() {
            imageLayer.stopAnimating()
        }

        /// Toggles animating the images.
        open func toggleAnimating() {
            imageLayer.toggleAnimating()
        }

        /// Returns a Boolean value indicating whether the animation is running.
        open var isAnimating: Bool {
            imageLayer.isAnimating
        }

        /**
         The amount of time it takes to go through one cycle of the images.

         The time duration is measured in seconds. The default value of this property is 0.0, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
         */
        open var animationDuration: TimeInterval {
            get { imageLayer.animationDuration }
            set { imageLayer.animationDuration = newValue }
        }

        /**
         Specifies the number of times to repeat the animation.

         The default value is 0, which specifies to repeat the animation indefinitely.
         */
        open var animationRepeatCount: Int {
            get { imageLayer.animationRepeatCount }
            set { imageLayer.animationRepeatCount = newValue }
        }

        /// A Boolean value indicating whether animatable images should automatically start animating.
        var autoAnimates: Bool {
            get { imageLayer.autoAnimates }
            set { imageLayer.autoAnimates = newValue }
        }

        public enum AnimationPlaybackOption: Int {
            /// Images don't animate automatically.
            case none
            /// Images automatically start animating.
            case automatic
            /// Images start animating when the mouse enteres and stop animating when the mouse exists the view.
            case mouseHover
            /// A mouse down toggles animating the images.
            case mouseDown
        }

        public var animationPlaybackOption: AnimationPlaybackOption = .automatic {
            didSet {
                imageLayer.autoAnimates = (animationPlaybackOption == .automatic)
                updateTrackingAreas()
            }
        }

        private func setupMouse() {
            updateTrackingAreas()
        }

        var trackingArea: TrackingArea?
        override open func updateTrackingAreas() {
            if animationPlaybackOption == .mouseHover {
                if trackingArea == nil {
                    trackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeAlways])
                }
            } else {
                trackingArea = nil
            }
            trackingArea?.update()
        }

        override open func mouseEntered(with _: NSEvent) {
            if animationPlaybackOption == .mouseHover {
                startAnimating()
            }
        }

        override open func mouseExited(with _: NSEvent) {
            if animationPlaybackOption == .mouseHover {
                stopAnimating()
            }
        }

        override open func mouseDown(with event: NSEvent) {
            if animationPlaybackOption == .mouseDown {
                toggleAnimating()
            } else {
                super.mouseDown(with: event)
            }
        }

        /// The transition animation when changing images.
        open var transition: ImageLayer.Transition {
            get { imageLayer.transition }
            set { imageLayer.transition = newValue }
        }

        override open var fittingSize: NSSize {
            imageLayer.fittingSize
        }

        override open func sizeToFit() {
            frame.size = fittingSize
        }

        override open func sizeThatFits(_ size: CGSize) -> CGSize {
            imageLayer.sizeThatFits(size)
        }

        private let imageLayer = ImageLayer()

        /*
         override public func makeBackingLayer() -> CALayer {
             return imageLayer
         }
         */

        private var symbolImageView: NSImageView?
        private func updateSymbolImageView() {
            if symbolImageView == nil {
                symbolImageView = NSImageView(frame: frame)
            }
            symbolImageView?.frame = frame
            if #available(macOS 12.0, *) {
                symbolImageView?.symbolConfiguration = self.symbolConfiguration
            }
            symbolImageView?.image = displayingImage
        }

        override public func alignmentRect(forFrame frame: NSRect) -> NSRect {
            updateSymbolImageView()
            let alignmentRect = symbolImageView?.alignmentRect(forFrame: frame) ?? super.alignmentRect(forFrame: frame)
            symbolImageView?.image = nil
            return alignmentRect
        }

        override public func frame(forAlignmentRect alignmentRect: NSRect) -> NSRect {
            updateSymbolImageView()
            let frameForAlignmentRect = symbolImageView?.frame(forAlignmentRect: alignmentRect) ?? super.frame(forAlignmentRect: alignmentRect)
            symbolImageView?.image = nil
            return frameForAlignmentRect
        }

        override open var intrinsicContentSize: CGSize {
            imageLayer.displayingSymbolImage?.alignmentRect.size ?? displayingImage?.alignmentRect.size ?? .zero
        }

        override public func viewDidChangeEffectiveAppearance() {
            super.viewDidChangeEffectiveAppearance()
            updateTintColor()
            if #available(macOS 12.0, iOS 13.0, *) {
                let resolved = resolvedSymbolConfiguration
                if resolved?.colors != symbolConfiguration?.colors {
                    imageLayer.symbolConfiguration = resolved
                }
            }
        }

        override public func viewDidChangeBackingProperties() {
            guard let window = window else { return }
            imageLayer.contentsScale = window.backingScaleFactor
        }

        public init() {
            super.init(frame: .zero)
            sharedInit()
        }

        public init(image: NSImage) {
            super.init(frame: .zero)
            sharedInit()
            self.image = image
        }

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }

        /**
         A view for hosting layered content on top of the image view.

         Use this view to host content that you want layered on top of the image view. This view is managed by the image view itself and is automatically sized to fill the image view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.

         The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `initclipsToBounds` property.
         */
        public let overlayContentView = NSView()

        func resizeOverlayView() {
            if let imageSize = displayingImage?.size {
                switch imageScaling {
                case .resizeAspect:
                    if imageSize.width >= imageSize.height {
                        overlayContentView.frame.size = imageSize.scaled(toWidth: bounds.width)
                    } else {
                        overlayContentView.frame.size = imageSize.scaled(toHeight: bounds.height)
                    }
                case .resize, .resizeAspectFill:
                    overlayContentView.frame.size = bounds.size
                default:
                    overlayContentView.frame.size = imageSize
                }
                switch imageScaling {
                case .bottom:
                    overlayContentView.frame.bottom = bounds.bottom
                case .bottomLeft:
                    overlayContentView.frame.origin = .zero
                case .bottomRight:
                    overlayContentView.frame.bottomRight = bounds.bottomRight
                case .left:
                    overlayContentView.frame.left = bounds.left
                case .right:
                    overlayContentView.frame.right = bounds.right
                case .topLeft:
                    overlayContentView.frame.topLeft = bounds.topLeft
                case .top:
                    overlayContentView.frame.top = bounds.top
                case .topRight:
                    overlayContentView.frame.topRight = bounds.topRight
                default:
                    overlayContentView.center = bounds.center
                }
            } else {
                overlayContentView.frame.size = bounds.size
                overlayContentView.frame.origin = .zero
            }
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        private func sharedInit() {
            wantsLayer = true
            clipsToBounds = true
            layer?.addSublayer(imageLayer)
            imageScaling = .resizeAspect
            addSubview(overlayContentView)
            //     self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        }
    }
#endif
