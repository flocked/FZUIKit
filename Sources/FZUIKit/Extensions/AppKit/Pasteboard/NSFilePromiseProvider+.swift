//
//  NSFilePromiseProvider+.swift
//
//
//  Created by Florian Zand on 12.02.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers

/// A file promise provider that calls a handler for writing the file.
open class FilePromiseProvider: NSFilePromiseProvider, NSFilePromiseProviderDelegate {
    /// The handler for writing the file.
    public typealias Handler = (_ url: URL, _ completionHandler: @escaping (Error?) -> Void) -> Void

    /// The file name for writing the file.
    open var fileName: String
    
    public let handler: Handler
            
    public init(fileName: String, fileType: String, handler: @escaping Handler) {
        self.fileName = fileName
        self.handler = handler
        super.init()
        self.fileType = fileType
        self.delegate = self
    }
    
    @available(macOS 11.0, *)
    public init(fileName: String, fileType: UTType, handler: @escaping Handler) {
        self.fileName = fileName
        self.handler = handler
        super.init()
        self.fileType = fileType.identifier
        self.delegate = self
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        return fileName
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        handler(url, completionHandler)
    }
}

/// A file promise provider that writes a codable type.
open class CodableFilePromiseProvider<Content: Codable>: NSFilePromiseProvider, NSFilePromiseProviderDelegate {
    /// The content to write.
    public let content: Content
    
    /// The file name for writing the file.
    open var fileName: String
    
    /// The strategy for handling an existing file.
    open var existingFileStrategy: ExistingFileStrategy = .skip
    
    /// The strategy for handling an existing file.
    public enum ExistingFileStrategy {
        /// Skips writing the file.
        case skip
        /// Overwriting the file.
        case overwrite
        /// Renames the existing file.
        case renameExisting((String)->(String))
        /// Renames the new file.
        case renameNew((String)->(String))
    }
    
    public enum FilePromiseError: Error {
        /// The file already exists at the specified url.
        case fileExistsAlready(URL)
    }
    
    public init(content: Content, fileName: String, fileType: String) {
        self.content = content
        self.fileName = fileName
        super.init()
        self.fileType = fileType
        self.delegate = self
    }
    
    @available(macOS 11.0, *)
    public init(content: Content, fileName: String, fileType: UTType) {
        self.content = content
        self.fileName = fileName
        super.init()
        self.fileType = fileType.identifier
        self.delegate = self
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        return fileName
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        do {
            var url = url
            var shouldWrite = true
            if FileManager.default.fileExists(at: url) {
                switch existingFileStrategy {
                case .skip:
                    shouldWrite = false
                case .overwrite:
                    break
                case .renameExisting(let handler):
                    let newURL = url.deletingLastPathComponent().appendingPathComponent(handler(fileName))
                    shouldWrite = FileManager.default.fileExists(at: newURL) == false
                    if shouldWrite {
                        try FileManager.default.moveItem(at: url, to: newURL)
                    }
                case .renameNew(let handler):
                    url = url.deletingLastPathComponent().appendingPathComponent(handler(fileName))
                    shouldWrite = !FileManager.default.fileExists(at: url)
                }
            }
            if shouldWrite {
                let data = try JSONEncoder().encode(content)
                try data.write(to: url, options: [.atomic])
                completionHandler(nil)
            } else {
                completionHandler(FilePromiseError.fileExistsAlready(url))
            }
        } catch {
            completionHandler(error)
        }
    }
}

public extension FileConvertible {
    func filePromiseProvider(fileName: String, fileType: String) -> CodableFilePromiseProvider<Self> {
        CodableFilePromiseProvider(content: self, fileName: fileName, fileType: fileType)
    }
    
    @available(macOS 11.0, *)
    func filePromiseProvider(fileName: String, fileType: UTType) -> CodableFilePromiseProvider<Self> {
        CodableFilePromiseProvider(content: self, fileName: fileName, fileType: fileType)
    }
}

/// A file promise provider that writes data.
open class DataFilePromiseProvider: NSFilePromiseProvider, NSFilePromiseProviderDelegate {
    /// The data to write.
    public let data: Data
    
    /// The file name for writing the file.
    open var fileName: String
    
    /// The strategy for handling an existing file.
    open var existingFileStrategy: ExistingFileStrategy = .skip
    
    /// The strategy for handling an existing file.
    public enum ExistingFileStrategy {
        /// Skips writing the file.
        case skip
        /// Overwriting the file.
        case overwrite
        /// Renames the existing file.
        case renameExisting((String)->(String))
        /// Renames the new file.
        case renameNew((String)->(String))
    }
    
    public enum FilePromiseError: Error {
        /// The file already exists at the specified url.
        case fileExistsAlready(URL)
    }
    
    public init(data: Data, fileName: String, fileType: String) {
        self.data = data
        self.fileName = fileName
        super.init()
        self.fileType = fileType
        self.delegate = self
    }
    
    @available(macOS 11.0, *)
    public init(data: Data, fileName: String, fileType: UTType) {
        self.data = data
        self.fileName = fileName
        super.init()
        self.fileType = fileType.identifier
        self.delegate = self
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        return fileName
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        do {
            var url = url
            var shouldWrite = true
            if FileManager.default.fileExists(at: url) {
                switch existingFileStrategy {
                case .skip:
                    shouldWrite = false
                case .overwrite:
                    break
                case .renameExisting(let handler):
                    let newURL = url.deletingLastPathComponent().appendingPathComponent(handler(fileName))
                    shouldWrite = FileManager.default.fileExists(at: newURL) == false
                    if shouldWrite {
                        try FileManager.default.moveItem(at: url, to: newURL)
                    }
                case .renameNew(let handler):
                    url = url.deletingLastPathComponent().appendingPathComponent(handler(fileName))
                    shouldWrite = !FileManager.default.fileExists(at: url)
                }
            }
            if shouldWrite {
                try data.write(to: url, options: [.atomic])
                completionHandler(nil)
            } else {
                completionHandler(FilePromiseError.fileExistsAlready(url))
            }
        } catch {
            completionHandler(error)
        }
    }
}
#endif
