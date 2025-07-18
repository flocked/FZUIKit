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
open class MagnifyImageView: NSControl {
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
        self.image = image
        return self
    }
    
    /// The images displayed by the image view.
    open var images: [NSImage] {
        get { imageView.images }
        set { imageView.images = newValue }
    }
    
    /// Sets the images displayed by the image view.
    @discardableResult
    open func images(_ images: [NSImage]) -> Self {
        self.images = images
        return self
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
        self.imageScaling = imageScaling
        return self
    }
    
    /// The image alignment inside the image view.
    open var imageAlignment: NSImageAlignment {
        get { imageView.imageAlignment }
        set { imageView.imageAlignment = newValue }
    }
    
    /// Sets the image alignment inside the image view.
    @discardableResult
    open func imageAlignment(_ alignment: NSImageAlignment) -> Self {
        self.imageAlignment = alignment
        return self
    }
    
    /// The corner radius of the image.
    open var imageCornerRadius: CGFloat {
        get { imageView.imageCornerRadius }
        set { imageView.imageCornerRadius = newValue }
    }
    
    /// Sets the corner radius of the image.
    @discardableResult
    open func imageCornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.imageCornerRadius = cornerRadius
        return self
    }
    
    /// The corner curve of the image.
    open var imageCornerCurve: CALayerCornerCurve {
        get { imageView.imageCornerCurve }
        set { imageView.imageCornerCurve = newValue }
    }
    
    /// Sets the corner curve of the image.
    @discardableResult
    open func imageCornerCurve(_ cornerCurve: CALayerCornerCurve) -> Self {
        self.imageCornerCurve = cornerCurve
        return self
    }
    
    /// The rounded corners of the image.
    open var imageRoundedCorners: CACornerMask {
        get { imageView.imageRoundedCorners }
        set { imageView.imageRoundedCorners = newValue }
    }
    
    /// Sets the rounded corners of the image.
    @discardableResult
    open func imageRoundedCorners(_ roundedCorners: CACornerMask) -> Self {
        self.imageRoundedCorners = roundedCorners
        return self
    }
    
    /// The background color of the image.
    open var imageBackgroundColor: NSColor? {
        get { imageView.imageBackgroundColor }
        set { imageView.imageBackgroundColor = newValue }
    }
    
    /// Sets the background color of the image.
    @discardableResult
    open func imageBackgroundColor(_ backgroundColor: NSColor?) -> Self {
        self.imageBackgroundColor = backgroundColor
        return self
    }
    
    /// The outer shadow of the image.
    open var imageShadow: ShadowConfiguration {
        get { imageView.imageShadow }
        set { imageView.imageShadow = newValue }

    }
    
    /// Sets the outer shadow of the image.
    @discardableResult
    open func imageShadow(_ shadow: ShadowConfiguration) -> Self {
        self.imageShadow = shadow
        return self
    }
    
    /// The inner shadow of the image.
    open var imageInnerShadow: ShadowConfiguration {
        get { imageView.imageInnerShadow }
        set { imageView.imageInnerShadow = newValue }
    }
    
    /// Sets the inner shadow of the image.
    @discardableResult
    open func imageInnerShadow(_ shadow: ShadowConfiguration) -> Self {
        self.imageInnerShadow = shadow
        return self
    }
    
    /// The border of the image.
    open var imageBorder: BorderConfiguration {
        get { imageView.imageBorder }
        set { imageView.imageBorder = newValue }
    }
    
    /// Sets the border of the image.
    @discardableResult
    open func imageBorder(_ border: BorderConfiguration) -> Self {
        self.imageBorder = border
        return self
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
        self.symbolConfiguration = symbolConfiguration
        return self
    }
    
    /// Sets the symbol configuration of the image.
    @available(macOS 12.0, *)
    @discardableResult
    open func imageSymbolConfiguration(_ symbolConfiguration: ImageSymbolConfiguration?) -> Self {
        self.symbolConfiguration = symbolConfiguration?.nsSymbolConfiguration()
        return self
    }
    
    /// The playback behavior for animated images.
    open var animationPlayback: ImageView.AnimationPlaybackOption {
        get { imageView.animationPlayback }
        set { imageView.animationPlayback = newValue }
    }
    
    /// Sets the playback behavior for animated images.
    @discardableResult
    open func animationPlayback(_ animationPlayback: ImageView.AnimationPlaybackOption) -> Self {
        self.animationPlayback = animationPlayback
        return self
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
        self.transitionAnimation = transition
        return self
    }
    
    /// The duration of the transition animation.
    open var transitionDuration: TimeInterval {
        get { imageView.transitionDuration }
        set { imageView.transitionDuration = newValue }
    }
    
    /// Sets the duration of the transition animation.
    @discardableResult
    open func transitionDuration(_ duration: TimeInterval) -> Self {
        transitionDuration = duration
        return self
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
        self.animationDuration = duration
        return self
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
        self.animationRepeatCount = repeatCount
        return self
    }
    
    /// The image tint color for template and symbol images.
    @IBInspectable open var tintColor: NSColor? {
        get { imageView.tintColor }
        set { imageView.tintColor = newValue }
    }
    
    /// Sets the image tint color for template and symbol images.
    @discardableResult
    open func tintColor(_ tintColor: NSColor?) -> Self {
        self.tintColor = tintColor
        return self
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
        preferredImageDynamicRange = dynamicRange
        return self
    }
    
    /// The default preferred dynamic image range.
    @available(macOS 14.0, *)
    open class var defaultPreferredImageDynamicRange: NSImage.DynamicRange {
        get { NSImageView.defaultPreferredImageDynamicRange }
        set { NSImageView.defaultPreferredImageDynamicRange = newValue }
    }
    
    /// A value that specifies if and how the image view can be selected.
    open var isSelectable: ImageView.SelectionOption {
        get { imageView.isSelectable }
        set { imageView.isSelectable = newValue }
    }
    
    /// Sets the value that indicates whether the image view can be selected.
    @discardableResult
    open func isSelectable(_ isSelectable: ImageView.SelectionOption) -> Self {
        self.isSelectable = isSelectable
        return self
    }
    
    /// A Boolean value indicating whether the image view is selected.
    open var isSelected: Bool {
        imageView.isSelected
    }
    
    /**
     A Boolean value indicating whether the user can drag a new image into the image view.
     
     When the value of this property is `true`, the user can set the displayed image by dragging an image onto the image view. The action is called.
     */
    open var isEditable: Bool {
        get { imageView.isEditable }
        set { imageView.isEditable = newValue }
    }
    
    /// Sets the Boolean value indicating whether the user can drag a new image into the image view.
    @discardableResult
    open func isEditable(_ isEditable: Bool) -> Self {
        self.isEditable = isEditable
        return self
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
        self.allowsCutCopyPaste = allowsCutCopyPaste
        return self
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
        self.hasScrollers = hasScrollers
        return self
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
        self.scrollElasticity = scrollElasticity
        return self
    }

    /// A Boolean value indicating whether the user can magnify the media.
    open var allowsMagnification: Bool {
        get { scrollView.allowsMagnification }
        set { scrollView.allowsMagnification = newValue }
    }
    
    /// Sets the Boolean value indicating whether the user can magnify the media.
    @discardableResult
    open func allowsMagnification(_ allows: Bool) -> Self {
        allowsMagnification = allows
        return self
    }

    /// The amount by which the media is currently scaled.
    open var magnification: CGFloat {
        get { scrollView.magnification }
        set { setMagnification(newValue) }
    }
    
    /// Sets the amount by which the media is currently scaled.
    @discardableResult
    open func magnification(_ magnification: CGFloat) -> Self {
        self.magnification = magnification
        return self
    }
    
    /// The minimum value to which the content can be magnified.
    open var minMagnification: CGFloat {
        get { scrollView.minMagnification }
        set { scrollView.minMagnification = newValue }
    }
    
    /// Sets the minimum value to which the content can be magnified.
    @discardableResult
    open func minMagnification(_ minMagnification: CGFloat) -> Self {
        self.minMagnification = minMagnification
        return self
    }

    /// The maximum value to which the content can be magnified.
    open var maxMagnification: CGFloat {
        get { self.scrollView.maxMagnification }
        set { self.scrollView.maxMagnification = newValue }
    }
    
    /// Sets the maximum value to which the content can be magnified.
    @discardableResult
    open func maxMagnification(_ maxMagnification: CGFloat) -> Self {
        self.maxMagnification = maxMagnification
        return self
    }
    
    /**
     The amount by which to zoom the image when the user presses either the plus or minus key.
     
     Specify a value of `0.0` to disable zooming via keyboard.
     */
    open var keyDownZoomFactor: CGFloat? {
        get { scrollView.keyDownZoomFactor }
        set { scrollView.keyDownZoomFactor = newValue }
    }
    
    /// Sets the amount by which to zoom the image when the user presses either the plus or minus key.
    @discardableResult
    open func keyDownZoomFactor(_ zoomFactor: CGFloat?) -> Self {
        keyDownZoomFactor = zoomFactor
        return self
    }
    
    /**
     The amount by which to momentarily zoom the image when the user holds the space key.
     
     Specify a value of `0.0` to disable zooming via space key.
     */
    open var spaceKeyZoomFactor: CGFloat? {
        get { scrollView.spaceKeyZoomFactor }
        set { scrollView.spaceKeyZoomFactor = newValue }
    }
    
    /// Sets the amount by which to momentarily zoom the image when the user holds the space key.
    @discardableResult
    open func spaceKeyZoomFactor(_ zoomFactor: CGFloat?) -> Self {
        spaceKeyZoomFactor = zoomFactor
        return self
    }
    
    /**
     The amount by which to zoom the image when the user double clicks the view.
     
     Specify a value of `0.0` to disable zooming via mouse clicks.
     */
    open var mouseClickZoomFactor: CGFloat? {
        get { scrollView.mouseClickZoomFactor }
        set { scrollView.mouseClickZoomFactor = newValue }
    }
    
    /// Sets the amount by which to zoom the image when the user double clicks the view.
    @discardableResult
    open func mouseClickZoomFactor(_ zoomFactor: CGFloat?) -> Self {
        mouseClickZoomFactor = zoomFactor
        return self
    }

    /**
     Zooms in the image by the specified factor.
     
     - Parameters:
        - factor: The amount by which to zoom in the image.
        - point: The point on which to center magnification.
     */
    public func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil) {
        scrollView.animator(isProxy()).zoomIn(factor: factor, centeredAt: centeredAt)
    }

    /**
     Zooms out the image by the specified factor.
     
     - Parameters:
        - factor: The amount by which to zoom out the image.
        - point: The point on which to center magnification.
     */
    public func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil) {
        scrollView.animator(isProxy()).zoomOut(factor: factor, centeredAt: centeredAt)
    }

    /**
     Magnifies the content by the given amount and optionally centers the result on the given point.

     - Parameters:
        - magnification: The amount by which to magnify the content.
        - point: The point (in content view space) on which to center magnification, or `nil` if the magnification shouldn't be centered.
     */
    public func setMagnification(_ magnification: CGFloat, centeredAt: CGPoint? = nil) {
        if let centeredAt = centeredAt {
            scrollView.animator(isProxy()).setMagnification(magnification, centeredAt: centeredAt)
        } else {
            scrollView.animator(isProxy()).magnification = magnification
        }
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
        imageView.actionBlock = { [weak self] _ in
            guard let self = self else { return }
            self.performAction()
        }
    }
}

#endif
