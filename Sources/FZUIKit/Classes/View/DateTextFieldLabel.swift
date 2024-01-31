//
//  DateTextFieldLabel.swift
//
//  Adopted from:
//  Tyler Hall
//

#if os(macOS)
    import AppKit

    /// A `NSTextField` that displays a date either absolute or relative.
    open class DateTextField: NSTextField {
        /// The mode a date gets displayed.
        public enum DateDisplayMode: Int {
            /// The textfield displays a relative date or time (e.g. "2 mins ago").
            case relative
            /// The textfield displays a absolute date or time (e.g. "10:11pm 04.04.2023").
            case absolute
        }

        /// The date to display.
        open var date: Date? {
            didSet { configurateDateString() }
        }

        /// The mode a date gets displayed.
        open var dateDisplayMode: DateDisplayMode = .relative {
            didSet { updateDateString() }
        }

        /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed by calling ``refreshDate()``.
        open var refreshDateInterval: TimeInterval? = 5 {
            didSet { configurateDateString() }
        }

        /// Refreshes the date string.
        open func refreshDate() {
            configurateDateString()
        }

        /// The date string style to use when ``dateDisplayMode-6bulg`` is set to `absolute`. The default value is `medium`.
        open var absoluteDateStyle: DateFormatter.Style {
            get { absoluteDateFormatter.dateStyle }
            set {
                absoluteDateFormatter.dateStyle = newValue
                if dateDisplayMode == .absolute {
                    updateDateString()
                }
            }
        }

        /// The date string time style to use when ``dateDisplayMode-6bulg`` is set to `absolute`. The default value is `medium`.
        open var absoluteTimeStyle: DateFormatter.Style {
            get { absoluteDateFormatter.timeStyle }
            set {
                absoluteDateFormatter.timeStyle = newValue
                if dateDisplayMode == .absolute {
                    updateDateString()
                }
            }
        }
        
        /// The date string style to use when ``dateDisplayMode-6bulg`` is set to `relative`. For example “yesterday” or “1 day ago”. The default value is `numeric`.
        open var relativeTimeStyle: RelativeDateTimeFormatter.DateTimeStyle {
            get { relativeDateFormatter.dateTimeStyle }
            set {
                relativeDateFormatter.dateTimeStyle = newValue
                if dateDisplayMode == .relative {
                    updateDateString()
                }
            }
        }

        /// Creates a date textfield with the specified date and display mode.
        public convenience init(date: Date, displayMode: DateDisplayMode) {
            self.init(date: date, displayMode: displayMode, frame: .zero)
        }

        /// Creates a date textfield with the specified date, display mode and frame.
        public convenience init(date: Date, displayMode: DateDisplayMode, frame: CGRect) {
            self.init(frame: frame)
            textLayout = .wraps
            absoluteDateStyle = .medium
            absoluteTimeStyle = .medium
            drawsBackground = false
            backgroundColor = nil
            isBezeled = false
            isBordered = false
            self.date = date
            dateDisplayMode = displayMode
            configurateDateString()
            sizeToFit()
        }

        let absoluteDateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
        let relativeDateFormatter = RelativeDateTimeFormatter()
        static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
        static let buffer: TimeInterval = 2
        var liveUpdateTimer: Timer?

        override open var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            if intrinsicContentSize.width == NSView.noIntrinsicMetric, let cell = cell {
                intrinsicContentSize.width = cell.cellSize(forBounds: CGRect(.zero, CGSize(CGFloat.greatestFiniteMagnitude, intrinsicContentSize.height))).rounded(.up).width
            }
            return intrinsicContentSize
        }

        func configurateDateString() {
            if dateDisplayMode == .absolute {
                liveUpdateTimer?.invalidate()
            }

            if let date = date {
                updateDateString()

                liveUpdateTimer?.invalidate()
                if let refreshInterval = refreshDateInterval {
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

        override open var stringValue: String {
            didSet {
                if stringValue != dateString {
                    self.date = nil
                }
            }
        }

        override open var attributedStringValue: NSAttributedString {
            didSet {
                date = nil
            }
        }
        
        var dateString: String?
        func updateDateString() {
            if let date = date {
                if dateDisplayMode == .relative {
                    stringValue = relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                } else {
                    stringValue = absoluteDateFormatter.string(from: date)
                }
                dateString = stringValue
                toolTip = stringValue
            } else {
                liveUpdateTimer?.invalidate()
                if toolTip == dateString {
                    toolTip = nil
                }
                dateString = nil
            }
        }
    }

#elseif os(iOS) || os(tvOS)
    import UIKit
    /// A `UILabel` that displays a date either absolute or relative.
    open class DateLabel: UILabel {
        /// The mode a date gets displayed.
        public enum DateDisplayMode {
            /// The textfield displays a relative date or time (e.g. "2 mins ago").
            case relative
            /// The textfield displays a absolute date or time (e.g. "10:11pm 04.04.2023").
            case absolute
        }

        /// The date to display.
        open var date: Date? {
            didSet { configurateDateString() }
        }

        /// The mode a date gets displayed.
        open var dateDisplayMode: DateDisplayMode = .relative {
            didSet { updateDateString() }
        }

        /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed by calling ``refreshDate()``.
        open var refreshDateInterval: TimeInterval? = 5 {
            didSet { configurateDateString() }
        }

        /// Refreshes the date text.
        open func refreshDate() {
            configurateDateString()
        }

        /// The date text style to use when ``dateDisplayMode-6bulg`` is set to `absolute`. The default value is `medium`.
        open var absoluteDateStyle: DateFormatter.Style {
            get { absoluteDateFormatter.dateStyle }
            set {
                absoluteDateFormatter.dateStyle = newValue
                if dateDisplayMode == .absolute {
                    updateDateString()
                }
            }
        }

        /// The date text time style to use when ``dateDisplayMode-6bulg`` is set to `absolute`. The default value is `medium`.
        open var absoluteTimeStyle: DateFormatter.Style {
            get { absoluteDateFormatter.timeStyle }
            set {
                absoluteDateFormatter.timeStyle = newValue
                if dateDisplayMode == .absolute {
                    updateDateString()
                }
            }
        }
        
        /// The date text style to use when ``dateDisplayMode-6bulg`` is set to `relative`. For example “yesterday” or “1 day ago”. The default value is `numeric`.
        open var relativeTimeStyle: RelativeDateTimeFormatter.DateTimeStyle {
            get { relativeDateFormatter.dateTimeStyle }
            set {
                relativeDateFormatter.dateTimeStyle = newValue
                if dateDisplayMode == .relative {
                    updateDateString()
                }
            }
        }

        /// Creates a date label with the specified date and display mode.
        public convenience init(date: Date, displayMode: DateDisplayMode) {
            self.init(date: date, displayMode: displayMode, frame: .zero)
        }

        /// Creates a date label with the specified date, display mode and frame.
        public convenience init(date: Date, displayMode: DateDisplayMode, frame: CGRect) {
            self.init(frame: frame)
            absoluteDateStyle = .medium
            absoluteTimeStyle = .medium
            self.date = date
            dateDisplayMode = displayMode
            configurateDateString()
            sizeToFit()
        }

        let absoluteDateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
        let relativeDateFormatter = RelativeDateTimeFormatter()
        static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
        static let buffer: TimeInterval = 2
        var liveUpdateTimer: Timer?

        func configurateDateString() {
            if dateDisplayMode == .absolute {
                liveUpdateTimer?.invalidate()
            }

            if let date = date {
                updateDateString()

                liveUpdateTimer?.invalidate()
                if let refreshInterval = refreshDateInterval {
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

        override open var text: String? {
            didSet {
                if text != dateString {
                    self.date = nil
                }
            }
        }

        override open var attributedText: NSAttributedString? {
            didSet {
                date = nil
            }
        }

        var dateString: String?
        func updateDateString() {
            if let date = date {
                if dateDisplayMode == .relative {
                    text = relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                    dateString = text
                } else {
                    text = absoluteDateFormatter.string(from: date)
                    dateString = text
                }
            } else {
                liveUpdateTimer?.invalidate()
                dateString = nil
            }
        }
    }

    /// A `UITextField` that displays a date either absolute or relative.
    open class DateTextField: UITextField {
        /// The mode a date gets displayed.
        public enum DateDisplayMode {
            /// The textfield displays a relative date or time (e.g. "2 mins ago").
            case relative
            /// The textfield displays a absolute date or time (e.g. "10:11pm 04.04.2023").
            case absolute
        }

        /// The date to display.
        open var date: Date? {
            didSet { configurateDateString() }
        }

        /// The mode a date gets displayed.
        open var dateDisplayMode: DateDisplayMode = .relative {
            didSet { updateDateString() }
        }

        /// The interval the displayed date gets refreshed. If `nil` the date gets only refreshed by calling ``refreshDate()``.
        open var refreshDateInterval: TimeInterval? = 5 {
            didSet { configurateDateString() }
        }

        /// Refreshes the date text.
        open func refreshDate() {
            configurateDateString()
        }

        /// The date text style to use when ``dateDisplayMode-6bulg`` is set to `absolute`. The default value is `medium`.
        open var absoluteDateStyle: DateFormatter.Style {
            get { absoluteDateFormatter.dateStyle }
            set {
                absoluteDateFormatter.dateStyle = newValue
                if dateDisplayMode == .absolute {
                    updateDateString()
                }
            }
        }

        /// The date text time style to use when ``dateDisplayMode-6bulg`` is set to `absolute`. The default value is `medium`.
        open var absoluteTimeStyle: DateFormatter.Style {
            get { absoluteDateFormatter.timeStyle }
            set {
                absoluteDateFormatter.timeStyle = newValue
                if dateDisplayMode == .absolute {
                    updateDateString()
                }
            }
        }
        
        /// The date text style to use when ``dateDisplayMode-6bulg`` is set to `relative`. For example “yesterday” or “1 day ago”. The default value is `numeric`.
        open var relativeTimeStyle: RelativeDateTimeFormatter.DateTimeStyle {
            get { relativeDateFormatter.dateTimeStyle }
            set {
                relativeDateFormatter.dateTimeStyle = newValue
                if dateDisplayMode == .relative {
                    updateDateString()
                }
            }
        }

        /// Creates a date textfield with the specified date and display mode.
        public convenience init(date: Date, displayMode: DateDisplayMode) {
            self.init(date: date, displayMode: displayMode, frame: .zero)
        }

        /// Creates a date textfield with the specified date, display mode and frame.
        public convenience init(date: Date, displayMode: DateDisplayMode, frame: CGRect) {
            self.init(frame: frame)
            absoluteDateStyle = .medium
            absoluteTimeStyle = .medium
            self.date = date
            dateDisplayMode = displayMode
            configurateDateString()
            borderStyle = .none
            backgroundColor = nil
            sizeToFit()
        }

        let absoluteDateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
        let relativeDateFormatter = RelativeDateTimeFormatter()
        static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
        static let buffer: TimeInterval = 2
        var liveUpdateTimer: Timer?

        func configurateDateString() {
            if dateDisplayMode == .absolute {
                liveUpdateTimer?.invalidate()
            }

            if let date = date {
                updateDateString()

                liveUpdateTimer?.invalidate()
                if let refreshInterval = refreshDateInterval {
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

        override open var text: String? {
            didSet {
                if text != dateString {
                    self.date = nil
                }
            }
        }

        override open var attributedText: NSAttributedString? {
            didSet {
                date = nil
            }
        }

        var dateString: String?
        func updateDateString() {
            if let date = date {
                if dateDisplayMode == .relative {
                    text = relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                    dateString = text
                } else {
                    text = absoluteDateFormatter.string(from: date)
                    dateString = text
                }
            } else {
                liveUpdateTimer?.invalidate()
                dateString = nil
            }
        }
    }
#endif
