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
public class PDFGraphicsRenderer: GraphicsRenderer {
    public typealias Context = PDFGraphicsRendererContext
    
    /// The format used to create the graphics renderer.
    public let format: PDFGraphicsRendererFormat
    
    /**
     Creates a PDF from a set of drawing instructions and saves it to a specified URL.
     
     You provide a set of drawing instructions as the block argument to this method, and the method attempts to write the resulting PDF to the supplied URL.
     You can call this method repeatedly to create multiple PDFs, each of which has identical dimensions and format.
     
     - Parameters:
        - url: The URL where the complete PDF file is saved.
        - actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output PDF.
     */
    public func writePDF(to url: URL, withActions actions: (_ context: Context) -> Void) throws {
        var bounds = format.renderingBounds
        if let consumer = CGDataConsumer(url: url as CFURL), let context = CGContext(consumer: consumer, mediaBox: &bounds, format.documentInfo.dictionary) {
            runDrawingActions(forContext: context, drawingActions: actions)
        } else {
            throw Errors.renderingFailed
        }
    }
    
    /**
     Creates a PDF from a set of drawing instructions and returns it as a data object.
     
     You provide a set of drawing instructions as the block argument to this method, and the method returns the resulting PDF encoded in a `Data` object.
     
     You can call this method repeatedly to create multiple PDFs, each of which has identical dimensions and format.
     
     - Parameter actions: A block that, when invoked by the renderer, executes a set of drawing instructions to create the output PDF.
     - Returns: A Data object that contains the encoded PDF.
     */
    public func pdfData(actions: (_ context: Context) -> Void) throws -> Data {
        var rect = format.renderingBounds
        let data = NSMutableData()
        if let consumer = CGDataConsumer(data: data), let context = CGContext(consumer: consumer, mediaBox: &rect, format.documentInfo.dictionary) {
            runDrawingActions(forContext: context, drawingActions: actions)
            return data as Data
        } else {
            throw Errors.renderingFailed
        }
    }
    
    enum Errors: Error {
        case renderingFailed
    }
    
    func runDrawingActions(forContext cgContext: CGContext, drawingActions: (_ context: Context) -> Void, completionActions: ((_ context: Context) -> Void)? = nil) {
        let context = PDFGraphicsRendererContext(context: NSGraphicsContext(cgContext: cgContext, flipped: format.isFlipped), format: format)
        context.beginRendering()
        drawingActions(context)
        completionActions?(context)
        context.endRendering()
    }
    
    public required init(bounds: CGRect) {
        self.format = .default()
        format.bounds = bounds
    }
    
    /**
     Creates an image renderer with the specified bounds and format.
     
     Use this initializer to create an image renderer when you want to override the default format for the current device. Provide the size of the images you want to create, and an instance of ``NSGraphicsImageGraphicsRendererFormat`` with the required configuration.
     
     - Parameters:
        - bounds: The bounds of the image context the image renderer creates and subsequently draws upon. Specify values in points in the Core Graphics coordinate space.
        - format: A ``NSGraphicsImageGraphicsRendererFormat`` object that encapsulates the format used to create the renderer context.
     - Returns: An initialized image renderer.
     */
    public init(bounds: NSRect, format: PDFGraphicsRendererFormat) {
        self.format = format
        format.bounds = bounds
    }
    
    /**
     Creates an image renderer for drawing images of the specified size.
     
     Use this initializer to create an image renderer that will draw images of a given size. This renderer uses the ``NSGraphicsImageGraphicsRendererFormat/default()`` static method on ``NSGraphicsImageGraphicsRendererContext`` to create its context, thereby selecting parameters that are the most appropriate for the current device.
     
     - Parameter size: The size of images output from the renderer, specified in points.
     - Returns: An initialized image renderer.
     
     */
    public convenience init(size: CGSize) {
        self.init(size: size, format: .default())
    }
    
    /**
     Creates an image renderer with the specified size and format.
     
     Use this initializer to create an image renderer when you want to override the default format for the current device.
     
     - Parameters:
        - size: The size of images output from the renderer, specified in points.
        - format: A ``NSGraphicsImageGraphicsRendererFormat`` object that encapsulates the format used to create the renderer context.
     - Returns: An initialized image renderer.
     */
    public init(size: CGSize, format: PDFGraphicsRendererFormat) {
        self.format = format
        format.bounds = CGRect(.zero, size)
    }
}

#endif
