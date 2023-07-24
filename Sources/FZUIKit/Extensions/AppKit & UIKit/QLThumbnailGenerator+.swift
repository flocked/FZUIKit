//
//  QLThumbnailGenerator+.swift
//
//
//  Created by Florian Zand on 30.11.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import QuickLookThumbnailing

public extension QLThumbnailGenerator {
    /**
     Cancels the generation of a thumbnail for tje given requests.
     
     - Parameters requests: The thumbnail creation requests that you want to cancel.
     */
    func cancel(_ requests: [QLThumbnailGenerator.Request]) {
        requests.forEach { self.cancel($0) }
    }
    
    /// Cancels the generation of all thumbnail requests.
    func cancelAllRequests() {
        self.cancel(processingRequests)
        self.cancel(pendingGenerationRequests)
        self.cancel(preparingGenerationRequests)
    }

    /// All thumbnail requests.
    var requests: [RequestStatus: [QLThumbnailGenerator.Request]] {
        var requests: [RequestStatus: [QLThumbnailGenerator.Request]] = [:]
        requests[.processing] = processingRequests
        requests[.pendingCancelled] = pendingCancelledRequests
        requests[.pendingGeneration] = pendingGenerationRequests
        requests[.preparingGeneration] = preparingGenerationRequests
        return requests
    }
    
    /// The status of the request
    enum RequestStatus: Int {
        /// The request is pending generation.
        case pendingGeneration
        /// The request is preparing for generation.
        case preparingGeneration
        /// The request is currently processed.
        case processing
        /// The request is pending cancellation.
        case pendingCancelled
    }

    internal var processingRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "requests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }

        return ((value(forKey: "requests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }

    internal var pendingCancelledRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "pendingCancelledRequests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }
        return ((value(forKey: "pendingCancelledRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }

    internal var pendingGenerationRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "pendingGenerationRequests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }

        return ((value(forKey: "pendingGenerationRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }

    internal var preparingGenerationRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "preparingGenerationRequests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }
        return ((value(forKey: "preparingGenerationRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }
}

public extension QLThumbnailGenerator.Request {
    /// The URL of the file for which you want to create a thumbnail.
    var fileURL: URL {
        get { value(forKey: "fileURL") as! URL }
        set { setValue(newValue, forKey: "fileURL") }
    }
}
