//
//  PDFGraphicsRendererContext.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

/// The drawing environment for a PDF renderer.
public final class PDFGraphicsRendererContext: GraphicsRendererContext {
    private var hasOpenPage: Bool = false
    private var previousContext: NSGraphicsContext?
    
    /**
     The format used to create the associated graphics renderer.
     
     If you specified a format object when you initialized the current renderer (`NSGraphicsImageRenderer`) object, then this property provides access to that object. Otherwise, a default format object was created for you using the renderer initialization parameters, tuned to the current device.
     */
    public let context: NSGraphicsContext
    
    /// The drawing configuration of the context.
    public let format: PDFGraphicsRendererFormat
    
    public internal(set) var pdfContextBounds: CGRect = .zero
    
    /**
     Begins a new page in a PDF graphics context. The bounds will be the same as specified by the document.
     
     If an existing page is open, it will be closed.
     
     - Parameter pageInfo: The page info associated to be associated with this page.
     */
    public func beginPage(pageInfo: PDFDocumentInfo = .none) {
        beginPage(withBounds: format.bounds, pageInfo: pageInfo)
    }
    
    /**
     Begins a new page in a PDF graphics context.
     
     If an existing page is open, it will be closed.
     
     - Parameters:
        - bounds: The bounds to use for this page.
        - pageInfo: The page info associated to be associated with this page.
     */
    public func beginPage(withBounds bounds: CGRect, pageInfo: PDFDocumentInfo = .none) {
        var pageInfo = pageInfo
        pageInfo.mediaBox = bounds
        pdfContextBounds = bounds
        endPageIfOpen()
        cgContext.beginPDFPage(pageInfo.dictionary)
        hasOpenPage = true
        
        if format.isFlipped {
            cgContext.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: format.bounds.height))
        }
    }
    
    /**
     Sets the URL associated with a rectangle in a PDF graphics context.
     
     -  Parameters:
        - name: A URL that specifies the destination of the contents associated with the rectangle.
        - rect: A rectangle specified in default user space (not device space).
     */
    public func setURL(_ url: URL, for rect: CGRect) {
        let url = url as CFURL
        cgContext.setURL(url, for: rect)
    }
    
    /**
     Sets a destination to jump to when a point in the current page of a PDF graphics context is clicked.
     
     -  Parameters:
        - name: A destination name.
        - point: A location in the current page of the PDF graphics context.
     */
    public func addDestination(withName name: String, at point: CGPoint) {
        let name = name as CFString
        cgContext.addDestination(name, at: point)
    }
    
    /**
     Sets a destination to jump to when a rectangle in the current PDF page is clicked.
     
     -  Parameters:
        - name: A destination name.
        - rect: A rectangle that specifies an area of the current page of a PDF graphics context. The rectangle is specified in default user space (not device space).
     */
    public func setDestinationWithName(_ name: String, for rect: CGRect) {
        let name = name as CFString
        cgContext.setDestination(name, for: rect)
    }
    
    /**
     Associates custom metadata with the PDF document.
     
     - Parameter metadata: A stream of XML data that is formatted according to the Extensible Metadata Platform, as described in section 10.2.2., “Metadata Streams”, of the PDF 1.7 specification.
     */
    public func addDocumentMetadata(_ metadata: Data?) {
        cgContext.addDocumentMetadata(metadata as CFData?)
    }
    
    func endPageIfOpen() {
        guard hasOpenPage else { return }
        cgContext.endPDFPage()
        hasOpenPage = false
        pdfContextBounds = .zero
    }
    
    func beginRendering() {
        format.isRendering = true
        previousContext = NSGraphicsContext.current
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    func endRendering() {
        format.isRendering = false
        endPageIfOpen()
        cgContext.closePDF()
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
        NSGraphicsContext.current = previousContext
        previousContext = nil
    }
    
    init(context: NSGraphicsContext, format: PDFGraphicsRendererFormat) {
        self.context = context
        self.format = format
    }
}

#endif
