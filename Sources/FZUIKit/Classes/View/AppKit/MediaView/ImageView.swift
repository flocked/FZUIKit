//
//  ImageView.swift
//
//
//  Created by Florian Zand on 13.03.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/// An enhanced image view.
@IBDesignable
open class ImageView: NSControl {
    
    let containerView = NSView()
    let imageView = NSImageView()
    var timer: DisplayLinkTimer? = nil
    var currentRepeatCount = 0
    var ignoreTransition = false
    var trackingArea: TrackingArea?
    let imageShadowView = NSView()
    
    /// The image displayed in the image view.
   @IBInspectable open var image: NSImage? {
       get { images.count == 1 ? images.first : animatedImage?.image }
        set {
            guard newValue != image else { return }
            if let newImage = newValue {
                if let animated = AnimatedImage(newImage) {
                    images = []
                    animatedImage = animated
                } else {
                    images = [newImage]
                }
            } else {
                images = []
            }
        }
    }

    /// The images displayed by the image view.
    open var images: [NSImage] = [] {
        didSet {
            animatedImage = nil
            imagesUpdated()
        }
    }
    
    var animatedImage: AnimatedImage? = nil {
        didSet {
            if let animatedImage = animatedImage {
                animationDuration = animatedImage.duration
                animationRepeatCount = animatedImage.loopCount
                imagesUpdated()
            }
        }
    }
    
    func imagesUpdated() {
        containerView.isHidden = imagesCount == 0
        imageShadowView.isHidden = containerView.isHidden
        overlayContentView.isHidden = containerView.isHidden
        stopAnimating()
        currentImageIndex = 0
        if isAnimatable, animationPlayback == .automatic {
            startAnimating()
        }
    }
    
    /// The currently displayed image.
    open var displayingImage: NSImage? {
        image ?? animatedImage?[currentImageIndex] ?? images[safe: currentImageIndex]
    }
    
    /// The image scaling.
    open var imageScaling: ImageScaling = .scaleToFit {
        didSet {
            guard oldValue != imageScaling else { return }
            imageView.imageScaling = imageScaling.nsImageScaling
            layout()
        }
    }
    
    /// Constants that specify the image scaling behavior.
    public enum ImageScaling {
        /// The image is resized to fit the entire bounds rectangle.
        case resize
        /// The image is resized to completely fill the bounds rectangle, while still preserving the aspect of the content.
        case scaleToFill
        /// The image is resized to fit the bounds rectangle, preserving the aspect of the content.
        case scaleToFit
        /// The image isn't resized.
        case none
        
        var nsImageScaling: NSImageScaling {
            switch self {
            case .resize: return .scaleAxesIndependently
            case .none: return .scaleNone
            default: return .scaleProportionallyUpOrDown
            }
        }
    }
    
    /// The image alignment inside the image view.
    open var imageAlignment: NSImageAlignment = .alignCenter {
        didSet {
            guard oldValue != imageAlignment else { return }
            imageView.imageAlignment = imageAlignment
            layout()
        }
    }
    
    /// The corner radius of the image.
    open var imageCornerRadius: CGFloat {
        get { containerView.cornerRadius }
        set { 
            containerView.cornerRadius = newValue
            imageShadowView.cornerRadius = newValue
        }
    }
    
    /// The corner curve of the image.
    open var imageCornerCurve: CALayerCornerCurve {
        get { containerView.cornerCurve }
        set { 
            containerView.cornerCurve = newValue
            imageShadowView.cornerCurve = newValue
        }
    }
    
    /// The rounded corners of the image.
    open var imageRoundedCorners: CACornerMask {
        get { containerView.roundedCorners }
        set { 
            containerView.roundedCorners = newValue
            imageShadowView.roundedCorners = newValue
        }
    }
    
    /// The background color of the image.
    open var imageBackgroundColor: NSColor? {
        get { containerView.backgroundColor }
        set { containerView.backgroundColor = newValue }
    }
    
    /// The inner shadow of the image.
    open var imageInnerShadow: ShadowConfiguration {
        get { containerView.innerShadow }
        set { containerView.innerShadow = newValue }
    }
    
    /// The outer shadow of the image.
    open var imageShadow: ShadowConfiguration {
        get { imageShadowView.outerShadow }
        set { 
            imageShadowView.outerShadow = newValue
            imageShadowView.backgroundColor = newValue.resolvedColor()
        }
    }
    
    /// The border of the image.
    open var imageBorder: BorderConfiguration {
        get { containerView.border }
        set { containerView.border = newValue }
    }
    
    /// The symbol configuration of the image.
    @available(macOS 11.0, *)
    open var symbolConfiguration: NSImage.SymbolConfiguration? {
        get { imageView.symbolConfiguration }
        set { imageView.symbolConfiguration = newValue }
    }
    
    /// Constants that specify the playback behavior for animated images.
    public enum AnimationPlaybackOption: Int, Hashable {
        /// Images don't start animate automatically.
        case none
        /// Images start animating automatically.
        case automatic
        /// Images start animating when the mouse enteres the view and stop animating when the mouse exists the view.
        case onMouseHover
        /// A mouse down click toggles animating the images.
        case onMouseClick
    }

    /// The playback behavior for animated images.
    open var animationPlayback: AnimationPlaybackOption = .automatic {
        didSet {
            guard oldValue != animationPlayback else { return }
            if animationPlayback == .automatic {
                startAnimating()
            } else {
                stopAnimating()
            }
            if animationPlayback == .onMouseHover {
                trackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeAlways])
                updateTrackingAreas()
            } else {
                trackingArea = nil
            }
        }
    }
    
    open override func updateTrackingAreas() {
        trackingArea?.update()
        super.updateTrackingAreas()
    }
    
    override open func mouseEntered(with event: NSEvent) {
        if animationPlayback == .onMouseHover {
            startAnimating()
        }
    }

    override open func mouseExited(with event: NSEvent) {
        if animationPlayback == .onMouseHover {
            stopAnimating()
        }
    }
    
    open override func becomeFirstResponder() -> Bool {
        if acceptsFirstResponder, !isSelected {
            isSelected = true
        }
        return acceptsFirstResponder
    }
    
    open override func resignFirstResponder() -> Bool {
        if isSelected {
            isSelected = false
        }
        return true
    }
    
    override open func mouseDown(with event: NSEvent) {
        if isSelectable == .byView, !isFirstResponder {
            makeFirstResponder()
            performAction()
        } else if isSelectable == .byImage, overlayContentView.frame.contains(event.location(in: self)), !isFirstResponder {
            makeFirstResponder()
            performAction()
        }
        if animationPlayback == .onMouseClick, overlayContentView.frame.contains(event.location(in: self)) {
            toggleAnimating()
        }
    }
    
    var currentImageIndex = 0 {
        didSet {
            updateDisplayingImage()
        }
    }
    
    func updateDisplayingImage() {
        if !ignoreTransition, let transition = transitionAnimation.transition(transitionDuration) {
            self.transition(transition)
        }
        let oldImageSize = imageView.image?.size
        if let animatedImage = animatedImage {
            imageView.image = animatedImage[currentImageIndex]
        } else {
            imageView.image = displayingImage
        }
        if oldImageSize != imageView.image?.size {
            layout()
        }
    }
    
    var imagesCount: Int {
        animatedImage?.count ?? images.count
    }
    
    /// The image frame position.
    public enum FramePosition: Hashable {
        /// The first image.
        case first
        /// The last image.
        case last
        /// A random image.
        case random
        /// The next image.
        case next
        /// The next image looped.
        case nextLooped
        /// The previous image.
        case previous
        /// The previous image looped.
        case previousLooped
        /// The image at the index.
        case index(Int)
    }
    
    /// Sets the displaying image to the specified position.
    open func setImageFrame(to position: FramePosition) {
        guard imagesCount > 0 else { return }
        switch position {
        case let .index(index):
            if index >= 0, index < imagesCount {
                currentImageIndex = index
            }
        case .first:
            currentImageIndex = 0
        case .last:
            currentImageIndex = imagesCount - 1
        case .random:
            currentImageIndex = Int.random(in: 0 ... imagesCount - 1)
        case .next:
            currentImageIndex += 1
            if currentImageIndex >= imagesCount {
                currentImageIndex = imagesCount - 1
            }
        case .nextLooped:
            currentImageIndex += 1
            if currentImageIndex >= imagesCount {
                currentImageIndex = 0
            }
        case .previous:
            currentImageIndex -= 1
            if currentImageIndex < 0 {
                currentImageIndex = 0
            }
        case .previousLooped:
            currentImageIndex -= 1
            if currentImageIndex < 0 {
                currentImageIndex = imagesCount - 1
            }
        }
    }
    
    /**
     A view for hosting layered content on top of the image view.
     
     Use this view to host content that you want layered on top of the image view. This view is managed by the image view itself and is automatically sized to fill the image view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public let overlayContentView = NSView()
    
    /**
     The current size and position of the image that displays within the image view’s bounds.
     
     Use this property to determine the display dimensions of the image within the image view’s bounds. The size and position of this rectangle depends on the image scaling and alignment.
     */
    public var imageBounds: CGRect {
        overlayContentView.frame
    }
    
    /// The transition animation when changing the displayed image.
    open var transitionAnimation: TransitionAnimation = .none
    
    /// The duration of the transition animation.
    open var transitionDuration: TimeInterval = 0.2
    
    /// Constants that specify the transition animation when changing between displayed images.
    public enum TransitionAnimation: Hashable, CustomStringConvertible {
        /// No transition animation.
        case none
        /// The new image fades in.
        case fade
        /// The new image slides into place over any existing image from the specified direction.
        case moveIn(_ direction: Direction = .fromLeft)
        /// The new image pushes any existing image as it slides into place from the specified direction.
        case push(_ direction: Direction = .fromLeft)
        /// The new image is revealed gradually in the specified direction.
        case reveal(_ direction: Direction = .fromLeft)
        
        /// The direction of the transition.
        public enum Direction: String, Hashable {
            /// From left.
            case fromLeft
            /// From right.
            case fromRight
            /// From bottom.
            case fromBottom
            /// From top.
            case fromTop
            var subtype: CATransitionSubtype {
                CATransitionSubtype(rawValue: rawValue)
            }
        }
        
        public var description: String {
            switch self {
            case .none: return "TransitionAnimation.none"
            case .fade: return "TransitionAnimation.fade"
            case .moveIn(let direction): return "TransitionAnimation.moveIn(\(direction.rawValue))"
            case .push(let direction): return "TransitionAnimation.push(\(direction.rawValue))"
            case .reveal(let direction): return "TransitionAnimation.reveal(\(direction.rawValue))"
            }
        }
        
        var type: CATransitionType? {
            switch self {
            case .fade: return .fade
            case .moveIn: return .moveIn
            case .push: return .push
            case .reveal: return .reveal
            case .none: return nil
            }
        }
        
        var subtype: CATransitionSubtype? {
            switch self {
            case .moveIn(let direction), .push(let direction), .reveal(let direction):
                return direction.subtype
            default: return nil
            }
        }
        
        func transition(_ duration: TimeInterval) -> CATransition? {
            guard let type = type else { return nil }
            return CATransition(type, subtype: subtype, duration: duration)
        }
    }
    
    /// Starts animating the images.
    open func startAnimating() {
        guard isAnimatable, !isAnimating else { return }
        currentRepeatCount = 0
        
        timer = DisplayLinkTimer(timeInterval: .seconds(timerInterval), repeating: true) { [weak self] timer in
            guard let self = self else { return }
            self.ignoreTransition = true
            self.setImageFrame(to: .nextLooped)
            self.ignoreTransition = false
            
            if self.animationRepeatCount != 0, self.currentImageIndex == 0 {
                self.currentRepeatCount += 1
            }
            if self.animationRepeatCount != 0, self.currentRepeatCount >= self.animationRepeatCount {
                self.timer?.stop()
                self.timer = nil
                self.currentRepeatCount = 0
            }
        }
    }

    /// Pauses animating the images.
    open func pauseAnimating() {
        timer?.stop()
        timer = nil
    }

    /// Stops animating the images and displays the first image.
    open func stopAnimating() {
        pauseAnimating()
        setImageFrame(to: .first)
    }

    /// Returns a Boolean value that indicates whether the animation is running.
    open var isAnimating: Bool {
        timer != nil
    }

    /// Toggles the animation.
    open func toggleAnimating() {
        if isAnimatable {
            if isAnimating {
                pauseAnimating()
            } else {
                startAnimating()
            }
        }
    }
    
    var timerInterval: TimeInterval {
        if animationDuration == 0.0 {
            return ImageSource.defaultFrameDuration / Double(imagesCount)
        } else {
            return animationDuration / Double(imagesCount)
        }
    }

    var isAnimatable: Bool {
        imagesCount > 1
    }

    /**
     The amount of time it takes to go through one cycle of the images.

     The time duration is measured in seconds. The default value of this property is `0.0`, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
     */
    open var animationDuration: TimeInterval = 0.0 {
        didSet {
            timer?.timeInterval.seconds = timerInterval
        }
    }
    
    /**
     Specifies the number of times to repeat the animation.

     The default value is `0`, which specifies to repeat the animation indefinitely.
     */
    open var animationRepeatCount: Int = 0
    
    /// The image tint color for template and symbol images.
    @IBInspectable open var tintColor: NSColor? {
        get { imageView.contentTintColor }
        set { imageView.contentTintColor = newValue }
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
   
    /// Constant that indicates whether the user can drag new images into the image view.
    public enum ImageDropOption: Int, Hashable {
        /// The user can drag a single image into the image view.
        case single
        /// The user can drag multiple images into the image view.
        case multiple
        /// The user can't drag any image into the image view.
        case none
    }
    
    /// A value that indicates whether the user can drag new images into the image view.
    open var allowsImageDrop: ImageDropOption  = .none {
        didSet {
            guard oldValue != allowsImageDrop else { return }
            if allowsImageDrop == .none {
                overlayContentView.dropHandlers.canDrop = nil
                overlayContentView.dropHandlers.didDrop = nil
            } else if overlayContentView.dropHandlers.canDrop == nil {
                overlayContentView.dropHandlers.canDrop = { [weak self] contents,_,_ in
                    guard let self = self else { return false }
                    switch self.allowsImageDrop {
                    case .single:
                        return contents.images.count == 1
                    case .multiple:
                        return !contents.images.isEmpty
                    case .none:
                        return false
                    }
                }
                overlayContentView.dropHandlers.didDrop = { [weak self] contents,_,_ in
                    guard let self = self else { return }
                    let droppedImages = contents.images
                    switch self.allowsImageDrop {
                    case .single:
                        guard droppedImages.count == 1 else { return }
                        self.image = droppedImages.first
                    case .multiple:
                        guard !droppedImages.isEmpty else { return }
                        self.images = droppedImages
                    case .none: break
                    }
                }
            }
        }
    }
    
    /*
    /**
     A Boolean value indicating whether the user can drag a new image into the image view.
     
     When the value of this property is true, the user can set the displayed image by dragging an image onto the image view. The default value of this property is false, which causes the image view to display only the programmatically set image.
     */
    open var isEditable: Bool {
        get { imageView.isEditable }
        set { imageView.isEditable = newValue }
    }
     */
    
    /// A value that indicates whether the image view can be selected.
    open var isSelectable: SelectionOption = false {
        didSet {
            guard isSelectable != oldValue else { return }
            if isSelectable == .off {
                resignFirstResponding()
            }
        }
    }
    
    /// Constant that indicates whether the user can select the image view.
    public enum SelectionOption: Int, ExpressibleByBooleanLiteral {
        /// The user can select the image view by clickling the image.
        case byImage
        /// The user can select the image view by clickling the image view.
        case byView
        /// The user can't select the image.
        case off
        
        public init(booleanLiteral value: Bool) {
            self = value ? .byView : .off
        }
    }
    
    /// A Boolean value indicating whether the image view is selected.
    @objc dynamic open internal(set) var isSelected: Bool = false

    
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
        imageShadowView.clipsToBounds = false
        addSubview(imageShadowView)
        
        imageView.frame = bounds
        imageView.animates = false
        imageView.imageScaling = imageScaling.nsImageScaling
        imageView.imageAlignment = imageAlignment
        
        containerView.frame = bounds
        containerView.clipsToBounds = true
        addSubview(containerView)
        containerView.addSubview(imageView)
        
        overlayContentView.frame = bounds
        containerView.addSubview(overlayContentView)
    }
    
    open override func layout() {
        super.layout()
        guard displayingImage != nil else { return }
        if imageScaling == .scaleToFill, let imageSize = displayingImage?.size {
            imageView.frame.size = imageSize.scaled(toFill: bounds.size)
                        
            switch imageAlignment {
            case .alignTopLeft:
                imageView.frame.topLeft = bounds.topLeft
            case .alignTop:
                imageView.frame.topCenter = bounds.topCenter
            case .alignTopRight:
                imageView.frame.topRight = bounds.topRight
            case .alignBottomLeft:
                imageView.frame.bottomLeft = bounds.bottomLeft
            case .alignBottom:
                imageView.frame.bottomCenter = bounds.bottomCenter
            case .alignBottomRight:
                imageView.frame.bottomRight = bounds.bottomRight
            case .alignLeft:
                imageView.frame.centerLeft = bounds.centerLeft
            case .alignRight:
                imageView.frame.centerRight = bounds.centerRight
            default:
                imageView.center = bounds.center
            }
            containerView.frame.origin.x = imageView.frame.x.clamped(min: 0)
            containerView.frame.origin.y = imageView.frame.y.clamped(min: 0)
            containerView.frame.size.width = imageView.frame.size.width.clamped(to: 0...bounds.width)
            containerView.frame.size.height = imageView.frame.size.height.clamped(to: 0...bounds.height)
        } else {
            imageView.frame = bounds
            containerView.frame = imageView.imageBounds
            imageView.frame = containerView.bounds
        }
        imageShadowView.frame = containerView.frame
        overlayContentView.frame = containerView.frame
    }
    
    override open func alignmentRect(forFrame frame: NSRect) -> NSRect {
        imageView.alignmentRect(forFrame: frame)
    }

    override open func frame(forAlignmentRect alignmentRect: NSRect) -> NSRect {
        imageView.frame(forAlignmentRect: alignmentRect)
    }
    
    open override var firstBaselineOffsetFromTop: CGFloat {
        imageView.firstBaselineOffsetFromTop
    }
    
    open override var lastBaselineOffsetFromBottom: CGFloat {
        imageView.lastBaselineOffsetFromBottom
    }
    
    open override var baselineOffsetFromBottom: CGFloat {
        imageView.baselineOffsetFromBottom
    }
    
    open override var firstBaselineAnchor: NSLayoutYAxisAnchor {
        get { imageView.firstBaselineAnchor }
    }
    
    open override var lastBaselineAnchor: NSLayoutYAxisAnchor {
        get { imageView.lastBaselineAnchor }
    }
    
    override open var acceptsFirstResponder: Bool { isSelectable != .off }
        
    override open func drawFocusRingMask() {
        NSBezierPath(roundedRect: focusRingMaskBounds, cornerRadius: isSelectable == .byImage ?  imageCornerRadius : cornerRadius).fill()
    }
    
    override open var focusRingMaskBounds: NSRect {
        isSelectable == .byImage ? overlayContentView.frame : bounds
    }
    
    class AnimatedImage {
        
        struct Frame {
            let image: NSImage?
            let duration: TimeInterval
            init(_ image: NSImage? = nil, duration: TimeInterval) {
                self.image = image
                self.duration = duration
            }
        }
                
        init?(_ image: NSImage) {
            guard let representation = image.bitmapImageRep, representation.frameCount > 1 else { return nil }
            self.image = image
            self.count = representation.frameCount
            self.loopCount = representation.loopCount
            for index in 0..<self.count {
                representation.currentFrame = index
                var frameDuration = representation.currentFrameDuration
                if frameDuration == .zero {
                    frameDuration = ImageSource.defaultFrameDuration
                }
                duration += frameDuration
                frames.append(Frame(nil, duration: frameDuration))
            }
            representation.currentFrame = 0
            
            DispatchQueue(label: "com.fzuikit.animatedImageQueue").async {
                for index in 0..<self.count {
                    representation.currentFrame = index
                    self.frames[index] = Frame(representation.cgImage?.nsImage, duration: self.frames[index].duration)
                }
            }
        }
        
        subscript(index: Int) -> NSImage? {
            frames[safe: index]?.image
        }
        
        let count: Int
        let loopCount: Int
        var duration: TimeInterval = 0.0
        let image: NSImage
        var frames: SynchronizedArray<Frame> = []
    }
}

extension ImageView.FramePosition: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}

extension CALayerContentsGravity {
    var scaling: NSImageScaling {
        switch self {
        case .resize: return .scaleAxesIndependently
        case .resizeAspect: return .scaleProportionallyUpOrDown
        default: return .scaleNone
        }
    }
    
    var alignment: NSImageAlignment {
        switch self {
        case .topLeft: return .alignTopLeft
        case .topRight: return .alignTopRight
        case .top: return .alignTop
        case .right: return .alignRight
        case .left: return .alignLeft
        case .bottom: return .alignBottom
        case .bottomLeft: return .alignBottomLeft
        case .bottomRight: return .alignBottomRight
        default: return .alignCenter
        }
    }
}

#endif
