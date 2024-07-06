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
    func recognizedTexts(completion: @escaping (_ recognizedTexts: [VNRecognizedText])->()) {
        if let cgImage = cgImage {
            cgImage.recognizedTexts(completion: completion)
        } else {
            completion([])
        }
    }
}

public extension CGImage {
    /// Returns the recognized texts in the image to the completion handler.
    func recognizedTexts(completion: @escaping (_ recognizedTexts: [VNRecognizedText])->()) {
        let requestHandler = VNImageRequestHandler(cgImage: self)
        let request = VNRecognizeTextRequest() { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            let recognizedTexts = observations.compactMap { $0.topCandidates(1).first }
            completion(recognizedTexts)
        }

        do {
            try requestHandler.perform([request])
        } catch {
            debugPrint("Unable to perform the requests: \(error).")
            completion([])
        }
    }
}

public extension CIImage {
    /// Returns the recognized texts in the image to the completion handler.
    func recognizedTexts(completion: @escaping (_ recognizedTexts: [VNRecognizedText])->()) {
        let requestHandler = VNImageRequestHandler(ciImage: self)
        let request = VNRecognizeTextRequest() { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            let recognizedTexts = observations.compactMap { $0.topCandidates(1).first }
            completion(recognizedTexts)
        }

        do {
            try requestHandler.perform([request])
        } catch {
            debugPrint("Unable to perform the requests: \(error).")
            completion([])
        }
    }
}


#endif
