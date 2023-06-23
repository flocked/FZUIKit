//
//  NewImageLayer.swift
//  FZCollection
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

public class ImageLayer: CALayer {
    public var contentTintColor: NSUIColor? = nil {
        didSet {
            updateDisplayingImageSymbolConfiguration()
        }
    }

    public var image: NSUIImage? {
        get { images.first }
        set {
            if let newImage = newValue {
                #if os(macOS)
                if newImage.isAnimated {
                    setGif(image: newImage)
                } else {
                    if #available(macOS 12.0, iOS 13.0, *) {
                        if newImage.isSymbolImage, let symbolConfiguration = symbolConfiguration, let updatedImage = newImage.applyingSymbolConfiguration(symbolConfiguration) {
                            self.images = [updatedImage]
                        } else {
                            self.images = [newImage]
                        }
                    } else {
                        images = [newImage]
                    }
                }
                #else
                if #available(iOS 15.0, *) {
                    if newImage.isSymbolImage, let symbolConfiguration = symbolConfiguration, let updatedImage = newImage.applyingSymbolConfiguration(symbolConfiguration) {
                        self.images = [updatedImage]
                    } else {
                        self.images = [newImage]
                    }
                } else {
                    images = [newImage]
                }
                #endif

            } else {
                images = []
            }
        }
    }

    public var displayingImage: NSUIImage? {
        if currentIndex > -1 && currentIndex < images.count {
            return images[currentIndex]
        }
        return nil
    }

    public var images: [NSUIImage] = [] {
        didSet {
            if isAnimating && !isAnimatable {
                stopAnimating()
            }
            setFrame(to: .first)
            updateDisplayingImage()
            if isAnimatable && !isAnimating && autoAnimates {
                startAnimating()
            }
        }
    }

    internal func updateDisplayingImageSymbolConfiguration() {
        if #available(macOS 12.0, iOS 15.0, *) {
            if contentTintColor != nil {
                if let image = self.displayingImage, image.isSymbolImage, let updatedImage = applyingSymbolConfiguration(to: image) {
                    self.images[self.currentIndex] = updatedImage
                    self.updateDisplayingImage()
                }
            }
        }
    }

    @available(macOS 12.0, iOS 15.0, *)
    internal func applyingSymbolConfiguration(to image: NSUIImage) -> NSUIImage? {
        var configuration: NSUIImage.SymbolConfiguration? = nil
        /*
         if let symbolConfiguration = symbolConfiguration {
         configuration = symbolConfiguration
         }

         if let contentTintColor = contentTintColor {
         let tintConfiguration = NSUIImage.SymbolConfiguration.palette(contentTintColor)
         configuration = configuration?.applying(tintConfiguration) ?? tintConfiguration

         }
         */

        #if os(macOS)
        if let contentTintColor = contentTintColor?.resolvedColor() {
            configuration = NSUIImage.SymbolConfiguration.palette(contentTintColor)
        }
        #else
        if let contentTintColor = contentTintColor {
            configuration = NSUIImage.SymbolConfiguration.palette(contentTintColor)
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
    @available(macOS 12.0, iOS 15.0, *)
    public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { _symbolConfiguration as? NSUIImage.SymbolConfiguration }
        set { _symbolConfiguration = newValue
            updateDisplayingImageSymbolConfiguration()
        }
    }

    public var imageScaling: CALayerContentsGravity {
        get {
            return contentsGravity
        }
        set {
            contentsGravity = newValue
        }
    }

    public var autoAnimates: Bool = true {
        didSet {
            if isAnimatable && !isAnimating && autoAnimates {
                startAnimating()
            }
        }
    }

    public var animationDuration: TimeInterval = 0.0

    public var isAnimating: Bool {
        return (displayLink != nil)
    }

    private var dlPreviousTimestamp: TimeInterval = 0.0
    private var dlCount: TimeInterval = 0.0
    public func startAnimating() {
        if isAnimatable {
            if !isAnimating {
                dlPreviousTimestamp = 0.0
                dlCount = 0.0
                displayLink = DisplayLink.shared.sink(receiveValue: { [weak self]
                    frame in
                        if let self = self {
                            let timeIntervalCount = frame.timestamp - self.dlPreviousTimestamp
                            self.dlCount = self.dlCount + timeIntervalCount
                            if self.dlCount > self.timerInterval * 2.0 {
                                self.dlCount = 0.0
                                self.setFrame(to: .next)
                                self.dlPreviousTimestamp = frame.timestamp
                            }
                        }
                })
            }
        }
    }

    public func pauseAnimating() {
        displayLink?.cancel()
        displayLink = nil
    }

    public func stopAnimating() {
        displayLink?.cancel()
        displayLink = nil
        setFrame(to: .first)
    }

    public func toggleAnimating() {
        if isAnimatable {
            if isAnimating {
                pauseAnimating()
            } else {
                startAnimating()
            }
        }
    }

    public enum FrameOption {
        case first
        case last
        case random
        case next
        case previous
    }

    public func setFrame(to option: FrameOption) {
        if images.isEmpty == false {
            switch option {
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

    #if os(macOS)
    public func setGif(image: NSImage) {
        if let frames = image.frames {
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
                    Swift.print(error)
                }
            }
        }
    }
    #endif

    private var currentIndex = 0 {
        didSet {
            updateDisplayingImage()
        }
    }

    private func updateDisplayingImage() {
        CATransaction.perform(animated: false, animations: {
            self.contents = displayingImage
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

    public var fittingSize: CGSize {
        if let imageSize = images.first?.size {
            return imageSize
        }
        return .zero
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
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

    public func sizeToFit() {
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

    override init() {
        super.init()
        sharedInit()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        sharedInit()
    }

    required init?(coder: NSCoder) {
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
                return CATransition(.push, duration)
            case let .fade(duration):
                return CATransition(.fade, duration)
            case let .moveIn(duration):
                return CATransition(.moveIn, duration)
            case let .reveal(duration):
                return CATransition(.reveal, duration)
            }
        }
    }
}
