//
//  FontMenuItemView.swift
//
//
//  Created by Florian Zand on 24.02.24.
//

#if os(macOS)
import AppKit

class FontMenuItemView: MenuItemView {
    let contentView = ContentView()
    
    var font: NSFont {
        get { contentView.font }
        set { contentView.font = newValue }
    }
    
    var title: String? {
        get { contentView.title }
        set { contentView.title = newValue }
    }
    
    init() {
        super.init(frame: CGRect(0, 0, 120, 28))
        sharedInit()
    }
    
    init(font: NSFont, title: String? = nil) {
        super.init(frame: CGRect(0, 0, 120, 28))
        sharedInit()
        self.title = title
        self.font = font
    }
    
    override init(frame frameRect: NSRect) {
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
    
    override var intrinsicContentSize: NSSize {
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
            update()
        }
        
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
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                    imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 12),
                    textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
                    textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                ]
            } else {
                imageView.removeFromSuperview()
                layoutConstraints = [
                    textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                    textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                ]
            }
            layoutConstraints.activate()
            centerConstraint = textField.firstBaselineAnchor.constraint(equalTo: centerYAnchor).activate()
            update()
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
