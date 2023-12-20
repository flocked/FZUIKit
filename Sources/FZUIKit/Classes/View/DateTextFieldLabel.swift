//
//  DateTextField.swift
//  
//  Adopted from:
//  Tyler Hall
//

#if os(macOS)
import AppKit

/// A `NSTextField` that displays a date either absolute or relative.
public class DateTextField: NSTextField {
    /// The mode a date gets displayed.
    public enum DateDisplayMode: Int {
        /// The textfield displays a relative date or time (e.g. "2 mins ago").
        case relative
        /// The textfield displays a absolute date or time (e.g. "10:11pm 04.04.2023").
        case absolute
    }

    /// The date to display.
    public var date: Date? {
        didSet { configurateDateString() }
    }
    
    /// The mode a date gets displayed.
    public var dateDisplayMode: DateDisplayMode = .relative {
        didSet { updateDateString() }
    }

    /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed via ``refreshDate()``.
    public var refreshDateInterval: TimeInterval? = 5 {
        didSet { configurateDateString()  } }
    
    
    /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed via ``refreshDate()``.
    public func refreshDate() {
        configurateDateString()
    }

    /// the date style of the displayed date, if ``dateDisplayMode-swift.property`` is set to ``DateDisplayMode-swift.enum/absolute``.
    public var dateStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.dateStyle = dateStyle
            updateDateString()
        }
    }

    /// the time style of the displayed date, if ``dateDisplayMode-swift.property`` is set to ``DateDisplayMode-swift.enum/absolute``.
    public var timeStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.timeStyle = timeStyle
            updateDateString()
        }
    }
    
    public convenience init(date: Date, displayMode: DateDisplayMode) {
        self.init(frame: .zero)
        self.textLayout = .wraps
        self.drawsBackground = false
        self.backgroundColor = nil
        self.isBezeled = false
        self.isBordered = false
        self.date = date
        self.configurateDateString()
        self.sizeToFit()
    }
    
    public convenience init(date: Date, displayMode: DateDisplayMode, frame: CGRect) {
        self.init(frame: frame)
        self.textLayout = .wraps
        self.drawsBackground = false
        self.backgroundColor = nil
        self.isBezeled = false
        self.isBordered = false
        self.date = date
        self.configurateDateString()
        self.sizeToFit()
    }
    
    internal let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
    internal static let relativeDateFormatter = RelativeDateTimeFormatter()
    internal static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
    internal static let buffer: TimeInterval = 2
    internal var liveUpdateTimer: Timer? = nil

    
    public override var intrinsicContentSize: NSSize {
        var intrinsicContentSize = super.intrinsicContentSize
        if intrinsicContentSize.width == NSView.noIntrinsicMetric, let cell = self.cell {
            intrinsicContentSize.width = cell.cellSize(forBounds: CGRect(.zero, CGSize(CGFloat.greatestFiniteMagnitude, intrinsicContentSize.height))).rounded(.up).width
        }
        return intrinsicContentSize
    }
    
    internal func configurateDateString() {
        if dateDisplayMode == .absolute {
            liveUpdateTimer?.invalidate()
        }

        if let date = date {
            updateDateString()

            liveUpdateTimer?.invalidate()
            if let refreshInterval = self.refreshDateInterval {
                let delta = Date().timeIntervalSince(date)
                let liveUpdateInterval: TimeInterval = (delta < DateTextField.slowRefreshInterval) ? refreshInterval : (DateTextField.slowRefreshInterval - DateTextField.buffer)
                
                liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
                    let delta = Date().timeIntervalSince(date)
                    if delta > (DateTextField.slowRefreshInterval + DateTextField.buffer) {
                        self.date = date
                    }
                    self.updateDateString()
                })
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
            toolTip = nil
        }
    }

    override public var stringValue: String {
        didSet {
            if stringValue != dateString {
                self.date = nil
            }
        }
    }

    override public var attributedStringValue: NSAttributedString {
        didSet {
            date = nil
        }
    }

    internal var dateString: String? = nil
    internal func updateDateString() {
        if let date = date {
            if dateDisplayMode == .relative {
                stringValue = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                dateString = stringValue
                toolTip = dateFormatter.string(from: date)
            } else {
                stringValue = dateFormatter.string(from: date)
                dateString = stringValue
                toolTip = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
            toolTip = nil
        }
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit
/// A `UILabel` that displays a date either absolute or relative.
public class DateLabel: UILabel {
    
    /// The mode a date gets displayed.
    public enum DateDisplayMode {
        /// The textfield displays a relative date or time (e.g. "2 mins ago").
        case relative
        /// The textfield displays a absolute date or time (e.g. "10:11pm 04.04.2023").
        case absolute
    }

    /// The date to display.
    public var date: Date? {
        didSet { configurateDateString() }
    }
    
    /// The mode a date gets displayed.
    public var dateDisplayMode: DateDisplayMode = .relative {
        didSet { updateDateString() }
    }

    /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed via ``refreshDate()``.
    public var refreshDateInterval: TimeInterval? = 5 {
        didSet { configurateDateString()  } }
    
    /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed via ``refreshDate()``.
    public func refreshDate() {
        configurateDateString()
    }


    /// the date style of the displayed date, if ``dateDisplayMode-swift.property`` is set to ``DateDisplayMode-swift.enum/absolute``.
    public var dateStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.dateStyle = dateStyle
            updateDateString()
        }
    }

    /// the time style of the displayed date, if ``dateDisplayMode-swift.property`` is set to ``DateDisplayMode-swift.enum/absolute``.
    public var timeStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.timeStyle = timeStyle
            updateDateString()
        }
    }
    
    public convenience init(date: Date, displayMode: DateDisplayMode) {
        self.init(frame: .zero)
        self.date = date
        self.configurateDateString()
        self.sizeToFit()
    }
    
    public convenience init(date: Date, displayMode: DateDisplayMode, frame: CGRect) {
        self.init(frame: frame)
        self.date = date
        self.configurateDateString()
        self.sizeToFit()
    }
    
    internal let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
    internal static let relativeDateFormatter = RelativeDateTimeFormatter()
    internal static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
    internal static let buffer: TimeInterval = 2
    internal var liveUpdateTimer: Timer? = nil

    internal func configurateDateString() {
        if dateDisplayMode == .absolute {
            liveUpdateTimer?.invalidate()
        }

        if let date = date {
            updateDateString()

            liveUpdateTimer?.invalidate()
            if let refreshInterval = self.refreshDateInterval {
                let delta = Date().timeIntervalSince(date)
                let liveUpdateInterval: TimeInterval = (delta < Self.slowRefreshInterval) ? refreshInterval : (Self.slowRefreshInterval - Self.buffer)
                
                liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
                    let delta = Date().timeIntervalSince(date)
                    if delta > (Self.slowRefreshInterval + Self.buffer) {
                        self.date = date
                    }
                    self.updateDateString()
                })
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
        }
    }

    override public var text: String? {
        didSet {
            if text != dateString {
                self.date = nil
            }
        }
    }

    override public var attributedText: NSAttributedString? {
        didSet {
            date = nil
        }
    }

    internal var dateString: String? = nil
    internal func updateDateString() {
        if let date = date {
            if dateDisplayMode == .relative {
                text = Self.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                dateString = text
            } else {
                text = dateFormatter.string(from: date)
                dateString = text
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
        }
    }
}

/// A `UITextField` that displays a date either absolute or relative.
public class DateTextField: UITextField {
    
    /// The mode a date gets displayed.
    public enum DateDisplayMode {
        /// The textfield displays a relative date or time (e.g. "2 mins ago").
        case relative
        /// The textfield displays a absolute date or time (e.g. "10:11pm 04.04.2023").
        case absolute
    }

    /// The date to display.
    public var date: Date? {
        didSet { configurateDateString() }
    }
    
    /// The mode a date gets displayed.
    public var dateDisplayMode: DateDisplayMode = .relative {
        didSet { updateDateString() }
    }

    /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed via ``refreshDate()``.
    public var refreshDateInterval: TimeInterval? = 5 {
        didSet { configurateDateString()  } }
    
    /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed via ``refreshDate()``.
    public func refreshDate() {
        configurateDateString()
    }


    /// the date style of the displayed date, if ``dateDisplayMode-swift.property`` is set to ``DateDisplayMode-swift.enum/absolute``.
    public var dateStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.dateStyle = dateStyle
            updateDateString()
        }
    }

    /// the time style of the displayed date, if ``dateDisplayMode-swift.property`` is set to ``DateDisplayMode-swift.enum/absolute``.
    public var timeStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.timeStyle = timeStyle
            updateDateString()
        }
    }
    
    public convenience init(date: Date, displayMode: DateDisplayMode) {
        self.init(frame: .zero)
        self.date = date
        self.configurateDateString()
        self.borderStyle = .none
        self.backgroundColor = nil
        self.sizeToFit()
    }
    
    public convenience init(date: Date, displayMode: DateDisplayMode, frame: CGRect) {
        self.init(frame: frame)
        self.date = date
        self.configurateDateString()
        self.borderStyle = .none
        self.backgroundColor = nil
        self.sizeToFit()
    }
    
    internal let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
    internal static let relativeDateFormatter = RelativeDateTimeFormatter()
    internal static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
    internal static let buffer: TimeInterval = 2
    internal var liveUpdateTimer: Timer? = nil

    internal func configurateDateString() {
        if dateDisplayMode == .absolute {
            liveUpdateTimer?.invalidate()
        }

        if let date = date {
            updateDateString()

            liveUpdateTimer?.invalidate()
            if let refreshInterval = self.refreshDateInterval {
                let delta = Date().timeIntervalSince(date)
                let liveUpdateInterval: TimeInterval = (delta < Self.slowRefreshInterval) ? refreshInterval : (Self.slowRefreshInterval - Self.buffer)
                
                liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
                    let delta = Date().timeIntervalSince(date)
                    if delta > (Self.slowRefreshInterval + Self.buffer) {
                        self.date = date
                    }
                    self.updateDateString()
                })
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
        }
    }

    override public var text: String? {
        didSet {
            if text != dateString {
                self.date = nil
            }
        }
    }

    override public var attributedText: NSAttributedString? {
        didSet {
            date = nil
        }
    }

    internal var dateString: String? = nil
    internal func updateDateString() {
        if let date = date {
            if dateDisplayMode == .relative {
                text = Self.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                dateString = text
            } else {
                text = dateFormatter.string(from: date)
                dateString = text
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
        }
    }
}
#endif
