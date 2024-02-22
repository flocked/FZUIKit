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
    /**
     The current size and position of the image that displays within the image view’s bounds.
     
     Use this property to determine the display dimensions of the image within the image view’s bounds. The size and position of this rectangle depend on the image scaling and alignment.
     */
    public var imageBounds: CGRect {
        guard let imageSize = image?.size else { return .zero }
    
        var contentFrame = CGRect(.zero, frame.size)
        switch self.imageFrameStyle {
        case .button, .groove:
            contentFrame = NSInsetRect(self.bounds, 2, 2)
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
     A view for hosting layered content on top of the image view.
     
     Use this view to host content that you want layered on top of the image view. This view is managed by the image view itself and is automatically sized to fill the image view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public var overlayContentView: NSView {
        if let view: NSView = getAssociatedValue(key: "overlayContentView", object: self) {
            return view
        }
        let overlayView = NSView()
        overlayView.clipsToBounds = true
        addSubview(withConstraint: overlayView)
        set(associatedValue: overlayView, key: "overlayContentView", object: self)
        return overlayView
    }
    
    /**
     A view for hosting layered content on top of the image view that automatically resizes to the image size and the image scaling.
     
     Use this view to host content that you want layered on top of the image view. This view is managed by the image view itself and is automatically sized to fill the image view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public var resizingOverlayContentView: NSView {
        if let view: NSView = getAssociatedValue(key: "resizingOverlayContentView", object: self) {
            return view
        }
        
        let overlayView = NSView()
        overlayView.clipsToBounds = true
        overlayView.frame = imageBounds
        overlayContentView.addSubview(overlayView)
        set(associatedValue: overlayView, key: "resizingOverlayContentView", object: self)
        needsResizingViewUpdate = true

        imageViewObserver.add(\.frame) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingOverlayContentView.frame = self.imageBounds
        }
        imageViewObserver.add(\.image) { [weak self] old, new in
            guard let self = self, old?.size != new?.size else { return }
            self.resizingOverlayContentView.frame = self.imageBounds
        }
        imageViewObserver.add(\.imageFrameStyle) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingOverlayContentView.frame = self.imageBounds
        }
        imageViewObserver.add(\.imageScaling) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingOverlayContentView.frame = self.imageBounds
        }
        imageViewObserver.add(\.imageAlignment) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingOverlayContentView.frame = self.imageBounds
        }
        return overlayView
    }
    
    var imageViewObserver: KeyValueObserver<NSImageView> {
        get { getAssociatedValue(key: "imageViewObserver", object: self, initialValue: KeyValueObserver(self)) }
    }
    
    var needsResizingViewUpdate: Bool {
        get { getAssociatedValue(key: "needsResizingViewUpdate", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "needsResizingViewUpdate", object: self) }

    }
}
#endif

