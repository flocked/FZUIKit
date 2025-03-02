//
//  PDFDocumentInfo.swift
//
//
//  Created by Florian Zand on 02.03.25.
//

#if os(macOS)
import AppKit

/// A set of attributes that represents the document or page information of a PDF.
public struct PDFDocumentInfo {
    /// The author of the PDF document.
    public var author: String?
    
    /// The creator of the PDF document.
    public var creator: String?
    
    /// The title of the PDF document.
    public var title: String?
    
    /// The owner password for the PDF document.
    public var ownerPassword: String?
    
    /// The user password for the PDF document.
    public var userPassword: String?
    
    /// A flag indicating if printing is allowed on the PDF document.
    public var allowsPrinting: Bool?
    
    /// A flag indicating if copying content is allowed from the PDF document.
    public var allowsCopying: Bool?
    
    /// A string that describes the output intent for the PDF document.
    public var outputIntent: String?
    
    /// A string containing the output intents for the PDF document.
    public var outputIntents: String?
    
    /// The subject of the PDF document.
    public var subject: String?
    
    /// A string containing keywords for the PDF document.
    public var keywords: String?
    
    /// The encryption key length for the PDF document.
    public var encryptionKeyLength: Int?
    
    /// The media box dimensions for the PDF document.
    public var mediaBox: CGRect?
    
    /// The crop box dimensions for the PDF document.
    public var cropBox: CGRect?
    
    /// The bleed box dimensions for the PDF document.
    public var bleedBox: CGRect?
    
    /// The trim box dimensions for the PDF document.
    public var trimBox: CGRect?
    
    /// The art box dimensions for the PDF document.
    public var artBox: CGRect?
    
    /// The output intent subtype for the PDF document.
    public var outputIntentSubtype: String?
    
    /// The output condition identifier for the PDF document.
    public var outputConditionIdentifier: String?
    
    /// The output condition for the PDF document.
    public var outputCondition: String?
    
    /// The registry name for the PDF document.
    public var registryName: String?
    
    /// The additional information about the PDF document.
    public var info: String?
    
    /// The destination output profile for the PDF document.
    public var destinationOutputProfile: String?
    
    public init() {
        
    }
    
    public static let none = PDFDocumentInfo()

    var dictionary: CFDictionary {
        var dict: [CFString: Any] = [:]
        dict[kCGPDFContextAuthor] = author
        dict[kCGPDFContextCreator] = creator
        dict[kCGPDFContextTitle] = title
        dict[kCGPDFContextOwnerPassword] = ownerPassword
        dict[kCGPDFContextUserPassword] = userPassword
        dict[kCGPDFContextAllowsPrinting] = allowsPrinting
        dict[kCGPDFContextAllowsCopying] = allowsCopying
        dict[kCGPDFContextOutputIntent] = outputIntent
        dict[kCGPDFContextOutputIntents] = outputIntents
        dict[kCGPDFContextSubject] = subject
        dict[kCGPDFContextKeywords] = keywords
        dict[kCGPDFContextEncryptionKeyLength] = encryptionKeyLength
        dict[kCGPDFContextMediaBox] = mediaBox
        dict[kCGPDFContextCropBox] = cropBox
        dict[kCGPDFContextBleedBox] = bleedBox
        dict[kCGPDFContextTrimBox] = trimBox
        dict[kCGPDFContextArtBox] = artBox
        dict[kCGPDFXOutputIntentSubtype] = outputIntentSubtype
        dict[kCGPDFXOutputConditionIdentifier] = outputConditionIdentifier
        dict[kCGPDFXOutputCondition] = outputCondition
        dict[kCGPDFXRegistryName] = registryName
        dict[kCGPDFXInfo] = info
        dict[kCGPDFXDestinationOutputProfile] = destinationOutputProfile
        return dict as CFDictionary
    }
}


#endif
