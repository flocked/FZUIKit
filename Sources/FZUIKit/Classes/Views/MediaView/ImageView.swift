//
//  ImageView.swift
//  
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AppKit
import Foundation

open class ImageView: NSView {
    /// The image displayed in the image view.
    open var image: NSImage? {
        get {
            imageLayer.image
        }
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
        get {
            imageLayer.images
        }
        set {
            imageLayer.images = newValue
            self.invalidateIntrinsicContentSize()
        }
    }
    
    /// The currently displayed image.
    open var displayingImage: NSUIImage? {
        return self.imageLayer.displayingImage
    }

    /// The scaling of the image.
    open var imageScaling: CALayerContentsGravity {
        get { imageLayer.imageScaling }
        set { imageLayer.imageScaling = newValue
              layerContentsPlacement = newValue.viewLayerContentsPlacement
        }
    }
    
    open override func layout() {
        if imageLayer.frame.size != self.bounds.size {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = 0.0
                imageLayer.frame.size = self.bounds.size
            }
        }
    }
    
    /// A color used to tint template images.
    open var tintColor: NSColor? {
        get { self.imageLayer.tintColor }
        set { self.imageLayer.tintColor = newValue }
    }

    /// The symbol configuration to use when rendering the image.
    @available(macOS 12.0, iOS 13.0, *)
    open var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { imageLayer.symbolConfiguration }
        set { imageLayer.symbolConfiguration = newValue }
    }
    
    /// Sets the displaying image to the specified option.
    open func setFrame(to option: ImageLayer.FrameOption) {
        imageLayer.setFrame(to: option)
        self.invalidateIntrinsicContentSize()
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
        return imageLayer.isAnimating
    }

    /**
     The amount of time it takes to go through one cycle of the images.
     
     The time duration is measured in seconds. The default value of this property is 0.0, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
     */
    open var animationDuration: TimeInterval {
        get {  imageLayer.animationDuration }
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
    internal var autoAnimates: Bool {
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
            self.imageLayer.autoAnimates = (animationPlaybackOption == .automatic)
            self.updateTrackingAreas()
        }
    }
    
    private func setupMouse() {
        self.updateTrackingAreas()
    }
    
    internal var trackingArea: NSTrackingArea? = nil
    open override func updateTrackingAreas() {
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
            self.trackingArea = nil
        }
        if self.animationPlaybackOption == .mouseHover {
            self.trackingArea = NSTrackingArea(rect: self.bounds, options: [.mouseEnteredAndExited, .activeAlways ], owner: nil)
            self.addTrackingArea(trackingArea!)
        }
    }
    
    open override func mouseEntered(with event: NSEvent) {
        if animationPlaybackOption == .mouseHover {
            self.startAnimating()
        }
    }
    
    open override func mouseExited(with event: NSEvent) {
        if animationPlaybackOption == .mouseHover {
            self.stopAnimating()
        }
    }
    
    open override func mouseDown(with event: NSEvent) {
        if animationPlaybackOption == .mouseDown {
            self.toggleAnimating()
        }
    }
    
    /// The transition animation when changing images.
    open var transition: ImageLayer.Transition {
        get { imageLayer.transition }
        set { imageLayer.transition = newValue }
    }

    override open var fittingSize: NSSize {
        return imageLayer.fittingSize
    }

    open func sizeToFit() {
        frame.size = fittingSize
    }

    open func sizeThatFits(_ size: CGSize) -> CGSize {
        return imageLayer.sizeThatFits(size)
    }

    private let imageLayer = ImageLayer()

    /*
    override public func makeBackingLayer() -> CALayer {
        return imageLayer
    }
    */
    
    private var symbolImageView: NSImageView? = nil
    private func updateSymbolImageView() {
        if symbolImageView == nil {
            symbolImageView = NSImageView(frame: self.frame)
        }
        symbolImageView?.frame = self.frame
        if #available(macOS 12.0, *) {
            symbolImageView?.symbolConfiguration = self.symbolConfiguration
        }
        symbolImageView?.image = displayingImage
    }
    
    public override func alignmentRect(forFrame frame: NSRect) -> NSRect {
        updateSymbolImageView()
        let alignmentRect = symbolImageView?.alignmentRect(forFrame: frame) ?? super.alignmentRect(forFrame: frame)
        symbolImageView?.image = nil
        return alignmentRect
    }
    
    public override func frame(forAlignmentRect alignmentRect: NSRect) -> NSRect {
        updateSymbolImageView()
        let frameForAlignmentRect = symbolImageView?.frame(forAlignmentRect: alignmentRect) ?? super.frame(forAlignmentRect: alignmentRect)
        symbolImageView?.image = nil
        return frameForAlignmentRect
    }

    open override var intrinsicContentSize: CGSize {
        return imageLayer.displayingSymbolImage?.alignmentRect.size ?? displayingImage?.alignmentRect.size ?? .zero
    }
    
    public override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        imageLayer.updateDisplayingImage()
    }
    
    public override func viewDidChangeBackingProperties() {
        guard let window = self.window else { return }
        imageLayer.contentsScale = window.backingScaleFactor
    }
    
    public init() {
        super.init(frame: .zero)
        self.sharedInit()
    }

    public init(image: NSImage) {
        super.init(frame: .zero)
        self.sharedInit()
        self.image = image
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        wantsLayer = true
        self.layer?.addSublayer(imageLayer)
        imageScaling = .resizeAspect
        //     self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
}
#endif
