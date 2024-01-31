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

    extension QLThumbnailGenerator {
        /**
         Cancels the generation of a thumbnail for the specified requests.

         - Parameter requests: The thumbnail creation requests to cancel.
         */
        public func cancel(_ requests: [QLThumbnailGenerator.Request]) {
            requests.forEach { self.cancel($0) }
        }

        /// Cancels the generation of all thumbnail requests.
        public func cancelAllRequests() {
            cancel(processingRequests)
            cancel(pendingGenerationRequests)
            cancel(preparingGenerationRequests)
        }

        /// All thumbnail requests.
        public var requests: [RequestStatus: [QLThumbnailGenerator.Request]] {
            var requests: [RequestStatus: [QLThumbnailGenerator.Request]] = [:]
            requests[.processing] = processingRequests
            requests[.pendingCancelled] = pendingCancelledRequests
            requests[.pendingGeneration] = pendingGenerationRequests
            requests[.preparingGeneration] = preparingGenerationRequests
            return requests
        }

        /// The status of the request
        public enum RequestStatus: Int {
            /// The request is pending generation.
            case pendingGeneration
            /// The request is preparing for generation.
            case preparingGeneration
            /// The request is currently processed.
            case processing
            /// The request is pending cancellation.
            case pendingCancelled
        }

        var processingRequests: [QLThumbnailGenerator.Request] {
            if let dic = value(forKey: "requests") as? NSDictionary {
                return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
            }

            return ((value(forKey: "requests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
        }

        var pendingCancelledRequests: [QLThumbnailGenerator.Request] {
            if let dic = value(forKey: "pendingCancelledRequests") as? NSDictionary {
                return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
            }
            return ((value(forKey: "pendingCancelledRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
        }

        var pendingGenerationRequests: [QLThumbnailGenerator.Request] {
            if let dic = value(forKey: "pendingGenerationRequests") as? NSDictionary {
                return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
            }

            return ((value(forKey: "pendingGenerationRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
        }

        var preparingGenerationRequests: [QLThumbnailGenerator.Request] {
            if let dic = value(forKey: "preparingGenerationRequests") as? NSDictionary {
                return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
            }
            return ((value(forKey: "preparingGenerationRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap(\.value)
        }
    }

    extension QLThumbnailGenerator.Request {
        /// The URL of the file for which you want to create a thumbnail.
        public var fileURL: URL {
            get { value(forKey: "fileURL") as? URL ?? URL(fileURLWithPath: "No request URL") }
            set { setValue(newValue, forKey: "fileURL") }
        }
        
        /**
         Generates various thumbnail representations for the request and calls the update handler for each thumbnail representation.

         - Parameters:
            - completionHandler: The completion handler to call when the thumbnail generation completes. It is always called when QLThumbnailGenerator finishes the generation of a requested thumbnail. The completion handler takes the following parameters:
                - thumbnail: The most representative version of the requested thumbnail or `nil` if `QLThumbnailGenerator` was unable to generate a thumbnail.
                - error: An error object that indicates why the thumbnail generation failed, or `nil` if the thumbnail generation succeeded.
         */
        public func generateBestRepresentation(completion completionHandler: @escaping (QLThumbnailRepresentation?, Error?) -> Void) {
            QLThumbnailGenerator.shared.generateBestRepresentation(for: self, completion: completionHandler)
        }
        
        /**
         Generates various thumbnail representations for the request and calls the update handler for each thumbnail representation.
         
         Use this method if you want to create a file icon or low-quality thumbnail quickly, and replace it with a higher quality thumbnail once it becomes available.

         - Parameters:
            - updateHandler: The handler to call successively for each requested representation of a thumbnail. `QuickLookThumbnailing` calls the updateHandler in order of lower quality to higher quality thumbnail types. If a better quality thumbnail becomes available before a lower quality one, the framework may skip the call to the updateHandler for the lower quality thumbnail. You can rely on QuickLookThumbnailing to call the updateHandler at least once by the time it finishes the creation of thumbnails with either the best requested thumbnail, or an error object. The handler takes the following parameters:
                - thumbnail: A thumbnail that is successfully generated or `nil` if `QLThumbnailGenerator` is unable to generate a thumbnail.
                - type: The type of the generated thumbnail representation.
                - error: An error object that indicates why the thumbnail generation failed, or `nil` if the thumbnail generation succeeded.
         */
        public func generateRepresentations(update updateHandler: @escaping ((QLThumbnailRepresentation?, QLThumbnailRepresentation.RepresentationType, Error?) -> Void)) {
            QLThumbnailGenerator.shared.generateRepresentations(for: self, update: updateHandler)
        }
        
        /// Cancels the thumbnail request.
        public func cancel() {
            QLThumbnailGenerator.shared.cancel([self])
        }
    }

#endif
