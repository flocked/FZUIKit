//
//  NSHostingContentView.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

#if os(macOS)
import AppKit
import SwiftUI
import FZSwiftUtils

class NSHostingContentView<Content, Background>: NSView, NSContentView, HostingContentView where Content: View, Background: View {
    
    var hostingController: SelfSizingHostingController<ContentView>!
    var hostingControllerConstraints: [NSLayoutConstraint] = []
    var boundsWidth: CGFloat = 0.0
    lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 50)
    var cachedHeights:[CGFloat:CGFloat] = [:]

    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            if let newValue = newValue as? NSHostingConfiguration<Content, Background> {
                appliedConfiguration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSHostingConfiguration<Content, Background>
    }
    
    /// Creates a hosting content view with the specified content configuration.
    public init(configuration: NSHostingConfiguration<Content, Background>) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        hostingController = SelfSizingHostingController(rootView: ContentView(configuration: appliedConfiguration))
        hostingController.view.backgroundColor = .clear
        updateAutoHeight()
        updateConfiguration()
    }
    
    var appliedConfiguration: NSHostingConfiguration<Content, Background> {
        didSet { updateConfiguration() }
    }
    
   @objc var autoHeight = false {
        didSet {
            guard oldValue != autoHeight else { return }
            updateAutoHeight()
        }
    }
    
    /*
    var didSetup = false
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        guard newSuperview != nil, !didSetup else { return }
        didSetup = true
        if newSuperview is NSTableCellView {
            autoHeight = true
        }
    }
     */
    
    func updateAutoHeight() {
        if !autoHeight {
            heightConstraint.activate(false)
            hostingControllerConstraints = addSubview(withConstraint: hostingController.view)
            hostingControllerConstraints.constant(appliedConfiguration.margins)
        } else {
            hostingController.view.removeFromSuperview()
            hostingControllerConstraints = []
            hostingController = .init(rootView: .init(configuration: appliedConfiguration))
            addSubview(hostingController.view)
            updateHeight()
            heightConstraint.activate(true)
        }
    }
    
    func updateConfiguration() {
        cachedHeights.removeAll()
        hostingController.fittingHeight = 0.0
        hostingController.rootView = ContentView(configuration: appliedConfiguration)
        hostingControllerConstraints.constant(appliedConfiguration.margins)
        hostingController.view.invalidateIntrinsicContentSize()
        // hostingController.sizingOptions = appliedConfiguration.sizingOptions
        updateHeight()
    }

    override func layout() {
        super.layout()
        guard bounds.width != boundsWidth else { return }
        if bounds.width > boundsWidth {
            updateHeight()
        }
        boundsWidth = bounds.width
    }
    
    func updateHeight(reset: Bool = false) {
        invalidateIntrinsicContentSize()
        guard let rowView = tableRowView else { return }
        if reset {
            cachedHeights[bounds.width] = hostingController.fittingHeight
        } else if cachedHeights[bounds.width] == nil {
            cachedHeights[bounds.width] = hostingController.sizeThatFits(in: CGSize(bounds.width, .greatestFiniteMagnitude)).height
        }
        
        if let cachedHeight = cachedHeights[bounds.width], rowView.frame.height > cachedHeight {
         //   rowView.frame.size.height = cachedHeight
        }
    }
    
    var tableRowView: NSTableRowView? {
        firstSuperview(for: NSTableRowView.self)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSHostingContentView {
    struct ContentView: View {
        let configuration: NSHostingConfiguration<Content, Background>
        
        init(configuration: NSHostingConfiguration<Content, Background>) {
            self.configuration = configuration
        }
        
        public var body: some View {
            ZStack {
                configuration.background
                configuration.content
            }
        }
    }
}

protocol HostingContentView {
    func updateHeight(reset: Bool)
}

class SelfSizingHostingController<Content: View>: NSHostingController<Content> {
    var fittingHeight: CGFloat = 0.0
    var boundsWidth: CGFloat = 0.0
    
    override func viewDidLayout() {
        super.viewDidLayout()
        if view.bounds.width != boundsWidth {
            boundsWidth = view.bounds.width
        } else {
            view.invalidateIntrinsicContentSize()
            let height = sizeThatFits(in: CGSize(view.bounds.width, .greatestFiniteMagnitude)).height
            if height > fittingHeight {
                fittingHeight = height
                (view.superview as? HostingContentView)?.updateHeight(reset: true)
            }
        }
    }
}

public struct _NSHostingConfigurationBackgroundView<S>: View where S: ShapeStyle {
    let style: S
    
    public var body: some View {
        Rectangle().fill(style)
    }
}

#endif
