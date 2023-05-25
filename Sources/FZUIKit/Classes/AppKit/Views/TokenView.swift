//
//  TokenFieldTokenView.swift
//  TokenField
//
//  Created by Umur Gedik on 22.05.2021.
//

#if os(macOS)

import AppKit
import SwiftUI

public class TokenView: NSView {
    public enum CornerType: Codable {
        case capsule
        case fixed(CGFloat)
        case rect
        case relative(CGFloat)
        case small
        case medium
        case large
    }

    public enum BackgroundStyle {
        case clear
        case color(NSColor)
        case visualEffect(VisualEffectStyle)

        public struct VisualEffectStyle {
            public var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow
            public var material: NSVisualEffectView.Material = .hudWindow
            public var appearance: NSAppearance.Name? = nil
            public static func `default`() -> Self { return self.init() }
            public static func appearance(_ name: NSAppearance.Name) -> Self { return self.init(appearance: name) }

            public static func darkAqua() -> Self { return self.init(appearance: .darkAqua) }
            public static func aqua() -> Self { return self.init(appearance: .aqua) }
            public static func vibrantDark() -> Self { return self.init(appearance: .vibrantDark) }
            public static func vibrantLight() -> Self { return self.init(appearance: .vibrantLight) }
        }
    }

    public var backgroundStyle: BackgroundStyle = .color(.controlAccentColor) {
        didSet { needsDisplay = true }
    }

    public struct Configuration {
        var opacity: Float?
        var cornerType: CornerType?
        var font: NSFont?
        var foregorundColor: NSColor?
        var backgroundStyle: BackgroundStyle?
        var imageSizeScaling: CGFloat?
        var paddings: NSDirectionalEdgeInsets?
        var imagePadding: CGFloat?
        var imageScaling: NSImageScaling?
        var imagePosition: NSDirectionalRectEdge?
        var borderWidth: CGFloat?
        var borderColor: NSColor?
        var size: CGFloat?

        public static func tinted(_ color: NSColor) -> Configuration {
            return Configuration(cornerType: .small, foregorundColor: color, backgroundStyle: .color(color.withBrightness(1.65)))
        }

        public static func colored(_ color: NSColor) -> Configuration {
            return Configuration(cornerType: .small, backgroundStyle: .color(color))
        }

        public static func opacity(_ opacity: Float) -> Configuration {
            return Configuration(opacity: opacity)
        }

        public static func coloredBorered(_ color: NSColor) -> Configuration {
            return Configuration(cornerType: .small, backgroundStyle: .color(color), borderWidth: 2.0)
        }

        public static func bordered(_: NSColor) -> Configuration {
            return Configuration(cornerType: .small, foregorundColor: nil, backgroundStyle: nil, borderWidth: 4.0, borderColor: NSColor.controlAccentColor)
        }

        public static func borderedColored(_ color: NSColor) -> Configuration {
            return Configuration(cornerType: .small, foregorundColor: color, backgroundStyle: nil, borderWidth: 4.0, borderColor: NSColor.controlAccentColor)
        }
    }

    var currentConfiguration: Configuration {
        return Configuration(opacity: opacity,
                             cornerType: cornerType,
                             font: font,
                             foregorundColor: foregroundColor,
                             backgroundStyle: backgroundStyle,
                             imageSizeScaling: imageSizeScaling,
                             paddings: paddings,
                             imagePadding: imagePadding,
                             imageScaling: imageScaling,
                             imagePosition: imagePosition,
                             borderWidth: borderWidth,
                             borderColor: borderColor)
    }

    public func applyConfiguration(_ newConfiguration: Configuration) {
        if let value = newConfiguration.opacity {
            opacity = value
        }

        if let value = newConfiguration.cornerType {
            cornerType = value
        }
        if let value = newConfiguration.font {
            font = value
        }
        if let value = newConfiguration.foregorundColor {
            foregroundColor = value
        }
        if let value = newConfiguration.backgroundStyle {
            backgroundStyle = value
        }
        if let value = newConfiguration.imageSizeScaling {
            imageSizeScaling = value
        }
        if let value = newConfiguration.paddings {
            paddings = value
        }
        if let value = newConfiguration.imagePadding {
            imagePadding = value
        }
        if let value = newConfiguration.imageScaling {
            imageScaling = value
        }
        if let value = newConfiguration.imagePosition {
            imagePosition = value
        }
        if let value = newConfiguration.borderWidth {
            borderWidth = value
        }
        if let value = newConfiguration.borderColor {
            borderColor = value
        }
        if let value = newConfiguration.size {
            sizeToFit(height: value)
        }
    }

    internal let textField = ResizingTextField(labelWithString: "")
    internal var imageView: NSImageView? = nil

    public var title: String {
        get { textField.stringValue }
        set { textField.stringValue = newValue }
    }

    public var opacity: Float = 1.0 {
        didSet { needsDisplay = true }
    }

    public var cornerType: CornerType = .small {
        didSet { needsDisplay = true }
    }

    public var font: NSFont {
        get { textField.font ?? .systemFont(ofSize: bounds.height) }
        set { textField.font = newValue }
    }

    public var foregroundColor = NSColor.white {
        didSet {
            textField.textColor = foregroundColor
            imageView?.contentTintColor = foregroundColor
        }
    }

    public var image: NSImage? = nil {
        didSet { updateImageView() }
    }

    internal func addImageView() {
        if imageView == nil {
            imageView = NSImageView()
            imageView?.imageScaling = imageScaling
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            imageView?.contentTintColor = foregroundColor
            addSubview(imageView!)
        }
    }

    internal func removeImageView() {
        imageView?.removeFromSuperview()
        imageView = nil
    }

    internal func updateImageView() {
        if let image = image {
            addImageView()
            imageView?.image = image
        } else {
            removeImageView()
        }
    }

    public var imageScaling: NSImageScaling = .scaleAxesIndependently {
        didSet {
            imageView?.imageScaling = imageScaling
        }
    }

    public var imagePadding: CGFloat = 6.0 {
        didSet { updateActiveConstraints() }
    }

    public var imageSizeScaling: CGFloat = 0.8 {
        didSet { updateActiveConstraints() }
    }

    public var imagePosition: NSDirectionalRectEdge = .trailing {
        didSet { updateActiveConstraints() }
    }

    internal var fittingString: String {
        var fitString = title
        if title == "" {
            if let placeholder = placeholderString, placeholder != "" {
                fitString = placeholder
            } else {
                fitString = "     "
            }
        }
        return fitString
    }

    public func sizeToFit(width: CGFloat) {
        let width = width - (paddings.leading + paddings.trailing)
        font = font.sized(toFit: fittingString, width: width)
    }

    public func sizeToFit(height: CGFloat) {
        let height = height - (paddings.top + paddings.bottom)
        font = font.sized(toFit: fittingString, height: height)
    }

    public var maxWidth: CGFloat? {
        get { textField.maxWidth }
        set { textField.maxWidth = newValue }
    }

    public var isEditable: Bool {
        get { textField.isEditable }
        set { textField.isEditable = newValue }
    }

    // public var isSelectable: Bool = true {
    //      didSet { needsDisplay = true } }

    public var placeholderString: String? {
        get { textField.placeholderString }
        set { textField.placeholderString = newValue }
    }

    //   public var backgroundColor: NSColor? = NSColor.controlAccentColor {
    //     didSet { needsDisplay = true } }

    public var isSelected = false {
        didSet {
            if isSelectable, let configuration = self.selectedConfiguration {
                self.applyConfiguration(configuration)
            } else if isSelectable == false, let configuration = self.nonSelectedConfiguration {
                self.applyConfiguration(configuration)
            }
        }
    }

    override public func mouseDown(with event: NSEvent) {
        toggleIsSelected()
        super.mouseDown(with: event)
    }

    override public func rightMouseDown(with theEvent: NSEvent) {
        toggleIsSelected()
        super.rightMouseDown(with: theEvent)
    }

    public func toggleIsSelected() {
        if isSelectable {
            isSelected = !isSelected
        }
    }

    var selectedConfiguration: Configuration? = .opacity(1.0)
    var nonSelectedConfiguration: Configuration? = .opacity(0.7)

    public var paddings = NSDirectionalEdgeInsets(1) {
        didSet {
            updateActiveConstraints()
        }
    }

    public func setEqualPadding(_ value: CGFloat) {
        imagePadding = value
        paddings = NSDirectionalEdgeInsets(value)
    }

    override public var acceptsFirstResponder: Bool {
        return true
    }

    internal var activeLayoutConstraints: [NSLayoutConstraint] = []
    internal func updateActiveConstraints() {
        NSLayoutConstraint.deactivate(activeLayoutConstraints)
        var paddings = self.paddings
        paddings.leading = self.paddings.leading + 2
        paddings.trailing = self.paddings.trailing + 2
        Swift.print(paddings)

        if let imageView = imageView {
            switch imagePosition {
            case .leading, .bottom:
                activeLayoutConstraints = [
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddings.leading),
                    imageView.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -imagePadding),
                    textField.topAnchor.constraint(equalTo: topAnchor, constant: paddings.top),
                    textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: paddings.bottom),
                    textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddings.trailing),
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: textField.bounds.height * imageSizeScaling),
                    imageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
                ]
                NSLayoutConstraint.activate(activeLayoutConstraints)
            case .trailing, .top:
                activeLayoutConstraints = [
                    imageView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: imagePadding),
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddings.trailing),
                    textField.topAnchor.constraint(equalTo: topAnchor, constant: -paddings.top),
                    textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddings.leading),
                    textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: paddings.bottom),
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: textField.bounds.height * imageSizeScaling),
                    imageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
                ]
                NSLayoutConstraint.activate(activeLayoutConstraints)
            default:
                break
            }
        } else {
            activeLayoutConstraints = [
                topAnchor.constraint(equalTo: textField.topAnchor, constant: -paddings.top),
                leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -paddings.leading),
                bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: paddings.bottom),
                trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: paddings.trailing),
            ]
            NSLayoutConstraint.activate(activeLayoutConstraints)
        }
    }

    internal var capsulePading: CGFloat = 0.0 {
        didSet {
            self.updateActiveConstraints()
        }
    }

    override public var wantsUpdateLayer: Bool { true }

    public convenience init(string: String? = nil, placeholder: String? = nil, color: NSColor = .controlAccentColor, image: NSImage? = nil, height _: CGFloat) {
        self.init(string: string)
        placeholderString = placeholder
        backgroundColor = color
        self.image = image
        //   self.sizeToFit(height: height)
    }

    internal let isSelectedAlphaValue: CGFloat = 0.75
    public init(string: String? = nil, color: NSColor = .controlAccentColor, paddings: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(2)) {
        self.paddings = paddings
        super.init(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        textField.drawsBackground = false
        textField.font = .systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        //    textField.backgroundColor = nil
        textField.isBordered = false
        textField.textColor = foregroundColor
        textField.isEditable = false
        textField.focusRingType = .none
        NSLayoutConstraint.activate(activeLayoutConstraints)
        backgroundColor = color
        if let string = string {
            textField.stringValue = string
            title = string
        }
        font = .systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        invalidateIntrinsicContentSize()
        frame.size = textField.fittingSize
        updateActiveConstraints()
        textField.editingStateHandler = textFieldEditStateChanged
    }

    internal func textFieldEditStateChanged(_ state: ResizingTextField.EditState) {
        if state != .didEnd {
            Swift.print("dfdff")
            wantsLayer = true
            layer?.masksToBounds = false
            layer?.shadowColor = NSColor.controlAccentColor.cgColor
            layer?.shadowOpacity = 1.0
            layer?.shadowRadius = 2.0
            //     self.layer?.borderColor = .white
            //       self.layer?.borderWidth = 0.5
            layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
        } else {
            layer?.shadowOpacity = 0.0
            //          self.layer?.borderWidth = 0.0
            layer?.shadowColor = nil
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal var visualEffectView: NSVisualEffectView? = nil
    internal func addVisualEffectView() {
        if visualEffectView == nil {
            visualEffectView = NSVisualEffectView()
            visualEffectView?.blendingMode = .withinWindow
            visualEffectView?.material = .hudWindow
            visualEffectView?.state = .followsWindowActiveState
            addSubview(withConstraint: visualEffectView!)
            visualEffectView?.sendToBack()
        }
    }

    internal func removeVisualEffectView() {
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
    }

    override public func updateLayer() {
        super.updateLayer()
        guard let layer = layer else { return }
        switch backgroundStyle {
        case .clear:
            removeVisualEffectView()
            layer.backgroundColor = nil
            layer.opacity = opacity
        case let .color(color):
            removeVisualEffectView()
            layer.backgroundColor = color.withAlphaComponent(CGFloat(opacity)).cgColor
        case let .visualEffect(style):
            addVisualEffectView()
            if let name = style.appearance {
                visualEffectView?.appearance = NSAppearance(named: name)!
            }
            visualEffectView?.material = style.material
            visualEffectView?.blendingMode = style.blendingMode
            layer.backgroundColor = nil
            layer.opacity = opacity
        }

        /*
         if let backgroundColor = self.backgroundColor {
         layer.backgroundColor = backgroundColor.withAlphaComponent(CGFloat(self.opacity)).cgColor
         layer.opacity = 1.0
         } else {
         layer.opacity = self.opacity
         }
         */

        switch cornerType {
        case .capsule:
            layer.cornerCurve = .continuous
            layer.cornerRadius = bounds.height / 2.0
            capsulePading = bounds.height / 4.0
        case let .fixed(value):
            layer.cornerCurve = .circular
            layer.cornerRadius = value
            capsulePading = 0
        case .rect:
            layer.cornerCurve = .circular
            layer.cornerRadius = 0
            capsulePading = 0
        case let .relative(value):
            let value = value / 2.0
            layer.cornerCurve = .circular
            layer.cornerRadius = bounds.height * value
            capsulePading = 0
        case .small:
            layer.cornerCurve = .circular
            layer.cornerRadius = 4.0
            capsulePading = 0
        case .medium:
            layer.cornerCurve = .circular
            layer.cornerRadius = 8.0
            capsulePading = 0
        case .large:
            layer.cornerCurve = .circular
            layer.cornerRadius = 12.0
            capsulePading = 0
        }
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor ?? foregroundColor.cgColor
    }
}

#endif
