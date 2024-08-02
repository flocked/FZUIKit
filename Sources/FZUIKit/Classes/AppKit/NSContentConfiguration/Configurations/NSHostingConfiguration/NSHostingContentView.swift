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

class NSHostingContentView<Content, Background>: NSView, NSContentView where Content: View, Background: View {
    
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
        hostingView = NSHostingView(rootView: ContentView(configuration: appliedConfiguration))
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingViewConstraints = addSubview(withConstraint: hostingView)
        updateConfiguration()
    }
    
    var appliedConfiguration: NSHostingConfiguration<Content, Background> {
        didSet { updateConfiguration() }
    }
    
    func updateConfiguration() {
        hostingView.rootView = ContentView(configuration: appliedConfiguration)
        if #available(macOS 13.0, *) {
            hostingView.sizingOptions = appliedConfiguration.sizingOptions
        }
        hostingViewConstraints.constant(appliedConfiguration.margins)
    }
    
    var hostingView: NSHostingView<ContentView>!
    var hostingViewConstraints: [NSLayoutConstraint] = []
    
    /*
     override var fittingSize: NSSize {
     hostingController.view.fittingSize
     }
     
     override var intrinsicContentSize: CGSize {
     var intrinsicContentSize = super.intrinsicContentSize
     if let width = appliedConfiguration.minWidth {
     intrinsicContentSize.width = max(intrinsicContentSize.width, width)
     }
     if let height = appliedConfiguration.minHeight {
     intrinsicContentSize.height = max(intrinsicContentSize.height, height)
     }
     return intrinsicContentSize
     }
     */
    
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
            }.frame(minWidth: configuration.minWidth, minHeight: configuration.minHeight)
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
