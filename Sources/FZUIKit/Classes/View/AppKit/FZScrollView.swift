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
            guard boundsSize.width > 0 && boundsSize.height > 0 else {
                boundsSize = bounds.size
                return
            }
            contentOffset.x *= (bounds.width / boundsSize.width)
            contentOffset.y *= (bounds.height / boundsSize.height)
        }
        boundsSize = bounds.size
    }
    
    open override var acceptsFirstResponder: Bool {
        true
    }
    
    open override func becomeFirstResponder() -> Bool {
        true
    }

    func sharedInit() {
        contentView = CenteredClipView()
        allowsMagnification = true
        minMagnification = 1.0
        maxMagnification = 3.0
        drawsBackground = false
        boundsSize = bounds.size
        mouseClickZoomFactor = 0.5
        keyDownZoomFactor = 0.3
        spaceKeyZoomFactor = 0.3
    }
}

/**
 A custom NSScrollView subclass that enforces its documentView to always
 match the size of the scroll view's viewport (contentView).

 This replicates the resizing behavior requested in the original Canvas setup,
 making the document view stretch to fit the visible area.
 */
open class AutosizingScrollView: NSScrollView {
    
    private var documentLayoutConstraints: [NSLayoutConstraint] = []

    public init() {
        super.init(frame: .zero)
        setupScrollView()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupScrollView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }

    private func setupScrollView() {
        translatesAutoresizingMaskIntoConstraints = false
        hasVerticalScroller = true
        hasHorizontalScroller = true
        autohidesScrollers = true
        allowsMagnification = true
        minMagnification = 1.0
        maxMagnification = 3.0
        drawsBackground = false
        mouseClickZoomFactor = 0.5
        keyDownZoomFactor = 0.3
        spaceKeyZoomFactor = 0.3
    }

    open override var documentView: NSView? {
        didSet {
            guard oldValue != documentView else { return }
            documentLayoutConstraints.activate(false)
            guard let newDocumentView = documentView else { return }
            newDocumentView.translatesAutoresizingMaskIntoConstraints = false
            documentLayoutConstraints = [
            newDocumentView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            newDocumentView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            newDocumentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newDocumentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
             newDocumentView.topAnchor.constraint(equalTo: contentView.topAnchor),
             newDocumentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)].activate()
        }
    }
    
    open override var fittingSize: NSSize {
        documentView?.fittingSize ?? super.fittingSize
    }
    
    open override var intrinsicContentSize: NSSize {
        documentView?.intrinsicContentSize ?? super.intrinsicContentSize
    }
}

#endif
