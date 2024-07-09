//
//  FZScrollView.swift
//  
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

open class FZScrollView: NSScrollView {
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
        guard bounds.width > 0 && bounds.height > 0 else { return }
        if let documentView = documentView {
            documentView.frame = bounds
            guard boundsSize.width > 0 && boundsSize.height > 0 else {
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
    }
}
#endif
