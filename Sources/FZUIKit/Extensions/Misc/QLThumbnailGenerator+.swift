//
//  QLThumbnailGenerator+.swift
//
//
//  Created by Florian Zand on 30.11.22.
//

#if os(macOS) || os(iOS)
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import QuickLookThumbnailing
import FZSwiftUtils

extension QLThumbnailGenerator {
    /**
     Cancels the generation of a thumbnail for the specified requests.

     - Parameter requests: The thumbnail creation requests to cancel.
     */
    public func cancel<S: Sequence<Request>>(_ requests: S) {
        requests.forEach({ cancel($0) })
    }

    /// Cancels all pending thumbnail generation requests.
    public func cancelAllRequests() {
        pendingRequests.forEach({ cancel($0) })
    }
    
    /**
     Cancels all pending requests that create thumbnails for the specified file URLs.
     
     - Parameter urls: The file URLs to cancel thumbnail generation requests for.
     */
    public func cancelRequests<S: Sequence<URL>>(for urls: S) {
        for request in pendingRequests {
            guard urls.contains(request.fileURL) else { continue }
            cancel(request)
        }
    }
    
    /// All requests that are currently pending generation.
    public var pendingRequests: [Request] {
        processingRequests + pendingGenerationRequests + preparingGenerationRequests
    }


    /// The requests currently being processed.
    var processingRequests: [Request] {
        (value(forKeySafely: "requests") as? [UUID: Request])?.map(\.value) ?? []
    }

    /// The requests pending cancellation.
    var pendingCancelledRequests: [Request] {
        (value(forKeySafely: "pendingCancelledRequests") as? [UUID: Request])?.map(\.value) ?? []
    }

    /// The requests pending generation.
    var pendingGenerationRequests: [Request] {
        (value(forKeySafely: "pendingGenerationRequests") as? [UUID: Request])?.map(\.value) ?? []
    }

    /// The request being prepared for generation.
    var preparingGenerationRequests: [Request] {
        (value(forKeySafely: "preparingGenerationRequests") as? [UUID: Request])?.map(\.value) ?? []
    }
}

extension QLThumbnailGenerator.Request {
    /// The URL of the file to create a thumbnail for.
    public var fileURL: URL {
        get { value(forKeySafely: "fileURL") as? URL ?? .file("/") }
    }

    /**
     Generates the best possible thumbnail representation for a file and calls a handler upon completion.

     - Parameter completionHandler: The completion handler to call when the thumbnail generation completes. It is always called when QLThumbnailGenerator finishes the generation of a requested thumbnail. The completion handler takes the following parameters:
        - thumbnail: The most representative version of the requested thumbnail or `nil` if `QLThumbnailGenerator` was unable to generate a thumbnail.
        - error: An error object indicating why the thumbnail generation failed, or `nil` if the thumbnail generation succeeded.
     */
    public func generateBestRepresentation(completion completionHandler: @escaping (_ thumbnail: QLThumbnailRepresentation?, _ error: Error?) -> Void) {
        QLThumbnailGenerator.shared.generateBestRepresentation(for: self, completion: completionHandler)
    }
    
    /**
     Generates the best possible thumbnail representation for a file and calls a handler upon completion.

     - Returns: The most representative version of the requested thumbnail.
     */
    public func generateBestRepresentation() async throws -> QLThumbnailRepresentation {
        try await QLThumbnailGenerator.shared.generateBestRepresentation(for: self)
    }

    /**
     Generates various thumbnail representations for the request and calls the update handler for each thumbnail representation.

     Use this method if you want to create a file icon or low-quality thumbnail quickly, and replace it with a higher quality thumbnail once it becomes available.

     - Parameter updateHandler: The handler to call successively for each requested representation of a thumbnail.  The handler is called in order of lower quality to higher quality thumbnail types. If a better quality thumbnail becomes available before a lower quality one, the framework may skip the call to the updateHandler for the lower quality thumbnail. You can rely on QuickLookThumbnailing to call the updateHandler at least once by the time it finishes the creation of thumbnails with either the best requested thumbnail, or an error object. The handler takes the following parameters:
        - thumbnail: A thumbnail that is successfully generated or `nil` if `QLThumbnailGenerator` is unable to generate a thumbnail.
        - type: The type of the generated thumbnail representation.
        - error: An error object indicating why the thumbnail generation failed, or `nil` if the thumbnail generation succeeded.
     */
    public func generateRepresentations(update updateHandler: @escaping ((_ thumbnail: QLThumbnailRepresentation?, _ type: QLThumbnailRepresentation.RepresentationType, _ error: Error?) -> Void)) {
        QLThumbnailGenerator.shared.generateRepresentations(for: self, update: updateHandler)
    }
    
    /**
     Saves a thumbnail for the request on disk at fileURL. The file saved at fileURL has to be deleted when it is not used anymore. This is primarily intended for file provider extensions which need to upload thumbnails and have a small memory limit.
     
     - Parameters:
        - fileURL: The file url of the thumbnail to save.
        - contentType: An image content type to save the thumbnail as, supported by CGImageDestination, such as [png](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype-swift.struct/png) or [jpeg](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype-swift.struct/jpeg).
        - completionHandler: Always called when the thumbnail generation is over. Will contain an error if the thumbnail could not be successfully saved to disk at fileURL.
     
     */
    public func saveBestRepresentation(to fileURL: URL, as contentType: UTType, completion completionHandler: @escaping @Sendable (Error?) -> Void) {
        QLThumbnailGenerator.shared.saveBestRepresentation(for: self, to: fileURL, as: contentType, completion: completionHandler)
    }
    
    /**
     Saves a thumbnail for the request on disk at fileURL. The file saved at fileURL has to be deleted when it is not used anymore. This is primarily intended for file provider extensions which need to upload thumbnails and have a small memory limit.

     - Parameters:
        - fileURL: The file url of the thumbnail to save.
        - contentType: An image content type to save the thumbnail as, supported by CGImageDestination, such as [png](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype-swift.struct/png) or [jpeg](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype-swift.struct/jpeg).
     */
    public func saveBestRepresentation(to fileURL: URL, as contentType: UTType) async throws {
       try await QLThumbnailGenerator.shared.saveBestRepresentation(for: self, to: fileURL, as: contentType)
    }

    /// Cancels the thumbnail request.
    public func cancel() {
        QLThumbnailGenerator.shared.cancel(self)
    }
}

#endif
