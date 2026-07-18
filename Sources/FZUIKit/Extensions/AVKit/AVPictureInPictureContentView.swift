//
//  AVPictureInPictureContentView.swift
//  PipExtension
//
//  Created by Florian Zand on 17.07.26.
//

#if os(macOS) || os(iOS)
import AVKit
import CoreImage
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

#if os(macOS)
private typealias PiPTextLabel = NSTextField
#else
private typealias PiPTextLabel = UILabel
#endif

/**
 A view that can provide Picture in Picture sizing and placeholder information.

 Conform to this protocol when a custom content view wants to describe its preferred Picture in Picture aspect ratio or provide a placeholder while it is moved into the Picture in Picture window.
 */
@available(iOS 15.0, macOS 12.0, *)
@MainActor
public protocol AVPictureInPictureContentView: NSUIView {
    /**
     The size whose proportions represent the view’s preferred Picture in Picture aspect ratio.

     The aspect ratio of the provided size is used for the picture in picture view.

     Call ``invalidatePictureInPictureContentSize()`` after this value changes while ``isDisplayingPictureInPicture`` is `true`.

     The default value is the view’s [bounds](https://developer.apple.com/documentation/appkit/nsview/bounds) size after laying out the view.
     */
    var preferredPictureInPictureContentSize: CGSize { get }

    /**
     The placeholder view to display while this view is shown in Picture in Picture.

     By default, this property returns a black placeholder view that displays a Picture in Picture symbol, ``pictureInPicturePlaceholderText``, and optionally a close button.
     */
    var pictureInPicturePlaceholderView: NSUIView? { get }

    /**
     The text to display below the Picture in Picture symbol in the default placeholder view.

     This property is only used when ``pictureInPicturePlaceholderView`` returns the default placeholder view.

     The default value is `nil`.
     */
    var pictureInPicturePlaceholderText: String? { get }

    /**
     A Boolean value indicating whether the default Picture in Picture placeholder view displays a close button in its top-right corner.

     This property is only used when ``pictureInPicturePlaceholderView`` returns the default placeholder view. The default value is `false`.
     */
    var showsPictureInPicturePlaceholderCloseButton: Bool { get }
}

/// The handlers for picture in picture of a `NSUIView` conforming to ``AVPictureInPictureContentView``.
public struct AVPictureInPictureContentViewHandlers {
    /// Called before Picture in Picture starts displaying the content view.
    public var willStart: ((_ contentView: AVPictureInPictureContentView) -> Void)?

    /// Called after Picture in Picture starts displaying the content view.
    public var didStart: ((_ contentView: AVPictureInPictureContentView) -> Void)?

    /// Called before Picture in Picture stops displaying the content view.
    public var willStop: ((_ contentView: AVPictureInPictureContentView) -> Void)?

    /// Called after Picture in Picture has stopped displaying the content view.
    public var didStop: ((_ contentView: AVPictureInPictureContentView) -> Void)?

    /// Called when Picture in Picture fails to start.
    public var didFailToStart: ((_ contentView: AVPictureInPictureContentView, _ error: Error) -> Void)?

    public var isDisplaying: ((_ contentView: AVPictureInPictureContentView, _ isDisplaying: Bool) -> Void)?
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
public extension AVPictureInPictureContentView {
    /// The handlers for picture in picture.
    var pictureInPictureHandlers: AVPictureInPictureContentViewHandlers {
        get { getAssociatedValue("pictureInPictureHandlers") ?? .init() }
        set {
            setAssociatedValue(newValue, key: "pictureInPictureHandlers")
            setupIsDisplayingObservation()
        }
    }

    var preferredPictureInPictureContentSize: CGSize {
        layoutIfNeeded()
        return bounds.size
    }

    var pictureInPicturePlaceholderView: NSUIView? {
        let placeholderView: PiPPlaceholderView = getAssociatedValue("pictureInPicturePlaceholderView", initialValue: {
            PiPPlaceholderView(contentView: self)
        })
        placeholderView.contentView = self
        placeholderView.textLabel.text = pictureInPicturePlaceholderText ?? ""
        placeholderView.closeButton.isHidden = !showsPictureInPicturePlaceholderCloseButton
        return placeholderView
    }

    var pictureInPicturePlaceholderText: String? {
        nil
    }

    var showsPictureInPicturePlaceholderCloseButton: Bool {
        false
    }

    /// A Boolean value indicating whether the view is currently displayed in picture in picture.
    var isDisplayingPictureInPicture: Bool {
        get {
            guard let controller = pipController else { return false }
            guard controller.contentView === self else { return false }
            return controller.isPictureInPictureActive
        }
        set {
            guard newValue != isDisplayingPictureInPicture else { return }
            if newValue {
                _pictureInPictureController.startPictureInPicture()
            } else {
                pipController?.stopPictureInPicture()
            }
        }
    }

    private func setupIsDisplayingObservation() {
        guard let pipController = pipController else { return }
        if pictureInPictureHandlers.isDisplaying == nil {
            isDisplayingObservation = nil
        } else if isDisplayingObservation == nil {
            isDisplayingObservation = pipController.observeChanges(for: \.isPictureInPictureActive) { [weak self] _, newValue in
                guard let self = self, self.pipController?.contentView === self else { return }
                self.pictureInPictureHandlers.isDisplaying?(self, newValue)
            }
        }
    }

    private var pipController: ContentViewPictureInPictureController? {
        getAssociatedValue("pictureInPictureController")
    }

    private var isDisplayingObservation: KeyValueObservation? {
        get { getAssociatedValue("isDisplayingObservation") }
        set { setAssociatedValue(newValue, key: "isDisplayingObservation") }
    }

    ///  The picture in picture controller for this content view.
    var pictureInPictureController: AVPictureInPictureController {
        _pictureInPictureController
    }
    
    private var _pictureInPictureController: ContentViewPictureInPictureController {
        let controller: ContentViewPictureInPictureController = getAssociatedValue("pictureInPictureController", initialValue: {
            let controller = ContentViewPictureInPictureController(
                contentView: self,
                preferredContentSize: preferredPictureInPictureContentSize
            )
            return controller
        })
        controller.contentView = self
        setupIsDisplayingObservation()
        return controller
    }

    /// Starts displaying the view in picture in picture.
    func startDisplayingPictureInPicture() {
        _ = pictureInPictureController
        isDisplayingPictureInPicture = true
    }

    /// Stops displaying the view in picture in picture.
    func stopDisplayingPictureInPicture() {
        isDisplayingPictureInPicture = false
    }

    /**
     Re-evaluates the view’s preferred Picture in Picture content size.

     Call this method after ``preferredPictureInPictureContentSize`` changes while ``isDisplayingPictureInPicture`` is `true`.
     */
    func invalidatePictureInPictureContentSize() {
        _pictureInPictureController.invalidateContentSize()
    }
}


// MARK: - Content View Controller

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class ContentViewPictureInPictureController: AVPictureInPictureController, @preconcurrency AVPictureInPictureControllerDelegate {
    private var allowsInternalMutation = true
    weak var forwardingDelegate: (any AVPictureInPictureControllerDelegate)?
    
    let displayLayer: AVSampleBufferDisplayLayer
    let playbackDelegate: PiPSampleBufferPlaybackDelegate

    var preferredContentSize: CGSize?
    var resolvedContentSize: CGSize
    var renderSize: CGSize
    weak var contentView: AVPictureInPictureContentView? {
        didSet {
            guard oldValue !== contentView else { return }
            removeInstalledContentView()
            removePlaceholderIfNeeded()
            removeContentViewSourceLayerIfPossible()
            resolvedPlaceholderView = nil
            if preferredContentSize == nil {
                invalidateContentSize()
            }
            if isPictureInPictureActive {
                installContentViewIfPossible()
            }
        }
    }

    private var containerView: PiPContentContainerView?
    private var sourceLayerHostView: PiPSourceLayerHostView?
    private var sourceLayerHostInstallAttempts = 0
    private var sourceLayerInstalledInContentView = false
    private var placeholderPlacement: PiPEarlyPlaceholderPlacement?
    private var resolvedPlaceholderView: NSUIView?
    private var contentViewFrameObservation: KeyValueObservation?

    override var contentSource: ContentSource? {
        get { super.contentSource }
        set {
            guard allowsInternalMutation else {
                assertionFailure("Changing contentSource is unsupported for AVPictureInPictureContentView controllers.")
                return
            }
            super.contentSource = newValue
        }
    }

    override var delegate: (any AVPictureInPictureControllerDelegate)? {
        get { forwardingDelegate }
        set { forwardingDelegate = newValue }
    }

    /**
     Creates a Picture in Picture controller that displays a custom content view.

     - Parameters:
       - contentView: The content view to display in Picture in Picture.
       - preferredContentSize: The preferred content size. Only the ratio between width and height is significant.
       - backgroundColor: The color used for the backing sample-buffer layer.
       - controlsStyle: The style of the system Picture in Picture controls.
     */
    init(
        contentView: AVPictureInPictureContentView,
        preferredContentSize: CGSize? = nil,
        controlsStyle: ControlsStyle? = nil
    ) {
        contentView.layoutIfNeeded()

        let inferredSize = contentView.preferredSize
        let requestedSize = preferredContentSize ?? inferredSize
        let contentSize = requestedSize.valid ?? CGSize(width: 16, height: 9)
        let renderSize = contentSize.renderSize()

        let displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.backgroundColor = .black

        let playbackDelegate = PiPSampleBufferPlaybackDelegate()
        let contentSource = ContentSource(
            sampleBufferDisplayLayer: displayLayer,
            playbackDelegate: playbackDelegate
        )

        self.displayLayer = displayLayer
        self.playbackDelegate = playbackDelegate
        self.preferredContentSize = preferredContentSize
        self.resolvedContentSize = contentSize
        self.renderSize = renderSize
        self.contentView = contentView

        super.init(contentSource: contentSource)

        self.controlsStyle = controlsStyle ?? .hidden
        installSourceLayerCarrierIfNeeded()
        enqueueCurrentFrame()
        allowsInternalMutation = false
        super.delegate = self
    }

    deinit {
        let sourceLayerHostView = sourceLayerHostView
        Task { @MainActor in
            sourceLayerHostView?.removeFromSuperview()
        }
    }


    func invalidateContentSize() {
        let requestedSize: CGSize

        if let preferredContentSize {
            requestedSize = preferredContentSize
        } else if let contentView = contentView {
            requestedSize = contentView.preferredSize
        } else {
            requestedSize = resolvedContentSize
        }

        guard let validatedSize = requestedSize.valid else {
            return
        }

        let ratioChanged = !validatedSize.aspectRatio.isApproximatelyEqual(to: resolvedContentSize.aspectRatio, epsilon: 0.001)

        resolvedContentSize = validatedSize

        guard ratioChanged else { return }

        renderSize = validatedSize.renderSize()
        sourceLayerHostView?.contentSize = renderSize
        updateContentViewSourceLayerFrame()
        displayLayer.flush()
        enqueueCurrentFrame()
    }

    func enqueueCurrentFrame() {
        guard
            let pixelBuffer = makePixelBuffer(),
            let sampleBuffer = makeSampleBuffer(from: pixelBuffer)
        else {
            return
        }

        if displayLayer.pipRenderingStatus == .failed {
            displayLayer.pipFlush()
        }

        displayLayer.pipEnqueue(sampleBuffer)
    }

    func installContentViewIfPossible() {
        guard
            containerView == nil,
            let contentView = contentView,
            let pipView = view
        else {
            return
        }

        contentView.pictureInPictureHandlers.willStart?(contentView)
        placeholderPlacement?.prepareForContentViewMove()

        let placeholderView: NSUIView? = placeholderPlacement == nil
            ? effectivePlaceholderView(for: contentView)
            : nil

        let container = PiPContentContainerView(
            contentView: contentView,
            placeholderView: placeholderView
        )
        container.translatesAutoresizingMaskIntoConstraints = false
        pipView.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: pipView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: pipView.trailingAnchor),
            container.topAnchor.constraint(equalTo: pipView.topAnchor),
            container.bottomAnchor.constraint(equalTo: pipView.bottomAnchor)
        ])

        containerView = container
        observeContentViewFrameIfNeeded(contentView)
        container.sendToFront()
        pipView.setNeedsLayout()
        pipView.layoutIfNeeded()
        contentView.pictureInPictureHandlers.didStart?(contentView)
    }

    func installPlaceholderIfPossible() {
        guard
            placeholderPlacement == nil,
            let contentView = contentView,
            contentView.superview != nil,
            let placeholderView = effectivePlaceholderView(for: contentView)
        else {
            return
        }

        guard let placement = PiPEarlyPlaceholderPlacement(
            contentView: contentView,
            placeholderView: placeholderView
        ) else {
            return
        }

        guard placement.canInstall else {
            return
        }

        guard placement.install() else {
            return
        }
        placeholderPlacement = placement
    }

    private func removePlaceholderIfNeeded() {
        placeholderPlacement?.removePlaceholderIfNeeded()
        placeholderPlacement = nil
    }

    private func effectivePlaceholderView(for contentView: AVPictureInPictureContentView) -> NSUIView? {
        if let resolvedPlaceholderView {
            return resolvedPlaceholderView
        }

        guard let placeholderView = contentView.pictureInPicturePlaceholderView, placeholderView !== contentView else {
            return nil
        }

        resolvedPlaceholderView = placeholderView
        return placeholderView
    }

    func installSourceLayerCarrierIfNeeded() {
        if sourceLayerInstalledInContentView, isContentViewVisibleInWindow {
            updateContentViewSourceLayerFrame()
            return
        }

        if sourceLayerInstalledInContentView {
            removeContentViewSourceLayerIfPossible()
        } else if displayLayer.superlayer != nil {
            guard isContentViewVisibleInWindow else {
                return
            }

            displayLayer.removeFromSuperlayer()
            sourceLayerHostView = nil
        }

        if installSourceLayerInContentViewIfPossible() {
            return
        }

        installSourceLayerHostIfPossible()
    }

    private func installSourceLayerInContentViewIfPossible() -> Bool {
        guard let contentView = contentView, isContentViewVisibleInWindow else {
            return false
        }

        displayLayer.isHidden = false
        displayLayer.opacity = 0.001
        contentView.optionalLayer?.insertSublayer(displayLayer, at: 0)
        sourceLayerInstalledInContentView = true
        updateContentViewSourceLayerFrame()
        return true
    }

    private var isContentViewVisibleInWindow: Bool {
        guard
            let contentView = contentView,
            contentView.window != nil,
            !contentView.bounds.isEmpty,
            contentView.alpha > 0.01,
            !contentView.isHidden
        else {
            return false
        }

        guard let visibleRect = contentView.visibleRectInWindow else {
            return false
        }

        #if os(macOS)
        let scale = contentView.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
        #else
        let scale = contentView.window?.screen.scale ?? UIScreen.main.scale
        #endif
        return visibleRect.width * scale >= 1 && visibleRect.height * scale >= 1
    }

    private func updateContentViewSourceLayerFrame() {
        guard sourceLayerInstalledInContentView, let contentView = contentView else {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        displayLayer.frame = contentView.bounds.isEmpty
            ? CGRect(origin: .zero, size: renderSize)
            : contentView.bounds
        CATransaction.commit()
    }

    private func removeContentViewSourceLayerIfPossible() {
        guard sourceLayerInstalledInContentView else {
            return
        }

        displayLayer.removeFromSuperlayer()
        sourceLayerInstalledInContentView = false
    }

    private func installSourceLayerHostIfPossible() {
        guard sourceLayerHostView == nil else { return }

        guard let window = NSUIWindowLocator.applicationWindow(preferredView: contentView) else {
            guard sourceLayerHostInstallAttempts < 20 else { return }
            sourceLayerHostInstallAttempts += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.installSourceLayerHostIfPossible()
            }
            return
        }

        let hostView = PiPSourceLayerHostView(displayLayer: displayLayer, contentSize: renderSize)
        hostView.translatesAutoresizingMaskIntoConstraints = false
        let hostParent = NSUIWindowLocator.hostView(for: window)
        hostParent.addSubview(hostView)

        NSLayoutConstraint.activate([
            hostView.leadingAnchor.constraint(equalTo: hostParent.leadingAnchor),
            hostView.bottomAnchor.constraint(equalTo: hostParent.bottomAnchor),
            hostView.widthAnchor.constraint(equalToConstant: renderSize.width),
            hostView.heightAnchor.constraint(equalToConstant: renderSize.height)
        ])

        sourceLayerHostView = hostView
    }

    func removeFallbackSourceLayerHostIfPossible() {
        sourceLayerHostView?.removeFromSuperview()
        sourceLayerHostView = nil
        sourceLayerHostInstallAttempts = 0
    }

    func removeInstalledContentView(notifyDidStop: Bool = false) {
        let stoppedContentView = contentView
        stopObservingContentViewFrame()
        containerView?.restoreContentViewIfNeeded()
        containerView?.removeFromSuperview()
        containerView = nil
        removePlaceholderIfNeeded()
        if notifyDidStop, let stoppedContentView {
            stoppedContentView.pictureInPictureHandlers.didStop?(stoppedContentView)
        }
    }

    private func observeContentViewFrameIfNeeded(_ contentView: AVPictureInPictureContentView) {
        guard contentViewFrameObservation == nil else {
            return
        }

        contentViewFrameObservation = (contentView as NSUIView).observeChanges(for: \.frame) { [weak self] oldFrame, newFrame in
            guard abs(oldFrame.size.aspectRatio - newFrame.size.aspectRatio) > 0.001 else {
                return
            }

            self?.invalidateContentSize()
        }
    }

    private func stopObservingContentViewFrame() {
        contentViewFrameObservation?.invalidate()
        contentViewFrameObservation = nil
    }

    func prepareForPictureInPictureStopAnimation() {
        guard let contentView = contentView else {
            return
        }

        contentView.pictureInPictureHandlers.willStop?(contentView)

        guard let placeholderPlacement else {
            return
        }

        containerView?.removeContentViewForExternalRestore()
        containerView?.removeFromSuperview()
        containerView = nil

        placeholderPlacement.restoreContentViewBehindPlaceholder(contentView)
        installSourceLayerCarrierIfNeeded()
        enqueueCurrentFrame()
    }

    func pictureInPictureDidStart() {
        installContentViewWithRetry()
    }

    func pictureInPictureDidStop() {
        removeInstalledContentView(notifyDidStop: true)
        removeFallbackSourceLayerHostIfPossible()
    }

    func pictureInPictureFailedToStart(error: Error) {
        let failedContentView = contentView
        removeInstalledContentView()
        removeFallbackSourceLayerHostIfPossible()
        if let failedContentView {
            failedContentView.pictureInPictureHandlers.didFailToStart?(failedContentView, error)
        }
    }

    private func installContentViewWithRetry(attempt: Int = 0) {
        installContentViewIfPossible()

        guard containerView == nil, attempt < 20 else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.installContentViewWithRetry(attempt: attempt + 1)
        }
    }

    private func makePixelBuffer() -> CVPixelBuffer? {
        let width = max(Int(renderSize.width.rounded()), 1)
        let height = max(Int(renderSize.height.rounded()), 1)

        var pixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        guard let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        let renderRect = CGRect(x: 0, y: 0, width: width, height: height)
        context.setFillColor(.black)
        context.fill(renderRect)

        if let contentView = contentView, !contentView.bounds.isEmpty, let image = contentView.renderedImage.cgImage {
            context.draw(image, in: renderRect)
        }
        return pixelBuffer
    }

    private func makeSampleBuffer(from pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var formatDescription: CMVideoFormatDescription?

        guard CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        ) == noErr, let formatDescription else {
            return nil
        }

        var timing = CMSampleTimingInfo(
            duration: .invalid,
            presentationTimeStamp: CMClockGetTime(CMClockGetHostTimeClock()),
            decodeTimeStamp: .invalid
        )
        var sampleBuffer: CMSampleBuffer?

        guard CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDescription,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        ) == noErr, let sampleBuffer else {
            return nil
        }

        CMSetAttachment(
            sampleBuffer,
            key: kCMSampleAttachmentKey_DisplayImmediately,
            value: kCFBooleanTrue,
            attachmentMode: kCMAttachmentMode_ShouldPropagate
        )

        return sampleBuffer
    }

    override func startPictureInPicture() {
        guard !isPictureInPictureActive else { return }
        installSourceLayerCarrierIfNeeded()
        enqueueCurrentFrame()
        installPlaceholderIfPossible()
        super.startPictureInPicture()
    }

    override func stopPictureInPicture() {
        guard isPictureInPictureActive else { return }
        prepareForPictureInPictureStopAnimation()
        super.stopPictureInPicture()
    }

    var view: NSUIView? {
        (value(forKeySafely: "pictureInPictureViewController") as? NSUIViewController)?.view
    }

    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        pictureInPictureDidStart()
        forwardingDelegate?.pictureInPictureControllerDidStartPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        pictureInPictureDidStop()
        forwardingDelegate?.pictureInPictureControllerDidStopPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        pictureInPictureFailedToStart(error: error)
        forwardingDelegate?.pictureInPictureController?(
            pictureInPictureController,
            failedToStartPictureInPictureWithError: error
        )
    }

    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        forwardingDelegate?.pictureInPictureControllerWillStartPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        forwardingDelegate?.pictureInPictureControllerWillStopPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping @Sendable (Bool) -> Void
    ) {
        if forwardingDelegate?.responds(to: #selector(AVPictureInPictureControllerDelegate.pictureInPictureController(_:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:))) == true {
            forwardingDelegate?.pictureInPictureController?(
                pictureInPictureController,
                restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler
            )
        } else {
            completionHandler(false)
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
private extension AVSampleBufferDisplayLayer {
    var pipRenderingStatus: AVQueuedSampleBufferRenderingStatus {
        if #available(iOS 17.0, macOS 14.0, *) {
            return sampleBufferRenderer.status
        } else {
            return status
        }
    }

    func pipFlush() {
        if #available(iOS 17.0, macOS 14.0, *) {
            sampleBufferRenderer.flush()
        } else {
            flush()
        }
    }

    func pipEnqueue(_ sampleBuffer: CMSampleBuffer) {
        if #available(iOS 17.0, macOS 14.0, *) {
            sampleBufferRenderer.enqueue(sampleBuffer)
        } else {
            enqueue(sampleBuffer)
        }
    }
}

// MARK: - Content Container

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class PiPSourceLayerHostView: NSUIView {
    let displayLayer: AVSampleBufferDisplayLayer
    var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    init(displayLayer: AVSampleBufferDisplayLayer, contentSize: CGSize) {
        self.displayLayer = displayLayer
        self.contentSize = contentSize
        super.init(frame: CGRect(origin: .zero, size: contentSize))

        isHidden = true
        #if !os(macOS)
        isUserInteractionEnabled = false
        #endif
        optionalLayer?.addSublayer(displayLayer)
    }

    override var intrinsicContentSize: CGSize {
        contentSize
    }

    #if os(macOS)
    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        displayLayer.frame = bounds
        CATransaction.commit()
    }
    #else
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        displayLayer.frame = bounds
        CATransaction.commit()
    }
    #endif

    required init?(coder: NSCoder) {
        nil
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class PiPEarlyPlaceholderPlacement {
    let placeholderView: NSUIView
    private let originalContentPlacement: OriginalViewPlacement
    private let originalPlaceholderPlacement: OriginalViewPlacement?
    private var placeholderConstraints: [NSLayoutConstraint] = []
    private var didPrepareForContentViewMove = false

    var canInstall: Bool {
        originalContentPlacement.superview != nil
    }

    init?(contentView: NSUIView, placeholderView: NSUIView) {
        guard
            placeholderView !== contentView,
            let originalContentPlacement = OriginalViewPlacement(view: contentView)
        else {
            return nil
        }

        self.placeholderView = placeholderView
        self.originalContentPlacement = originalContentPlacement
        self.originalPlaceholderPlacement = OriginalViewPlacement(view: placeholderView)
    }

    func install() -> Bool {
        guard let originalSuperview = originalContentPlacement.superview else {
            return false
        }

        originalPlaceholderPlacement?.deactivateConstraints()
        placeholderView.removeFromSuperview()

        placeholderView.translatesAutoresizingMaskIntoConstraints = originalContentPlacement.translatesAutoresizingMaskIntoConstraints
        placeholderView.autoresizingMask = originalContentPlacement.autoresizingMask
        placeholderView.frame = originalContentPlacement.frame
        placeholderView.bounds = originalContentPlacement.bounds
        placeholderView.center = originalContentPlacement.center

        let insertionIndex = min(
            originalContentPlacement.siblingIndex + 1,
            originalSuperview.subviews.count
        )
        originalSuperview.insertSubview(placeholderView, at: insertionIndex)

        placeholderConstraints = originalContentPlacement.constraintsReplacingView(with: placeholderView)
        NSLayoutConstraint.activate(placeholderConstraints)
        return true
    }

    func prepareForContentViewMove() {
        guard !didPrepareForContentViewMove else {
            return
        }

        didPrepareForContentViewMove = true
        originalContentPlacement.deactivateConstraints()
    }

    func restoreContentViewBehindPlaceholder(_ contentView: NSUIView) {
        originalContentPlacement.restore(contentView)

        if let superview = placeholderView.superview {
            placeholderView.sendToFront()
            superview.setNeedsLayout()
            superview.layoutIfNeeded()
        }
    }

    func removePlaceholderIfNeeded() {
        NSLayoutConstraint.deactivate(placeholderConstraints)
        placeholderConstraints = []
        placeholderView.removeFromSuperview()
        originalPlaceholderPlacement?.restore(placeholderView)
    }

    @MainActor
    private struct OriginalViewPlacement {
        weak var view: NSUIView?
        weak var superview: NSUIView?
        let siblingIndex: Int
        let translatesAutoresizingMaskIntoConstraints: Bool
        let frame: CGRect
        let bounds: CGRect
        let center: CGPoint
        let autoresizingMask: NSUIView.AutoresizingMask
        let constraints: [NSLayoutConstraint]

        init?(view: NSUIView) {
            guard let superview = view.superview else {
                return nil
            }

            self.view = view
            self.superview = superview
            self.siblingIndex = superview.subviews.firstIndex(of: view) ?? superview.subviews.count
            self.translatesAutoresizingMaskIntoConstraints = view.translatesAutoresizingMaskIntoConstraints
            self.frame = view.frame
            self.bounds = view.bounds
            self.center = view.center
            self.autoresizingMask = view.autoresizingMask
            self.constraints = Self.activeConstraintsReferencing(view)
        }

        func restore(_ view: NSUIView) {
            guard let superview else {
                return
            }

            if view.superview !== superview {
                let insertionIndex = min(siblingIndex, superview.subviews.count)
                superview.insertSubview(view, at: insertionIndex)
            }

            view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
            view.autoresizingMask = autoresizingMask
            view.frame = frame
            view.bounds = bounds
            view.center = center

            NSLayoutConstraint.activate(constraints.filter { !$0.isActive })
        }

        func deactivateConstraints() {
            NSLayoutConstraint.deactivate(constraints)
        }

        func constraintsReplacingView(with replacementView: NSUIView) -> [NSLayoutConstraint] {
            guard let view else {
                return []
            }

            return constraints.map { constraint in
                let replacementConstraint = NSLayoutConstraint(
                    item: replacementItem(
                        constraint.firstItem,
                        originalView: view,
                        replacementView: replacementView
                    )!,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: replacementItem(
                        constraint.secondItem,
                        originalView: view,
                        replacementView: replacementView
                    ),
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant
                )
                replacementConstraint.priority = constraint.priority
                replacementConstraint.identifier = constraint.identifier
                replacementConstraint.shouldBeArchived = constraint.shouldBeArchived
                return replacementConstraint
            }
        }

        private func replacementItem(_ item: Any?, originalView: NSUIView, replacementView: NSUIView) -> Any? {
            guard let item else {
                return nil
            }

            if (item as AnyObject) === originalView {
                return replacementView
            }

            return item
        }

        private static func activeConstraintsReferencing(_ view: NSUIView) -> [NSLayoutConstraint] {
            var constraints: [NSLayoutConstraint] = view.constraints.filter(\.isActive)
            var currentSuperview: NSUIView? = view.superview

            while let currentView = currentSuperview {
                constraints += currentView.constraints.filter {
                    $0.isActive && ($0.firstItem === view || $0.secondItem === view)
                }
                currentSuperview = currentView.superview
            }

            return constraints
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class PiPContentContainerView: NSUIView {
    let contentView: NSUIView
    private let placeholderView: NSUIView?
    private let originalContentPlacement: OriginalViewPlacement?
    private let originalPlaceholderPlacement: OriginalViewPlacement?
    private var placeholderConstraints: [NSLayoutConstraint] = []
    private var didRestoreContentView = false

    init(contentView: NSUIView, placeholderView: NSUIView?) {
        self.contentView = contentView
        self.placeholderView = placeholderView === contentView ? nil : placeholderView
        self.originalContentPlacement = OriginalViewPlacement(view: contentView)
        self.originalPlaceholderPlacement = self.placeholderView.flatMap { OriginalViewPlacement(view: $0) }
        super.init(frame: .zero)

        clipsToBounds = true

        installPlaceholderIfNeeded()
        if self.placeholderView == nil {
            originalContentPlacement?.deactivateConstraints()
        }
        contentView.removeFromSuperview()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func restoreContentViewIfNeeded() {
        guard !didRestoreContentView else {
            return
        }

        didRestoreContentView = true
        contentView.removeFromSuperview()

        removePlaceholderIfNeeded()

        guard let originalContentPlacement else {
            return
        }

        originalContentPlacement.restore(contentView)
    }

    func removeContentViewForExternalRestore() {
        guard !didRestoreContentView else {
            return
        }

        didRestoreContentView = true
        contentView.removeFromSuperview()
    }

    private func installPlaceholderIfNeeded() {
        guard
            let placeholderView,
            let originalContentPlacement,
            let originalSuperview = originalContentPlacement.superview
        else {
            return
        }

        originalContentPlacement.deactivateConstraints()
        originalPlaceholderPlacement?.deactivateConstraints()
        placeholderView.removeFromSuperview()

        placeholderView.translatesAutoresizingMaskIntoConstraints = originalContentPlacement.translatesAutoresizingMaskIntoConstraints
        placeholderView.autoresizingMask = originalContentPlacement.autoresizingMask
        placeholderView.frame = originalContentPlacement.frame
        placeholderView.bounds = originalContentPlacement.bounds
        placeholderView.center = originalContentPlacement.center

        let insertionIndex = min(originalContentPlacement.siblingIndex, originalSuperview.subviews.count)
        originalSuperview.insertSubview(placeholderView, at: insertionIndex)

        placeholderConstraints = originalContentPlacement.constraintsReplacingView(with: placeholderView)
        NSLayoutConstraint.activate(placeholderConstraints)
    }

    private func removePlaceholderIfNeeded() {
        guard let placeholderView else {
            return
        }

        NSLayoutConstraint.deactivate(placeholderConstraints)
        placeholderConstraints = []
        placeholderView.removeFromSuperview()
        originalPlaceholderPlacement?.restore(placeholderView)
    }

    @MainActor
    private struct OriginalViewPlacement {
        weak var view: NSUIView?
        weak var superview: NSUIView?
        let siblingIndex: Int
        let translatesAutoresizingMaskIntoConstraints: Bool
        let frame: CGRect
        let bounds: CGRect
        let center: CGPoint
        let autoresizingMask: NSUIView.AutoresizingMask
        let constraints: [NSLayoutConstraint]

        init?(view: NSUIView) {
            guard let superview = view.superview else {
                return nil
            }

            self.view = view
            self.superview = superview
            self.siblingIndex = superview.subviews.firstIndex(of: view) ?? superview.subviews.count
            self.translatesAutoresizingMaskIntoConstraints = view.translatesAutoresizingMaskIntoConstraints
            self.frame = view.frame
            self.bounds = view.bounds
            self.center = view.center
            self.autoresizingMask = view.autoresizingMask
            self.constraints = Self.activeConstraintsReferencing(view)
        }

        func restore(_ view: NSUIView) {
            guard let superview else {
                return
            }

            if view.superview !== superview {
                let insertionIndex = min(siblingIndex, superview.subviews.count)
                superview.insertSubview(view, at: insertionIndex)
            }

            view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
            view.autoresizingMask = autoresizingMask
            view.frame = frame
            view.bounds = bounds
            view.center = center

            NSLayoutConstraint.activate(constraints.filter { !$0.isActive })
        }

        func deactivateConstraints() {
            NSLayoutConstraint.deactivate(constraints)
        }

        func constraintsReplacingView(with replacementView: NSUIView) -> [NSLayoutConstraint] {
            guard let view else {
                return []
            }

            return constraints.map { constraint in
                let replacementConstraint = NSLayoutConstraint(
                    item: replacementItem(
                        constraint.firstItem,
                        originalView: view,
                        replacementView: replacementView
                    )!,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: replacementItem(
                        constraint.secondItem,
                        originalView: view,
                        replacementView: replacementView
                    ),
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant
                )
                replacementConstraint.priority = constraint.priority
                replacementConstraint.identifier = constraint.identifier
                replacementConstraint.shouldBeArchived = constraint.shouldBeArchived
                return replacementConstraint
            }
        }

        private func replacementItem(_ item: Any?, originalView: NSUIView, replacementView: NSUIView) -> Any? {
            guard let item else {
                return nil
            }

            if (item as AnyObject) === originalView {
                return replacementView
            }

            return item
        }

        private static func activeConstraintsReferencing(_ view: NSUIView) -> [NSLayoutConstraint] {
            var constraints: [NSLayoutConstraint] = view.constraints.filter(\.isActive)
            var currentSuperview: NSUIView? = view.superview

            while let currentView = currentSuperview {
                constraints += currentView.constraints.filter {
                    $0.isActive && ($0.firstItem === view || $0.secondItem === view)
                }
                currentSuperview = currentView.superview
            }

            return constraints
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class PiPPlaceholderView: NSUIView {
    private let imageView = NSUIImageView(image: .symbol("pip")!).translatesAutoresizingMaskIntoConstraints(false)
    #if os(macOS)
    fileprivate let textLabel = NSTextField.label().font(.subheadline).textColor(.systemGray).translatesAutoresizingMaskIntoConstraints(false).maximumNumberOfLines(0).alignment(.center)
    #else
    fileprivate let textLabel = UILabel().font(.subheadline).textColor(.systemGray).translatesAutoresizingMaskIntoConstraints(false).textAlignment(.center).numberOfLines(0)
    #endif

    #if os(macOS)
    fileprivate lazy var closeButton = NSButton.image(.symbol("pip.exit") ?? .symbol("xmark.circle.fill")!) { [weak self] _ in
        self?.contentView?.stopDisplayingPictureInPicture()
    }.toolTip("Close Picture in Picture").contentTintColor(.systemGray).isHidden(true).translatesAutoresizingMaskIntoConstraints(false)
    #else
    fileprivate lazy var closeButton = UIButton.system(image: .symbol("pip.exit") ?? .symbol("xmark.circle.fill")!, primaryAction: UIAction(title: "Close") { [weak self] _ in
        self?.contentView?.stopDisplayingPictureInPicture()
    }).accessibilityLabel("Close Picture in Picture").tintColor(.systemGray).isHidden(true).translatesAutoresizingMaskIntoConstraints(false)
    #endif

    weak var contentView: AVPictureInPictureContentView?

    init(contentView: AVPictureInPictureContentView?) {
        self.contentView = contentView
        super.init(frame: .zero)
        configure()
        textLabel.text = ""
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        textLabel.text = ""
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        textLabel.text = ""
    }

    private func configure() {
        backgroundColor = .black
        clipsToBounds = true

        addSubview(closeButton)

        let stackView = NSUIStackView.vertical(.center, spacing: 12) {
            [imageView, textLabel]
        }.translatesAutoresizingMaskIntoConstraints(false)
        #if !os(macOS)
        stackView.isUserInteractionEnabled = false
        #endif
        addSubview(stackView)

        #if os(macOS)
        imageView.contentTintColor = .systemGray
        imageView.imageScaling = .scaleProportionallyUpOrDown
        #else
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        #endif

        [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
         closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
         closeButton.widthAnchor.constraint(equalToConstant: 32),
         closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
         stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
         stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
         stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
         stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
         imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.26),
         imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
         textLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.82)].activate()
    }
}

@available(iOS 15.0, macOS 12.0, *)
private extension AVPictureInPictureContentView {
    var preferredSize: CGSize {
        if let size = preferredPictureInPictureContentSize.valid {
            return size
        }
        #if os(macOS)
        let fittingSize = fittingSize
        #else
        let fittingSize = systemLayoutSizeFitting(
            NSUIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )
        #endif

        return fittingSize.valid ?? intrinsicContentSize.valid ?? bounds.size.valid ??  CGSize(width: 16, height: 9)
    }
}

@available(iOS 15.0, macOS 12.0, *)
private final class PiPSampleBufferPlaybackDelegate:
    NSObject,
    AVPictureInPictureSampleBufferPlaybackDelegate
{
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        setPlaying playing: Bool
    ) {}

    func pictureInPictureControllerTimeRangeForPlayback(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> CMTimeRange {
        CMTimeRange(
            start: .zero,
            duration: CMTime(seconds: Double.greatestFiniteMagnitude, preferredTimescale: 1)
        )
    }

    func pictureInPictureControllerIsPlaybackPaused(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> Bool {
        false
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        didTransitionToRenderSize newRenderSize: CMVideoDimensions
    ) {}

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        skipByInterval skipInterval: CMTime,
        completion completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    func pictureInPictureControllerShouldProhibitBackgroundAudioPlayback(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> Bool {
        true
    }
}

// MARK: - Platform Helpers

#if os(macOS)
fileprivate extension NSTextField {
    var text: String {
        get { stringValue }
        set { stringValue = newValue }
    }
}

fileprivate extension NSUIView {
    func layoutIfNeeded() {
        layoutSubtreeIfNeeded()
    }

    var alpha: CGFloat {
        alphaValue
    }
}
#endif

// MARK: - PiP Window Lookup

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private enum NSUIWindowLocator {
    static func applicationWindow(preferredView: NSUIView?) -> NSUIWindow? {
        if let window = preferredView?.window {
            return window
        }

        #if os(macOS)
        let windows = NSApplication.shared.windows
        return NSApplication.shared.keyWindow
            ?? NSApplication.shared.mainWindow
            ?? windows.first(where: { $0.isVisible })
        #else
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)

        return windows.first(where: \.isKeyWindow)
            ?? windows.first(where: { !$0.isHidden && $0.windowLevel == .normal })
        #endif
    }

    static func hostView(for window: NSUIWindow) -> NSUIView {
        #if os(macOS)
        if let contentView = window.contentView {
            return contentView
        }
        let contentView = NSUIView(frame: window.contentLayoutRect)
        window.contentView = contentView
        return contentView
        #else
        return window
        #endif
    }

    static func pictureInPictureWindow() -> NSUIWindow? {
        #if os(macOS)
        return NSApplication.shared.windows.first(where: isPictureInPictureWindow)
        #else
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)

        return windows.first(where: isPictureInPictureWindow)
        #endif
    }

    private static func isPictureInPictureWindow(_ window: NSUIWindow) -> Bool {
        let className = NSStringFromClass(type(of: window))

        if className.localizedCaseInsensitiveContains("PictureInPicture") ||
            className.localizedCaseInsensitiveContains("PIP") ||
            className.localizedCaseInsensitiveContains("PGHosted")
        {
            return true
        }

        #if os(macOS)
        return window.level.rawValue > NSWindow.Level.normal.rawValue &&
            window.frame.width > 0 &&
            window.frame.height > 0 &&
            window.isVisible
        #else
        return window.windowLevel > .normal &&
            window.bounds.width > 0 &&
            window.bounds.height > 0 &&
            !window.isHidden &&
            window.rootViewController != nil
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private extension NSUIView {
    var visibleRectInWindow: CGRect? {
        guard
            let window = window,
            !bounds.isEmpty,
            !isHidden,
            alpha > 0.01
        else {
            return nil
        }

        let rootView = NSUIWindowLocator.hostView(for: window)
        var visibleRect = convert(bounds, to: rootView)
        visibleRect = visibleRect.intersection(rootView.bounds)

        var ancestor = superview
        while let view = ancestor {
            guard !view.isHidden, view.alpha > 0.01 else {
                return nil
            }

            if view.clipsToBounds {
                visibleRect = visibleRect.intersection(view.convert(view.bounds, to: rootView))
            }

            guard !visibleRect.isNull, !visibleRect.isEmpty else {
                return nil
            }

            if view === rootView {
                break
            }

            ancestor = view.superview
        }

        guard !visibleRect.isNull, !visibleRect.isEmpty else {
            return nil
        }

        return visibleRect
    }
}

#if !os(macOS)
extension AVPictureInPictureController {
    /**
     A Boolean value that indicates whether the Picture in Picture window appears to be dragged to the side.

     This value is inferred from private Picture in Picture view geometry and may not be reliable on every iOS version or for every Picture in Picture implementation.
     */
    var isPictureInPictureDraggedToSide: Bool {
        pictureInPictureSideStateSnapshot.isDraggedToSide
    }

    /**
     A diagnostic snapshot used to infer whether the Picture in Picture window is dragged to the side.

     The snapshot contains the candidate rectangles that were inspected so callers can log or debug why `isPictureInPictureDraggedToSide` returned a particular value.
     */
    var pictureInPictureSideStateSnapshot: PictureInPictureSideStateSnapshot {
        guard
            isPictureInPictureActive,
            let viewController = value(forKeySafely: "pictureInPictureViewController") as? UIViewController,
            let window = viewController.view.window
        else {
            return PictureInPictureSideStateSnapshot(isDraggedToSide: false, candidates: [])
        }

        let screenBounds = window.windowScene?.screen.bounds ?? UIScreen.main.bounds
        var candidates: [PictureInPictureSideStateSnapshot.Candidate] = []

        func appendRectCandidate(name: String, frame: CGRect) {
            candidates.append(
                PictureInPictureSideStateSnapshot.Candidate(
                    name: name,
                    frame: frame,
                    visibleRatio: Self.visibleRatio(of: frame, in: screenBounds)
                )
            )
        }

        func appendCandidate(name: String, view: NSUIView) {
            let frameInWindow = view.convert(view.bounds, to: window)
            let frameOnScreen = window.convert(frameInWindow, to: nil)
            appendRectCandidate(name: name, frame: frameOnScreen)

            if let presentationLayer = view.layer.presentation() {
                let presentationFrame = view.layer.superlayer?.convert(
                    presentationLayer.frame,
                    to: nil
                ) ?? presentationLayer.frame
                appendRectCandidate(name: "\(name) presentationLayer", frame: presentationFrame)
            }
        }

        appendCandidate(name: "pictureInPictureViewController.view", view: viewController.view)

        var superview = viewController.view.superview
        var index = 0
        while let view = superview, index < 8 {
            appendCandidate(name: "superview[\(index)] \(type(of: view))", view: view)
            superview = view.superview
            index += 1
        }

        appendRectCandidate(name: "window \(type(of: window)) convert(bounds,to:nil)", frame: window.convert(window.bounds, to: nil))
        appendRectCandidate(name: "window \(type(of: window)) frame", frame: window.frame)
        appendRectCandidate(
            name: "window \(type(of: window)) center/bounds",
            frame: CGRect(
                x: window.center.x - window.bounds.width / 2.0,
                y: window.center.y - window.bounds.height / 2.0,
                width: window.bounds.width,
                height: window.bounds.height
            )
        )

        if let presentationLayer = window.layer.presentation() {
            appendRectCandidate(name: "window \(type(of: window)) presentationLayer frame", frame: presentationLayer.frame)
        }

        let isDraggedToSide = candidates.contains { candidate in
            guard candidate.frame.width > 1, candidate.frame.height > 1 else {
                return false
            }

            return candidate.visibleRatio < 0.75
        }

        return PictureInPictureSideStateSnapshot(isDraggedToSide: isDraggedToSide, candidates: candidates)
    }

    private static func visibleRatio(of frame: CGRect, in screenBounds: CGRect) -> CGFloat {
        guard frame.width > 0, frame.height > 0 else {
            return 0
        }

        let visibleFrame = frame.intersection(screenBounds)
        guard !visibleFrame.isNull, !visibleFrame.isEmpty else {
            return 0
        }

        return (visibleFrame.width * visibleFrame.height) / (frame.width * frame.height)
    }
}
#endif

/// A diagnostic snapshot describing candidate Picture in Picture frames used to infer side-drag state.
struct PictureInPictureSideStateSnapshot {
    /// A candidate frame inspected while calculating Picture in Picture side-drag state.
    struct Candidate {
        /// The debug name of the candidate view or layer.
        let name: String

        /// The candidate frame in screen coordinates.
        let frame: CGRect

        /// The fraction of the candidate frame that is visible inside the screen bounds.
        let visibleRatio: CGFloat
    }

    /// A Boolean value indicating whether any candidate appears mostly outside the screen bounds.
    let isDraggedToSide: Bool

    /// The frames inspected while calculating `isDraggedToSide`.
    let candidates: [Candidate]
}

fileprivate extension CGSize {
    var valid: CGSize? {
        isFinite && !isEmpty && self != .noIntrinsicSize ? self : nil
    }
    
    func renderSize(maximumDimension: CGFloat = 320) -> CGSize {
        guard valid != nil else {
            return CGSize(width: 320, height: 180)
        }
        let scale = maximumDimension / Swift.max(width, height)
        return CGSize(width: Swift.max((width * scale).rounded(), 1), height: Swift.max((height * scale).rounded(), 1))
    }
    
    func renderSize(fitting viewSize: CGSize?, minimum: CGFloat = 320, maximum: CGFloat = 960) -> CGSize {
        guard let size = valid else {
            return CGSize(width: 480, height: 270)
        }
        let targetMaximumDimension = (viewSize?.valid?.max ?? 480.0).clamped(to: minimum...maximum)
        let scale = targetMaximumDimension / size.max
        (size.width * scale).rounded().clamped(min: 1)
        return CGSize(
            width: Swift.max((size.width * scale).rounded(), 1),
            height: Swift.max((size.height * scale).rounded(), 1)
        ).clamped(min: CGSize(1))
    }
}

#endif
