//
//  ImageView.swift
//  
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AppKit
import Foundation

public class ImageView: NSView {
    /// The image displayed in the image view.
    public var image: NSImage? {
        get {
            imageLayer.image
        }
        set {
            imageLayer.image = newValue
            self.invalidateIntrinsicContentSize()
        }
    }

    /// The images displayed in the image view.
    public var images: [NSImage] {
        get {
            imageLayer.images
        }
        set {
            imageLayer.images = newValue
            self.invalidateIntrinsicContentSize()
        }
    }
    
    /// The currently displaying image.
    public var displayingImage: NSUIImage? {
        return self.imageLayer.displayingImage
    }

    /// The scaling of the image.
    public var imageScaling: CALayerContentsGravity {
        get {
            imageLayer.imageScaling
        }
        set {
            imageLayer.imageScaling = newValue
            layerContentsPlacement = newValue.viewLayerContentsPlacement
        }
    }
    
    /// A color used to tint template images.
    public var tintColor: NSColor? {
        get { self.imageLayer.tintColor }
        set { self.imageLayer.tintColor = newValue }
    }

    /// The symbol configuration to use when rendering the image.
    @available(macOS 12.0, iOS 13.0, *)
    public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { imageLayer.symbolConfiguration }
        set { imageLayer.symbolConfiguration = newValue }
    }
    
    /// Sets the displaying image to the specified option.
    public func setFrame(to option: ImageLayer.FrameOption) {
        imageLayer.setFrame(to: option)
        self.invalidateIntrinsicContentSize()
    }

    /// Starts animating the images in the receiver.
    public func startAnimating() {
        imageLayer.startAnimating()
    }

    /// Pauses animating the images in the receiver.
    public func pauseAnimating() {
        imageLayer.pauseAnimating()
    }

    /// Stops animating the images in the receiver.
    public func stopAnimating() {
        imageLayer.stopAnimating()
    }

    /// Toggles the animation.
    public func toggleAnimating() {
        imageLayer.toggleAnimating()
    }
    
    /// Returns a Boolean value indicating whether the animation is running.
    public var isAnimating: Bool {
        return imageLayer.isAnimating
    }

    /// The amount of time it takes to go through one cycle of the images.
    public var animationDuration: TimeInterval {
        get {
            imageLayer.animationDuration
        }
        set {
            imageLayer.animationDuration = newValue
        }
    }
    
    /// A Boolean value indicating whether animatable images should automatically start animating.
    public var autoAnimates: Bool {
        get {
            imageLayer.autoAnimates
        }
        set {
            imageLayer.autoAnimates = newValue
        }
    }

    override public var fittingSize: NSSize {
        return imageLayer.fittingSize
    }

    public func sizeToFit() {
        frame.size = fittingSize
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        return imageLayer.sizeThatFits(size)
    }

    private let imageLayer = ImageLayer()

    override public func makeBackingLayer() -> CALayer {
        return imageLayer
    }
    
    internal var symbolImageView: NSImageView? = nil
    public override func alignmentRect(forFrame frame: NSRect) -> NSRect {
        if #available(macOS 12.0, *) {
            if let symbolConfiguration = self.symbolConfiguration, let displayingImage = displayingImage, displayingImage.isSymbolImage == true  {
                if symbolImageView == nil {
                    symbolImageView = NSImageView(frame: self.frame)
                }
                symbolImageView?.frame = self.frame
                symbolImageView?.symbolConfiguration = symbolConfiguration
                symbolImageView?.image = displayingImage
                return symbolImageView?.alignmentRect(forFrame: frame) ?? super.alignmentRect(forFrame: frame)
            }
        }
        return super.alignmentRect(forFrame: frame)
    }
    
    public override func frame(forAlignmentRect alignmentRect: NSRect) -> NSRect {
        if #available(macOS 12.0, *) {
            if let symbolConfiguration = self.symbolConfiguration, let displayingImage = displayingImage, displayingImage.isSymbolImage == true  {
                if symbolImageView == nil {
                    symbolImageView = NSImageView(frame: self.frame)
                }
                symbolImageView?.frame = self.frame
                symbolImageView?.symbolConfiguration = symbolConfiguration
                symbolImageView?.image = displayingImage
                return symbolImageView?.frame(forAlignmentRect: alignmentRect) ?? super.frame(forAlignmentRect: alignmentRect)
            }
        }
        return super.frame(forAlignmentRect: alignmentRect)
    }

    override public var intrinsicContentSize: CGSize {
        return displayingImage?.size ?? CGSize(width: NSUIView.noIntrinsicMetric, height: NSUIView.noIntrinsicMetric)
    }
    
    override public func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        imageLayer.updateDisplayingImage()
    }

    public init(image: NSImage) {
        super.init(frame: .zero)
        self.image = image
    }

    public init(image: NSImage, frame: CGRect) {
        super.init(frame: frame)
        self.image = image
    }

    public init(images: [NSImage]) {
        super.init(frame: .zero)
        self.images = images
    }

    public init(images: [NSImage], frame: CGRect) {
        super.init(frame: frame)
        self.images = images
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

    /*
     public override var wantsUpdateLayer: Bool {
     return true
     }
     */
}
#endif
