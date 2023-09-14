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
    /// The image displayed in the image layer.
    open var image: NSUIImage? {
        get { images.count == 1 ? images.first : nil }
        set {
            guard newValue != self.image else { return }
            if let newImage = newValue {
                #if os(macOS)
                if newImage.isAnimated {
                    self.setAnimatedImage(newImage)
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
    
    /**
     The images displayed in the image layer.
     
     Setting this property to an array with multiple images will remove the image represented by the image property.
     */
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
    open var displayingImage: NSUIImage? {
        guard currentImageIndex >= 0, currentImageIndex < images.count else { return nil }
        return images[currentImageIndex]
    }
    
#if os(macOS)
/// Displays the specified animated image.
private func setAnimatedImage(_ image: NSImage) {
    if image.isAnimated, let frames = image.frames {
        self.animationRepeatCount = image.animationLoopCount ?? 0
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
            guard oldValue != tintColor else { return }
            updateDisplayingImage()
        }
    }
    
    /// The symbol configuration to use when rendering the image.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 6.0, *)
    public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { _symbolConfiguration as? NSUIImage.SymbolConfiguration }
        set {
            guard newValue != symbolConfiguration else { return }
            _symbolConfiguration = newValue
            updateDisplayingImage()
        }
    }
    
    public enum FrameOption {
        case first
        case last
        case random
        case next
        case nextLooped
        case previous
        case previousLooped
        case index(Int)
    }

    /// Sets the displaying image to the specified option.
    public func setFrame(to option: FrameOption) {
        if images.isEmpty == false {
            switch option {
            case .index(let index):
                if index >= 0, index < images.count {
                    currentImageIndex = index
                }
            case .first:
                currentImageIndex = 0
            case .last:
                currentImageIndex = images.count - 1
            case .random:
                currentImageIndex = Int.random(in: 0 ... images.count - 1)
            case .next:
                currentImageIndex = currentImageIndex.next(in: 0 ... images.count - 1)
            case .nextLooped:
                currentImageIndex = currentImageIndex.nextLooped(in: 0 ... images.count - 1)
            case .previous:
                currentImageIndex = currentImageIndex.previous(in: 0 ... images.count - 1)
            case .previousLooped:
                currentImageIndex = currentImageIndex.previousLooped(in: 0 ... images.count - 1)
            }
        } else {
            currentImageIndex = -1
        }
    }

    /// Starts animating the images in the receiver.
    public func startAnimating() {
        if isAnimatable {
            if !isAnimating {
                timerPreviousTimestamp = 0.0
                timerCurrentInterval = 0.0
                timerCurrentLoopCount = 0
                displayLink = DisplayLink.shared.sink(receiveValue: { [weak self]
                    frame in
                        if let self = self {
                            let timeIntervalCount = frame.timestamp - self.timerPreviousTimestamp
                            self.timerCurrentInterval = self.timerCurrentInterval + timeIntervalCount
                            if self.timerCurrentInterval > self.timerInterval * 2.0 {
                                self.timerCurrentInterval = 0.0
                                self.setFrame(to: .nextLooped)
                                if self.animationRepeatCount != 0, self.currentImageIndex == 0 {
                                    self.timerCurrentLoopCount += 1
                                }
                                if self.animationRepeatCount != 0, self.timerCurrentLoopCount >= self.animationRepeatCount {
                                    self.displayLink?.cancel()
                                    self.displayLink = nil
                                    self.timerCurrentLoopCount = 0
                                }
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

    /// Stops animating the images and displays the first image.
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
    
    /**
     The amount of time it takes to go through one cycle of the images.
     
     The time duration is measured in seconds. The default value of this property is 0.0, which causes the image layer to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
     */
    public var animationDuration: TimeInterval = 0.0
    
    /**
     Specifies the number of times to repeat the animation.
     
     The default value is 0, which specifies to repeat the animation indefinitely.
     */
    public var animationRepeatCount: Int = 0

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

    private var currentImageIndex = 0 {
        didSet {
            updateDisplayingImage()
        }
    }
    
    internal var maskLayer: CALayer? = nil

    private var _symbolConfiguration: Any? = nil

    private var timerPreviousTimestamp: TimeInterval = 0.0
    private var timerCurrentInterval: TimeInterval = 0.0
    private var timerCurrentLoopCount: Int = 0
    
    internal var displayingSymbolImage: NSUIImage? = nil
    internal func updateDisplayingImage() {
        if var image = self.displayingImage {
            displayingSymbolImage = nil
            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, *), image.isSymbolImage == true {
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
                if let symbolConfiguration = self.symbolConfiguration {
                    configuration = configuration?.applying(symbolConfiguration) ?? symbolConfiguration
                }
                if let configuration = configuration {
                    image = image.applyingSymbolConfiguration(configuration) ?? image
                    displayingSymbolImage = image
                }
            }
            self.contents = image
        } else {
            self.contents = nil
        }
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
        self.displayingSymbolImage?.size ??
        self.displayingImage?.size ?? .zero
    }

    open func sizeThatFits(_ size: CGSize) -> CGSize {
        if let imageSize = displayingSymbolImage?.size ?? displayingImage?.size {
            return imageSize.scaled(toFit: size)
        }
        return self.bounds.size
    /*
            switch imageScaling {
            case .resize, .resizeAspect:
                switch (size.width, size.height) {
                case (NSView.noIntrinsicMetric, NSView.noIntrinsicMetric):
                    return imageSize
                case (NSView.noIntrinsicMetric, let height):
                    return imageSize.scaled(toHeight: height)
                case (let width, NSView.noIntrinsicMetric):
                    return imageSize.scaled(toWidth: width)
                default:
                    return imageScaling == .resize ? size : imageSize.scaled(toFit: size)
                }
            case .resizeAspectFill:
                if size == CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric) {
                    return imageSize
                } else {
                    return imageSize.scaled(toFill: size)
                }
            default: return imageSize
            }
        }
        return self.frame.size
*/
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

    /// The transition animation when changing images.
    public var transition: Transition = .none {
        didSet {
            guard oldValue != transition else { return }
            self.removeAnimation(forKey: "transition")
            if let transition = self.transition.caTransition, transition.duration != 0.0 {
                self.add(transition, forKey: nil)
            }
        }
    }

    public enum Transition: Hashable {
        case none
        case fade(duration: CGFloat)
        case push(duration: CGFloat, direction: CATransitionSubtype)
        case moveIn(duration: CGFloat, direction: CATransitionSubtype)
        case reveal(duration: CGFloat, direction: CATransitionSubtype)

        fileprivate var caTransition: CATransition? {
            switch self {
            case .none:
                return nil
            case let .push(duration, direction):
                return .push(duration: duration, direction: direction)
            case let .fade(duration):
                return .fade(duration: duration)
            case let .moveIn(duration, direction):
                return .moveIn(duration: duration, direction: direction)
            case let .reveal(duration, direction):
                return .reveal(duration: duration, direction: direction)
            }
        }
    }
}

extension ImageLayer.FrameOption: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}
