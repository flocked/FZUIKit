//
//  NSImageView+ReservedSize.swift
//
//
//  Created by Florian Zand on 22.02.26.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSImageView {
    /**
     The layout size that the system reserves for the image, and then centers the image within.
     
     Use this property to ensure:
     - Consistent horizontal alignment for images across adjacent content views, even when the images vary in width.
     - Consistent height for content views, even when the images vary in height.
     
     The reserved layout size only affects the amount of space for the image, and its positioning within that space. It doesn’t affect the size of the image.
     
     The default value is `zero`. A width or height of zero means that the system uses the default behavior for that dimension:
     - The system centers symbol images inside a predefined reserved layout size that scales with the content size category.
     - Nonsymbol images use a reserved layout size equal to the actual size of the displayed image.
     */
    public var reservedLayoutSize: CGSize? {
        get { reservedLayoutCell?.reservedLayoutSize }
        set {
            if newValue != nil, let cell = cell as? NSImageCell, reservedLayoutCell == nil {
                do {
                    wantsLayer = true
                    let layer = layer
                    self.cell = try cell.archiveBasedCopy(as: ReservedLayoutImageCell.self)
                    layer?.delegate = self as? any CALayerDelegate
                    self.layer = layer
                    reservedLayoutCell?.setupObservations(for: self)
                } catch {
                    Swift.print(error)
                }
            }
            reservedLayoutCell?.reservedLayoutSize = newValue
        }
    }
    
    /**
     The system standard layout dimension for reserved layout size.
     
     Setting the ``reservedLayoutSize`` width or height to this constant results in using the system standard value for a symbol image for that dimension, even when the image is not a symbol image.
     */
    public static let standardDimension: CGFloat = -CGFloat.greatestFiniteMagnitude
    
    /// Sets the layout size that the system reserves for the image, and then centers the image within.
    @discardableResult
    public func reservedLayoutSize(_ size: CGSize?) -> Self {
        reservedLayoutSize = size
        return self
    }
    
    private var reservedLayoutCell: ReservedLayoutImageCell? {
        cell as? ReservedLayoutImageCell
    }
    
    @objc(ReservedLayoutImageCell)
    private class ReservedLayoutImageCell: NSImageCell {
        static let reservedLayoutStandardSize = CGSize(33.0, 22.0)
        var reservedLayoutSize: CGSize? = .zero
        var symbolSize = ReservedLayoutImageCell.reservedLayoutStandardSize
        var observations: [KeyValueObservation] = []
        var needsSymbolSizeUpdate = true
        var previousSymbolConfiguration: NSImage.SymbolConfiguration?

        override var cellSize: NSSize {
            guard let reservedLayoutSize = reservedLayoutSize, let image = image else { return super.cellSize }
            var cellSize = reservedLayoutSize
            if cellSize.width == 0 || cellSize.width == NSImageView.standardDimension {
                if cellSize.width == NSImageView.standardDimension ||  image.isSymbolImage {
                    updateSymbolSize()
                    cellSize.width = symbolSize.width
                } else {
                    cellSize.width = image.size.width
                }
            }
            if cellSize.height == 0 || cellSize.height == NSImageView.standardDimension {
                if cellSize.height == NSImageView.standardDimension || image.isSymbolImage {
                    updateSymbolSize()
                    cellSize.height = symbolSize.height
                } else {
                    cellSize.height = image.size.height
                }
            }
            return cellSize
        }
        
        override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
            guard reservedLayoutSize != nil, let image = image else {
                super.draw(withFrame: cellFrame, in: controlView)
                return
            }
            let reservedSize = cellSize
            var imageRect: CGRect = CGRect(.zero, image.size)

            switch imageAlignment {
            case .alignLeft, .alignTopLeft, .alignBottomLeft:
                imageRect.origin.x = cellFrame.origin.x
            case .alignRight, .alignTopRight, .alignBottomRight:
                imageRect.origin.x = cellFrame.maxX - reservedSize.width
            case .alignCenter, .alignTop, .alignBottom:
                imageRect.origin.x = cellFrame.midX - (reservedSize.width / 2.0)
            default:
                imageRect.origin.x = cellFrame.origin.x
            }
            switch imageAlignment {
            case .alignBottom, .alignBottomLeft, .alignBottomRight:
                imageRect.origin.y = cellFrame.origin.y
            case .alignTop, .alignTopLeft, .alignTopRight:
                imageRect.origin.y = cellFrame.maxY - reservedSize.height
            case .alignCenter, .alignLeft, .alignRight:
                imageRect.origin.y = cellFrame.midY - (reservedSize.height / 2.0)
            default:
                imageRect.origin.y = cellFrame.origin.y
            }
         //   imageRect.origin.x += (reservedSize.width - image.size.width) / 2
          //  imageRect.origin.y += (reservedSize.height - image.size.height) / 2
           // image.draw(in: imageRect)
            super.draw(withFrame: imageRect, in: controlView)
        }
                
        func updateSymbolSize() {
            guard needsSymbolSizeUpdate else { return }
            needsSymbolSizeUpdate = false
            let resolvedSymbolConfiguration = symbolConfiguration ?? image?.symbolConfiguration
            guard resolvedSymbolConfiguration != previousSymbolConfiguration else { return }
            previousSymbolConfiguration = resolvedSymbolConfiguration
            symbolSize =  resolvedSymbolConfiguration?.reservedLayoutSize() ?? Self.reservedLayoutStandardSize
        }
        
        func setupObservations(for imageView: NSImageView) {
            observations += imageView.observeChanges(for: \.image) { [weak self] old, new in
                guard let self = self, old?.symbolConfiguration != new?.symbolConfiguration else { return }
                self.needsSymbolSizeUpdate = true
            }
            observations += imageView.observeChanges(for: \.symbolConfiguration) { [weak self] old, new in
                guard let self = self else { return }
                self.needsSymbolSizeUpdate = true
            }
        }
    }
}

fileprivate extension NSImageView {
    static func reservedLayoutSize(for configuration: NSImage.SymbolConfiguration) -> CGSize {
        if let size = symbolConfigurationSizes[configuration] {
            return size
        }
        guard let imageSize = NSImage.symbol("theatermasks", withConfiguration: configuration)?.size else {
            return CGSize(33.0, 22.0)
        }
        symbolConfigurationSizes[configuration] = imageSize
        return imageSize
    }
    
    static var symbolConfigurationSizes: [NSImage.SymbolConfiguration: CGSize] {
        get { getAssociatedValue("symbolConfigurationSizes", initialValue: [.default: NSImage.symbol("theatermasks", withConfiguration: .default)!.size]) }
        set { setAssociatedValue(newValue, key: "symbolConfigurationSizes") }
    }
    
    var currentSymbolConfiguration: NSImage.SymbolConfiguration {
        symbolConfiguration ?? image?.symbolConfiguration ?? .default
    }
}



fileprivate extension NSImage.SymbolConfiguration {
    static let `default` = NSImage.SymbolConfiguration(textStyle: .body)
}

public extension NSImageCell {
    /// The image view associated with this cell.
    var imageView: NSImageView? {
        controlView as? NSImageView
    }
    
    /// The symbol configuration to use when rendering the image.
    @objc dynamic var symbolConfiguration: NSImage.SymbolConfiguration? {
        get { imageView?.symbolConfiguration ?? value(forKey: "_symbolConfiguration") }
        set {
            if let imageView = imageView {
                imageView.symbolConfiguration = newValue
            } else {
                setValue(safely: newValue, forKey: "_symbolConfiguration")
            }
        }
    }
}

public class ReservedLayoutImageView: NSImageView {
    
    /// The layout size reserved for the image.
    public var reservedLayoutSizeAlt: CGSize = .zero {
        didSet {
            guard oldValue != reservedLayoutSizeAlt else { return }
            self.invalidateIntrinsicContentSize()
            self.needsLayout = true
            self.needsDisplay = true
        }
    }
    
    public override var symbolConfiguration: NSImage.SymbolConfiguration? {
        didSet {
            guard oldValue != symbolConfiguration else { return }
            self.invalidateIntrinsicContentSize()
            self.needsLayout = true
            self.needsDisplay = true
        }
    }
    
    public override var imageAlignment: NSImageAlignment {
        didSet {
            guard oldValue != imageAlignment else { return }
            self.needsLayout = true
            self.needsDisplay = true
        }
    }
       
    /*
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.cell = ReservedImageCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cell = ReservedImageCell()
    }
    */
    
    public override class var cellClass: AnyClass? {
        get { ReservedImageCell.self }
        set { }
    }
    
    static let reservedLayoutStandardSize = CGSize(33.0, 22.0)
    
    public override var intrinsicContentSize: NSSize {
        guard let image = self.image else { return reservedLayoutSizeAlt }
        var intrinsicContentSize: CGSize = super.intrinsicContentSize
        
        var calculatedSize: CGSize = .zero
        
        if reservedLayoutSizeAlt.width == 0.0 || reservedLayoutSizeAlt.width == Self.standardDimension {
            intrinsicContentSize.width = image.isSymbolImage || reservedLayoutSizeAlt.width == 0.0 ? calculatedSize.width : image.size.width
        } else if reservedLayoutSizeAlt.width > 0.0 {
            intrinsicContentSize.width = reservedLayoutSizeAlt.width
        }
        
        if reservedLayoutSizeAlt.height == 0.0 || reservedLayoutSizeAlt.height == Self.standardDimension {
            intrinsicContentSize.height = image.isSymbolImage || reservedLayoutSizeAlt.height == 0.0 ? calculatedSize.height : image.size.height
        } else if reservedLayoutSizeAlt.height > 0.0 {
            intrinsicContentSize.height = reservedLayoutSizeAlt.height
        }
        return intrinsicContentSize
    }
}

class ReservedImageCell: NSImageCell {
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        guard let image = self.image else { return rect }
        
        let imageSize = image.size
        var drawingOrigin = rect.origin
        
        // Calculate horizontal alignment
        switch imageAlignment {
        case .alignCenter, .alignTop, .alignBottom:
            drawingOrigin.x += (rect.width - imageSize.width) / 2
        case .alignRight, .alignTopRight, .alignBottomRight:
            drawingOrigin.x += (rect.width - imageSize.width)
        case .alignLeft, .alignTopLeft, .alignBottomLeft:
            drawingOrigin.x += 0
        @unknown default:
            drawingOrigin.x += (rect.width - imageSize.width) / 2
        }
        
        // Calculate vertical alignment
        // Note: AppKit's coordinate system is usually flipped (bottom-up)
        // unless the view's isFlipped is true.
        switch imageAlignment {
        case .alignCenter, .alignLeft, .alignRight:
            drawingOrigin.y += (rect.height - imageSize.height) / 2
        case .alignTop, .alignTopLeft, .alignTopRight:
            drawingOrigin.y += (rect.height - imageSize.height)
        case .alignBottom, .alignBottomLeft, .alignBottomRight:
            drawingOrigin.y += 0
        @unknown default:
            drawingOrigin.y += (rect.height - imageSize.height) / 2
        }
        
        return NSRect(origin: drawingOrigin, size: imageSize)
    }
}

extension NSUIImage.SymbolConfiguration {
    /// The layout size that the system reserves for symbol images witth this configuration, and then centers the image within.
    func reservedLayoutSize() -> CGSize {
        Self.reservedLayoutSizes[reservedLayoutSizeKey] {
            NSUIImage.symbol("theatermasks")?.applyingSymbolConfiguration(self)?.size ?? CGSize(33.0, 22.0)
        }
    }
        
    private static var reservedLayoutSizes: [ReservedLayoutSizeKey: CGSize] {
        get { getAssociatedValue("reservedLayoutSizes") ?? [:] }
        set { setAssociatedValue(newValue, key: "reservedLayoutSizes") }
    }
    
    private var reservedLayoutSizeKey: ReservedLayoutSizeKey {
        #if os(macOS)
        .init(pointSize: pointSize, weight: weight, scale: scale)
        #else
        .init(pointSize: pointSize, weight: weight, scale: scale, textStyle: textStyle)
        #endif
    }
    
    private struct ReservedLayoutSizeKey: Hashable {
        let pointSize: CGFloat
        let weight: NSFont.Weight
        let scale: NSImage.SymbolScale
        #if !os(macOS)
        let textStyle: String?
        #endif
    }
}


#endif
