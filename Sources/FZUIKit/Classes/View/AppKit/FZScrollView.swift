//
//  File.swift
//  
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

open class FZScrollView: NSScrollView {
    
    lazy var _verticalScrollElasticity = verticalScrollElasticity
    lazy var _horizontalScrollElasticity = horizontalScrollElasticity
    lazy var _hasVerticalScroller = hasVerticalScroller
    lazy var _hasHorizontalScroller = hasHorizontalScroller
    var magnificationObservation: KeyValueObservation?
    
    /**
     The amount by which to zoom the image when the user presses either the plus or minus key.
     
     Specify a value of `0.0` to disable zooming via keyboard.
     */
    open var keyDownZoomFactor: CGFloat = 0.3
    
    /**
     The amount by which to momentarily zoom the image when the user holds the space key.
     
     Specify a value of `0.0` to disable zooming via space key.
     */
    open var spaceKeyZoomFactor: CGFloat = 0.3
    
    /**
     The amount by which to zoom the image when the user double clicks the view.
     
     Specify a value of `0.0` to disable zooming via mouse clicks.
     */
    open var mouseClickZoomFactor: CGFloat = 0.5
    
    override open func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 30:
            guard keyDownZoomFactor != 0.0 else { return }
            if event.modifierFlags.contains(.command) {
                setMagnification(maxMagnification)
            } else {
                zoomIn(factor: keyDownZoomFactor)
            }
        case 44:
            guard keyDownZoomFactor != 0.0 else { return }
            if event.modifierFlags.contains(.command) {
                setMagnification(1.0)
            } else {
                zoomOut(factor: keyDownZoomFactor)
            }
        case 49:
            guard spaceKeyZoomFactor != 0.0 else { return }
            zoomIn(factor: spaceKeyZoomFactor, animationDuration: 0.2)
        default:
            super.keyDown(with: event)
        }
    }
    
    open override func keyUp(with event: NSEvent) {
        if event.keyCode == 49, spaceKeyZoomFactor != 0.0 {
            zoomOut(factor: spaceKeyZoomFactor, animationDuration: 0.2)
        }
    }
    
    open override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        Swift.print("scrollWheel")
    }
    
    override open func mouseDown(with event: NSEvent) {
        guard mouseClickZoomFactor != 0.0 else { return }
        if event.clickCount == 2 {
            if magnification != 1.0 {
                setMagnification(1.0)
            } else {
                zoomIn(factor: mouseClickZoomFactor, centeredAt: event.location(in: self))
            }
        }
    }

    func setMagnification(_ magnification: CGFloat) {
        setMagnification(magnification, centeredAt: nil, animationDuration: nil)
    }
    
    /// A Boolean that indicates whether the scrollers should be hidden if the scroll view is completly zoomed out.
    open var hidesScrollersWhenZoomedOut: Bool = true {
        didSet { setupMagnificationObservation() }
    }
    
    func setupMagnificationObservation() {
        if hidesScrollersWhenZoomedOut {
            if magnificationObservation == nil {
                magnificationObservation = observeChanges(for: \.magnification) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.updateScrollerVisibility()
                }
                updateScrollerVisibility()
            }
        } else {
            magnificationObservation = nil
        }
    }
    
    func updateScrollerVisibility() {
        guard hidesScrollersWhenZoomedOut else { return }
        if magnification == 1.0, minMagnification == 1.0 {
            _verticalScrollElasticity = verticalScrollElasticity
            _horizontalScrollElasticity = horizontalScrollElasticity
            _hasVerticalScroller = hasVerticalScroller
            _hasHorizontalScroller = hasHorizontalScroller
            verticalScrollElasticity = .none
            horizontalScrollElasticity = .none
            hasVerticalScroller = false
            hasHorizontalScroller = false
        } else {
            verticalScrollElasticity = _verticalScrollElasticity
            horizontalScrollElasticity = _horizontalScrollElasticity
            hasVerticalScroller = _hasVerticalScroller
            hasHorizontalScroller = _hasHorizontalScroller
        }
    }
    
    /**
     Initializes the scroll view with the specified document view.
     
     - Parameter documentView: The document view.
     
     - Returns: An initialized scroll view object.
     */
    public init(documentView: NSView) {
        super.init(frame: .zero)
        self.documentView = documentView
        sharedInit()
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
        documentView?.fittingSize ?? super.fittingSize
    }
    
    open override var intrinsicContentSize: NSSize {
        documentView?.intrinsicContentSize ?? super.intrinsicContentSize
    }
    
    open override var documentView: NSView? {
        didSet {
            guard oldValue != documentView else { return }
            documentView?.frame = bounds
        }
    }
    
    var boundsSize: CGSize = .zero
    
    override open func layout() {
        super.layout()
        if let documentView = documentView {
            documentView.frame = bounds
            guard boundsSize != .zero else {
                boundsSize = bounds.size
                return
            }
            contentOffset.x *= (bounds.width / boundsSize.width)
            contentOffset.y *= (bounds.height / boundsSize.height)
        }
        boundsSize = bounds.size
    }

    func sharedInit() {
        contentView = CenteredClipView()
        allowsMagnification = true
        minMagnification = 1.0
        maxMagnification = 3.0
        drawsBackground = false
        boundsSize = bounds.size
        setupMagnificationObservation()
    }
}
#endif
