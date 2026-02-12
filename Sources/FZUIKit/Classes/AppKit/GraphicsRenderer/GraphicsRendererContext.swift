//
//  GraphicsRendererContext.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

/// An object for the drawing environments of graphics renderers.
public protocol GraphicsRendererContext: AnyObject {
    associatedtype Format: GraphicsRendererFormat
    
    /// The format used to create the associated graphics renderer.
    var format: Format { get }
    
    /// The graphics context.
    var context: NSGraphicsContext { get }
}

extension GraphicsRendererContext {
    /**
     The underlying Core Graphics context.
     
     Use this property to gain access to the underlying Core Graphics context when you need more drawing functionality than is offered by `AppKit` and `NSGraphicsGraphicsRendererContext`.
     
     For an example of how and when to use the Core Graphics context in an image renderer, see Using Core Graphics rendering functions in `NSGraphicsImageRenderer.
     */
    public var cgContext: CGContext {
        context.cgContext
    }
    
    /**
     Paints a rectangular path using the currently selected stroke color.
     
     Before calling this method, select the stroke color with the `setStroke()` method on an instance of `NSColor`.
     
     - Parameter rect: A rectangle, specified in the Core Graphics coordinate space with values in points.
     */
    public func stroke(_ rect: CGRect) {
        cgContext.withSavedGState {
            cgContext.stroke(rect)
        }
    }
    
    /**
     Paints a rectangular path using the currently selected stroke color and specified blend mode.
     
     Before calling this method, select the stroke color with the `setStroke()` method on an instance of `NSColor`.
     
     The blend mode specifies how the new value for a given pixel is calculated, given the existing pixel value and the currently selected fill color.
     
     - Parameters:
        - rect: A rectangle, specified in the Core Graphics coordinate space with values in points.
        - blendMode: The blend mode applied to the stroke operation.
     */
    public func stroke(_ rect: CGRect, blendMode: CGBlendMode) {
        cgContext.withSavedGState {
            cgContext.setBlendMode(blendMode)
            cgContext.stroke(rect)
        }
    }
    
    /**
     Paints a rectangular area with the currently selected fill color.
     
     Before calling this method, select the fill color with the `setFill()` method on an instance of `NSColor`.
     
     - Parameter rect: A rectangle, specified in the Core Graphics coordinate space with values in points.
     */
    public func fill(_ rect: CGRect) {
        cgContext.withSavedGState {
            cgContext.fill([rect])
        }
    }
    
    /**
     Paints a rectangular area with the currently selected fill color using the supplied blend mode.
     
     Before calling this method, select the fill color with the `setFill()` method on an instance of `NSColor`.
     
     The blend mode specifies how the new value for a given pixel is calculated, given the existing pixel value and the currently selected fill color.
     
     - Parameters:
        - rect: A rectangle, specified in the Core Graphics coordinate space with values in points.
        - blendMode: The blend mode applied to the stroke operation.
     */
    public func fill(_ rect: CGRect, blendMode: CGBlendMode) {
        cgContext.withSavedGState {
            cgContext.setBlendMode(blendMode)
            cgContext.fill(rect)
        }
    }
    
    /**
     Sets the clipping mask for the drawing context to the specified rectangle.
     
     To restrict the active drawing area to the specified rectangle, call this method before executing drawing commands.
     
     To use a more complex shape as a clipping mask, use the `clip(to:mask:)` method on the underlying Core Graphics context, accessed through the ``cgContext`` property.
     
     - Parameter rect: The rectangle to which the drawing context is clipped, specified in the Core Graphics coordinate space with values in points.
     */
    public func clip(to rect: CGRect) {
        cgContext.withSavedGState {
            cgContext.clip(to: rect)
        }
    }
}

#endif
