//
//  ContentConfigurationView.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

#if os(macOS)

import AppKit

/// A view that displays a content configuration.
public class ContentConfigurationView: NSView {
    
    init(configuration: NSContentConfiguration) {
        super.init(frame: .zero)
        self.configuration = configuration
        setupConfiguration()
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public var configuration: NSContentConfiguration? {
        didSet { setupConfiguration() }
    }
    
    func setupConfiguration() {
        if let configuration = configuration {
            if let contentView = contentView, contentView.supports(configuration) {
                contentView.configuration = configuration
            } else {
                contentView?.removeFromSuperview()
                contentView = configuration.makeContentView()
                addSubview(withConstraint: contentView!)
            }
        } else {
            contentView?.removeFromSuperview()
            contentView = nil
        }
    }
    
    var contentView: (NSView & NSContentView)?
}

#endif
