//
//  PDFRenderer.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A graphics renderer for creating PDFs.
public class GraphicsPDFRenderer: GraphicsRenderer {
    private let bounds: CGRect
    
    public typealias Context = GraphicsPDFRendererContext
    
    /// The format used to create the graphics renderer.
    public let format: GraphicsPDFRendererFormat
    
    /**
     Creates a PDF from a set of drawing instructions and saves it to a specified URL.
     
     You provide a set of drawing instructions as the block argument to this method, and the method attempts to write the resulting PDF to the supplied URL.
     You can call this method repeatedly to create multiple PDFs, each of which has identical dimensions and format.
     
     - Parameters:
        - url: The URL where the complete PDF file is saved.
        - actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output PDF.
     */
    public func writePDF(to url: URL, withActions actions: (_ context: Context) -> Void) throws {
        try GraphicsPDFRendererContext(url: url, format: format).render(actions)
    }
    
    /**
     Creates a PDF from a set of drawing instructions and returns it as a data object.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting PDF encoded in a `Data` object.
     
     You can call this method repeatedly to create multiple PDFs, each of which has identical dimensions and format.
     
     - Parameter actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output PDF.
     - Returns: A Data object that contains the encoded PDF.
     */
    public func pdfData(actions: (_ context: Context) -> Void) throws -> Data {
        let data = NSMutableData()
        try GraphicsPDFRendererContext(data: data, format: format).render(actions)
        return data as Data
    }
    
    /**
     Creates an PDF renderer with the specified bounds.
     
     This renderer uses the ``GraphicsPDFRendererFormat/default()`` static method on ``GraphicsPDFRendererContext`` to create its context, thereby selecting parameters that are the most appropriate for the current device.
     
     - Parameter bounds: The bounds of the Core Graphics context available to the renderer, with values in points.
     - Returns: An initialized PDF graphics renderer.
     */
    public required init(bounds: CGRect) {
        self.format = .default()
        self.bounds = bounds
    }
    
    /**
     Creates a new graphics renderer with the specified bounds and format.
     
     Use this initializer to create an PDF renderer when you want to override the default format for the current device. Provide the bounds of the PDF pages you want to create, and an instance of ``GraphicsPDFRendererFormat`` with the required configuration.
     
     - Parameters:
        - bounds: The bounds of the Core Graphics context available to the renderer, with values in points.
        - format: A ``GraphicsPDFRendererFormat`` object that encapsulates the format applied to the renderer’s context.
     - Returns: An initialized PDF graphics renderer.
     */
    public init(bounds: NSRect, format: GraphicsPDFRendererFormat) {
        self.format = format
        self.bounds = bounds
    }
    
    /**
     Creates a new graphics renderer with the specified bounds.
     
     This renderer uses the ``GraphicsPDFRendererFormat/default()`` static method on ``GraphicsPDFRendererContext`` to create its context, thereby selecting parameters that are the most appropriate for the current device.
     
     - Parameter size: The size of PDF pages output from the renderer, specified in points.
     - Returns: An initialized PDF graphics renderer.

     */
    public init(size: CGSize) {
        self.format = .default()
        self.bounds = size.rect
    }
    
    /**
     Creates a PDF renderer with the specified size and format.
     
     Use this initializer to create an PDF renderer when you want to override the default format for the current device.
     
     - Parameters:
        - size: The size of PDF pages output from the renderer, specified in points.
        - format: A ``GraphicsPDFRendererFormat`` object that encapsulates the format applied to the renderer’s context.
     - Returns: An initialized PDF graphics renderer.
     */
    public init(size: CGSize, format: GraphicsPDFRendererFormat) {
        self.format = format
        self.bounds = size.rect
    }
}

#endif
