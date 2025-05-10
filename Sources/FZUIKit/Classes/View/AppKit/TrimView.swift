//
//  TrimView.swift
//
//
//  Created by Florian Zand on 12.04.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import AVKit

/// A view for trimming content (like `AVPlayerItem`).
@IBDesignable
@available(macOS 12.0, *)
open class TrimView: NSControl {
    
    private let trimBorderView = NSImageView(frame: .zero).imageScaling(.scaleAxesIndependently)
    private let markerView = NSImageView(frame: .zero).imageScaling(.scaleAxesIndependently).image(TrimView.trimIndicatorImage)
    private var imageViews: [ImageView] = []
    private var overlayViews = [NSView().backgroundColor(.black.withAlphaComponent(0.5)).cornerRadius(6).roundedCorners(.leftCorners), NSView().backgroundColor(.black.withAlphaComponent(0.5)).cornerRadius(6).roundedCorners(.rightCorners)
    ]
    private var previousBounds: CGRect = .zero
    private var asssetPresentationSize: CGSize = .zero
    private var assetIsReady = false
    private var isDraggingMin = false
    private var isDraggingMax = false
    private let trimHandleWidth: CGFloat = 13.0
    private var offset: CGFloat = 0
    private let markerIndicatorTextField = NSTextField.wrapping("000:00,00").font(.caption).alignment(.center)
    private let markerIndicatorView = NSView()
    private lazy var markerIndicatorPopover = NSPopover(view: markerIndicatorView).animates(false)
    
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
        let offset = (trimHandleWidth+(markerView.bounds.width/4.0)) / bounds.width * total
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
    
    /// The asset to trim.
    open var asset: AVAsset? {
        didSet {
            guard oldValue !== asset else { return }
            asssetPresentationSize = .zero
            assetIsReady = false
            DispatchQueue.global(qos: .background).async {
                guard let track = (try? self.asset?.load(.tracks))?.first else { return }
                DispatchQueue.main.async {
                    self.assetIsReady = true
                    self.asssetPresentationSize = track.naturalSize.applying(track.preferredTransform)
                    self.range = 0.0...track.timeRange.duration.seconds
                    self.trimmedRange = self.range
                    self.markerValue = 0.0
                    self.updateThumbnails()
                }
            }
        }
    }
    
    /// Sets the asset to trim.
    @discardableResult
    open func asset(_ asset: AVAsset?) -> Self {
        self.asset = asset
        return self
    }
    
    /// Sets the player item to trim.
    @discardableResult
    open func item(_ item: AVPlayerItem?) -> Self {
        self.asset = item?.asset
        return self
    }
    
    /// The current size and position of the trimmed area within the view’s bounds.
    @objc dynamic open var trimmedContentBounds: CGRect {
        trimBorderView.frame.offsetBy(dx: trimHandleWidth)
    }
    
    /// A Boolean value indicating whether a indicator of the current `markerValue` is displayed while the user changes it's value.
    open var displaysMarkerIndicator: Bool = true
    
    /// Sets the Boolean value indicating whether a indicator of the current `markerValue` is displayed while the user changes it's value.
    @discardableResult
    open func displaysMarkerIndicator(_ displays: Bool) -> Self {
        self.displaysMarkerIndicator = displays
        return self
    }
    
    /**
     The style of the marker indcator text that is displayed while the user changes the `markerValue` value.
     
     To enable displaying the ``markerValue`` while the user changes the `markerValue` value, set ``displaysMarkerIndicator`` to `true`.
     */
    open var markerIndicatorStyle: MarkerIndicatorStyle = .automatic
    
    /**
     Sets the style of the marker indcator text that is displayed while the user changes the `markerValue` value.
     
     To enable displaying the ``markerValue`` while the user changes the `markerValue` value, set ``displaysMarkerIndicator`` to `true`.
     */
    @discardableResult
    open func markerIndicatorStyle(_ style: MarkerIndicatorStyle) -> Self {
        self.markerIndicatorStyle = style
        return self
    }
    
    /// The style of the trim view's marker indcator text that is displayed while the user changes the `markerValue` value.
    public enum MarkerIndicatorStyle: Hashable {
        /**
         Automatic formatting.
         
         The value is formatted as time (`XX:XX,XX`), if ``TrimView/asset`` isn't `nil`.
         */
        case automatic
        /// Value.
        case value
        /// The value is formatted as time (`XX:XX,XX`).
        case time
        /// The value is formatted using the specified number formatter.
        case numberFormatter(NumberFormatter)
        
        init(_ rawValue: Int, _ numberFormatter: NumberFormatter?) {
            switch rawValue {
            case 0: self = .automatic
            case 1: self = .value
            case 2: self = .time
            default: self = numberFormatter != nil ? .numberFormatter(numberFormatter!) : .automatic
            }
        }
        
        var rawValue: Int {
            switch self {
            case .automatic: return 0
            case .value: return 1
            case .time: return 2
            case .numberFormatter: return 3
            }
        }
        
        var numberFormatter: NumberFormatter? {
            switch self {
            case .numberFormatter(let numberFormatter):
                return numberFormatter
            default: return nil
            }
        }
    }
    

    open override func layout() {
        super.layout()
        if previousBounds.size != bounds.size {
            updateFrames()
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
        let trimFrame = CGRect(x: trimStartX, y: 0, width: trimEndX - trimStartX, height: bounds.height)
        if trimBorderView.frame != trimFrame {
            willChangeValue(for: \.trimmedContentBounds)
            trimBorderView.frame = CGRect(x: trimStartX, y: 0, width: trimEndX - trimStartX, height: bounds.height)
            didChangeValue(for: \.trimmedContentBounds)
        }
        
        let markerX = (clampedMarkerValue - range.lowerBound) / total * bounds.width
        markerView.frame = CGRect(x: markerX - (markerView.bounds.width/2.0), y: 0, width: markerView.bounds.width, height: contentView.bounds.height)
        markerView.center.y = bounds.center.y
        
        overlayViews.forEach({ $0.frame.size.height = contentView.bounds.height })
        overlayViews[0].frame.origin.x = contentView.frame.x
        overlayViews[0].frame.size.width = contentView.bounds.width*trimmedPercentageRange.lowerBound
        overlayViews[0].center.y = bounds.center.y
        overlayViews[1].frame.size.width = contentView.bounds.width*(1.0-trimmedPercentageRange.upperBound)
        overlayViews[1].frame.origin.x = contentView.bounds.width-(contentView.bounds.width*(1.0-trimmedPercentageRange.upperBound))+contentView.frame.x
        overlayViews[1].center.y = bounds.center.y
        
        updateImageViews()
    }
    
    private func updateImageViews() {
        let width = contentView.bounds.width/CGFloat(imageViews.count)
        for value in imageViews.indexed() {
            value.element.frame.origin.x = width * CGFloat(value.index)
            value.element.frame.size = CGSize(width, contentView.bounds.height)
        }
    }

    private func updateThumbnails() {
        guard let asset = asset, assetIsReady else { return }
        let thumbnailSize = asssetPresentationSize.scaled(toHeight: contentView.bounds.height)
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
        
        AVAssetImageGenerator(asset: asset).generateCGImagesAsynchronously(forTimes: times) { requestTime, image, actualTime, result, error in
            if let image = image, let index = times.firstIndex(where: {$0.seconds == requestTime.seconds}) {
                DispatchQueue.main.async {
                    self.imageViews[safe: index]?.image = image.nsImage
                }
            }
        }
    }

    open override func mouseDown(with event: NSEvent) {
        isDraggingMin = false
        isDraggingMax = false

        let total = range.upperBound - range.lowerBound
        guard total != 0 else { return }

        let location = event.location(in: self)
        let valueAtX = range.lowerBound + (location.x / bounds.width) * total
        
        let trimStartX = ((trimmedRange.lowerBound - range.lowerBound) / total * bounds.width)
        let trimEndX = ((trimmedRange.upperBound - range.lowerBound) / total * bounds.width)
        let trimFrame = CGRect(x: trimStartX, y: 0, width: trimEndX - trimStartX, height: bounds.height)
        if trimFrame.contains(location) {
            guard isEnabled else { return }
            let localX = location.x - trimFrame.origin.x
            if localX <= trimHandleWidth {
                offset = (localX/bounds.width) * total
                isDraggingMin = true
                
                trimmedRange = (valueAtX-offset).clamped(max: trimmedRange.upperBound)...trimmedRange.upperBound
            } else if localX >= trimFrame.width - trimHandleWidth {
                offset = ((trimFrame.width - localX) / bounds.width) * total
                isDraggingMax = true
                trimmedRange = trimmedRange.lowerBound...(valueAtX+offset).clamped(min: trimmedRange.lowerBound)
            }
        } else if location.x < trimFrame.minX {
            guard isEnabled else { return }
            isDraggingMin = true
            trimmedRange = min(valueAtX, trimmedRange.upperBound)...trimmedRange.upperBound
        } else if location.x > trimFrame.maxX {
            guard isEnabled else { return }
            isDraggingMax = true
            trimmedRange = trimmedRange.lowerBound...max(valueAtX, trimmedRange.lowerBound)
        }
        markerValue = valueAtX
        displayMarkerIndicator()
        if isContinuous {
            performAction()
        }
    }

    open override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)
        let total = range.upperBound - range.lowerBound

        guard total != 0 else { return }

        let valueAtX = range.lowerBound + (location.x / bounds.width) * total

        if isDraggingMin {
            trimmedRange = (valueAtX-offset).clamped(max: trimmedRange.upperBound)...trimmedRange.upperBound
        } else if isDraggingMax {
            trimmedRange = trimmedRange.lowerBound...(valueAtX+offset).clamped(min: trimmedRange.lowerBound)
        }
        markerValue = valueAtX
        displayMarkerIndicator()
        if isContinuous {
            performAction()
        }
    }
    
    open override func mouseUp(with event: NSEvent) {
        if !isContinuous {
            performAction()
        }
        displayMarkerIndicator(shouldDisplay: false)
    }
    
    private func displayMarkerIndicator(shouldDisplay: Bool = true) {
        if displaysMarkerIndicator, shouldDisplay {
            switch markerIndicatorStyle {
            case .automatic:
                markerIndicatorTextField.stringValue = asset != nil ? markerValue.timeString : "\(markerValue)"
            case .value:
                markerIndicatorTextField.stringValue = "\(markerValue)"
            case .time:
                markerIndicatorTextField.stringValue =  markerValue.timeString
            case .numberFormatter(let numberFormatter):
                markerIndicatorTextField.stringValue = numberFormatter.string(for: markerValue) ?? "\(markerValue)"
            }
            markerIndicatorTextField.sizeToFit()
            markerIndicatorTextField.wraps = false
            var rect = CGRect(.zero, markerIndicatorTextField.bounds.size)
            rect.size.width += 6
            rect.size.height += 6
            markerIndicatorView.frame = rect
            markerIndicatorTextField.center = markerIndicatorView.bounds.center
            markerIndicatorPopover.contentSize = markerIndicatorView.bounds.size
            markerIndicatorPopover.show(relativeTo: markerView.bounds, of: markerView, preferredEdge: .top)
        } else {
            markerIndicatorPopover.close()
        }
        // Swift.print(markerValue, markerValue.timeString)
    }
    
    open override var intrinsicContentSize: NSSize {
        CGSize(NSView.noIntrinsicMetric, controlSize == .large ? 50 : 38)
    }
    
    open override func sizeToFit() {
        frame.size.height = controlSize == .large ? 50 : 38
    }
    
    open override var fittingSize: NSSize {
        var size = CGSize(40, controlSize == .large ? 50 : 38)
        size.width += asssetPresentationSize.scaled(toHeight: size.height).width*2.0
        return size
    }
    
    @IBInspectable
    open override var controlSize: NSControl.ControlSize {
        didSet {
            guard oldValue != controlSize else { return }
            trimBorderView.image = controlSize == .large ? Self.largeTrimSelectionImage : Self.trimSelectionImage
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
    open override var isEnabled: Bool {
        didSet {
            trimBorderView.alphaValue = isEnabled ? 1.0 : 0.5
        }
    }
    
    @IBInspectable
    open override var isContinuous: Bool { didSet { } }
    
    /// Creates a trim view for trimming the specified player item.
    public init(item: AVPlayerItem) {
        super.init(frame: CGRect(.zero, CGSize(300, 38)))
        sharedInit()
        defer { asset = item.asset }
    }
    
    /// Creates a trim view for trimming the specified asset.
    public init(asset: AVAsset) {
        super.init(frame: CGRect(.zero, CGSize(300, 38)))
        sharedInit()
        defer { self.asset = asset }
    }
    
    /// Creates a trim view.
    public init() {
        super.init(frame: CGRect(.zero, CGSize(300, 38)))
        sharedInit()
    }

    /// Creates a trim view with the specified frame.
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    /// Creates a trim view.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
        markerValue = coder.decodeDouble(forKey: "markerValue")
        range = coder.decodeDouble(forKey: "rangeLowerBound")...coder.decodeDouble(forKey: "rangeUpperBound")
        trimmedRange = coder.decodeDouble(forKey: "trimmedRangeLowerBound")...coder.decodeDouble(forKey: "trimmedRangeUpperBound")
        displaysMarker = coder.decodeBool(forKey: "displaysMarker")
        markerIndicatorStyle = .init(coder.decodeInteger(forKey: "markerIndicatorStyle"), coder.decode(forKey: "markerIndicatorStyleNumberFormatter"))
        if let url: URL = coder.decode(forKey: "assetURL") {
            asset = AVURLAsset(url: url)
        }
    }
    
    open override func encode(with coder: NSCoder) {
        coder.encode(markerValue, forKey: "markerValue")
        coder.encode(range.lowerBound, forKey: "rangeLowerBound")
        coder.encode(range.upperBound, forKey: "rangeUpperBound")
        coder.encode(trimmedRange.lowerBound, forKey: "trimmedRangeLowerBound")
        coder.encode(trimmedRange.upperBound, forKey: "trimmedRangeUpperBound")
        coder.encode(displaysMarker, forKey: "displaysMarker")
        coder.encode((asset as? AVURLAsset)?.url, forKey: "assetURL")
        coder.encode(markerIndicatorStyle.rawValue, forKey: "markerIndicatorStyle")
        coder.encode(markerIndicatorStyle.numberFormatter, forKey: "markerIndicatorStyleNumberFormatter")
    }
    
    private func sharedInit() {
        trimBorderView.image = Self.trimSelectionImage
        addSubview(contentView)
        addSubview(markerView)
        overlayViews.forEach({ addSubview($0) })
        markerView.frame.size.width = 3
        addSubview(trimBorderView)
        markerIndicatorView.addSubview(markerIndicatorTextField)
    }
    
    /// An image that can be used for trim selection.
    public static var trimSelectionImage: NSImage? {
        Bundle(for: AVPlayerView.self).image(forResource: "TrimViewSelectionSmall")
    }
    
    /// A large-sized image that can be used for trim selection.
    public static var largeTrimSelectionImage: NSImage? {
        Bundle(for: AVPlayerView.self).image(forResource: "TrimViewSelectionLarge")
    }
    
    /// An image that can be used as trim indicator.
    public static var trimIndicatorImage: NSImage? {
        Bundle(for: AVPlayerView.self).image(forResource: "TrimViewIndicator")
    }
}

fileprivate extension CGFloat {
    var timeString: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let hundredths = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        let minuteFormat: String
        if minutes >= 1000 {
            minuteFormat = "%04d:%02d,%02d"
        } else if minutes >= 100 {
            minuteFormat = "%03d:%02d,%02d"
        } else {
            minuteFormat = "%02d:%02d,%02d"
        }
        return String(format: minuteFormat, minutes, seconds, hundredths)
    }
}
#endif
