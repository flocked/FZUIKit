//
//  DragPreview.swift
//
//
//  Created by Florian Zand on 01.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import QuickLookThumbnailing

/// A graphical preview for a single drag item, used by the system after a drag has started.
public class DragPreview {
    var render: ((_ completion:  @escaping ([NSDraggingImageComponent])->())->()) =  { $0([]) }
    var id = UUID().hashValue
    var draggingImageComponents: [NSDraggingImageComponent]?
    
    /// The background color to display behind the preview.
    public var backgroundColor: NSColor?
    
    /// The portion of the image to show in the preview.
    public var visiblePath: NSBezierPath?
    
    /**
     The path to use for drawing the preview’s shadow.
     
     If `nil`, the system uses the ``visiblePath`` to draw the shadow.
     */
    public var shadowPath: NSBezierPath?
    
    func components(for image: NSImage, frame: CGRect?) -> [NSDraggingImageComponent] {
        var component = NSDraggingImageComponent(image: image, frame: frame, key: .icon)
        if let visiblePath = visiblePath, let image = image.image(maskedBy: visiblePath, size: component.frame.size) {
            component = NSDraggingImageComponent(image: image, frame: frame, key: .icon)
        }
        var imageComponents: [NSDraggingImageComponent] = []
        if let backgroundColor = backgroundColor {
            imageComponents += .init(image: NSImage(color: backgroundColor, size: component.frame.size), key: .backgroundColor)
        }
        if let shadowPath = shadowPath ?? visiblePath {
            imageComponents += .init(image: NSImage(shadowPath: shadowPath, size: component.frame.size, configuration: .black()), key: .shadow)
        }
        return imageComponents + [component]
    }

    /// Creates a drag item preview that displays the specified image.
    public init(image: NSImage, frame: CGRect? = nil) {
        render = { [weak self] completion in
            guard let self = self else { return }
            completion(self.components(for: image, frame: frame))
        }
    }
    
    /// Creates a drag item preview that displays the specified view.
    public init(view: NSView, frame: CGRect? = nil) {
        render = { [weak self] completion in
            guard let self = self else { return }
            completion(self.components(for: view.renderedImage, frame: frame))
        }
    }
    
    /// Creates a drag item preview that displays a preview of the specified file.
    public init(fileURL: URL, frame: CGRect? = nil) {
        render = { [weak self] completion in
            guard let self = self else { return }
            QLThumbnailGenerator.Request(fileAt: fileURL, size: frame?.size ?? CGSize(200, 150), scale: 1.0, representationTypes: .lowQualityThumbnail).generateRepresentations { representation, type, error in
                if let image = representation?.nsImage {
                    completion(self.components(for: image, frame: frame))
                } else {
                    completion([])
                }
            }
        }
    }
    
    /// Creates a drag item preview that displays the specified dragging image components.
    public init(imageComponents: [NSDraggingImageComponent]) {
        render = { completion in
            completion(imageComponents)
        }
    }
    
    /// Creates a drag item preview that displays the dragging image components returned by the specified handler.
    public init(imageComponentsProvider: @escaping ()->([NSDraggingImageComponent])) {
        render = { completion in
            completion(imageComponentsProvider())
        }
    }
    
    init() {
        id = -1
    }
}

extension DragPreview: Equatable {
    public static func == (lhs: DragPreview, rhs: DragPreview) -> Bool {
        lhs.id == rhs.id
    }
}

extension NSShadow {
    func renderAsImage(path shadowPath: NSBezierPath, size: CGSize) -> NSImage {
        NSImage(shadowPath: shadowPath, size: size, color: shadowColor ?? .clear, radius: shadowBlurRadius, offset: shadowOffset.point)
    }
}

extension NSImage {
   convenience init(shadowPath: NSBezierPath, size: CGSize, configuration: ShadowConfiguration) {
        self.init(size: size)
        self.lockFocus()
        NSShadow(configuration: configuration).set()
        shadowPath.fill()
        self.unlockFocus()
    }
    
    convenience init(shadowPath: NSBezierPath, size: CGSize, color: NSColor = .shadowColor, radius: CGFloat = 2.0, offset: CGPoint = CGPoint(x: 1.0, y: -1.5)) {
        self.init(shadowPath: shadowPath, size: size, configuration: .color(color, opacity: 1.0, radius: radius, offset: offset))
    }
}


extension NSDraggingItem.ImageComponentKey {
    /// A key for a corresponding value that is a dragging item’s background color.
    static let backgroundColor = NSDraggingItem.ImageComponentKey("backgroundColor")
    
    /// A key for a corresponding value that is a dragging item’s shadow.
    static let shadow = NSDraggingItem.ImageComponentKey("shadow")
}

#endif
