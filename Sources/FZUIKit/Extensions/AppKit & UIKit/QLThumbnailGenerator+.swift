//
//  File.swift
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
    enum RequestStatus {
        case processing
        case pendingCancelled
        case pendingGeneration
        case preparingGeneration
    }

    func cancel(_ requests: [QLThumbnailGenerator.Request]) {
        requests.forEach { self.cancel($0) }
    }

    var requests: [(request: QLThumbnailGenerator.Request, status: RequestStatus)] {
        var requests: [(request: QLThumbnailGenerator.Request, status: RequestStatus)] = []
        processingRequests.forEach { requests.append((request: $0, status: .processing)) }
        pendingCancelledRequests.forEach { requests.append((request: $0, status: .pendingCancelled)) }
        pendingGenerationRequests.forEach { requests.append((request: $0, status: .pendingGeneration)) }
        preparingGenerationRequests.forEach { requests.append((request: $0, status: .preparingGeneration)) }

        return requests
    }

    var processingRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "requests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }

        return ((value(forKey: "requests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }

    var pendingCancelledRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "pendingCancelledRequests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }
        return ((value(forKey: "pendingCancelledRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }

    var pendingGenerationRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "pendingGenerationRequests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }

        return ((value(forKey: "pendingGenerationRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }

    var preparingGenerationRequests: [QLThumbnailGenerator.Request] {
        if let dic = value(forKey: "preparingGenerationRequests") as? NSDictionary {
            return ((dic as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
        }

        return ((value(forKey: "preparingGenerationRequests") as? [UUID: QLThumbnailGenerator.Request]) ?? [:]).compactMap { $0.value }
    }
}

public extension QLThumbnailGenerator.Request {
    var fileURL: URL {
        get { value(forKey: "fileURL") as! URL }
        set { setValue(newValue, forKey: "fileURL") }
    }
}
