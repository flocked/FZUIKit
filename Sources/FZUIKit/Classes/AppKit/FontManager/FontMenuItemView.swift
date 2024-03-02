//
//  FontMenuItemView.swift
//
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit

public class FontMenuItemView: MenuItemView {
    let contentView = ContentView()
    
    public var font: NSFont {
        get { contentView.font }
        set { contentView.font = newValue }
    }
    
    public var title: String? {
        get { contentView.title }
        set { contentView.title = newValue }
    }
    
    public var showsSelection: Bool {
        get { contentView.showsSelection }
        set { contentView.showsSelection = newValue }
    }
    
    public init() {
        super.init(frame: CGRect(0, 0, 120, 28))
        sharedInit()
    }
    
    public init(font: NSFont, title: String? = nil) {
        super.init(frame: CGRect(0, 0, 120, 28))
        sharedInit()
        self.title = title
        self.font = font
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
        
    func sharedInit() {
        addSubview(contentView, layoutAutomatically: true)
    }
    
    public override var intrinsicContentSize: NSSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width = contentView.frame.width
        return intrinsicContentSize
    }
}

extension FontMenuItemView {
    
    class ContentView: NSView {
        static let textField = NSTextField(wrappingLabelWithString: "")
        let imageView = NSImageView()
        let textField = VerticallyCenteredTextField(wrappingLabelWithString: "")
        var centerConstraint: NSLayoutConstraint?
        var layoutConstraints: [NSLayoutConstraint] = []

        var font: NSFont {
            get { textField.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize) }
            set {
                textField.font = newValue
                update()
            }
        }
        
        var title: String? = nil {
            didSet {
                textField.stringValue = title ?? font.fontName
                update()
            }
        }
        
        var showsSelection: Bool = true {
            didSet {
                guard oldValue != showsSelection else { return }
                setupConstraints()
            }
        }
        
        func update() {
            if let font = textField.font {
                centerConstraint?.constant = (font.pointSize / 2.0) - 1.5
            }
            textField.sizeToFit()
            frame.size.width = fittingSize.width + 4
        }
        
        init() {
            super.init(frame: CGRect(0, 0, 120, 28))
            sharedInit()
        }
        
        init(font: NSFont, title: String? = nil) {
            super.init(frame: CGRect(0, 0, 120, 28))
            sharedInit()
            self.title = title
            textField.stringValue = title ?? font.fontName
            self.font = font
            adjustFont()
            update()
        }
        
        let specialFontNames: Set<String> = [
            "Bodoni Ornaments", "Webdings", "Wingdings", "Wingdings2", "Wingdings3"
        ]
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }
        
        func sharedInit() {
            imageView.imageScaling = .scaleProportionallyUpOrDown
            imageView.translatesAutoresizingMaskIntoConstraints = false
            if #available(macOS 11.0, *) {
                imageView.symbolConfiguration = .init(pointSize: NSFont.systemFontSize, weight: .heavy)
            }
            imageView.contentTintColor = .labelColor
            
            textField.isSelectable = false
            textField.lineBreakMode = .byTruncatingTail
            textField.maximumNumberOfLines = 1
            textField.translatesAutoresizingMaskIntoConstraints = false
            addSubview(textField)
            
            setupConstraints()
        }
        
        func setupConstraints() {
            layoutConstraints.activate(false)
            centerConstraint?.activate(false)
            if showsSelection {
                addSubview(imageView)
                layoutConstraints = [
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 12),
                    textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
                    textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                ]
            } else {
                imageView.removeFromSuperview()
                layoutConstraints = [
                    textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                    textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                ]
            }
            layoutConstraints.activate()
            centerConstraint = textField.firstBaselineAnchor.constraint(equalTo: centerYAnchor).activate()
            update()
        }
        
        private func adjustFont(height: CGFloat? = 28.0){
            let height: CGFloat = height ?? frame.height
            var current = font
            if let familyName = font.familyName, specialFontNames.contains(familyName) {
                current = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            }
            let margin: CGFloat = 4
            while current.pointSize > 1 {
                let attrStr = NSMutableAttributedString(string: textField.stringValue, attributes: [.font: current])
                let rect = attrStr.boundingRect(with: NSSize(width: 0, height: height), options: [.usesDeviceMetrics, .usesFontLeading])
                
                if rect.height + margin <= height {
                    break
                }
                current = current.withSize(current.pointSize - 1)
            }
            font = current
        }
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            guard let item = enclosingMenuItem else { imageView.image = nil; return }
            switch item.state {
            case .on: imageView.image = item.onStateImage
            case .mixed: imageView.image = item.mixedStateImage
            default: imageView.image = item.offStateImage
            }
        }
    }
}
#endif
