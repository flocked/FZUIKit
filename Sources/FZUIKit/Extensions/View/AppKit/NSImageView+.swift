//
//  NSImageView+.swift
//
//
//  Created by Florian Zand on 22.02.24.
//


#if os(macOS)
import AppKit
import FZSwiftUtils
 
extension NSImageView {
    /// Sets the image displayed by the image view.
    @discardableResult
    public func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
    
    /// Sets the symbol configuration.
    @available(macOS 11, *)
    @discardableResult
    public func symbolConfiguration(_ configuration: NSImage.SymbolConfiguration?) -> Self {
        self.symbolConfiguration = configuration
        return self
    }
    
    /// Sets the symbol configuration.
    @available(macOS 13, *)
    @discardableResult
    public func symbolConfiguration(_ configuration: ImageSymbolConfiguration?) -> Self {
        self.imageSymbolConfiguration = configuration
        return self
    }
    
    /// Sets the color used to tint template images in the view hierarchy.
    @discardableResult
    public func contentTintColor(_ color: NSColor?) -> Self {
        contentTintColor = color
        return self
    }
        
    /// Sets the scaling mode applied to make the cell’s image fit the frame of the image view.
    @discardableResult
    public func imageScaling(_ imageScaling: NSImageScaling) -> Self {
        self.imageScaling = imageScaling
        return self
    }
    
    /// Sets the alignment of the cell’s image inside the image view.
    @discardableResult
    public func imageAlignment(_ alignment: NSImageAlignment) -> Self {
        imageAlignment = alignment
        return self
    }
    
    /// Sets Boolean value indicating whether the image view automatically plays animated images.
    @discardableResult
    public func animates(_ animates: Bool) -> Self {
        self.animates = animates
        return self
    }
    
    /**
     The current size and position of the image that displays within the image view’s bounds.
     
     Use this property to determine the display dimensions of the image within the image view’s bounds. The size and position of this rectangle depends on the image scaling and alignment.
     */
    public var imageBounds: CGRect {
        if let bounds = value(forKeySafely: "_drawingRectForImage") as? CGRect {
            return bounds
        }
        
        guard let imageSize = image?.size else { return .zero }
    
        var contentFrame = CGRect(.zero, frame.size)
        switch imageFrameStyle {
        case .button, .groove:
            contentFrame = NSInsetRect(bounds, 2, 2)
        case .photo:
            contentFrame = CGRect(x: contentFrame.origin.x + 1, y: contentFrame.origin.x + 2, width: contentFrame.size.width - 3, height: contentFrame.size.height - 3)
        case .grayBezel:
            contentFrame = NSInsetRect(self.bounds, 8, 8)
        default:
            break
        }

        var drawingSize = imageSize
        switch imageScaling {
        case .scaleAxesIndependently:
            drawingSize = contentFrame.size
        case .scaleProportionallyUpOrDown:
            drawingSize = drawingSize.scaled(toFit: contentFrame.size)
        case .scaleProportionallyDown:
            drawingSize = drawingSize.scaled(toFit: contentFrame.size)
            if drawingSize.width > imageSize.width {
                drawingSize.width = imageSize.width
            }
            if drawingSize.height > imageSize.height {
                drawingSize.height = imageSize.height
            }
        default:
            if drawingSize.width > contentFrame.size.width { drawingSize.width = contentFrame.size.width }
            if drawingSize.height > contentFrame.size.height { drawingSize.height = contentFrame.size.height }
        }

        var drawingPosition = NSPoint(x: contentFrame.origin.x + contentFrame.size.width / 2 - drawingSize.width / 2,
                                      y: contentFrame.origin.y + contentFrame.size.height / 2 - drawingSize.height / 2)
        switch imageAlignment {
        case .alignTop:
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
        case .alignTopLeft:
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
            drawingPosition.x = contentFrame.origin.x
        case .alignTopRight:
            drawingPosition.y = contentFrame.origin.y + contentFrame.size.height - drawingSize.height
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        case .alignLeft:
            drawingPosition.x = contentFrame.origin.x
        case .alignBottom:
            drawingPosition.y = contentFrame.origin.y
        case .alignBottomLeft:
            drawingPosition.y = contentFrame.origin.y
            drawingPosition.x = contentFrame.origin.x
        case .alignBottomRight:
            drawingPosition.y = contentFrame.origin.y
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        case .alignRight:
            drawingPosition.x = contentFrame.origin.x + contentFrame.size.width - drawingSize.width
        default:
            break
        }

        return CGRect(x: round(drawingPosition.x), y: round(drawingPosition.y), width: ceil(drawingSize.width), height: ceil(drawingSize.height))
      }
    
    /**
     A view for hosting content on top of the image view.
     
     Use this view to host content that you want layered on top of the image view. This view is managed by the image view itself and is automatically sized to fill the image view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public var overlayContentView: NSView {
        if let overlayView: NSView = getAssociatedValue("overlayContentView") {
            return overlayView
        }
        
        let overlayView = NSView().clipsToBounds(true).frame(imageBounds)
        addSubview(overlayView)
        setAssociatedValue(overlayView, key: "overlayContentView")

        overlayImageViewObservation.add(\.frame) { [weak self] _, _ in
            guard let self = self else { return }
            self.overlayContentView.frame = self.imageBounds
        }
        overlayImageViewObservation.add(\.image) { [weak self] old, new in
            guard let self = self, old?.size != new?.size else { return }
            self.overlayContentView.frame = self.imageBounds
        }
        overlayImageViewObservation.add(\.imageFrameStyle) { [weak self] _, _ in
            guard let self = self else { return }
            self.overlayContentView.frame = self.imageBounds
        }
        overlayImageViewObservation.add(\.imageScaling) { [weak self] _, _ in
            guard let self = self else { return }
            self.overlayContentView.frame = self.imageBounds
        }
        overlayImageViewObservation.add(\.imageAlignment) { [weak self] _, _ in
            guard let self = self else { return }
            self.overlayContentView.frame = self.imageBounds
        }
        return overlayView
    }
    
    var overlayImageViewObservation: KeyValueObserver<NSImageView> {
        get { getAssociatedValue("overlayImageViewObservation", initialValue: KeyValueObserver(self)) }
    }

    /// The transition animation when changing the image.
    public var transitionAnimation: TransitionAnimation {
        get { getAssociatedValue("TransitionAnimation") ?? .none }
        set {
            guard newValue != transitionAnimation else { return }
            setAssociatedValue(newValue, key: "TransitionAnimation")
            if newValue.type == nil  {
                transitionImageObservation = []
            } else if transitionImageObservation.isEmpty {
                transitionImageObservation = [observeWillChange(\.image) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateTransition()
                }, observeChanges(for: \.image) {  [weak self] _, _ in
                    guard let self = self else { return }
                    self.transition(nil)
                }].nonNil
            }
        }
    }
    
    
    /// The duration of the transition animation when changing the image.
    public var transitionDuration: TimeInterval {
        get { getAssociatedValue("transitionDuration") ?? 0.2 }
        set {
            guard newValue != transitionDuration else { return }
            setAssociatedValue(newValue, key: "transitionDuration")
            updateTransition()
        }
    }
    
    /// The transition animation when changing the image.
    public enum TransitionAnimation: Hashable, CustomStringConvertible {
        /// No transition animation.
        case none
        /// The new image fades in animated..
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
        
        var subtype: CATransitionSubtype? {
            switch self {
            case .moveIn(let direction), .push(let direction), .reveal(let direction):
                return direction.subtype
            default: return nil
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
    }
    
    var transitionImageObservation: [KeyValueObservation] {
        get { getAssociatedValue("transitionImageObservation") ?? [] }
        set { setAssociatedValue(newValue, key: "transitionImageObservation") }
    }
    
    func updateTransition() {
        guard let type = transitionAnimation.type else { return }
        transition(CATransition(type, subtype: transitionAnimation.subtype, duration: transitionDuration))
    }
}
#endif
