//
//  File.swift
//
//
//  Created by Florian Zand on 24.05.23.
//

#if os(macOS)
    import AppKit
    import AVFoundation
    import FZSwiftUtils
    import Quartz

    public protocol PreviewableMedia {}
    extension AVURLAsset: PreviewableMedia {}
    extension NSImage: PreviewableMedia {}

    public protocol QLPreviewableMedia: QLPreviewable {
        var media: PreviewableMedia { get }
    }

    public extension QLPreviewableMedia {
        var previewItemURL: URL! {
            mediaPreviewItemURL() ?? nil
        }

        var previewItemTransitionImage: NSImage? {
            media as? NSImage
        }

        internal func mediaPreviewItemURL() -> URL? {
            if let temporaryPreviewFile: URL = temporaryPreviewFile {
                return temporaryPreviewFile
            }
            if let asset = media as? AVURLAsset {
                return asset.url
            } else if media is NSImage {
                return try? createTemporaryPreviewFileIfNeeded()
            }
            return nil
        }

        internal var temporaryPreviewFile: URL? {
            getAssociatedValue(key: "_QLPreviewableMedia_temporaryPreviewFile", object: self)
        }

        internal func createTemporaryPreviewFileIfNeeded() throws -> URL? {
            if let temporaryPreviewFile = temporaryPreviewFile {
                return temporaryPreviewFile
            } else if let image = media as? NSImage, let data = image.jpegData {
                let fileName = NSUUID().uuidString
                var fileURL = QuicklookPanel.shared.temporaryURL()
                fileURL = fileURL.appendingPathComponent(fileName).appendingPathExtension("jpeg")
                try data.write(to: fileURL)
                set(associatedValue: fileURL, key: "_QLPreviewableMedia_temporaryPreviewFile", object: self)
                return fileURL
            }
            return nil
        }

        internal func deleteTemporaryPreviewFile() throws {
            if let fileURL: URL = getAssociatedValue(key: "_QLPreviewableMedia_temporaryPreviewFile", object: self) {
                try FileManager.default.removeItem(at: fileURL)
                let nilURL: URL? = nil
                set(associatedValue: nilURL, key: "_QLPreviewableMedia_temporaryPreviewFile", object: self)
            }
        }
    }

#endif
