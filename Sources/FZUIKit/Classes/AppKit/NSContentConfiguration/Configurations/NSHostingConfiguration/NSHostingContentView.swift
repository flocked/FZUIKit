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
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        if newSuperview is NSTableCellView {
            autoHeight = true
        }
    }
    
    func updateAutoHeight() {
        if !autoHeight {
            hostingControllerConstraints = addSubview(withConstraint: hostingController.view)
            hostingControllerConstraints.constant(appliedConfiguration.margins)
            heightConstraint.activate(false)
        } else {
            hostingController.view.removeFromSuperview()
            hostingControllerConstraints = []
            addSubview(hostingController.view)
           // updateHeight()
           // heightConstraint.activate(true)
        }
    }
    
    func updateConfiguration() {
        hostingController.rootView = ContentView(configuration: appliedConfiguration)
       // hostingController.sizingOptions = appliedConfiguration.sizingOptions
        hostingControllerConstraints.constant(appliedConfiguration.margins)
        hostingController.view.invalidateIntrinsicContentSize()
    }

    override func layout() {
        super.layout()
        guard bounds.width != boundsWidth else { return }
        boundsWidth = bounds.width
        updateHeight()
    }
    
    func updateHeight() {
        guard autoHeight else { return }
        let height = hostingController.sizeThatFits(in: CGSize(bounds.width, .greatestFiniteMagnitude)).height
        hostingController.viewHeight = height
        hostingController.view.frame.size = CGSize(bounds.width, height)
        heightConstraint.constant = height
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
    func updateHeight()
}

class SelfSizingHostingController<Content: View>: NSHostingController<Content> {
    var viewHeight: CGFloat = 0.0
    override func viewDidLayout() {
        super.viewDidLayout()
        view.invalidateIntrinsicContentSize()
        let height = sizeThatFits(in: CGSize(view.bounds.width, .greatestFiniteMagnitude)).height
        if viewHeight != height {
            viewHeight = height
            (view.superview as? HostingContentView)?.updateHeight()
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
