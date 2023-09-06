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

    /// The images displayed in the image view.
    open var images: [NSImage] {
        get {
            imageLayer.images
        }
        set {
            imageLayer.images = newValue
            self.invalidateIntrinsicContentSize()
        }
    }
    
    /// The currently displaying image.
    open var displayingImage: NSUIImage? {
        return self.imageLayer.displayingImage
    }

    /// The scaling of the image.
    open var imageScaling: CALayerContentsGravity {
        get {
            imageLayer.imageScaling
        }
        set {
            imageLayer.imageScaling = newValue
            layerContentsPlacement = newValue.viewLayerContentsPlacement
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

    /// Starts animating the images in the receiver.
    open func startAnimating() {
        imageLayer.startAnimating()
    }

    /// Pauses animating the images in the receiver.
    open func pauseAnimating() {
        imageLayer.pauseAnimating()
    }

    /// Stops animating the images in the receiver.
    open func stopAnimating() {
        imageLayer.stopAnimating()
    }

    /// Toggles the animation.
    open func toggleAnimating() {
        imageLayer.toggleAnimating()
    }
    
    /// Returns a Boolean value indicating whether the animation is running.
    open var isAnimating: Bool {
        return imageLayer.isAnimating
    }

    /// The amount of time it takes to go through one cycle of the images.
    open var animationDuration: TimeInterval {
        get {
            imageLayer.animationDuration
        }
        set {
            imageLayer.animationDuration = newValue
        }
    }
    
    /// A Boolean value indicating whether animatable images should automatically start animating.
    open var autoAnimates: Bool {
        get {
            imageLayer.autoAnimates
        }
        set {
            imageLayer.autoAnimates = newValue
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

    override public func makeBackingLayer() -> CALayer {
        return imageLayer
    }
    
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

    override open var intrinsicContentSize: CGSize {
        return displayingImage?.alignmentRect.size ?? super.intrinsicContentSize
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
        imageScaling = .resizeAspect
        //     self.layerContentsRedrawPolicy = .onSetNeedsDisplay
    }
}
#endif
