//
//  ColorPickerView.swift
//
//  Parts taken from:
//  Taken from steventroughtonsmith
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS)
import AppKit

public class ColorPickerView: NSView {
    public var itemSize: CGFloat = 24 {
        didSet { setNeedsDisplay(bounds) }
    }

    public var selectionDotSize: CGFloat = 6 {
        didSet { setNeedsDisplay(bounds) }
    }

    public var mouseOverExpansion: CGFloat = 2 {
        didSet { setNeedsDisplay(bounds) }
    }

    public var padding: CGFloat = 4 {
        didSet { setNeedsDisplay(bounds) }
    }

    public var systemPadding: CGFloat = 10 {
        didSet { setNeedsDisplay(bounds) }
    }

    // MARK: -

    public var selectedColorIndexes: [Int] = []
    public var selectedColors: [(color: NSColor, name: String)] {
        selectedColorIndexes.compactMap { self.colors[$0] }
    }

    public var allowsMultipleSelection: Bool = true
    public var allowsEmptySelection: Bool = true {
        didSet {
            if allowsEmptySelection == false && selectedColorIndexes.isEmpty && colors.isEmpty == false {
                selectedColorIndexes = [0]
                setNeedsDisplay(bounds)
            }
        }
    }

    @IBOutlet public var nameTextField: NSTextField? = nil

    var mouseLocation = CGPoint.zero
    var hooveringColorIbdex = -1
    var mouseMoved = false

    // MARK: -

    public var colors: [(color: NSColor, name: String)] = [
        (#colorLiteral(red: 0.898, green: 0.306, blue: 0.647, alpha: 1.000), "Pink"),
        (#colorLiteral(red: 0.643, green: 0.522, blue: 0.957, alpha: 1.000), "Purple"),
        (#colorLiteral(red: 0.647, green: 0.765, blue: 0.945, alpha: 1.000), "Light Blue"),
        (#colorLiteral(red: 0.000, green: 0.769, blue: 0.953, alpha: 1.000), "Blue"),
        (#colorLiteral(red: 0.306, green: 0.886, blue: 0.624, alpha: 1.000), "Green"),
        (#colorLiteral(red: 0.953, green: 0.902, blue: 0.439, alpha: 1.000), "Yellow"),
        (#colorLiteral(red: 0.957, green: 0.537, blue: 0.286, alpha: 1.000), "Orange"),
    ]

    // MARK: - Input

    func beginMouseTracking() {
        let trackingArea1 = NSTrackingArea(rect: bounds, options: [.mouseMoved, .activeAlways], owner: self)
        addTrackingArea(trackingArea1)

        let trackingArea2 = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self)
        addTrackingArea(trackingArea2)
    }

    override public func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        mouseMoved(with: event)
    }

    override public func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        mouseLocation = event.location(in: self)
        mouseMoved = true
        setNeedsDisplay(bounds)
    }

    override public func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)

        mouseLocation = .zero
        hooveringColorIbdex = -1
        mouseMoved = false
        setNeedsDisplay(bounds)
    }

    func updateColorNameTextField() {
        if mouseMoved, hooveringColorIbdex != -1 {
            nameTextField?.stringValue = colors[hooveringColorIbdex].name
            nameTextField?.textColor = .secondaryLabelColor
        } else {
            nameTextField?.textColor = .labelColor
            nameTextField?.stringValue = selectedColors.compactMap { $0.name }.joined(separator: ", ")
        }
    }

    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        mouseLocation = event.location(in: self)
        for i in 0 ..< colors.count {
            let subRect = CGRect(x: systemPadding + CGFloat(i) * itemSize, y: 0, width: itemSize, height: itemSize)
            if subRect.contains(mouseLocation) {
                if allowsEmptySelection, let idx = selectedColorIndexes.firstIndex(of: i) {
                    selectedColorIndexes.remove(at: idx)
                    updateColorNameTextField()
                    didSelectItem()
                } else {
                    if allowsMultipleSelection && selectedColorIndexes.contains(i) == false {
                        selectedColorIndexes.append(i)
                        updateColorNameTextField()
                        didSelectItem()
                    } else if allowsMultipleSelection == false && selectedColorIndexes.contains(i) == false {
                        selectedColorIndexes = [i]
                        updateColorNameTextField()
                        didSelectItem()
                    }
                }
            }
        }

        setNeedsDisplay(bounds)
    }

    // MARK: - Drawing

    override public func draw(_: NSRect) {
        hooveringColorIbdex = -1
        for i in 0 ..< colors.count {
            let subRect = CGRect(x: systemPadding + CGFloat(i) * itemSize, y: 0, width: itemSize, height: itemSize)
            colors[i].color.setFill()
            var circleRect = subRect.insetBy(dx: padding, dy: padding)

            if subRect.contains(mouseLocation) {
                if mouseMoved && hooveringColorIbdex == -1 {
                    hooveringColorIbdex = i
                }
                circleRect = circleRect.insetBy(dx: -mouseOverExpansion, dy: -mouseOverExpansion)
            }

            let circle = NSBezierPath(ovalIn: circleRect)
            circle.fill()

            /* Border */
            let strokeColor = colors[i].color.blended(withFraction: 0.3, of: .black) ?? .black
            strokeColor.setStroke()

            let lineWidth = CGFloat(1)

            let ring = NSBezierPath(ovalIn: circleRect)
            ring.lineWidth = lineWidth
            ring.stroke()

            if selectedColorIndexes.contains(i) {
                let selectionColor = colors[i].color.blended(withFraction: 0.5, of: .black) ?? .black
                selectionColor.setFill()

                let dot = NSBezierPath(ovalIn: CGRect(origin: CGPoint(x: subRect.midX - selectionDotSize / 2, y: subRect.midY - selectionDotSize / 2), size: CGSize(width: selectionDotSize, height: selectionDotSize)))
                dot.fill()
            }
        }
        updateColorNameTextField()
    }

    // MARK: -

    func didSelectItem() {
        guard selectedColorIndexes.isEmpty == false else { return }

        let colors = selectedColors
        NotificationCenter.default.post(name: NSNotification.Name("ColorPickerViewDidPick"), object: colors)
    }

    // MARK: -

    override public var intrinsicContentSize: NSSize {
        CGSize(width: systemPadding + (CGFloat(colors.count) * itemSize) + systemPadding, height: itemSize)
    }

    override public func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        beginMouseTracking()
    }

    override public func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        beginMouseTracking()
    }
}
#endif
