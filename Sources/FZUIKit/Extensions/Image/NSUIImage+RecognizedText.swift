//
//  NSUIImage+RecognizedText.swift
//
//
//  Created by Florian Zand on 07.07.24.
//

#if os(macOS) || canImport(UIKit)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Vision

public extension NSUIImage {
    /// Returns the recognized texts in the image to the completion handler.
    func recognizedTexts(completion: @escaping (_ result: Result<[VNRecognizedText], Error>)->()) {
        if let cgImage = cgImage {
            cgImage.recognizedTexts(completion: completion)
        } else {
            completion(.failure(TextRecognizionErrors.noCGImage))
        }
    }
    
    /// Errors for recognizing texts in an image.
    enum TextRecognizionErrors: Error {
        /// Unable to convert the image to a `CGImage`.
        case noCGImage
        /// Unable to recognize text.
        case unableToRecognizeText
    }
}

public extension CGImage {
    /// Returns the recognized texts in the image to the completion handler.
    func recognizedTexts(completion: @escaping (_ result: Result<[VNRecognizedText], Error>)->()) {
        let requestHandler = VNImageRequestHandler(cgImage: self)
        let request = VNRecognizeTextRequest() { request, error in
            if let recognizedTexts = (request.results as? [VNRecognizedTextObservation])?.compactMap({ $0.topCandidates(1).first}) {
                completion(.success(recognizedTexts))
            } else {
                completion(.failure(error ?? NSUIImage.TextRecognizionErrors.unableToRecognizeText))
            }
        }

        do {
            try requestHandler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}

public extension CIImage {
    /// Returns the recognized texts in the image to the completion handler.
    func recognizedTexts(completion: @escaping (_ result: Result<[VNRecognizedText], Error>)->()) {
        let requestHandler = VNImageRequestHandler(ciImage: self)
        let request = VNRecognizeTextRequest() { request, error in
            if let recognizedTexts = (request.results as? [VNRecognizedTextObservation])?.compactMap({ $0.topCandidates(1).first}) {
                completion(.success(recognizedTexts))
            } else {
                completion(.failure(error ?? NSUIImage.TextRecognizionErrors.unableToRecognizeText))
            }
        }

        do {
            try requestHandler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}


#endif
