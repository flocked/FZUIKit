//
//  TrimView.swift
//
//
//  Created by Florian Zand on 12.04.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import FZUIKit
import AVKit

/// A view for trimming content (like `AVPlayerItem`).
@IBDesignable
open class TrimView: NSControl {
    
    private let trimBorderView = NSImageView(frame: .zero).imageScaling(.scaleAxesIndependently)
    private let markerView = NSView(frame: .zero).size(CGSize(1)).backgroundColor(.systemRed)
    private var imageViews: [ImageView] = []
    private var overlayViews = Array(generate: {NSView(frame: .zero).backgroundColor(.black.withAlphaComponent(0.5))}, count: 2)
    private var previousBounds: CGRect = .zero
    private let player = AVPlayer()
    private var itemIsReady = false
    private var isDraggingMin = false
    private var isDraggingMax = false
    private let trimHandleWidth: CGFloat = 13.0
    private var offset: CGFloat = 0
    
    /// The content view.
    public let contentView = NSView(frame: .zero).cornerRadius(6.0)

    /// The range that can be trimmed.
    open var range: ClosedRange<CGFloat> = 0...1.0 {
        didSet {
            guard oldValue != range else { return }
            trimmedRange = trimmedRange.clamped(to: range)
            markerValue = markerValue.clamped(to: range)
            updateFrames()
            updateThumbnails()
        }
    }
    
    /// Sets the range that can be trimmed.
    @discardableResult
    open func range(_ range: ClosedRange<CGFloat>) -> Self {
        self.range = range
        return self
    }

    /// The trimmed range.
    open var trimmedRange: ClosedRange<CGFloat> = 0...1.0 {
        didSet {
            guard oldValue != trimmedRange else { return }
            trimmedRange = trimmedRange.clamped(to: range)
            markerValue = markerValue.clamped(to: trimmedRange)
            updateFrames()
            updateImageViews()
            updateThumbnails()
        }
    }
    
    /// Sets the trimmed range.
    @discardableResult
    open func trimmedRange(_ range: ClosedRange<CGFloat>) -> Self {
        trimmedRange = range
        return self
    }

    /// The trim trimmed in percentages (between `0.0` & `1.0`).
    open var trimmedPercentageRange: ClosedRange<CGFloat> {
        get {
            let total = range.upperBound - range.lowerBound
            guard total != 0 else { return 0...0 }
            return ((trimmedRange.lowerBound - range.lowerBound) / total)...((trimmedRange.upperBound - range.lowerBound) / total)
        }
        set {
            let total = range.upperBound - range.lowerBound
            trimmedRange = (range.lowerBound + newValue.lowerBound * total)...(range.lowerBound + newValue.upperBound * total)
        }
    }
    
    /// Sets the trimmed range in percentages (between `0.0` & `1.0`).
    @discardableResult
    open func trimmedPercentageRange(_ range: ClosedRange<CGFloat>) -> Self {
        trimmedPercentageRange = range
        return self
    }

    /// The marker value.
    @IBInspectable
    @objc dynamic open var markerValue: CGFloat = 0.0 {
        didSet {
            guard oldValue != markerValue else { return }
            markerValue = markerValue.clamped(to: trimmedRange)
            updateFrames()
        }
    }
    
    private var clampedMarkerValue: CGFloat {
        let total = range.upperBound-range.lowerBound
        let offset = (trimHandleWidth+(markerView.bounds.width/2.0)) / bounds.width * total
        let lowerBound = trimmedRange.lowerBound+offset
        let trimmedRange = lowerBound...(trimmedRange.upperBound-offset).clamped(min: lowerBound)
        return markerValue.clamped(to: trimmedRange)
    }
    
    /// Sets the marker value.
    @discardableResult
    open func markerValue(_ markerValue: CGFloat) -> Self {
        self.markerValue = markerValue
        return self
    }
    
    open override var doubleValue: Double {
        get { clampedMarkerValue }
        set { markerValue = newValue }
    }

    /// The marker value in percentage (between `0.0` & `1.0`).
    open var markerPercentageValue: CGFloat {
        get {
            let total = range.upperBound - range.lowerBound
            guard total != 0 else { return 0 }
            return (markerValue - range.lowerBound) / total
        }
        set {
            let total = range.upperBound - range.lowerBound
            markerValue = range.lowerBound + newValue * total
        }
    }
    
    /// Sets the marker value in percentage (between `0.0` & `1.0`).
    @discardableResult
    open func markerPercentageValue(_ markerPercentageValue: CGFloat) -> Self {
        self.markerPercentageValue = markerPercentageValue
        return self
    }
    
    /// A Boolean value indicating whether the marker is displayed.
    open var displaysMarker: Bool {
        get { !markerView.isHidden }
        set { markerView.isHidden = !newValue }
    }
    
    /// Sets the Boolean value indicating whether the marker is displayed.
    @discardableResult
    open func displaysMarker(_ displays: Bool) -> Self {
        displaysMarker = displays
        return self
    }
    
    /// The color of the marker.
    public var markerColor: NSColor {
        get { markerView.backgroundColor! }
        set { markerView.backgroundColor = newValue }
    }
    
    /// Sets the color of the marker.
    @discardableResult
    open func markerColor(_ color: NSColor) -> Self {
        markerColor = color
        return self
    }
    
    /// The width of the marker.
    var markerWidth: CGFloat = 1.0 {
        didSet {
            guard oldValue != markerWidth else { return }
            updateFrames()
        }
    }
    
    /// Sets the width of the marker.
    @discardableResult
    open func markerWidth(_ width: CGFloat) -> Self {
        markerWidth = width
        return self
    }
    
    /// The player item to trim.
    open weak var item: AVPlayerItem? {
        didSet {
            guard oldValue !== item else { return }
            oldValue?.statusHandler = nil
            itemIsReady = false
            player.replaceCurrentItem(with: item)
            item?.statusHandler = { [weak self] status in
                guard let self = self, status == .readyToPlay, let item = self.item else { return }
                self.itemIsReady = true
                self.range = 0.0...item.duration.seconds
                self.trimmedRange = self.range
                self.markerValue = 0.0
                self.updateThumbnails()
            }
        }
    }
    
    /// Sets the player item to trim.
    @discardableResult
    open func item(_ item: AVPlayerItem?) -> Self {
        self.item = item
        return self
    }
    
    /// The current size and position of the trimmed area within the view’s bounds.
    @objc dynamic open var trimmedContentBounds: CGRect {
        trimBorderView.frame.offsetBy(dx: trimHandleWidth)
    }

    open override func layout() {
        super.layout()
        if previousBounds.size != bounds.size {
            updateFrames()
            updateImageViews()
        }
        previousBounds = bounds
    }
    
    private func updateFrames() {
        contentView.frame.size = CGSize(bounds.width - 26, bounds.height-4)
        contentView.center = bounds.center
        
        let total = range.upperBound - range.lowerBound
        guard total != 0 else { return }

        let trimStartX = (trimmedRange.lowerBound - range.lowerBound) / total * bounds.width
        let trimEndX = (trimmedRange.upperBound - range.lowerBound) / total * bounds.width
        let markerX = (clampedMarkerValue - range.lowerBound) / total * bounds.width

        willChangeValue(for: \.trimmedContentBounds)
        trimBorderView.frame = CGRect(x: trimStartX, y: 0, width: trimEndX - trimStartX, height: bounds.height)
        didChangeValue(for: \.trimmedContentBounds)
        markerView.frame = CGRect(x: markerX - (markerWidth/2.0), y: 0, width: markerWidth, height: contentView.bounds.height)
        markerView.center.y = bounds.center.y
        
        overlayViews.forEach({ $0.frame.size.height = contentView.bounds.height })
        overlayViews[0].frame.origin = .zero
        overlayViews[0].frame.size.width = contentView.bounds.width*trimmedPercentageRange.lowerBound
        overlayViews[1].frame.size.width = contentView.bounds.width*(1.0-trimmedPercentageRange.upperBound)
        overlayViews[1].frame.origin.x = contentView.bounds.width-(contentView.bounds.width*(1.0-trimmedPercentageRange.upperBound))
    }
    
    private func updateImageViews() {
        let width = contentView.bounds.width/CGFloat(imageViews.count)
        for value in imageViews.indexed() {
            value.element.frame.origin.x = width * CGFloat(value.index)
            value.element.frame.size = CGSize(width, contentView.bounds.height)
        }
    }

    private func updateThumbnails() {
        guard let item = item, itemIsReady else { return }
        let thumbnailSize = item.presentationSize.scaled(toHeight: contentView.bounds.height)
        let thumbnailCount = Int(ceil(contentView.bounds.width / thumbnailSize.width))
        guard thumbnailCount > 1 else { return }
        if imageViews.count > thumbnailCount {
            for i in (imageViews.count-thumbnailCount..<imageViews.count).reversed() {
                imageViews[i].removeFromSuperview()
                imageViews.remove(at: i)
            }
        } else if imageViews.count < thumbnailCount {
            for i in 0..<thumbnailCount-imageViews.count {
                let imageView = ImageView(frame: CGRect(x: CGFloat(i)*thumbnailSize.width, y: 0, width: thumbnailSize.width, height: contentView.bounds.height)).imageScaling(.scaleToFill).backgroundColor(.black)
                contentView.addSubview(imageView)
                imageViews += imageView
            }
        }
        
        updateImageViews()
        let lowerIndex = imageViews.firstIndex(where: {$0.frame.contains(CGPoint(contentView.bounds.width*trimmedPercentageRange.lowerBound, 0))}) ?? 0
        let upperIndex = imageViews.firstIndex(where: {$0.frame.contains(CGPoint(contentView.bounds.width*trimmedPercentageRange.upperBound, 0))}) ?? imageViews.count

        var times: [CMTime] = []
        let seconds = (range.upperBound-range.lowerBound)/CGFloat(thumbnailCount-1)
        for i in 0..<thumbnailCount {
            if i == lowerIndex {
                times += CMTime(seconds: trimmedRange.lowerBound)
            } else if i == upperIndex {
                times += CMTime(seconds: trimmedRange.upperBound)
            } else {
                times += CMTime(seconds: range.lowerBound + (CGFloat(i)*seconds))
            }
        }
        
        AVAssetImageGenerator(asset: item.asset).generateCGImagesAsynchronously(forTimes: times) { requestTime, image, actualTime, result, error in
            if let image = image, let index = times.firstIndex(where: {$0.seconds == requestTime.seconds}) {
                DispatchQueue.main.async {
                    self.imageViews[safe: index]?.image = image.nsImage
                }
            }
        }
    }

    open override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }
        isDraggingMin = false
        isDraggingMax = false

        let location = event.location(in: self)
        let x = location.x
        let width = bounds.width
        let total = range.upperBound - range.lowerBound

        guard total != 0 else { return }

        let valueAtX = range.lowerBound + (x / width) * total
        
        let trimStartX = ((trimmedRange.lowerBound - range.lowerBound) / total * width)
        let trimEndX = ((trimmedRange.upperBound - range.lowerBound) / total * width)
        let trimFrame = CGRect(x: trimStartX, y: 0, width: trimEndX - trimStartX, height: bounds.height)
        if trimFrame.contains(location) {
            let localX = x - trimFrame.origin.x
            if localX <= trimHandleWidth {
                offset = (localX/bounds.width) * total
                isDraggingMin = true
                trimmedRange = (valueAtX-offset).clamped(max: trimmedRange.upperBound)...trimmedRange.upperBound
            } else if localX >= trimFrame.width - trimHandleWidth {
                offset = ((trimFrame.width - localX) / width) * total
                isDraggingMax = true
                trimmedRange = trimmedRange.lowerBound...(valueAtX+offset).clamped(min: trimmedRange.lowerBound)
            }
        } else if x < trimFrame.minX {
            isDraggingMin = true
            trimmedRange = min(valueAtX, trimmedRange.upperBound)...trimmedRange.upperBound
        } else if x > trimFrame.maxX {
            isDraggingMax = true
            trimmedRange = trimmedRange.lowerBound...max(valueAtX, trimmedRange.lowerBound)
        }
        markerValue = valueAtX
        
        if isContinuous {
            performAction()
        }
    }

    open override func mouseDragged(with event: NSEvent) {
        guard isEnabled else { return }
        let location = event.location(in: self)
        let x = location.x
        let width = bounds.width
        let total = range.upperBound - range.lowerBound

        guard total != 0 else { return }

        let valueAtX = range.lowerBound + (x / width) * total

        if isDraggingMin {
            trimmedRange = (valueAtX-offset).clamped(max: trimmedRange.upperBound)...trimmedRange.upperBound
        } else if isDraggingMax {
            trimmedRange = trimmedRange.lowerBound...(valueAtX+offset).clamped(min: trimmedRange.lowerBound)
        }
        markerValue = valueAtX
        if isContinuous {
            performAction()
        }
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard isEnabled, !isContinuous else { return }
        performAction()
    }
    
    open override var intrinsicContentSize: NSSize {
        if #available(macOS 11.0, *) {
            CGSize(NSView.noIntrinsicMetric, controlSize == .large ? 50 : 38)
        } else {
            CGSize(NSView.noIntrinsicMetric, 38)
        }
    }
    
    open override func sizeToFit() {
        if #available(macOS 11.0, *) {
            frame.size.height = controlSize == .large ? 50 : 38
        } else {
            frame.size.height = 38
        }
    }
    
    open override var fittingSize: NSSize {
        if #available(macOS 11.0, *) {
            CGSize(40, controlSize == .large ? 50 : 38)
        } else {
            CGSize(40, 38)
        }
    }
    
    @IBInspectable
    open override var controlSize: NSControl.ControlSize {
        didSet {
            guard oldValue != controlSize else { return }
            if #available(macOS 11.0, *) {
                trimBorderView.image = Bundle(for: AVPlayerView.self).image(forResource: controlSize == .large ? "TrimViewSelectionLarge" : "TrimViewSelectionSmall")
            } else {
                trimBorderView.image = Bundle(for: AVPlayerView.self).image(forResource: "TrimViewSelectionSmall")
            }
        }
    }
    
    @IBInspectable
    var minValue: CGFloat {
        get { range.lowerBound }
        set { range = newValue...range.upperBound }
    }
    
    @IBInspectable
    var maxValue: CGFloat {
        get { range.upperBound }
        set { range = range.lowerBound...newValue }
    }
    
    @IBInspectable
    var trimmedMinValue: CGFloat {
        get { trimmedRange.lowerBound }
        set { trimmedRange = newValue...trimmedRange.upperBound }
    }
    
    @IBInspectable
    var trimmedMaxValue: CGFloat {
        get { trimmedRange.upperBound }
        set { trimmedRange = trimmedRange.lowerBound...newValue }
    }
    
    @IBInspectable
    public override var isEnabled: Bool { didSet { } }
    
    @IBInspectable
    open override var isContinuous: Bool { didSet { } }
    
    public init(item: AVPlayerItem) {
        super.init(frame: CGRect(.zero, CGSize(300, 38)))
        sharedInit()
        self.item = item
    }
    
    public init() {
        super.init(frame: CGRect(.zero, CGSize(300, 38)))
        sharedInit()
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
        markerValue = coder.decodeDouble(forKey: "markerValue")
        range = coder.decodeDouble(forKey: "rangeLowerBound")...coder.decodeDouble(forKey: "rangeUpperBound")
        trimmedRange = coder.decodeDouble(forKey: "trimmedRangeLowerBound")...coder.decodeDouble(forKey: "trimmedRangeUpperBound")
        displaysMarker = coder.decodeBool(forKey: "displaysMarker")
    }
    
    open override func encode(with coder: NSCoder) {
        coder.encode(markerValue, forKey: "markerValue")
        coder.encode(range.lowerBound, forKey: "rangeLowerBound")
        coder.encode(range.upperBound, forKey: "rangeUpperBound")
        coder.encode(trimmedRange.lowerBound, forKey: "trimmedRangeLowerBound")
        coder.encode(trimmedRange.upperBound, forKey: "trimmedRangeUpperBound")
        coder.encode(displaysMarker, forKey: "displaysMarker")
    }
    
    private func sharedInit() {
        trimBorderView.image = Bundle(for: AVPlayerView.self).image(forResource: "TrimViewSelectionSmall")
        addSubview(contentView)
        addSubview(markerView)
        overlayViews.forEach({ contentView.addSubview($0) })
        addSubview(trimBorderView)
    }
}
#endif
