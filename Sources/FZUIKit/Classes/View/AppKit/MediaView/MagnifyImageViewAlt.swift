//
//  MagnifyImageViewAlt.swift
//
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A magnifiable view that displays images.
open class MagnifyImageViewAlt: FZScrollView {
    let imageView = ImageView()
    
    /// The image displayed in the image view.
    @IBInspectable open var image: NSImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    /// The images displayed by the image view.
    open var images: [NSImage] {
        get { imageView.images }
        set { imageView.images = newValue }
    }
    
    /// The currently displayed image.
    open var displayingImage: NSImage? {
        imageView.displayingImage
    }
    
    /// The image scaling.
    open var imageScaling: ImageView.ImageScaling {
        get { imageView.imageScaling }
        set { imageView.imageScaling = newValue }
    }
    
    /// The image alignment inside the image view.
    open var imageAlignment: NSImageAlignment {
        get { imageView.imageAlignment }
        set { imageView.imageAlignment = newValue }
    }
    
    /// The corner radius of the image.
    open var imageCornerRadius: CGFloat {
        get { imageView.imageCornerRadius }
        set { imageView.imageCornerRadius = newValue }
    }
    
    /// The corner curve of the image.
    open var imageCornerCurve: CALayerCornerCurve {
        get { imageView.imageCornerCurve }
        set { imageView.imageCornerCurve = newValue }
    }
    
    /// The rounded corners of the image.
    open var imageRoundedCorners: CACornerMask {
        get { imageView.imageRoundedCorners }
        set { imageView.imageRoundedCorners = newValue }
    }
    
    /// The background color of the image.
    open var imageBackgroundColor: NSColor? {
        get { imageView.imageBackgroundColor }
        set { imageView.imageBackgroundColor = newValue }
    }
    
    /// The inner shadow of the image.
    open var imageInnerShadow: ShadowConfiguration {
        get { imageView.imageInnerShadow }
        set { imageView.imageInnerShadow = newValue }
    }
    
    /// The outer shadow of the image.
    open var imageShadow: ShadowConfiguration {
        get { imageView.imageShadow }
        set { imageView.imageShadow = newValue }

    }
    
    /// The border of the image.
    open var imageBorder: BorderConfiguration {
        get { imageView.imageBorder }
        set { imageView.imageBorder = newValue }
    }
    
    /// The symbol configuration of the image.
    @available(macOS 11.0, *)
    open var symbolConfiguration: NSImage.SymbolConfiguration? {
        get { imageView.symbolConfiguration }
        set { imageView.symbolConfiguration = newValue }
    }
    
    /// The playback behavior for animated images.
    open var animationPlayback: ImageView.AnimationPlaybackOption {
        get { imageView.animationPlayback }
        set { imageView.animationPlayback = newValue }
    }
    
    /// Sets the displaying image to the specified position.
    open func setImageFrame(to position: ImageView.FramePosition) {
        imageView.setImageFrame(to: position)
    }
    
    /**
     A view for hosting layered content on top of the image view.
     
     Use this view to host content that you want layered on top of the image view. This view is managed by the image view itself and is automatically sized to fill the image view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public var overlayContentView: NSView {
        imageView.overlayContentView
    }
    
    /// The transition animation when changing the displayed image.
    open var transitionAnimation: ImageView.TransitionAnimation {
        get { imageView.transitionAnimation }
        set { imageView.transitionAnimation = newValue }
    }
    
    /// The duration of the transition animation.
    open var transitionDuration: TimeInterval {
        get { imageView.transitionDuration }
        set { imageView.transitionDuration = newValue }
    }
    
    /// Starts animating the images.
    open func startAnimating() {
        imageView.startAnimating()
    }
    
    /// Pauses animating the images.
    open func pauseAnimating() {
        imageView.pauseAnimating()
    }
    
    /// Stops animating the images and displays the first image.
    open func stopAnimating() {
        imageView.stopAnimating()
    }

    /// Returns a Boolean value that indicates whether the animation is running.
    open var isAnimating: Bool {
        imageView.isAnimating
    }

    /// Toggles the animation.
    open func toggleAnimating() {
        imageView.toggleAnimating()
    }
    
    /**
     The amount of time it takes to go through one cycle of the images.

     The time duration is measured in seconds. The default value of this property is `0.0`, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
     */
    open var animationDuration: TimeInterval {
        get { imageView.animationDuration }
        set { imageView.animationDuration = newValue }
    }
    
    /**
     Specifies the number of times to repeat the animation.

     The default value is `0`, which specifies to repeat the animation indefinitely.
     */
    open var animationRepeatCount: Int {
        get { imageView.animationRepeatCount }
        set { imageView.animationRepeatCount = newValue }
    }
    
    /// The image tint color for template and symbol images.
    @IBInspectable open var tintColor: NSColor? {
        get { imageView.tintColor }
        set { imageView.tintColor = newValue }
    }
    
    /// The dynamic range of the image.
    @available(macOS 14.0, *)
    open var imageDynamicRange: NSImage.DynamicRange {
        get { imageView.imageDynamicRange }
    }
    
    /// The preferred dynamic image range.
    @available(macOS 14.0, *)
    open var preferredImageDynamicRange: NSImage.DynamicRange {
        get { imageView.preferredImageDynamicRange }
        set { imageView.preferredImageDynamicRange = newValue }
    }
    
    /// The default preferred dynamic image range.
    @available(macOS 14.0, *)
    open class var defaultPreferredImageDynamicRange: NSImage.DynamicRange {
        get { NSImageView.defaultPreferredImageDynamicRange }
        set { NSImageView.defaultPreferredImageDynamicRange = newValue }
    }
    
    /// A value that indicates whether the user can drag new images into the image view.
    open var allowsImageDrop: ImageView.ImageDropOption {
        get { imageView.allowsImageDrop }
        set { imageView.allowsImageDrop = newValue }
    }
    
    /// A value that specifies if and how the image view can be selected.
    open var isSelectable: ImageView.SelectionOption {
        get { imageView.isSelectable }
        set { imageView.isSelectable = newValue }
    }
    
    /// A Boolean value indicating whether the image view is selected.
    open var isSelected: Bool {
        imageView.isSelected
    }
    
    /**
     A Boolean value indicating whether the image view lets the user cut, copy, and paste the image contents.

     When the value of this property is `true`, the user can cut, copy, or paste the image in the image view.
     */
    open var allowsCutCopyPaste: Bool {
        get { imageView.allowsCutCopyPaste }
        set { imageView.allowsCutCopyPaste = newValue }
    }
    
    /**
     Adds an indefinite symbol effect to the image view with the specified options and animation.
     
     - Parameters:
        - effect: The symbol effect to add.
        - options: The options for the symbol effect.
        - animated: A Boolean value that indicates whether to animate the addition of a scale, appear, or disappear effect.
    */
    @MainActor
    @available(macOS 14.0, *)
    func addSymbolEffect(
        _ effect: some IndefiniteSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
        imageView.addSymbolEffect(effect, options: options, animated: animated)
    }
    
    /**
     Adds a discrete symbol effect to the image view with the specified options and animation.
     
     - Parameters:
        - effect: The symbol effect to add.
        - options: The options for the symbol effect.
        - animated: A Boolean value that indicates whether to animate the addition of a scale, appear, or disappear effect.
    */
    @MainActor
    @available(macOS 14.0, *)
    func addSymbolEffect(
        _ effect: some DiscreteSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
        imageView.addSymbolEffect(effect, options: options, animated: animated)
    }
    
    /**
     Adds a discrete, indefinite symbol effect to the image view with the specified options and animation.
     
     - Parameters:
        - effect: The symbol effect to add.
        - options: The options for the symbol effect.
        - animated: A Boolean value that indicates whether to animate the addition of a scale, appear, or disappear effect.
     */
    @MainActor
    @available(macOS 14.0, *)
    func addSymbolEffect(
        _ effect: some DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
        imageView.addSymbolEffect(effect, options: options, animated: animated)
    }
    
    /**
     Sets a symbol image using the specified content-transition effect and options.
     
     - Parameters:
        - image: The symbol image to set.
        - contentTransition: The content transition to use when setting the symbol image.
        - options: The options to use when setting the symbol image.
     */
    @MainActor
    @available(macOS 14.0, *)
    func setSymbolImage(
        _ image: NSImage,
        contentTransition: some ContentTransitionSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default) {
            imageView.setSymbolImage(image, contentTransition: contentTransition, options: options)
    }
    
    /**
     Removes the symbol effect that matches the specified indefinite effect type, using the specified options and animation setting.
     
     - Parameters:
        - effect: The symbol effect to match for removal.
        - options: The options to use when removing the symbol effect.
        - animated: A Boolean value that indicates whether to animate the removal of a scale, appear, or disappear effect.
     */
    @MainActor
    @available(macOS 14.0, *)
    func removeSymbolEffect(
        ofType effect: some IndefiniteSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
            imageView.removeSymbolEffect(ofType: effect, options: options, animated: animated)
    }
    
    /**
     Removes the symbol effect that matches the specified discrete, indefinite effect type, using the specified options and animation setting.
     
     - Parameters:
        - effect: The symbol effect to match for removal.
        - options: The options to use when removing the symbol effect.
        - animated: A Boolean value that indicates whether to animate the removal of a scale, appear, or disappear effect.
     */
    @MainActor
    @available(macOS 14.0, *)
    func removeSymbolEffect(
        ofType effect: some DiscreteSymbolEffect & IndefiniteSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
            imageView.removeSymbolEffect(ofType: effect, options: options, animated: animated)
    }
    
    /**
     Removes the symbol effect that matches the specified discrete effect type, using the specified options and animation setting.
     
     - Parameters:
        - effect: The symbol effect to match for removal.
        - options: The options to use when removing the symbol effect.
        - animated: A Boolean value that indicates whether to animate the removal of a scale, appear, or disappear effect.
     */
    @MainActor
    @available(macOS 14.0, *)
    func removeSymbolEffect(
        ofType effect: some DiscreteSymbolEffect & SymbolEffect,
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
            imageView.removeSymbolEffect(ofType: effect, options: options, animated: animated)
    }
    
    /**
     Removes all symbol effects from the image view, using the specified options and animation setting.
     
     - Parameters:
        - options: The options to use when removing the symbol effects.
        - animated: A Boolean value that indicates whether to animate the removal of a scale, appear, or disappear effects.
     */
    @MainActor
    @available(macOS 14.0, *)
    func removeAllSymbolEffects(
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
            imageView.removeAllSymbolEffects(options: options, animated: animated)
    }
    
    /// A Boolean that indicates whether the scroll view has scrollers.
    open var hasScrollers: Bool {
        get { hasVerticalScroller }
        set {
            hasVerticalScroller = newValue
            hasHorizontalScroller = newValue
        }
    }

    /// The scroll view’s scrolling elasticity mode.
    open var scrollElasticity: NSScrollView.Elasticity {
        get { verticalScrollElasticity }
        set {
            verticalScrollElasticity = newValue
            horizontalScrollElasticity = newValue
        }
    }
    
    /**
     Returns an image view initialized with the specified image.
     
     - Parameter image: The initial image to display in the image view. You may specify an image object that contains an animated sequence of images.
     
     - Returns: An initialized image view object.
     */
    public init(image: NSImage?) {
        super.init(frame: .zero)
        sharedInit()
        imageView.image = image
    }
    
    public override init() {
        super.init(frame: .zero)
        sharedInit()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    open override var fittingSize: NSSize {
        imageView.fittingSize
    }
    
    open override var intrinsicContentSize: NSSize {
        imageView.intrinsicContentSize
    }

    override func sharedInit() {
        super.sharedInit()
        backgroundColor = .black
        imageView.frame = bounds
        documentView = imageView
    }
}

#endif
