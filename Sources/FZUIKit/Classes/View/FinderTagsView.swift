//
//  FinderTagsView.swift
//
//
//  Created by Florian Zand on 28.07.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A representation of a Finder tag.
public struct FinderTag: Hashable, CustomStringConvertible, Codable {
    /// The name of the Finder Tag.
    public var name: String
    /// he color of the Finder tag.
    public var color: Color = .none
    
    /// Creates a represntation of a Finder tag with the specified name and color.
    public init(name: String, color: Color = .none) {
        self.name = name
        self.color = color
    }
    
    /// Returns the Finder tags for the specified file.
    public static func tags(for url: URL) -> [FinderTag]? {
        guard let data = try? url.extendedAttributes.getData(for: "com.apple.metadata:_kMDItemUserTags"), let strings = try? PropertyListDecoder().decode([String].self, from: data) else { return nil }
        return strings.compactMap({FinderTag(string: $0)})
    }

    private init?(string: String) {
        let components = string.split(separator: "\n")
        guard let name = components.first else { return nil }
        self.name = String(name)
        guard components.count > 1, let color = Color(rawValue: Int(components[1]) ?? -1) else { return }
        self.color = color
    }
    
    public var description: String {
        "\(name) (\(color))"
    }
    
    /// The color of a Finder tag.
    public enum Color: Int, CaseIterable, Hashable, CustomStringConvertible, Codable {
        /// None.
        case none
        /// Gray.
        case gray
        /// Green.
        case green
        /// Purple.
        case purple
        /// Blue.
        case blue
        /// Yellow.
        case yellow
        /// Red.
        case red
        /// Orange.
        case orange
        
        public var description: String {
            switch self {
            case .none: "none"
            case .gray: "none"
            case .green: "green"
            case .purple: "purple"
            case .blue: "blue"
            case .yellow: "yellow"
            case .red: "red"
            case .orange: "orange"
            }
        }
        
        var color: NSColor {
            switch self {
                case .none: .clear
                case .gray: .systemGray
                case .green: .systemGreen
                case .purple: .systemPurple
                case .blue: .systemBlue
                case .yellow: .systemYellow
                case .red: .systemRed
                case .orange: .systemOrange
            }
        }
        
        public static let allCases: [Self] = [.none, .red, .orange, .yellow, .green, .blue, .purple, .gray]
    }
}

/// A view that displays Finder tags.
public class FinderTagsView: NSView {
    /// The Finder tags.
    public var tags: [FinderTag] = [] {
        didSet {
            guard oldValue != tags else { return }
            toolTip = visibleTags.map(\.name).formatted(.list(type: .and, width: .short))
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }
    
    private var visibleTags: [FinderTag] {
        tags.filter { $0.color != .none }
    }
    
    /// The offset between the Finder tag circles.
    public var offset: CGFloat = 6 {
        didSet {
            guard oldValue != offset else { return }
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }
    
    /// The spacing between the Finder tag circles.
    public var spacing: CGFloat = 1.5 {
        didSet {
            guard oldValue != spacing else { return }
            needsDisplay = true
        }
    }
    
    /// The border width of the Finder tag circles.
    public var borderWidth: CGFloat = 1.0 {
        didSet {
            guard oldValue != borderWidth else { return }
            needsDisplay = true
        }
    }
    
    /// The diameter of the Finder tag circles.
    public var diameter: CGFloat = 12 {
        didSet {
            guard oldValue != diameter else { return }
            invalidateIntrinsicContentSize()
            needsDisplay = true
        }
    }
    
    public var backgroundStyle: NSView.BackgroundStyle = .normal {
        didSet {
            guard oldValue != backgroundStyle else { return }
            needsDisplay = true
        }
    }
    
    public override func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
        self.backgroundStyle = backgroundStyle
    }
    
    /// Creates a Finder tags view with the specified tags.
    public init(tags: [FinderTag]) {
        self.tags = tags
        super.init(frame: .zero)
        frame.size = fittingSize
        wantsLayer = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        if let colors: [FinderTag.Color] = coder.decode(forKey: "Colors"), let names: [String] = coder.decode(forKey: "names") {
            tags = zip(names, colors).map({ FinderTag(name: $0, color: $1)})
        }
        diameter = coder.decode(forKey: "diameter") ?? diameter
        borderWidth = coder.decode(forKey: "borderWidth") ?? borderWidth
        spacing = coder.decode(forKey: "spacing") ?? spacing
        offset = coder.decode(forKey: "offset") ?? offset
        wantsLayer = true
    }
    
    public override func encode(with coder: NSCoder) {
        coder.encode(tags.map({$0.name}), forKey: "names")
        coder.encode(tags.map({$0.color}), forKey: "colors")
        coder.encode(diameter, forKey: "diameter")
        coder.encode(borderWidth, forKey: "borderWidth")
        coder.encode(spacing, forKey: "spacing")
        coder.encode(offset, forKey: "offset")
    }
    
    public override var intrinsicContentSize: NSSize {
        let count = visibleTags.count
        guard count > 0 else { return .zero }
        return NSSize(width: diameter + CGFloat(count - 1) * offset, height: diameter)
    }
    
    public override var isFlipped: Bool { true }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let visibleTags = visibleTags
        guard !visibleTags.isEmpty else { return }
                
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        let yOffset = (bounds.height - diameter) / 2.0
        for (index, tag) in visibleTags.enumerated().reversed() {
            context.saveGState()
            
            let xOffset = CGFloat(index) * offset
            let rect = CGRect(x: bounds.width - diameter - xOffset, y: yOffset, width: diameter, height: diameter)
                        
            if index < visibleTags.count - 1 {
                context.beginTransparencyLayer(auxiliaryInfo: nil)
                
                drawTagCircle(in: context, rect: rect, color: tag.color.color)
                
                let neighborX = bounds.width - diameter - (CGFloat(index + 1) * offset)
                let cutoutRect = CGRect(x: neighborX, y: yOffset, width: diameter, height: diameter)
                    .insetBy(dx: -spacing, dy: -spacing)
                
                context.setBlendMode(.destinationOut)
                context.setFillColor(NSColor.black.cgColor)
                context.fillEllipse(in: cutoutRect)
                
                context.endTransparencyLayer()
            } else {
                drawTagCircle(in: context, rect: rect, color: tag.color.color)
            }
            
            context.restoreGState()
        }
    }
    
    private func drawTagCircle(in context: CGContext, rect: CGRect, color: NSColor) {
        context.setFillColor(color.withAlphaComponent(0.82).cgColor)
        context.fillEllipse(in: rect)
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(1.0)
        context.strokeEllipse(in: rect.insetBy(dx: 0.5, dy: 0.5))
        
        guard backgroundStyle == .emphasized else { return }
        context.setStrokeColor(NSColor.white.withAlphaComponent(0.9).cgColor)
        context.setLineWidth(borderWidth)
        let inset = borderWidth / 2.0
        context.strokeEllipse(in: rect.insetBy(dx: inset, dy: inset))
    }
}
#endif
