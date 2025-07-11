//
//  NSViewProtocol.swift
//
//
//  Created by Florian Zand on 21.08.24.
//

#if os(macOS)
import AppKit

/// The group of methods that are fundamental to all `NSView` objects.
public protocol NSViewProtocol: NSView {
    
    /// Returns the size that best fits the specified size.
    func sizeThatFits(in size: CGSize) -> CGSize
    
    /// Returns the size that best fits the specified width.
    func sizeThatFits(width: CGFloat) -> CGSize
    
    /// Returns the size that best fits the specified height.
    func sizeThatFits(height: CGFloat) -> CGSize
    
    /// A Boolean value that indicates whether the view is enabled.
    var isEnabled: Bool { get set }
    
    /*
    /**
     The background color of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    var backgroundColor: NSUIColor? { get set }
    /**
     A Boolean value that indicates whether the view is the first responder.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.
     */
    var isFirstResponder: Bool { get }
     */
}

extension NSUIView: NSViewProtocol { }

#elseif os(iOS) || os(tvOS)
import UIKit

/// The group of methods that are fundamental to all `UIView` objects.
public protocol UIViewProtocol: UIView {
    /// A Boolean value that indicates whether the view is enabled.
    var isEnabled: Bool { get set }
}

extension NSUIView: UIViewProtocol { }

#endif
