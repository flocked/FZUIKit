//
//  FZSWLabel.swift
//
//
//  Created by Florian Zand on 11.10.22.
//

#if os(macOS)
import SwiftUI
@available(macOS 12.0, *)
public class FZSWLabel: NSView {
    internal var hostingView: NSHostingView<ContentView>!
    public var configuration = Configuration() {
        didSet { updateHostingView() }
    }

    public var text: String? {
        get { configuration.text }
        set { configuration.text = newValue }
    }

    public var systemName: String? {
        get { configuration.systemImage }
        set { configuration.systemImage = newValue }
    }

    public var margin: CGFloat {
        get { configuration.margin }
        set { configuration.margin = newValue }
    }

    public var iconToTextPadding: CGFloat {
        get { configuration.iconToTextPadding }
        set { configuration.iconToTextPadding = newValue }
    }

    public var textStyle: Configuration.TextStyle {
        get { configuration.textStyle }
        set { configuration.textStyle = newValue }
    }

    public var weight: NSFont.Weight {
        get { configuration.weight }
        set { configuration.weight = newValue }
    }

    public var imageScale: NSImage.SymbolScale {
        get { configuration.imageScale }
        set { configuration.imageScale = newValue }
    }

    public var foregroundColor: NSColor {
        get { configuration.foregroundColor }
        set { configuration.foregroundColor = newValue }
    }

    public var shape: Configuration.LabelShape {
        get { configuration.shape }
        set { configuration.shape = newValue }
    }

    public var background: Configuration.Background {
        get { configuration.background }
        set { configuration.background = newValue }
    }

    public var imagePosition: Configuration.IconPlacement {
        get { configuration.iconPlacement }
        set { configuration.iconPlacement = newValue }
    }

    public var labelShadow: Configuration.ShadowProperties {
        get { configuration.shadow }
        set { configuration.shadow = newValue }
    }

    public func sizeToFit() {
        frame.size = fittingSize
        hostingView.frame.size = fittingSize
    }

    internal func updateHostingView() {
        hostingView.rootView = ContentView(properties: configuration)
        sizeToFit()
    }

    override public var intrinsicContentSize: NSSize {
        return self.fittingSize
    }

    override public var fittingSize: NSSize {
        return hostingView.fittingSize
    }

    internal func sharedInit() {
        hostingView = NSHostingView<ContentView>(rootView: ContentView(properties: configuration))
        wantsLayer = true
        layer?.masksToBounds = false
        addSubview(hostingView)
        translatesAutoresizingMaskIntoConstraints = false
        sizeToFit()
    }

    public init() {
        super.init(frame: .zero)
        sharedInit()
    }

    public init(text: String) {
        super.init(frame: .zero)
        sharedInit()
        self.text = text
        updateHostingView()
    }

    public init(text: String, systemName: String) {
        super.init(frame: .zero)
        sharedInit()
        self.text = text
        self.systemName = systemName
        updateHostingView()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
