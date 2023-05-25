//
//  File.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

#if os(macOS)
import AppKit
import AVFoundation
import FZSwiftUtils
import Quartz

/**
 A protocol that defines a set of properties you implement to make the conformng object previewable by QuicklookPanel and QuicklookView.
 */
public protocol QLPreviewableContent {
    /// The url to the content to preview.
    var previewURL: URL? { get }
    /// The title of the content to preview.
    var previewTitle: String? { get }
    ///  The image to use for the transition zoom effect for the content.
    var previewTransitionImage: NSImage? { get }
}

internal protocol QLTemporaryFile: QLPreviewableContent {
    func deleteTemporaryQLFile() throws
    func createTemporaryQLFile() throws -> URL?
    func getTemporaryQLFile() -> URL?
    var temporaryQLFile: URL? { get }
}

public extension QLPreviewableContent {
    var previewTransitionImage: NSImage? {
        return nil
    }

    var previewTitle: String? {
        return nil
    }
}

extension URL: QLPreviewableContent {
    public var previewURL: URL? {
        return self
    }
}

extension NSURL: QLPreviewableContent {
    public var previewURL: URL? {
        return self as URL
    }
}

extension NSDocument: QLPreviewableContent {
    public var previewURL: URL? {
        return fileURL
    }

    public var previewTitle: String? {
        return displayName
    }
}

extension AVURLAsset: QLPreviewableContent {
    public var previewURL: URL? {
        return url
    }
}

extension NSImage: QLPreviewableContent, QLTemporaryFile {
    public var previewURL: URL? {
        return getTemporaryQLFile()
    }

    public var previewTransitionImage: NSImage? {
        return self
    }

    internal func getTemporaryQLFile() -> URL? {
        if let temporaryQLFile: URL = temporaryQLFile {
            return temporaryQLFile
        } else {
            return try? createTemporaryQLFile()
        }
    }

    internal var temporaryQLFile: URL? {
        getAssociatedValue(key: "_NSImage_temporaryQLFile", object: self)
    }

    internal func createTemporaryQLFile() throws -> URL? {
        if let temporaryQLFile = temporaryQLFile {
            return temporaryQLFile
        } else if let data = jpegData {
            let fileName = NSUUID().uuidString
            var fileURL = QuicklookPanel.shared.temporaryURL()
            fileURL = fileURL.appendingPathComponent(fileName).appendingPathExtension("jpeg")
            try data.write(to: fileURL)
            set(associatedValue: fileURL, key: "_NSImage_temporaryQLFile", object: self)
            return fileURL
        }
        return nil
    }

    internal func deleteTemporaryQLFile() throws {
        if let fileURL: URL = getAssociatedValue(key: "_NSImage_temporaryQLFile", object: self) {
            try FileManager.default.removeItem(at: fileURL)
            let nilURL: URL? = nil
            set(associatedValue: nilURL, key: "_NSImage_temporaryQLFile", object: self)
        }
    }
}

extension NSView: QLPreviewableContent, QLTemporaryFile {
    public var previewURL: URL? {
        return getTemporaryQLFile()
    }

    public var previewTransitionImage: NSImage? {
        return renderedImage
    }

    internal func getTemporaryQLFile() -> URL? {
        if let temporaryQLFile: URL = temporaryQLFile {
            return temporaryQLFile
        } else {
            return try? createTemporaryQLFile()
        }
    }

    internal var temporaryQLFile: URL? {
        getAssociatedValue(key: "_NSView_temporaryQLFile", object: self)
    }

    internal func createTemporaryQLFile() throws -> URL? {
        if let temporaryQLFile = temporaryQLFile {
            return temporaryQLFile
        } else if let data = renderedImage.jpegData {
            let fileName = NSUUID().uuidString
            var fileURL = QuicklookPanel.shared.temporaryURL()
            fileURL = fileURL.appendingPathComponent(fileName).appendingPathExtension("jpeg")
            try data.write(to: fileURL)
            set(associatedValue: fileURL, key: "_NSView_temporaryQLFile", object: self)
            return fileURL
        }
        return nil
    }

    internal func deleteTemporaryQLFile() throws {
        if let fileURL: URL = getAssociatedValue(key: "_NSView_temporaryQLFile", object: self) {
            try FileManager.default.removeItem(at: fileURL)
            let nilURL: URL? = nil
            set(associatedValue: nilURL, key: "_NSView_temporaryQLFile", object: self)
        }
    }
}

#endif
