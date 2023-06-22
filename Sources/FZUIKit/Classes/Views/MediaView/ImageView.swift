//
//  NewImageVIew.swift
//  FZCollection
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AppKit
import Foundation

open class ImageView: NSView {
    open var contentTintColor: NSColor? {
        get { self.imageLayer.contentTintColor }
        set { self.imageLayer.contentTintColor = newValue }
    }

    override open func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        imageLayer.updateDisplayingImageSymbolConfiguration()
    }

    open var image: NSImage? {
        get {
            imageLayer.image
        }
        set {
            imageLayer.image = newValue
        }
    }

    open var images: [NSImage] {
        get {
            imageLayer.images
        }
        set {
            imageLayer.images = newValue
        }
    }

    open var imageScaling: CALayerContentsGravity {
        get {
            imageLayer.imageScaling
        }
        set {
            imageLayer.imageScaling = newValue
            layerContentsPlacement = newValue.viewLayerContentsPlacement
        }
    }

    @available(macOS 12.0, iOS 13.0, *)
    open var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { imageLayer.symbolConfiguration }
        set { imageLayer.symbolConfiguration = newValue }
    }

    open var autoAnimates: Bool {
        get {
            imageLayer.autoAnimates
        }
        set {
            imageLayer.autoAnimates = newValue
        }
    }

    open var animationDuration: TimeInterval {
        get {
            imageLayer.animationDuration
        }
        set {
            imageLayer.animationDuration = newValue
        }
    }

    open var isAnimating: Bool {
        return imageLayer.isAnimating
    }

    open func startAnimating() {
        imageLayer.startAnimating()
    }

    open func pauseAnimating() {
        imageLayer.pauseAnimating()
    }

    open func stopAnimating() {
        imageLayer.stopAnimating()
    }

    open func toggleAnimating() {
        imageLayer.toggleAnimating()
    }

    open func setFrame(to option: ImageLayer.FrameOption) {
        imageLayer.setFrame(to: option)
    }

    open func setGif(image: NSImage) {
        imageLayer.setGif(image: image)
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

    override open func makeBackingLayer() -> CALayer {
        return imageLayer
    }

    open var displayingImage: NSUIImage? {
        return self.imageLayer.displayingImage
    }

    override open var intrinsicContentSize: CGSize {
        return displayingImage?.size ?? CGSize(width: NSUIView.noIntrinsicMetric, height: NSUIView.noIntrinsicMetric)
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
     open override var wantsUpdateLayer: Bool {
     return true
     }
     */
}
#endif
