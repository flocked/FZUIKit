//
//  MagnifyImageView.swift
//
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A magnifiable view that displays images.
open class MagnifyImageView: NSView {
    let imageView = ImageView()
    let scrollView = FZScrollView()
    
    /// The image displayed in the image view.
    @IBInspectable open var image: NSImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    /// Sets the image displayed in the image view.
    @discardableResult
    open func image(_ image: NSImage?) -> Self {
        set(\.image, to: image)
    }
    
    /// The images displayed by the image view.
    open var images: [NSImage] {
        get { imageView.images }
        set { imageView.images = newValue }
    }
    
    /// Sets the images displayed by the image view.
    @discardableResult
    open func images(_ images: [NSImage]) -> Self {
        set(\.images, to: images)
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
    
    /// Sets the image scaling.
    @discardableResult
    open func imageScaling(_ imageScaling: ImageView.ImageScaling) -> Self {
        set(\.imageScaling, to: imageScaling)
    }
    
    /// The image alignment inside the image view.
    open var imageAlignment: NSImageAlignment {
        get { imageView.imageAlignment }
        set { imageView.imageAlignment = newValue }
    }
    
    /// Sets the image alignment inside the image view.
    @discardableResult
    open func imageAlignment(_ alignment: NSImageAlignment) -> Self {
        set(\.imageAlignment, to: alignment)
    }
    
    /// The corner radius of the image.
    open var imageCornerRadius: CGFloat {
        get { imageView.imageCornerRadius }
        set { imageView.imageCornerRadius = newValue }
    }
    
    /// Sets the corner radius of the image.
    @discardableResult
    open func imageCornerRadius(_ cornerRadius: CGFloat) -> Self {
        set(\.imageCornerRadius, to: cornerRadius)
    }
    
    /// The corner curve of the image.
    open var imageCornerCurve: CALayerCornerCurve {
        get { imageView.imageCornerCurve }
        set { imageView.imageCornerCurve = newValue }
    }
    
    /// Sets the corner curve of the image.
    @discardableResult
    open func imageCornerCurve(_ cornerCurve: CALayerCornerCurve) -> Self {
        set(\.imageCornerCurve, to: cornerCurve)
    }
    
    /// The rounded corners of the image.
    open var imageRoundedCorners: CACornerMask {
        get { imageView.imageRoundedCorners }
        set { imageView.imageRoundedCorners = newValue }
    }
    
    /// Sets the rounded corners of the image.
    @discardableResult
    open func imageRoundedCorners(_ roundedCorners: CACornerMask) -> Self {
        set(\.imageRoundedCorners, to: roundedCorners)
    }
    
    /// The background color of the image.
    open var imageBackgroundColor: NSColor? {
        get { imageView.imageBackgroundColor }
        set { imageView.imageBackgroundColor = newValue }
    }
    
    /// Sets the background color of the image.
    @discardableResult
    open func imageBackgroundColor(_ backgroundColor: NSColor?) -> Self {
        set(\.imageBackgroundColor, to: backgroundColor)
    }
    
    /// The outer shadow of the image.
    open var imageShadow: ShadowConfiguration {
        get { imageView.imageShadow }
        set { imageView.imageShadow = newValue }

    }
    
    /// Sets the outer shadow of the image.
    @discardableResult
    open func imageShadow(_ shadow: ShadowConfiguration) -> Self {
        set(\.imageShadow, to: shadow)
    }
    
    /// The inner shadow of the image.
    open var imageInnerShadow: ShadowConfiguration {
        get { imageView.imageInnerShadow }
        set { imageView.imageInnerShadow = newValue }
    }
    
    /// Sets the inner shadow of the image.
    @discardableResult
    open func imageInnerShadow(_ shadow: ShadowConfiguration) -> Self {
        set(\.imageInnerShadow, to: shadow)
    }
    
    /// The border of the image.
    open var imageBorder: BorderConfiguration {
        get { imageView.imageBorder }
        set { imageView.imageBorder = newValue }
    }
    
    /// Sets the border of the image.
    @discardableResult
    open func imageBorder(_ border: BorderConfiguration) -> Self {
        set(\.imageBorder, to: border)
    }
    
    /// The symbol configuration of the image.
    @available(macOS 11.0, *)
    open var symbolConfiguration: NSImage.SymbolConfiguration? {
        get { imageView.symbolConfiguration }
        set { imageView.symbolConfiguration = newValue }
    }
    
    /// Sets the symbol configuration of the image.
    @discardableResult
    @available(macOS 11.0, *)
    open func symbolConfiguration(_ symbolConfiguration: NSImage.SymbolConfiguration?) -> Self {
        set(\.symbolConfiguration, to: symbolConfiguration)
    }
    
    /// The playback behavior for animated images.
    open var animationPlayback: ImageView.AnimationPlaybackOption {
        get { imageView.animationPlayback }
        set { imageView.animationPlayback = newValue }
    }
    
    /// Sets the playback behavior for animated images.
    @discardableResult
    open func animationPlayback(_ animationPlayback: ImageView.AnimationPlaybackOption) -> Self {
        set(\.animationPlayback, to: animationPlayback)
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
    
    /// Sets the transition animation when changing the displayed image.
    @discardableResult
    open func transitionAnimation(_ transition: ImageView.TransitionAnimation) -> Self {
        set(\.transitionAnimation, to: transition)
    }
    
    /// The duration of the transition animation.
    open var transitionDuration: TimeInterval {
        get { imageView.transitionDuration }
        set { imageView.transitionDuration = newValue }
    }
    
    /// Sets the duration of the transition animation.
    @discardableResult
    open func transitionDuration(_ duration: TimeInterval) -> Self {
        set(\.transitionDuration, to: duration)
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
    
    /// Sets the amount of time it takes to go through one cycle of an animated image.
    @discardableResult
    open func animationDuration(_ duration: TimeInterval) -> Self {
        set(\.animationDuration, to: duration)
    }
    
    /**
     Specifies the number of times to repeat the animation.

     The default value is `0`, which specifies to repeat the animation indefinitely.
     */
    open var animationRepeatCount: Int {
        get { imageView.animationRepeatCount }
        set { imageView.animationRepeatCount = newValue }
    }
    
    /// Sets the number of times to repeat the animation.
    @discardableResult
    open func animationRepeatCount(_ repeatCount: Int) -> Self {
        set(\.animationRepeatCount, to: repeatCount)
    }
    
    /// The image tint color for template and symbol images.
    @IBInspectable open var tintColor: NSColor? {
        get { imageView.tintColor }
        set { imageView.tintColor = newValue }
    }
    
    /// Sets the image tint color for template and symbol images.
    @discardableResult
    open func tintColor(_ tintColor: NSColor?) -> Self {
        set(\.tintColor, to: tintColor)
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
    
    /// Sets the preferred dynamic image range.
    @discardableResult
    @available(macOS 14.0, *)
    open func preferredImageDynamicRange(_ dynamicRange: NSImage.DynamicRange) -> Self {
        set(\.preferredImageDynamicRange, to: dynamicRange)
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
    
    /// Sets the value that indicates whether the user can drag new images into the image view.
    @discardableResult
    open func allowsImageDrop(_ allowsImageDrop: ImageView.ImageDropOption) -> Self {
        set(\.allowsImageDrop, to: allowsImageDrop)
    }
    
    /// A value that specifies if and how the image view can be selected.
    open var isSelectable: ImageView.SelectionOption {
        get { imageView.isSelectable }
        set { imageView.isSelectable = newValue }
    }
    
    /// Sets the value that indicates whether the image view can be selected.
    @discardableResult
    open func isSelectable(_ isSelectable: ImageView.SelectionOption) -> Self {
        set(\.isSelectable, to: isSelectable)
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
    
    /// Sets the Boolean value indicating whether the image view lets the user cut, copy, and paste the image contents.
    @discardableResult
    open func allowsCutCopyPaste(_ allowsCutCopyPaste: Bool) -> Self {
        set(\.allowsCutCopyPaste, to: allowsCutCopyPaste)
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
    open func addSymbolEffect(
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
    open func addSymbolEffect(
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
    open func addSymbolEffect(
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
    open func setSymbolImage(
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
    open func removeSymbolEffect(
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
    open func removeSymbolEffect(
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
    open func removeSymbolEffect(
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
    open func removeAllSymbolEffects(
        options: SymbolEffectOptions = .default,
        animated: Bool = true) {
            imageView.removeAllSymbolEffects(options: options, animated: animated)
    }
    
    // MARK: - Scroll
    
    /// A Boolean that indicates whether the media view has scrollers.
    open var hasScrollers: Bool {
        get { scrollView.hasVerticalScroller }
        set {
            scrollView.hasVerticalScroller = newValue
            scrollView.hasHorizontalScroller = newValue
        }
    }
    
    /// Sets the Boolean that indicates whether the media view has scrollers.
    @discardableResult
    open func hasScrollers(_ hasScrollers: Bool) -> Self {
        set(\.hasScrollers, to: hasScrollers)
    }

    /// The scrolling elasticity mode.
    open var scrollElasticity: NSScrollView.Elasticity {
        get { scrollView.verticalScrollElasticity }
        set {
            scrollView.verticalScrollElasticity = newValue
            scrollView.horizontalScrollElasticity = newValue
        }
    }
    
    /// Sets the scrolling elasticity mode.
    @discardableResult
    open func scrollElasticity(_ scrollElasticity: NSScrollView.Elasticity) -> Self {
        set(\.scrollElasticity, to: scrollElasticity)
    }

    /// A Boolean value indicating whether the user can magnify the media.
    open var allowsMagnification: Bool {
        get { scrollView.allowsMagnification }
        set { scrollView.allowsMagnification = newValue }
    }
    
    /// Sets the Boolean value indicating whether the user can magnify the media.
    @discardableResult
    open func allowsMagnification(_ allows: Bool) -> Self {
        set(\.allowsMagnification, to: allows)
    }

    /// The amount by which the media is currently scaled.
    open var magnification: CGFloat {
        get { scrollView.magnification }
        set { setMagnification(newValue) }
    }
    
    /// Sets the amount by which the media is currently scaled.
    @discardableResult
    open func magnification(_ magnification: CGFloat) -> Self {
        set(\.magnification, to: magnification)
    }
    
    /// The minimum value to which the content can be magnified.
    open var minMagnification: CGFloat {
        get { scrollView.minMagnification }
        set { scrollView.minMagnification = newValue }
    }
    
    /// Sets the minimum value to which the content can be magnified.
    @discardableResult
    open func minMagnification(_ minMagnification: CGFloat) -> Self {
        set(\.minMagnification, to: minMagnification)
    }

    /// The maximum value to which the content can be magnified.
    open var maxMagnification: CGFloat {
        get { self.scrollView.maxMagnification }
        set { self.scrollView.maxMagnification = newValue }
    }
    
    /// Sets the maximum value to which the content can be magnified.
    @discardableResult
    open func maxMagnification(_ maxMagnification: CGFloat) -> Self {
        set(\.maxMagnification, to: maxMagnification)
    }
    
    /**
     The amount by which to zoom the image when the user presses either the plus or minus key.
     
     Specify a value of `0.0` to disable zooming via keyboard.
     */
    open var keyDownZoomFactor: CGFloat {
        get { scrollView.keyDownZoomFactor }
        set { scrollView.keyDownZoomFactor = newValue }
    }
    
    /// Sets the amount by which to zoom the image when the user presses either the plus or minus key.
    @discardableResult
    open func keyDownZoomFactor(_ zoomFactor: CGFloat) -> Self {
        set(\.keyDownZoomFactor, to: zoomFactor)
    }
    
    /**
     The amount by which to momentarily zoom the image when the user holds the space key.
     
     Specify a value of `0.0` to disable zooming via space key.
     */
    open var spaceKeyZoomFactor: CGFloat {
        get { scrollView.spaceKeyZoomFactor }
        set { scrollView.spaceKeyZoomFactor = newValue }
    }
    
    /// Sets the amount by which to momentarily zoom the image when the user holds the space key.
    @discardableResult
    open func spaceKeyZoomFactor(_ zoomFactor: CGFloat) -> Self {
        set(\.spaceKeyZoomFactor, to: zoomFactor)
    }
    
    /**
     The amount by which to zoom the image when the user double clicks the view.
     
     Specify a value of `0.0` to disable zooming via mouse clicks.
     */
    open var mouseClickZoomFactor: CGFloat {
        get { scrollView.mouseClickZoomFactor }
        set { scrollView.mouseClickZoomFactor = newValue }
    }
    
    /// Sets the amount by which to zoom the image when the user double clicks the view.
    @discardableResult
    open func mouseClickZoomFactor(_ zoomFactor: CGFloat) -> Self {
        set(\.mouseClickZoomFactor, to: zoomFactor)
    }

    open func scroll(to point: CGPoint) {
        scrollView.contentView.setBoundsOrigin(point)
        scrollView.scroll(scrollView.contentView, to: point)
    }

    open func scroll(to point: CGPoint, animationDuration: TimeInterval) {
        scrollView.scroll(point, animationDuration: animationDuration)
    }

    /**
     Zooms in the image by the specified factor.
     
     - Parameters:
        - factor: The amount by which to zoom in the image.
        - point: The point on which to center magnification.
        - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
     */
    open func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        zoom(factor: factor, centeredAt: centeredAt, animationDuration: animationDuration)
    }

    /**
     Zooms out the image by the specified factor.
     
     - Parameters:
        - factor: The amount by which to zoom out the image.
        - point: The point on which to center magnification.
        - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
     */
    open func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        scrollView.zoom()
        zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
    }

    func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        if allowsMagnification {
            let range = maxMagnification - minMagnification
            if range > 0.0 {
                let factor = factor.clamped(to: -1.0 ... 1.0)
                let newMag = (magnification + (range * factor)).clamped(to: minMagnification ... maxMagnification)
                setMagnification(newMag, centeredAt: centeredAt, animationDuration: animationDuration)
                var point = CGPoint.zero
                point.x = bounds.size.width / 2.0
                point.y = bounds.size.height / 2.0
                scrollView.contentOffset = point
            }
        }
    }

    /**
     Magnifies the content by the given amount and optionally centers the result on the given point.

     - Parameters:
        - magnification: The amount by which to magnify the content.
        - point: The point (in content view space) on which to center magnification, or `nil` if the magnification shouldn't be centered.
        - animationDuration: The animation duration of the magnification, or `nil` if the magnification shouldn't be animated.
     */
    open func setMagnification(_ magnification: CGFloat, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        scrollView.setMagnification(magnification, centeredAt: centeredAt, animationDuration: animationDuration)
        if magnification == 1.0 {
            scrollElasticity = .none
            hasScrollers = false
        } else {
            hasScrollers = true
            scrollElasticity = .automatic
        }
    }

    open override var enclosingScrollView: NSScrollView? {
        scrollView
    }
    
    open override func layout() {
        super.layout()
        scrollView.frame = bounds
    }
    
    // MARK: - Init
    
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
    
    public init() {
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

    func sharedInit() {
        backgroundColor = .black
        imageView.frame = bounds
        scrollView.frame = bounds
        scrollView.documentView = imageView
        addSubview(scrollView)
    }
}

#endif
