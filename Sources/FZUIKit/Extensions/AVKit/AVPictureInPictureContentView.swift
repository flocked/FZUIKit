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

@available(iOS 15.0, macOS 12.0, *)
@MainActor
/**
 A view that can provide Picture in Picture sizing and placeholder information.

 Conform to this protocol when a custom content view wants to describe its preferred Picture in Picture aspect ratio or provide a placeholder while it is moved into the Picture in Picture window.
 */
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

     By default, this property returns a black placeholder view that displays a Picture in Picture symbol and ``placeholderContentText``.
     */
    var placeholderView: NSUIView? { get }

    /**
     The text to display below the Picture in Picture symbol in the default placeholder view.

     This property is only used when ``placeholderView`` returns the default placeholder view.
     
     The default value is `nil`.
     */
    var placeholderContentText: String? { get }
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
extension AVPictureInPictureContentView {
    /// The handlers for picture in picture.
    public var pictureInPictureHandlers: AVPictureInPictureContentViewHandlers {
        get { getAssociatedValue("pictureInPictureHandlers") ?? .init() }
        set {
            setAssociatedValue(newValue, key: "pictureInPictureHandlers")
            setupIsDisplayingObservation()
        }
    }

    public var preferredPictureInPictureContentSize: CGSize {
        platformLayoutIfNeeded()
        return bounds.size
    }

    public var placeholderView: NSUIView? {
        let placeholderView: PiPPlaceholderView = getAssociatedValue("pictureInPicturePlaceholderView", initialValue: {
            PiPPlaceholderView(text: placeholderContentText)
        })
        placeholderView.text = placeholderContentText
        return placeholderView
    }

    public var placeholderContentText: String? { nil }

    /// A Boolean value indicating whether the view is currently displayed in picture in picture.
    public var isDisplayingPictureInPicture: Bool {
        get {
            guard let controller = pipController else { return false }
            guard controller.contentView === self else { return false }
            return controller.isPictureInPictureActive
        }
        set {
            guard let pipController = pipController, newValue != isDisplayingPictureInPicture else { return }
            if newValue {
                pipController.startPictureInPicture()
            } else {
                pipController.stopPictureInPicture()
            }
        }
    }
    
    private func setupIsDisplayingObservation() {
        guard let pipController = pipController else { return }
        if pictureInPictureHandlers.isDisplaying == nil {
            isDisplayingObservation = nil
        } else if isDisplayingObservation == nil {
            isDisplayingObservation = pipController.observeChanges(for: \.isPictureInPictureActive) { [weak self] oldValue, newValue in
                guard let self = self, self.pipController?.contentView === self else { return }
                self.pictureInPictureHandlers.isDisplaying?(self, newValue)
            }
        }
    }
    
    private var pipController: AVPictureInPictureController? {
        getAssociatedValue("pictureInPictureController")
    }
    
    private var isDisplayingObservation: KeyValueObservation? {
        get { getAssociatedValue("isDisplayingObservation") }
        set { setAssociatedValue(newValue, key: "isDisplayingObservation") }
    }
    
    ///  The picture in picture controller for this content view.
    public var pictureInPictureController: AVPictureInPictureController {
        let controller: AVPictureInPictureController = getAssociatedValue("pictureInPictureController", initialValue: {
            AVPictureInPictureController(
                contentView: self,
                placeholderView: placeholderView,
                preferredContentSize: preferredPictureInPictureContentSize
            )
        })
        controller.contentView = self
        setupIsDisplayingObservation()
        return controller
    }

    /// Starts displaying the view in picture in picture.
    public func startDisplayingPictureInPicture() {
        isDisplayingPictureInPicture = true
    }

    /// Stops displaying the view in picture in picture.
    public func stopDisplayingPictureInPicture() {
        isDisplayingPictureInPicture = false
    }
    
    /**
     Re-evaluates the view’s preferred Picture in Picture content size.

     Call this method after ``preferredPictureInPictureContentSize`` changes while ``isDisplayingPictureInPicture`` is `true`.
     */
    public func invalidatePictureInPictureContentSize() {
        pictureInPictureController.invalidateContentSize()
    }
}


@available(iOS 15.0, macOS 12.0, *)
@MainActor
fileprivate extension AVPictureInPictureController {
    /**
     Creates a Picture in Picture controller that displays a custom content view.

     - Parameters:
       - contentView: The content view to display in Picture in Picture.
       - placeholderView: The view to show in the content view’s original location while Picture in Picture is active.
       - preferredContentSize: The preferred content size. Only the ratio between width and height is significant.
       - backgroundColor: The color used for the backing sample-buffer layer.
       - controlsStyle: The style of the system Picture in Picture controls.
     */
    convenience init(contentView: AVPictureInPictureContentView,
                     placeholderView: NSUIView? = nil,
                     preferredContentSize: CGSize? = nil,
                     backgroundColor: NSUIColor = .black,
                     controlsStyle: ControlsStyle? = nil) {
        contentView.platformLayoutIfNeeded()

        let inferredSize = PiPContentSizeResolver.preferredSize(for: contentView)
        let requestedSize = preferredContentSize ?? inferredSize
        let contentSize = PiPContentSizeResolver.validatedSize(requestedSize)
            ?? CGSize(width: 16, height: 9)
        let renderSize = PiPContentSizeResolver.renderSize(for: contentSize)

        let displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.backgroundColor = backgroundColor.cgColor

        let playbackDelegate = PiPSampleBufferPlaybackDelegate()
        let contentSource = ContentSource(
            sampleBufferDisplayLayer: displayLayer,
            playbackDelegate: playbackDelegate
        )
        self.init(contentSource: contentSource)
        let state = PiPControllerState(
            controller: self,
            displayLayer: displayLayer,
            playbackDelegate: playbackDelegate,
            backgroundColor: backgroundColor,
            preferredContentSize: preferredContentSize,
            resolvedContentSize: contentSize,
            renderSize: renderSize,
            contentView: contentView
        )

        pipState = state
        self.controlsStyle = controlsStyle ?? .hidden
        state.installDelegateProxy()
        swizzleStartStopIfNeeded(shuldSwizzle: true)
        state.installSourceLayerCarrierIfNeeded()
        state.enqueueCurrentFrame()
    }

    /**
     The custom content view displayed in Picture in Picture.
     
     This property is used internally by ``AVPictureInPictureContentView``.
     */
    var contentView: AVPictureInPictureContentView? {
        get { pipState?.contentView }
        set {
            pipState?.setContentView(newValue)
            updateStartStopSwizzleForContentViewConfiguration()
        }
    }
    
    /**
     The preferred content proportions.

     Set this property to `nil` to determine the content size automatically from the content view. Only the ratio between the width and height is significant.
     */
    var preferredContentSize: CGSize? {
        get { pipState?.preferredContentSize }
        set { pipState?.setPreferredContentSize(newValue) }
    }

    /// The content proportions currently used by Picture in Picture.
    var contentSize: CGSize {
        pipState?.resolvedContentSize ?? .zero
    }

    /**
     Re-evaluates the content size when automatic sizing is enabled.

     Call this method after the content view changes its preferred layout or Picture in Picture aspect ratio.
     */
    func invalidateContentSize() {
        pipState?.invalidateContentSize()
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
extension AVPictureInPictureController {
    func updateStartStopSwizzleForContentViewConfiguration() {
        swizzleStartStopIfNeeded(
            shuldSwizzle: contentView != nil
        )
    }

    func swizzleStartStopIfNeeded(shuldSwizzle: Bool) {
        if shuldSwizzle, startStopHooks.isEmpty {
            do {
                startStopHooks += try hook(#selector(startPictureInPicture), closure: {
                   original, pipController, selector in
                    MainActor.assumeIsolated {
                        pipController.pipState?.installSourceLayerCarrierIfNeeded()
                        pipController.pipState?.enqueueCurrentFrame()
                        pipController.pipState?.installPlaceholderIfPossible()
                    }
                    original(pipController, selector)
                } as @convention(block) (
                    (AVPictureInPictureController, Selector) -> Void,  AVPictureInPictureController, Selector) -> Void)
                startStopHooks += try hook(#selector(stopPictureInPicture), closure: {
                   original, pipController, selector in
                    MainActor.assumeIsolated {
                        pipController.pipState?.prepareForPictureInPictureStopAnimation()
                    }
                    original(pipController, selector)
                } as @convention(block) (
                    (AVPictureInPictureController, Selector) -> Void,  AVPictureInPictureController, Selector) -> Void)
            } catch {
                
            }
        } else if !shuldSwizzle {
            startStopHooks.forEach({ try? $0.revert() })
            startStopHooks = []
        }
    }
    
    var startStopHooks: [Hook] {
        get { getAssociatedValue("startStopHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "startStopHooks") }
    }
}

// MARK: - Controller State

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class PiPControllerState {

    weak var controller: AVPictureInPictureController?

    let displayLayer: AVSampleBufferDisplayLayer
    let playbackDelegate: PiPSampleBufferPlaybackDelegate

    var backgroundColor: NSUIColor
    var preferredContentSize: CGSize?
    var resolvedContentSize: CGSize
    var renderSize: CGSize
    weak var contentView: AVPictureInPictureContentView?

    private var containerView: PiPContentContainerView?
    private var sourceLayerHostView: PiPSourceLayerHostView?
    private var sourceLayerHostInstallAttempts = 0
    private var sourceLayerInstalledInContentView = false
    private var placeholderPlacement: PiPEarlyPlaceholderPlacement?
    private var resolvedPlaceholderView: NSUIView?
    private var delegateProxy: PiPControllerDelegateProxy?
    private var contentViewFrameObservation: KeyValueObservation?

    init(
        controller: AVPictureInPictureController,
        displayLayer: AVSampleBufferDisplayLayer,
        playbackDelegate: PiPSampleBufferPlaybackDelegate,
        backgroundColor: NSUIColor,
        preferredContentSize: CGSize?,
        resolvedContentSize: CGSize,
        renderSize: CGSize,
        contentView: AVPictureInPictureContentView?
    ) {
        self.controller = controller
        self.displayLayer = displayLayer
        self.playbackDelegate = playbackDelegate
        self.backgroundColor = backgroundColor
        self.preferredContentSize = preferredContentSize
        self.resolvedContentSize = resolvedContentSize
        self.renderSize = renderSize
        self.contentView = contentView
    }

    deinit {
        let sourceLayerHostView = sourceLayerHostView
        let contentView = contentView
        let contentViewFrameObservation = contentViewFrameObservation
        Task { @MainActor in
            contentViewFrameObservation?.invalidate()
            sourceLayerHostView?.removeFromSuperview()
        }
    }

    func installDelegateProxy() {
        guard controller != nil else { return }
        delegateProxy = PiPControllerDelegateProxy(state: self)
    }

    func setContentView(_ contentView: AVPictureInPictureContentView?) {
        guard self.contentView !== contentView else { return }
        removeInstalledContentView()
        removePlaceholderIfNeeded()
        removeContentViewSourceLayerIfPossible()
        resolvedPlaceholderView = nil
        self.contentView = contentView
        if preferredContentSize == nil {
            invalidateContentSize()
        }

        installContentViewIfPossible()
    }

    @discardableResult
    fileprivate func resolveContentView() -> AVPictureInPictureContentView? {
        contentView
    }

    func setPreferredContentSize(_ size: CGSize?) {
        if let size, PiPContentSizeResolver.validatedSize(size) == nil {
            return
        }

        preferredContentSize = size
        invalidateContentSize()
    }

    func invalidateContentSize() {
        let requestedSize: CGSize

        if let preferredContentSize {
            requestedSize = preferredContentSize
        } else if let contentView = resolveContentView() {
            requestedSize = PiPContentSizeResolver.preferredSize(for: contentView)
        } else {
            requestedSize = resolvedContentSize
        }

        guard let validatedSize = PiPContentSizeResolver.validatedSize(requestedSize) else {
            return
        }

        let ratioChanged = PiPContentSizeResolver.aspectRatiosDiffer(
            validatedSize,
            resolvedContentSize
        )

        resolvedContentSize = validatedSize

        guard ratioChanged else { return }

        renderSize = PiPContentSizeResolver.renderSize(for: validatedSize)
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
            let contentView = resolveContentView(),
            let pipView = controller?.pictureInPictureViewControllerView
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
        pipView.platformBringSubviewToFront(container)
        pipView.platformSetNeedsLayout()
        pipView.platformLayoutIfNeeded()
        contentView.pictureInPictureHandlers.didStart?(contentView)
        Swift.print("customPiP contentView installed", "pipView:", type(of: pipView), "window:", pipView.window.map { type(of: $0) } ?? "nil")
    }

    func installPlaceholderIfPossible() {
        guard
            placeholderPlacement == nil,
            let contentView = resolveContentView(),
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

        guard let placeholderView = contentView.placeholderView, placeholderView !== contentView else {
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
        guard let contentView = resolveContentView(), isContentViewVisibleInWindow else {
            return false
        }

        displayLayer.isHidden = false
        displayLayer.opacity = 0.001
        contentView.platformLayer.insertSublayer(displayLayer, at: 0)
        sourceLayerInstalledInContentView = true
        updateContentViewSourceLayerFrame()
        return true
    }

    private var isContentViewVisibleInWindow: Bool {
        guard
            let contentView = resolveContentView(),
            contentView.platformWindow != nil,
            !contentView.bounds.isEmpty,
            contentView.platformAlpha > 0.01,
            !contentView.platformIsHidden
        else {
            return false
        }

        guard let visibleRect = contentView.visibleRectInWindow else {
            return false
        }

        let scale = contentView.platformScale
        return visibleRect.width * scale >= 1 && visibleRect.height * scale >= 1
    }

    private func updateContentViewSourceLayerFrame() {
        guard sourceLayerInstalledInContentView, let contentView = resolveContentView() else {
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

        guard let window = NSUIWindowLocator.applicationWindow(preferredView: resolveContentView()) else {
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
        let stoppedContentView = resolveContentView()
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
        guard let contentView = resolveContentView() else {
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
        let failedContentView = resolveContentView()
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

        #if os(macOS)
        let fillColor = CIColor(color: backgroundColor) ?? .black
        #else
        let fillColor = CIColor(color: backgroundColor)
        #endif
        let image = CIImage(color: fillColor).cropped(
            to: CGRect(x: 0, y: 0, width: width, height: height)
        )

        CIContext().render(
            image,
            toBitmap: baseAddress,
            rowBytes: CVPixelBufferGetBytesPerRow(pixelBuffer),
            bounds: image.extent,
            format: .BGRA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

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
            platformSetNeedsLayout()
        }
    }

    init(displayLayer: AVSampleBufferDisplayLayer, contentSize: CGSize) {
        self.displayLayer = displayLayer
        self.contentSize = contentSize
        super.init(frame: CGRect(origin: .zero, size: contentSize))

        platformIsHidden = true
        platformIsUserInteractionEnabled = false
        platformLayer.addSublayer(displayLayer)
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
        placeholderView.platformCenter = originalContentPlacement.center

        let insertionIndex = min(
            originalContentPlacement.siblingIndex + 1,
            originalSuperview.subviews.count
        )
        originalSuperview.platformInsertSubview(placeholderView, at: insertionIndex)

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
            superview.platformBringSubviewToFront(placeholderView)
            superview.platformSetNeedsLayout()
            superview.platformLayoutIfNeeded()
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
            self.center = view.platformCenter
            self.autoresizingMask = view.autoresizingMask
            self.constraints = Self.activeConstraintsReferencing(view)
        }

        func restore(_ view: NSUIView) {
            guard let superview else {
                return
            }

            if view.superview !== superview {
                let insertionIndex = min(siblingIndex, superview.subviews.count)
                superview.platformInsertSubview(view, at: insertionIndex)
            }

            view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
            view.autoresizingMask = autoresizingMask
            view.frame = frame
            view.bounds = bounds
            view.platformCenter = center

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

        platformClipsToBounds = true

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
        placeholderView.platformCenter = originalContentPlacement.center

        let insertionIndex = min(originalContentPlacement.siblingIndex, originalSuperview.subviews.count)
        originalSuperview.platformInsertSubview(placeholderView, at: insertionIndex)

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
            self.center = view.platformCenter
            self.autoresizingMask = view.autoresizingMask
            self.constraints = Self.activeConstraintsReferencing(view)
        }

        func restore(_ view: NSUIView) {
            guard let superview else {
                return
            }

            if view.superview !== superview {
                let insertionIndex = min(siblingIndex, superview.subviews.count)
                superview.platformInsertSubview(view, at: insertionIndex)
            }

            view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
            view.autoresizingMask = autoresizingMask
            view.frame = frame
            view.bounds = bounds
            view.platformCenter = center

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

    private static let defaultText = "Video is playing in picture in picture."
    private let imageView = NSUIImageView(image: .pictureInPictureSymbol)
    private let textLabel = PiPTextLabel.pipLabel()

    var text: String? {
        get { textLabel.platformText }
        set { textLabel.platformText = newValue ?? Self.defaultText }
    }

    init(text: String?) {
        super.init(frame: .zero)
        configure()
        self.text = text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        text = nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
        text = nil
    }

    private func configure() {
        platformBackgroundColor = .black
        platformClipsToBounds = true

        let stackView = NSUIStackView.pipStackView(arrangedSubviews: [imageView, textLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.platformAxis = .vertical
        stackView.platformSetCenterAlignment()
        stackView.spacing = 12
        stackView.platformIsUserInteractionEnabled = false
        addSubview(stackView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.platformContentModeScaleAspectFit()
        imageView.platformTintColor = .systemGray

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.platformFont = .pipSubheadline
        textLabel.platformTextColor = .systemGray
        textLabel.platformTextAlignment = .center
        textLabel.platformNumberOfLines = 0

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.26),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            textLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.82)
        ])
    }
}

// MARK: - Content Size Resolution

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private enum PiPContentSizeResolver {

    static func preferredSize(for view: AVPictureInPictureContentView) -> CGSize {
        if let size = validatedSize(view.preferredPictureInPictureContentSize) {
            return size
        }

        return preferredSize(for: view as NSUIView)
    }

    static func preferredSize(for view: NSUIView) -> CGSize {
        #if os(macOS)
        let fittingSize = view.fittingSize
        #else
        let fittingSize = view.systemLayoutSizeFitting(
            NSUIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )
        #endif

        if let size = validatedSize(fittingSize) {
            return size
        }

        if let size = validatedSize(view.intrinsicContentSize) {
            return size
        }

        if let size = validatedSize(view.bounds.size) {
            return size
        }

        return CGSize(width: 16, height: 9)
    }

    static func validatedSize(_ size: CGSize) -> CGSize? {
        guard
            size.width.isFinite,
            size.height.isFinite,
            size.width > 0,
            size.height > 0,
            size.width != NSUIView.noIntrinsicMetric,
            size.height != NSUIView.noIntrinsicMetric
        else {
            return nil
        }

        return size
    }

    static func renderSize(
        for aspectRatioSize: CGSize,
        maximumDimension: CGFloat = 320
    ) -> CGSize {
        guard let size = validatedSize(aspectRatioSize) else {
            return CGSize(width: 320, height: 180)
        }

        let scale = maximumDimension / max(size.width, size.height)

        return CGSize(
            width: max((size.width * scale).rounded(), 1),
            height: max((size.height * scale).rounded(), 1)
        )
    }

    static func aspectRatiosDiffer(
        _ lhs: CGSize,
        _ rhs: CGSize,
        tolerance: CGFloat = 0.001
    ) -> Bool {
        guard lhs.height > 0, rhs.height > 0 else {
            return true
        }

        return abs(lhs.width / lhs.height - rhs.width / rhs.height) > tolerance
    }
}

// MARK: - Sample Buffer Playback Delegate

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

// MARK: - Controller Delegate Proxy

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private final class PiPControllerDelegateProxy:
    NSObject,
    @preconcurrency AVPictureInPictureControllerDelegate
{
    weak var state: PiPControllerState?
    var delegateObservation: KeyValueObservation?
    weak var delegate: (any AVPictureInPictureControllerDelegate)?

    init(state: PiPControllerState) {
        self.state = state
        super.init()
        delegate = state.controller?.delegate
        state.controller?.delegate = self
        delegateObservation = state.controller?.observeChanges(for: \.delegate) { [weak self] oldValue, newValue in
            guard let self = self, newValue !== self else { return }
            self.delegate = newValue
            self.state?.controller?.delegate = self
        }
    }

    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        state?.pictureInPictureDidStart()
        delegate?.pictureInPictureControllerDidStartPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        state?.pictureInPictureDidStop()
        delegate?.pictureInPictureControllerDidStopPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        state?.pictureInPictureFailedToStart(error: error)
        delegate?.pictureInPictureController?(
            pictureInPictureController,
            failedToStartPictureInPictureWithError: error
        )
    }

    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        delegate?.pictureInPictureControllerWillStartPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        delegate?.pictureInPictureControllerWillStopPictureInPicture?(pictureInPictureController)
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler
        completionHandler: @escaping @Sendable (Bool) -> Void
    ) {
        if delegate?.responds(to: #selector(AVPictureInPictureControllerDelegate.pictureInPictureController(_:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:))) == true {
            delegate?.pictureInPictureController?(
                pictureInPictureController,
                restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler
            )
        } else {
            completionHandler(false)
        }
    }
}

// MARK: - Platform Helpers

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private extension NSUIView {
    var platformWindow: NSUIWindow? {
        window
    }

    var platformLayer: CALayer {
        #if os(macOS)
        wantsLayer = true
        if layer == nil {
            layer = CALayer()
        }
        return layer!
        #else
        return layer
        #endif
    }

    var platformAlpha: CGFloat {
        #if os(macOS)
        alphaValue
        #else
        alpha
        #endif
    }

    var platformIsHidden: Bool {
        get { isHidden }
        set { isHidden = newValue }
    }

    var platformIsUserInteractionEnabled: Bool {
        get {
            #if os(macOS)
            true
            #else
            isUserInteractionEnabled
            #endif
        }
        set {
            #if !os(macOS)
            isUserInteractionEnabled = newValue
            #endif
        }
    }

    var platformClipsToBounds: Bool {
        get {
            #if os(macOS)
            layer?.masksToBounds ?? false
            #else
            clipsToBounds
            #endif
        }
        set {
            #if os(macOS)
            platformLayer.masksToBounds = newValue
            #else
            clipsToBounds = newValue
            #endif
        }
    }

    var platformBackgroundColor: NSUIColor? {
        get {
            #if os(macOS)
            guard let cgColor = layer?.backgroundColor else { return nil }
            return NSUIColor(cgColor: cgColor)
            #else
            return backgroundColor
            #endif
        }
        set {
            #if os(macOS)
            platformLayer.backgroundColor = newValue?.cgColor
            #else
            backgroundColor = newValue
            #endif
        }
    }

    var platformCenter: CGPoint {
        get { CGPoint(x: frame.midX, y: frame.midY) }
        set {
            frame.origin = CGPoint(
                x: newValue.x - frame.width / 2.0,
                y: newValue.y - frame.height / 2.0
            )
        }
    }

    var platformScale: CGFloat {
        #if os(macOS)
        window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
        #else
        window?.screen.scale ?? UIScreen.main.scale
        #endif
    }

    func platformSetNeedsLayout() {
        #if os(macOS)
        needsLayout = true
        #else
        setNeedsLayout()
        #endif
    }

    func platformLayoutIfNeeded() {
        #if os(macOS)
        layoutSubtreeIfNeeded()
        #else
        layoutIfNeeded()
        #endif
    }

    func platformInsertSubview(_ subview: NSUIView, at index: Int) {
        #if os(macOS)
        if index >= subviews.count {
            addSubview(subview)
        } else {
            addSubview(subview, positioned: .below, relativeTo: subviews[index])
        }
        #else
        insertSubview(subview, at: index)
        #endif
    }

    func platformBringSubviewToFront(_ subview: NSUIView) {
        #if os(macOS)
        addSubview(subview, positioned: .above, relativeTo: nil)
        #else
        bringSubviewToFront(subview)
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, *)
private extension NSUIImage {
    static var pictureInPictureSymbol: NSUIImage {
        #if os(macOS)
        return NSUIImage(systemSymbolName: "pip", accessibilityDescription: nil) ?? NSUIImage(size: CGSize(width: 24, height: 24))
        #else
        return NSUIImage(systemName: "pip") ?? NSUIImage()
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private extension NSUIImageView {
    var platformTintColor: NSUIColor? {
        get {
            #if os(macOS)
            contentTintColor
            #else
            tintColor
            #endif
        }
        set {
            #if os(macOS)
            contentTintColor = newValue
            #else
            tintColor = newValue
            #endif
        }
    }

    func platformContentModeScaleAspectFit() {
        #if os(macOS)
        imageScaling = .scaleProportionallyUpOrDown
        #else
        contentMode = .scaleAspectFit
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private extension NSUIStackView {
    static func pipStackView(arrangedSubviews: [NSUIView]) -> NSUIStackView {
        #if os(macOS)
        NSUIStackView(views: arrangedSubviews)
        #else
        NSUIStackView(arrangedSubviews: arrangedSubviews)
        #endif
    }

    var platformAxis: NSUIUserInterfaceLayoutOrientation {
        get {
            #if os(macOS)
            orientation == .vertical ? .vertical : .horizontal
            #else
            axis
            #endif
        }
        set {
            #if os(macOS)
            orientation = newValue == .vertical ? .vertical : .horizontal
            #else
            axis = newValue
            #endif
        }
    }

    func platformSetCenterAlignment() {
        #if os(macOS)
        alignment = .centerX
        #else
        alignment = .center
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private extension PiPTextLabel {
    static func pipLabel() -> PiPTextLabel {
        #if os(macOS)
        let label = PiPTextLabel(labelWithString: "")
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        return label
        #else
        return PiPTextLabel()
        #endif
    }

    var platformText: String? {
        get {
            #if os(macOS)
            stringValue
            #else
            text
            #endif
        }
        set {
            #if os(macOS)
            stringValue = newValue ?? ""
            #else
            text = newValue
            #endif
        }
    }

    var platformFont: NSUIFont? {
        get { font }
        set { font = newValue }
    }

    var platformTextColor: NSUIColor? {
        get { textColor }
        set { textColor = newValue }
    }

    var platformTextAlignment: NSTextAlignment {
        get {
            #if os(macOS)
            alignment
            #else
            textAlignment
            #endif
        }
        set {
            #if os(macOS)
            alignment = newValue
            #else
            textAlignment = newValue
            #endif
        }
    }

    var platformNumberOfLines: Int {
        get {
            #if os(macOS)
            maximumNumberOfLines
            #else
            numberOfLines
            #endif
        }
        set {
            #if os(macOS)
            maximumNumberOfLines = newValue
            #else
            numberOfLines = newValue
            #endif
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
private extension NSUIFont {
    static var pipSubheadline: NSUIFont {
        #if os(macOS)
        NSUIFont.preferredFont(forTextStyle: .subheadline)
        #else
        NSUIFont.preferredFont(forTextStyle: .subheadline)
        #endif
    }
}

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
            className.localizedCaseInsensitiveContains("PGHosted") {
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
private extension AVPictureInPictureController {
    var pipState: PiPControllerState? {
        get { getAssociatedValue("customPIPState") }
        set { setAssociatedValue(newValue, key: "customPIPState") }
    }

    var pictureInPictureViewControllerView: NSUIView? {
        (value(forKeySafely: "pictureInPictureViewController") as? NSUIViewController)?.view
    }
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
private extension NSUIView {
    var visibleRectInWindow: CGRect? {
        guard
            let window = platformWindow,
            !bounds.isEmpty,
            !platformIsHidden,
            platformAlpha > 0.01
        else {
            return nil
        }

        let rootView = NSUIWindowLocator.hostView(for: window)
        var visibleRect = convert(bounds, to: rootView)
        visibleRect = visibleRect.intersection(rootView.bounds)

        var ancestor = superview
        while let view = ancestor {
            guard !view.platformIsHidden, view.platformAlpha > 0.01 else {
                return nil
            }

            if view.platformClipsToBounds {
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
#endif
