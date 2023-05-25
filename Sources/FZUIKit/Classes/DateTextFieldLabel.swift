//
//  DateTextField.swift
//  DateTextField
//
//  Adopted from by Tyler Hall
//

#if os(macOS)
import AppKit

public class DateTextField: NSTextField {
    internal let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
    internal static let relativeDateFormatter = RelativeDateTimeFormatter()

    internal static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
    internal static let buffer: TimeInterval = 2

    public var date: Date? {
        didSet { configurateDateString() }
    }

    public var updateDateLive = true {
        didSet { updateDateString() }
    }

    public var liveUpdateTimer: Timer? {
        didSet { configurateDateString() }
    }

    public var refreshInterval: TimeInterval = 5 {
        didSet {
            liveUpdateTimer?.invalidate()
            configurateDateString()
        }
    }

    public var useRelativeDate = true {
        didSet { updateDateString() }
    }

    public var dateStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.dateStyle = dateStyle
            updateDateString()
        }
    }

    public var timeStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.timeStyle = timeStyle
            updateDateString()
        }
    }

    internal func configurateDateString() {
        if updateDateLive == false {
            liveUpdateTimer?.invalidate()
        }

        if let date = date {
            updateDateString()

            let delta = Date().timeIntervalSince(date)
            let liveUpdateInterval: TimeInterval = (delta < DateTextField.slowRefreshInterval) ? refreshInterval : (DateTextField.slowRefreshInterval - DateTextField.buffer)

            liveUpdateTimer?.invalidate()
            liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
                let delta = Date().timeIntervalSince(date)
                if delta > (DateTextField.slowRefreshInterval + DateTextField.buffer) {
                    self.date = date
                }
                self.updateDateString()
            })
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
            if useRelativeDate {
                dateString = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                stringValue = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                toolTip = dateFormatter.string(from: date)
            } else {
                dateString = dateFormatter.string(from: date)
                stringValue = dateFormatter.string(from: date)
                toolTip = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
            toolTip = nil
        }
    }
}

#elseif canImport(UIKit)
import UIKit
public class DateLabel: UILabel {
    internal let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
    internal static let relativeDateFormatter = RelativeDateTimeFormatter()

    internal static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
    internal static let buffer: TimeInterval = 2

    public var date: Date? {
        didSet { configurateDateString() }
    }

    public var updateDateLive = true {
        didSet { updateDateString() }
    }

    public var liveUpdateTimer: Timer? {
        didSet { configurateDateString() }
    }

    public var refreshInterval: TimeInterval = 5 {
        didSet {
            liveUpdateTimer?.invalidate()
            configurateDateString()
        }
    }

    public var useRelativeDate = true {
        didSet { updateDateString() }
    }

    public var dateStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.dateStyle = dateStyle
            updateDateString()
        }
    }

    public var timeStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.timeStyle = timeStyle
            updateDateString()
        }
    }

    internal func configurateDateString() {
        if updateDateLive == false {
            liveUpdateTimer?.invalidate()
        }

        if let date = date {
            updateDateString()

            let delta = Date().timeIntervalSince(date)
            let liveUpdateInterval: TimeInterval = (delta < DateTextField.slowRefreshInterval) ? refreshInterval : (DateTextField.slowRefreshInterval - DateTextField.buffer)

            liveUpdateTimer?.invalidate()
            liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
                let delta = Date().timeIntervalSince(date)
                if delta > (DateTextField.slowRefreshInterval + DateTextField.buffer) {
                    self.date = date
                }
                self.updateDateString()
            })
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
            if useRelativeDate {
                dateString = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                text = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
            } else {
                dateString = dateFormatter.string(from: date)
                text = dateFormatter.string(from: date)
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
        }
    }
}

public class DateTextField: UITextField {
    internal let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .medium; return formatter }()
    internal static let relativeDateFormatter = RelativeDateTimeFormatter()

    internal static let slowRefreshInterval: TimeInterval = 30 // How quickly the timer should repeat after it's been a while.
    internal static let buffer: TimeInterval = 2

    public var date: Date? {
        didSet { configurateDateString() }
    }

    public var updateDateLive = true {
        didSet { updateDateString() }
    }

    public var liveUpdateTimer: Timer? {
        didSet { configurateDateString() }
    }

    public var refreshInterval: TimeInterval = 5 {
        didSet {
            liveUpdateTimer?.invalidate()
            configurateDateString()
        }
    }

    public var useRelativeDate = true {
        didSet { updateDateString() }
    }

    public var dateStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.dateStyle = dateStyle
            updateDateString()
        }
    }

    public var timeStyle: DateFormatter.Style = .medium {
        didSet {
            dateFormatter.timeStyle = timeStyle
            updateDateString()
        }
    }

    internal func configurateDateString() {
        if updateDateLive == false {
            liveUpdateTimer?.invalidate()
        }

        if let date = date {
            updateDateString()

            let delta = Date().timeIntervalSince(date)
            let liveUpdateInterval: TimeInterval = (delta < DateTextField.slowRefreshInterval) ? refreshInterval : (DateTextField.slowRefreshInterval - DateTextField.buffer)

            liveUpdateTimer?.invalidate()
            liveUpdateTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
                let delta = Date().timeIntervalSince(date)
                if delta > (DateTextField.slowRefreshInterval + DateTextField.buffer) {
                    self.date = date
                }
                self.updateDateString()
            })
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
            if useRelativeDate {
                dateString = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
                text = DateTextField.relativeDateFormatter.localizedString(for: date, relativeTo: Date())
            } else {
                dateString = dateFormatter.string(from: date)
                text = dateFormatter.string(from: date)
            }
        } else {
            liveUpdateTimer?.invalidate()
            dateString = nil
        }
    }
}

#endif
