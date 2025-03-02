//
//  Renderer.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import Foundation

/// An object for creating graphics renderers.
public protocol GraphicsRenderer: AnyObject {
    /// The associated context type this renderer will use.
    associatedtype Context: GraphicsRendererContext
    
    /// The format used to create the graphics renderer.
    var format: Context.Format { get }
    
    /// Creates a new graphics renderer with the specified bounds and a default format.
    init(bounds: CGRect)
}

#endif
