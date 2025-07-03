//
//  InnerShadowLayer.swift
//
//
//  Created by Florian Zand on 16.09.21.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// A layer with an inner shadow.
open class InnerShadowLayer: CALayer {
    
    /// The configuration of the inner shadow.
    open var configuration: ShadowConfiguration {
        get { ShadowConfiguration(color: color, colorTransformer: colorTransformer, opacity: CGFloat(shadowOpacity), radius: shadowRadius, offset: shadowOffset.point) }
        set {
            isUpdating = true
            color = newValue.color
            colorTransformer = newValue.colorTransformer
            if let view = superlayer?.parentView {
                updateShadowColor(for: view)
            } else {
                shadowColor = newValue.resolvedColor()?.cgColor
            }
            shadowOpacity = Float(newValue.opacity)
            let needsUpdate = shadowOffset != newValue.offset.size || shadowRadius != newValue.radius
            shadowOffset = newValue.offset.size
            shadowRadius = newValue.radius
            isUpdating = false
            if needsUpdate {
                updateShadowPath()
            }
        }
    }
    
    var _maskShape: PathShape? {
        didSet { updateShadowPath() }
    }
    
    /**
     Initalizes an inner shadow layer with the specified configuration.
     
     - Parameter configuration: The configuration of the inner shadow.
     - Returns: The inner shadow layer.
     */
    public init(configuration: ShadowConfiguration) {
        super.init()
        sharedInit()
        self.configuration = configuration
    }
    
    override public init() {
        super.init()
        sharedInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }
    
    var color: NSUIColor? = nil
    var colorTransformer: ColorTransformer? = nil
    var isUpdating: Bool = false
    var _superlayerObservation: KeyValueObservation?
    var viewObservation: KeyValueObservation?
    
    func sharedInit() {
        shadowOpacity = 0.0
        shadowColor = nil
        backgroundColor = .clear
        masksToBounds = true
        shadowOffset = .zero
        shadowRadius = 0.0
        zPosition = -CGFloat(Float.greatestFiniteMagnitude) + 1
        #if os(macOS)
        _superlayerObservation = observeChanges(for: \.superlayer) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.updateViewObservation()
        }
        #endif
    }
    
    #if os(macOS)
    func updateViewObservation() {
        if let view = superlayer?.parentView {
            updateShadowColor(for: view)
            shadowColor = color?.resolvedColor(for: view).cgColor
            viewObservation = view.observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.updateShadowColor(for: view)
            }
        } else {
            viewObservation = nil
        }
    }
    #endif
    
    func updateShadowColor(for view: NSUIView) {
        if let color = color?.resolvedColor(for: view) {
            shadowColor = (colorTransformer?(color) ?? color).cgColor
        }
    }
    
    func updateShadowPath() {
        let path: NSUIBezierPath
        let innerPart: NSUIBezierPath
        if let maskPath = _maskShape?.path(in: bounds.insetBy(dx: -20, dy: -20)), let innerMaskPath = maskShape?.path(in: bounds) {
            path = NSUIBezierPath(cgPath: maskPath)
            #if os(macOS)
            innerPart = NSUIBezierPath(cgPath: innerMaskPath).reversed
            #else
            innerPart = NSUIBezierPath(cgPath: innerMaskPath).reversing()
            #endif
        } else {
            path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
            #if os(macOS)
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
            #else
            innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
            #endif
        }
        path.append(innerPart)
        shadowPath = path.cgPath
    }
    
    override open var shadowRadius: CGFloat {
        didSet {
            if !isUpdating, oldValue != shadowRadius { updateShadowPath() }
        }
    }
    
    override open var shadowOffset: CGSize {
        didSet {
            if !isUpdating, oldValue != shadowOffset { updateShadowPath() }
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            if !isUpdating, oldValue != bounds { updateShadowPath() }
        }
    }
    
    override open var cornerRadius: CGFloat {
        didSet {
            if !isUpdating, oldValue != cornerRadius { updateShadowPath() }
        }
    }
    
    override open var shadowColor: CGColor? {
        didSet {
            if !isUpdating, oldValue != shadowColor { color = shadowColor?.nsUIColor }
        }
    }
}

#endif

#if os(macOS)

extension NSView {
    var dynamicLayerColors: DynamicLayerColors {
        getAssociatedValue("dynamicLayerColors", initialValue: DynamicLayerColors(for: self))
    }
}
class DynamicLayerColors {
    init(for view: NSView) {
        self.view = view
    }
    
    var dynamicColors: [WritableKeyPath<CALayer, CGColor>: DynamicColor] = [:] {
        didSet { updateObserver() }
    }
    
    var dynamicColorsOpt: [WritableKeyPath<CALayer, CGColor?>: DynamicColor] = [:] {
        didSet { updateObserver() }
    }
    
    weak var view: NSView?
    
    subscript(keyPath: WritableKeyPath<CALayer, CGColor>) -> NSColor? {
        get {
            update(keyPath)
            return dynamicColors[keyPath]?.color
        }
        set {
            guard newValue != dynamicColors[keyPath]?.color else { return }
            dynamicColors[keyPath] = DynamicColor(newValue)
        }
    }
    
    subscript(keyPath: WritableKeyPath<CALayer, CGColor?>) -> NSColor? {
        get {
            update(keyPath)
            return dynamicColorsOpt[keyPath]?.color
        }
        set {
            guard newValue != dynamicColorsOpt[keyPath]?.color else { return }
            dynamicColorsOpt[keyPath] = DynamicColor(newValue)
        }
    }
    
    func update(_ keyPath: WritableKeyPath<CALayer, CGColor>) {
        guard let view = view, var layer = view.layer, let dynamic = dynamicColors[keyPath] else { return }
        guard !dynamic.isMatching(layer[keyPath: keyPath]) else { return }
        dynamicColors[keyPath] = nil
    }
    
    func update(_ keyPath: WritableKeyPath<CALayer, CGColor?>) {
        guard let view = view, var layer = view.layer, let dynamic = dynamicColorsOpt[keyPath] else { return }
        guard !dynamic.isMatching(layer[keyPath: keyPath]) else { return }
        dynamicColorsOpt[keyPath] = nil
    }
    
    func updateColors() {
        guard let view = view, var layer = view.layer else { return }
        for val in dynamicColors {
            if val.value.isMatching(layer[keyPath: val.key]) {
                layer[keyPath: val.key] = val.value.color.resolvedColor(for: view).cgColor
            } else {
                dynamicColors[val.key] = nil
            }
        }
        
        for val in dynamicColorsOpt {
            if val.value.isMatching(layer[keyPath: val.key]) {
                layer[keyPath: val.key] = val.value.color.resolvedColor(for: view).cgColor
            } else {
                dynamicColorsOpt[val.key] = nil
            }
        }
    }
    
    
    var appearanceObservation: KeyValueObservation?
    
    func updateObserver() {
        if dynamicColors.isEmpty && dynamicColorsOpt.isEmpty {
            appearanceObservation = nil
        } else if appearanceObservation == nil {
            appearanceObservation = view?.observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                self?.updateColors()
            }
        }
    }
    
    struct DynamicColor {
        let color: NSColor
        private var light: CGColor
        private var dark: CGColor
        
        func isMatching(_ color: CGColor) -> Bool {
            color == light || color == dark
        }
        
        func isMatching(_ color: CGColor?) -> Bool {
            guard let color = color else { return false }
            return isMatching(color)
        }
        
        init?(_ color: NSColor?) {
            guard let color = color, color.isDynamic else { return nil }
            let colors = color.dynamicColors
            self.color = color
            self.light = colors.light.cgColor
            self.dark = colors.dark.cgColor
        }
    }
    
    /*
    subscript(keyPath: WritableKeyPath<CALayer, CGColor>) -> NSColor? {
        get {
            dynamicColors[keyPath]
        }
    }
    
    subscript(keyPath: WritableKeyPath<CALayer, CGColor?>) -> NSColor? {
        get {
            dynamicColorsOpt[keyPath]
        }
    }
     */
}
#endif
