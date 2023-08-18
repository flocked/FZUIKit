//
//  ImageLayer.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import Combine
import FZSwiftUtils

open class ImageLayer: CALayer {
    /// The image displayed in the image view.
    open var image: NSUIImage? {
        get { images.count == 1 ? images.first : nil }
        set {
            if let newImage = newValue {
                #if os(macOS)
                if newImage.isAnimated, newImage.framesCount > 1 {
                    self.setGifImage(newImage)
                } else {
                    images = [newImage]
                }
                #else
                images = [newImage]
                #endif
            } else {
                images = []
            }
        }
    }
    
    /// The images displayed in the image layer.
    open var images: [NSUIImage] = [] {
        didSet {
            if isAnimating && !isAnimatable {
                stopAnimating()
            }
            setFrame(to: .first)
            if isAnimatable && !isAnimating && autoAnimates {
                startAnimating()
            }
        }
    }
    
    /// The currently displaying image.
    open fileprivate(set) var displayingImage: NSUIImage? = nil
    
#if os(macOS)
/// Displays the specified GIF image.
internal func setGifImage(_ image: NSImage) {
    if image.isAnimated, let frames = image.frames {
        Task {
            var duration = 0.0
            do {
                let allFrames = try frames.collect()
                for frame in allFrames {
                    duration = duration + (frame.duration ?? ImageSource.defaultFrameDuration)
                }
                self.animationDuration = duration
                self.images = allFrames.compactMap { NSImage(cgImage: $0.image) }
            } catch {
                Swift.debugPrint(error)
            }
        }
    }
}
#endif
    
    /// The scaling of the image.
    public var imageScaling: CALayerContentsGravity {
        get {
            return contentsGravity
        }
        set {
            contentsGravity = newValue
        }
    }
    
    /// A color used to tint template images.
    open var tintColor: NSUIColor? = nil {
        didSet {
            updateDisplayingImage()
        }
    }
    
    /// The symbol configuration to use when rendering the image.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
    public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { _symbolConfiguration as? NSUIImage.SymbolConfiguration }
        set { _symbolConfiguration = newValue
            updateDisplayingImage()
        }
    }
    
    public enum FrameOption {
        case first
        case last
        case random
        case next
        case previous
        case index(Int)
    }

    /// Sets the displaying image to the specified option.
    public func setFrame(to option: FrameOption) {
        if images.isEmpty == false {
            switch option {
            case .index(let index):
                if index >= 0, index < images.count {
                    currentIndex = index
                }
            case .first:
                currentIndex = 0
            case .last:
                currentIndex = images.count - 1
            case .random:
                currentIndex = Int.random(in: 0 ... images.count - 1)
            case .next:
                currentIndex = currentIndex.nextLooped(in: 0 ... images.count - 1)
            case .previous:
                currentIndex = currentIndex.previousLooped(in: 0 ... images.count - 1)
            }
        } else {
            currentIndex = -1
        }
    }

    /// Starts animating the images in the receiver.
    public func startAnimating() {
        if isAnimatable {
            if !isAnimating {
                timerPreviousTimestamp = 0.0
                timerCurrentInterval = 0.0
                displayLink = DisplayLink.shared.sink(receiveValue: { [weak self]
                    frame in
                        if let self = self {
                            let timeIntervalCount = frame.timestamp - self.timerPreviousTimestamp
                            self.timerCurrentInterval = self.timerCurrentInterval + timeIntervalCount
                            if self.timerCurrentInterval > self.timerInterval * 2.0 {
                                self.timerCurrentInterval = 0.0
                                self.setFrame(to: .next)
                                self.timerPreviousTimestamp = frame.timestamp
                            }
                        }
                })
            }
        }
    }

    /// Pauses animating the images in the receiver.
    public func pauseAnimating() {
        displayLink?.cancel()
        displayLink = nil
    }

    /// Stops animating the images in the receiver.
    public func stopAnimating() {
        displayLink?.cancel()
        displayLink = nil
        setFrame(to: .first)
    }

    /// Toggles the animation.
    public func toggleAnimating() {
        if isAnimatable {
            if isAnimating {
                pauseAnimating()
            } else {
                startAnimating()
            }
        }
    }
    
    /// The amount of time it takes to go through one cycle of the images.
    public var animationDuration: TimeInterval = 0.0

    /// Returns a Boolean value indicating whether the animation is running.
    public var isAnimating: Bool {
        return (displayLink != nil)
    }
    
    /// A Boolean value indicating whether animatable images should automatically start animating.
    public var autoAnimates: Bool = true {
        didSet {
            if isAnimatable && !isAnimating && autoAnimates {
                startAnimating()
            }
        }
    }

    private var currentIndex = 0 {
        didSet {
            updateDisplayingImage()
        }
    }
    
    internal var needsSymbolConfiguration: Bool {
        if #available(macOS 12.0, iOS 15.0, *) {
           return self.tintColor != nil || self.symbolConfiguration != nil
        } else {
            return false
        }
    }
    
    internal var maskLayer: CALayer? = nil

    @available(macOS 12.0, iOS 15.0, *)
    internal func applyingSymbolConfiguration(to image: NSUIImage) -> NSUIImage? {
        var configuration: NSUIImage.SymbolConfiguration? = nil
        #if os(macOS)
        if let tintColor = tintColor?.resolvedColor() {
            configuration = NSUIImage.SymbolConfiguration.palette(tintColor)
        }
        #else
        if let tintColor = tintColor {
            configuration = NSUIImage.SymbolConfiguration.palette(tintColor)
        }
        #endif

        if let symbolConfiguration = symbolConfiguration {
            configuration = configuration?.applying(symbolConfiguration) ?? symbolConfiguration
        }

        if let configuration = configuration {
            return image.applyingSymbolConfiguration(configuration)
        }
        return nil
    }

    internal var _symbolConfiguration: Any? = nil

    private var timerPreviousTimestamp: TimeInterval = 0.0
    private var timerCurrentInterval: TimeInterval = 0.0

    internal func updateDisplayingImage() {
        if currentIndex > -1 && currentIndex < images.count {
            let displayingImage = images[currentIndex]
            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, *) {
                if displayingImage.isSymbolImage, needsSymbolConfiguration {
                    self.displayingImage = applyingSymbolConfiguration(to: displayingImage) ?? displayingImage
                }
            }
            self.displayingImage = displayingImage
        } else {
            self.displayingImage = nil
        }
        
        CATransaction.perform(duration: 0.0, animations: {
            self.contents = self.displayingImage
        })
    }

    private var displayLink: AnyCancellable? = nil
    private var timeStamp: TimeInterval = 0

    private var timerInterval: TimeInterval {
        if animationDuration == 0.0 {
            return ImageSource.defaultFrameDuration
        } else {
            return animationDuration / Double(images.count)
        }
    }

    private var isAnimatable: Bool {
        return (images.count > 1)
    }

    open var fittingSize: CGSize {
        self.displayingImage?.size ?? .zero
    }

    open func sizeThatFits(_ size: CGSize) -> CGSize {
        if let imageSize = images.first?.size {
            if imageSize.width <= size.width && imageSize.height <= size.height {
                return imageSize
            } else {
                switch imageScaling {
                case .resizeAspect:
                    if size.width == .infinity {
                        return imageSize.scaled(toHeight: size.height)
                    } else if size.height == .infinity {
                        return imageSize.scaled(toWidth: size.width)
                    }
                    return imageSize.scaled(toFit: size)
                default:
                    return size
                }
            }
        }
        return .zero
    }

    open func sizeToFit() {
        frame.size = fittingSize
    }

    public init(image: NSUIImage) {
        super.init()
        self.image = image
    }

    public init(layer: CALayer, image: NSUIImage) {
        super.init(layer: layer)
        self.image = image
    }

    public init(images: [NSUIImage]) {
        super.init()
        self.images = images
    }

    public init(layer: CALayer, images: [NSUIImage]) {
        super.init(layer: layer)
        self.images = images
    }

    public override init() {
        super.init()
        sharedInit()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        isOpaque = true
        contentsGravity = .resizeAspect
    }

    public var transition: Transition = .none {
        didSet {
            //  updateTransitionAnimation()
        }
    }

    /*
     private func updateTransitionAnimation() {
     if let transition = self.transition.caTransition, transition.duration != 0.0 {
     self.removeAnimation(forKey: "transition")
     self.transitionAnimation = transition
     } else {
     self.transitionAnimation = nil
     }
     }
     */

    public struct Trans {
        var type: TransitionType = .fade
        var duration: CGFloat = 0.1
        internal var caTransition: CATransition? {
            guard duration != 0.0 else { return nil }
            let transition = CATransition()
            transition.type = type.caTransitionType
            transition.duration = duration
            return transition
        }

        public enum TransitionType {
            case push
            case fade
            case moveIn
            case reveal

            internal var caTransitionType: CATransitionType {
                switch self {
                case .push:
                    return .push
                case .fade:
                    return .fade
                case .moveIn:
                    return .moveIn
                case .reveal:
                    return .reveal
                }
            }
        }
    }

    public enum Transition {
        case none
        case push(CGFloat)
        case fade(CGFloat)
        case moveIn(CGFloat)
        case reveal(CGFloat)

        fileprivate var caTransition: CATransition? {
            switch self {
            case .none:
                return nil
            case let .push(duration):
                return CATransition(.push, duration: duration)
            case let .fade(duration):
                return CATransition(.fade, duration: duration)
            case let .moveIn(duration):
                return CATransition(.moveIn, duration: duration)
            case let .reveal(duration):
                return CATransition(.reveal,  duration: duration)
            }
        }
    }
}

extension ImageLayer.FrameOption: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}
