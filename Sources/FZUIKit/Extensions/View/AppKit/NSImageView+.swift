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
    func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
    
    /// Sets the symbol configuration.
    @available(macOS 11, *)
    @discardableResult
    func symbolConfiguration(_ configuration: NSImage.SymbolConfiguration?) -> Self {
        self.symbolConfiguration = configuration
        return self
    }
    
    /// Sets the symbol configuration.
    @available(macOS 12, *)
    @discardableResult
    func symbolConfiguration(_ configuration: ImageSymbolConfiguration?) -> Self {
        self.symbolConfiguration = configuration?.nsUI()
        return self
    }
    
    /// Sets the color used to tint template images in the view hierarchy.
    @discardableResult
    func contentTintColor(_ color: NSColor?) -> Self {
        contentTintColor = color
        return self
    }
        
    /// Sets the scaling mode applied to make the cell’s image fit the frame of the image view.
    @discardableResult
    func imageScaling(_ imageScaling: NSImageScaling) -> Self {
        self.imageScaling = imageScaling
        return self
    }
    
    /// Sets the alignment of the cell’s image inside the image view.
    @discardableResult
    func imageAlignment(_ alignment: NSImageAlignment) -> Self {
        imageAlignment = alignment
        return self
    }
    
    /// Sets Boolean value indicating whether the image view automatically plays animated images.
    @discardableResult
    func animates(_ animates: Bool) -> Self {
        self.animates = animates
        return self
    }
    
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

/*
 extension NSImageView {
     static var didSwizzleImageScaling: Bool {
         get { getAssociatedValue(key: "didSwizzleImageScaling", object: self, initialValue: false) }
         set { set(associatedValue: newValue, key: "didSwizzleImageScaling", object: self) }
     }
     
     var isScaleToFill: Bool {
         get { getAssociatedValue(key: "isScaleToFill", object: self, initialValue: false) }
         set {
             set(associatedValue: newValue, key: "isScaleToFill", object: self)
             if newValue == true {
                 wantsLayer = true
                 layer?.contentsGravity = .resizeAspectFill
             }
         }
     }
     
     var layerImageView: NSView {
         get {
             if let view: NSView = getAssociatedValue(key: "layerImageView", object: self) {
                 return view
             }
             let view = NSView()
             view.wantsLayer = true
             view.layer?.contentsGravity = .resizeAspectFill
             set(associatedValue: view, key: "layerImageView", object: self)
             return view
         }
     }
     
     @objc var swizzled_image: NSImage? {
         get {
             if isScaleToFill {
                 return getAssociatedValue(key: "swizzled_image", object: self, initialValue: image)
             } else {
                 return self.swizzled_image
             }
         }
         set {
             if isScaleToFill {
                 if layerImageView.superview == nil {
                     addSubview(withConstraint: layerImageView)
                 }
                 set(associatedValue: newValue, key: "swizzled_image", object: self)
                 self.swizzled_image = nil
                 layerImageView.layer?.contents = newValue
             } else {
                 layerImageView.removeFromSuperview()
                 layerImageView.layer?.contents = nil
                 set(associatedValue: nil as NSImage?, key: "swizzled_image", object: self)
                 self.swizzled_image = newValue
             }
         }
     }
     
     @objc var swizzled_imageScaling: NSImageScaling {
         get { isScaleToFill ? .scaleToFill : self.swizzled_imageScaling }
         set {
             guard newValue != self.swizzled_imageScaling else { return }
             let currentImage = image
             if newValue != .scaleToFill {
                 self.swizzled_imageScaling = newValue
             }
             if newValue == .scaleToFill || isScaleToFill {
                 image = currentImage
             }
             isScaleToFill = newValue == .scaleToFill
         }
     }
     static func swizzleImageScaling() {
         guard didSwizzleImageScaling == false else { return }
         didSwizzleImageScaling = true
         do {
             try Swizzle(NSImageView.self) {
                 #selector(setter: NSImageView.imageScaling) <-> #selector(setter: NSImageView.swizzled_imageScaling)
                 #selector(getter: NSImageView.imageScaling) <-> #selector(getter: NSImageView.swizzled_imageScaling)
                 #selector(setter: NSImageView.image) <-> #selector(setter: NSImageView.swizzled_image)
                 #selector(getter: NSImageView.image) <-> #selector(getter: NSImageView.swizzled_image)
             }
         } catch {
             Swift.debugPrint(error)
         }
     }
 }

 extension NSImageScaling {
     public static var scaleToFill: NSImageScaling {
         NSImageView.swizzleImageScaling()
         return NSImageScaling(rawValue: 100) ?? .scaleProportionallyUpOrDown
     }
     public static var scaleToFit: NSImageScaling {
         .scaleProportionallyUpOrDown
     }
 }
 */
