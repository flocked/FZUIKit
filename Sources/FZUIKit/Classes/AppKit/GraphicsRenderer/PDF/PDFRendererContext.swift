//
//  GraphicsPDFRendererContext.swift
//  
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

/// The drawing environment for a PDF renderer.
public final class GraphicsPDFRendererContext: GraphicsRendererContext {
    private var hasOpenPage: Bool = false
    
    /**
     The format used to create the associated graphics renderer.
     
     If you specified a format object when you initialized the current renderer (`NSGraphicsImageRenderer`) object, then this property provides access to that object. Otherwise, a default format object was created for you using the renderer initialization parameters, tuned to the current device.
     */
    public let context: NSGraphicsContext
    
    /// The drawing configuration of the context.
    public let format: GraphicsPDFRendererFormat
    
    /**
     The bounds of the PDF context for the current page.
     
     This value represents the bounds provided to the ``beginPage(withBounds:pageInfo:)`` method that created the current page. If the current page was created using the ``beginPage()`` method, the bounds are equal to those provided at the initialization of the PDF renderer.
     */
    public private(set) var pdfContextBounds: CGRect = .zero
    
    /**
     Begins a new page in a PDF graphics context. The bounds will be the same as specified by the document.
     
     If an existing page is open, it will be closed.
     */
    public func beginPage() {
        beginPage(withBounds: format.bounds, pageInfo: format.documentInfo)
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
        cgContext.beginPDFPage(pageInfo.dictionary as CFDictionary)
        hasOpenPage = true
        guard format.isFlipped else { return }
        cgContext.flipVertically()
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
    
    private func endPageIfOpen() {
        guard hasOpenPage else { return }
        cgContext.endPDFPage()
        hasOpenPage = false
        pdfContextBounds = .zero
    }
    
    private func beginRendering() {
        format.isRendering = true
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.saveGraphicsState()
    }
    
    private func endRendering() {
        format.isRendering = false
        endPageIfOpen()
        cgContext.closePDF()
        context.restoreGraphicsState()
        NSGraphicsContext.restoreGraphicsState()
    }
    
    func render(_ actions: (_ context: GraphicsPDFRendererContext) -> Void) {
        beginRendering()
        actions(self)
        endRendering()
    }
    
    init(url: URL, format: GraphicsPDFRendererFormat) throws {
        guard let context = CGContext(url: url, mediaBox: format.renderingBounds, auxiliaryInfo: format.documentInfo.dictionary) else { throw Errors.renderingFailed }
        self.context = NSGraphicsContext(cgContext: context, flipped: format.isFlipped)
        self.format = format
    }
    
    init(data: NSMutableData, format: GraphicsPDFRendererFormat) throws {
        guard let context = CGContext(data: data, mediaBox: format.renderingBounds, auxiliaryInfo: format.documentInfo.dictionary) else { throw Errors.renderingFailed }
        self.context = NSGraphicsContext(cgContext: context, flipped: format.isFlipped)
        self.format = format
    }
    
    private enum Errors: Error {
        case renderingFailed
    }
}

#endif
