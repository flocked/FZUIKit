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

/// A color picker view.
    open class ColorPickerView: NSView {
        enum ColorSection: Hashable {
            case main
        }
        struct ColorItem: Hashable {
            let color: NSColor
            let name: String
        }
        typealias DataSource = NSCollectionViewDiffableDataSource<ColorSection, ColorItem>
        
        let collectionView = NSCollectionView()
        var dataSouze: DataSource!
        func updateCollectionViewLayout() {
            collectionView.collectionViewLayout = .grid()
        }
            
        func setupCollectionView() {
            updateCollectionViewLayout()
            dataSouze = DataSource(collectionView: collectionView) { collectionView, indexPath, colorItem in
                let item = collectionView.makeItem(withIdentifier: "", for: indexPath) as! ColorCollectionItem
                item.color = colorItem.color
                item.colorName = colorItem.name
                item.shape = self.itemShape
                return item
                
            }
        }
        
        /// The handler that gets called when the selection changes.
        open var selectionAction: (()->())? = nil
        
        /// The size of the color items.
        open var itemSize: CGFloat = 24 {
            didSet { setNeedsDisplay(bounds) }
        }
        
        /// The shape of the color items.
        public enum ItemShape: Hashable {
            /// The color items are circular.
            case circular
            /// The color items are rounded rectangles with the specified corner radius.
            case roundedRect(cornerRadius: CGFloat)
        }
        
        /// The shape of the color items.
        public var itemShape: ItemShape = .circular {
            didSet {
                guard oldValue != itemShape else { return }
                setNeedsDisplay(bounds)
            }
        }

        /// The selection dot size.
        open var selectionDotSize: CGFloat = 6 {
            didSet { setNeedsDisplay(bounds) }
        }

        /// The item scale factor when the mouse is hovering an item.
        open var mouseHoverScaleFactor: CGFloat = 1.1 {
            didSet { setNeedsDisplay(bounds) }
        }

        /// The item spacing.
        open var itemSpacing: CGFloat = 4 {
            didSet { 
                guard oldValue != itemSpacing else { return }
                updateCollectionViewLayout()
                setNeedsDisplay(bounds)
            }
        }

        open var padding: CGFloat = 10 {
            didSet { setNeedsDisplay(bounds) }
        }

        // MARK: -

        /// The selected color indexes.
        @objc dynamic open var selectedColorIndexes: [Int] = []
        
        /// The selected colors.
        open var selectedColors: [(color: NSColor, name: String)] {
            selectedColorIndexes.compactMap { self.colors[$0] }
        }

        /// A Boolean value that determines whether users can select more than one color.
        open var allowsMultipleSelection: Bool = true
        
        /// A Boolean value that determines whether users can select no color.
        open var allowsEmptySelection: Bool = true {
            didSet {
                if allowsEmptySelection == false, selectedColorIndexes.isEmpty, colors.isEmpty == false {
                    selectedColorIndexes = [0]
                    setNeedsDisplay(bounds)
                }
            }
        }

        /// The text field that displays the name of the colors.
        @IBOutlet open var nameTextField: NSTextField?

        var mouseLocation = CGPoint.zero
        var hooveringColorIbdex = -1
        var mouseMoved = false

        // MARK: -

        /// The color items.
        open var colors: [(color: NSColor, name: String)] = [
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

        override open func mouseDragged(with event: NSEvent) {
            super.mouseDragged(with: event)

            mouseMoved(with: event)
        }

        override open func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)

            mouseLocation = event.location(in: self)
            mouseMoved = true
            setNeedsDisplay(bounds)
        }

        override open func mouseExited(with event: NSEvent) {
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
                nameTextField?.stringValue = selectedColors.compactMap(\.name).joined(separator: ", ")
            }
        }

        override open func mouseUp(with event: NSEvent) {
            super.mouseUp(with: event)

            mouseLocation = event.location(in: self)
            for i in 0 ..< colors.count {
                let subRect = CGRect(x: padding + CGFloat(i) * itemSize, y: 0, width: itemSize, height: itemSize)
                if subRect.contains(mouseLocation) {
                    if allowsEmptySelection, let idx = selectedColorIndexes.firstIndex(of: i) {
                        selectedColorIndexes.remove(at: idx)
                        updateColorNameTextField()
                        didSelectItem()
                    } else {
                        if allowsMultipleSelection, selectedColorIndexes.contains(i) == false {
                            selectedColorIndexes.append(i)
                            updateColorNameTextField()
                            didSelectItem()
                        } else if allowsMultipleSelection == false, selectedColorIndexes.contains(i) == false {
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

        override open func draw(_: NSRect) {
            hooveringColorIbdex = -1
            for i in 0 ..< colors.count {
                let subRect = CGRect(x: padding + CGFloat(i) * itemSize, y: 0, width: itemSize, height: itemSize)
                colors[i].color.setFill()
                var circleRect = subRect.insetBy(dx: itemSpacing, dy: itemSpacing)

                if subRect.contains(mouseLocation) {
                    if mouseMoved, hooveringColorIbdex == -1 {
                        hooveringColorIbdex = i
                    }
                    
                    circleRect = circleRect.insetBy(dx: itemSize-(itemSize*mouseHoverScaleFactor), dy: itemSize-(itemSize*mouseHoverScaleFactor))
                }

                let bezier: NSBezierPath
                switch itemShape {
                case .circular:
                    bezier = NSBezierPath(ovalIn: circleRect)
                case .roundedRect(let cornerRadius):
                    bezier = NSBezierPath(roundedRect: circleRect, cornerRadius: cornerRadius)
                }
                bezier.fill()

                /* Border */
                let strokeColor = colors[i].color.blended(withFraction: 0.3, of: .black) ?? .black
                strokeColor.setStroke()

                let lineWidth = CGFloat(1)

                
                let ring: NSBezierPath
                switch itemShape {
                case .circular:
                    ring = NSBezierPath(ovalIn: circleRect)
                case .roundedRect(let cornerRadius):
                    ring = NSBezierPath(roundedRect: circleRect, cornerRadius: cornerRadius)
                }
                ring.lineWidth = lineWidth
                ring.stroke()

                if selectedColorIndexes.contains(i) {
                    let selectionColor = colors[i].color.blended(withFraction: 0.5, of: .black) ?? .black
                    selectionColor.setFill()

                    let dot: NSBezierPath
                    switch itemShape {
                    case .circular:
                        dot =  NSBezierPath(ovalIn: CGRect(origin: CGPoint(x: subRect.midX - selectionDotSize / 2, y: subRect.midY - selectionDotSize / 2), size: CGSize(width: selectionDotSize, height: selectionDotSize)))
                    case .roundedRect(let cornerRadius):
                        dot = NSBezierPath(roundedRect: CGRect(origin: CGPoint(x: subRect.midX - selectionDotSize / 2, y: subRect.midY - selectionDotSize / 2), size: CGSize(width: selectionDotSize, height: selectionDotSize)), cornerRadius: cornerRadius)
                    }
                    dot.fill()
                }
            }
            updateColorNameTextField()
        }

        // MARK: -

        func didSelectItem() {
            guard selectedColorIndexes.isEmpty == false else { return }
            // let colors = selectedColors
            selectionAction?()
        }

        // MARK: -

        override open var intrinsicContentSize: NSSize {
            CGSize(width: padding + (CGFloat(colors.count) * itemSize) + padding, height: itemSize)
        }

        override open func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            beginMouseTracking()
        }

        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            beginMouseTracking()
        }
    }

extension ColorPickerView {
    class ColorCollectionItem: NSCollectionViewItem {
        
        var color: NSColor? = nil {
            didSet { view.backgroundColor = color } }
        
        var colorName: String? = nil
        var shape: ColorPickerView.ItemShape = .circular
        
        override func viewDidLayout() {
            super.viewDidLayout()
            switch shape {
            case .circular:
                view.cornerRadius = view.bounds.height / 2.0
            case .roundedRect(let cornerRadius):
                view.cornerRadius = cornerRadius
            }
        }
        
        override func loadView() {
            view = NSView()
        }
    }
}
#endif
