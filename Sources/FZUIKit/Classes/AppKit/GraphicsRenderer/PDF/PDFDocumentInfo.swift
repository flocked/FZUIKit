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
    
    /// A Boolean value indicating whether printing is allowed on the PDF document.
    public var allowsPrinting: Bool = true
    
    /// A Boolean value indicating whether copying content is allowed from the PDF document.
    public var allowsCopying: Bool = true
    
    /// An array containing the output intents for the PDF document.
    public var outputIntents: [OutputIntend]?
    
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
    
    /// The output intent PDF/X.
    public struct OutputIntend {
        /// A string identifying the intended output device or production condition in a human- or machine-readable form.
        public  var outputConditionIdentifier: String
        
        /// A string identifying the intended output device or production condition in a human-readable form.
        public  var outputCondition: String?
        
        /// A string identifying the registry in which the condition designated by ``identifier`` is defined.
        public var registryName: String?
        /**
         A human-readable string containing additional information or comments about the intended target device or production condition.
         
         This value is required if the value of ``outputConditionIdentifier`` does not specify a standard production condition.
         */
        public var info: String?
        /**
         An ICC profile stream defining the transformation from the PDF document’s source colors to output device colorants.
         
         This value is required if the value of ``outputConditionIdentifier`` does not specify a standard production condition.
         */
        public var destinationOutputProfile: CGColorSpace?
        
        public init(outputConditionIdentifier: String, outputCondition: String? = nil, registryName: String? = nil, info: String? = nil, destinationOutputProfile: CGColorSpace? = nil) {
            self.outputConditionIdentifier = outputConditionIdentifier
            self.outputCondition = outputCondition
            self.registryName = registryName
            self.info = info
            self.destinationOutputProfile = destinationOutputProfile
        }
        
        var dictionary: [CFString: Any] {
            var dict: [CFString: Any] = [:]
            dict[kCGPDFXOutputIntentSubtype] = "GTS_PDFX"
            dict[kCGPDFXOutputConditionIdentifier] = outputConditionIdentifier
            dict[kCGPDFXOutputCondition] = outputCondition
            dict[kCGPDFXRegistryName] = registryName
            dict[kCGPDFXInfo] = info
            dict[kCGPDFXDestinationOutputProfile] = destinationOutputProfile
            return dict
        }
    }
    
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
        dict[kCGPDFContextOutputIntents] = outputIntents?.map({$0.dictionary})
        dict[kCGPDFContextSubject] = subject
        dict[kCGPDFContextKeywords] = keywords
        dict[kCGPDFContextEncryptionKeyLength] = encryptionKeyLength
        dict[kCGPDFContextMediaBox] = mediaBox
        dict[kCGPDFContextCropBox] = cropBox
        dict[kCGPDFContextBleedBox] = bleedBox
        dict[kCGPDFContextTrimBox] = trimBox
        dict[kCGPDFContextArtBox] = artBox
        return dict as CFDictionary
    }
}


#endif
