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
    
    /// The handler for writing the file.
    public let handler: Handler
    
    /// The operation queue from which to issue the write request.
    public var operationQueue: OperationQueue = .main
    
    
    /**
     Initializes a file promise provider that calls the specified handler for writing the file.
     
     - Parameters:
        - fileName: the drag destination file's name.
        - fileType: The file content type (`UTI`).
        - handler: The handler for writing the file.
     */
    public init(fileName: String, fileType: String, handler: @escaping Handler) {
        self.fileName = fileName
        self.handler = handler
        super.init()
        self.fileType = fileType
        self.delegate = self
    }
    
    /**
     Initializes a file promise provider that calls the specified handler for writing the file.
     
     - Parameters:
        - fileName: the drag destination file's name.
        - fileType: The file content type.
        - handler: The handler for writing the file.
     */
    @available(macOS 11.0, *)
    public convenience init(fileName: String, fileType: UTType, handler: @escaping Handler) {
        self.init(fileName: fileName, fileType: fileType.identifier, handler: handler)
    }
    
    /**
     Initializes a file promise provider that writes the specified data.
     
     - Parameters:
        - data: The data to write.
        - fileName: the drag destination file's name.
        - fileType: The file content type (`UTI`).
        - existingFileStrategy: The strategy for handling an existing file.
     */
    public convenience init(data: Data, fileName: String, fileType: String, existingFileStrategy: ExistingFileStrategy = .skip) {
        self.init(fileName: fileName, fileType: fileType) { url, completionHandler in
            do {
                let url = try Self.checkExistingFile(url: url, fileName: fileName, strategy: existingFileStrategy)
                try data.write(to: url, options: [.atomic])
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }
    
    /**
     Initializes a file promise provider that writes the specified data.
     
     - Parameters:
        - data: The data to write.
        - fileName: the drag destination file's name.
        - fileType: The file content type.
        - existingFileStrategy: The strategy for handling an existing file.
     */
    @available(macOS 11.0, *)
    public convenience init(data: Data, fileName: String, fileType: UTType, existingFileStrategy: ExistingFileStrategy = .skip) {
        self.init(data: data, fileName: fileName, fileType: fileType.identifier, existingFileStrategy: existingFileStrategy)
    }
    
    /**
     Initializes a file promise provider that writes the specified codable type.
     
     - Parameters:
        - content: The codable type to write.
        - fileName: the drag destination file's name.
        - fileType: The file content type (`UTI`).
        - existingFileStrategy: The strategy for handling an existing file.
     */
    public convenience init<Content: Encodable>(content: Content, fileName: String, fileType: String, existingFileStrategy: ExistingFileStrategy = .skip) {
        self.init(fileName: fileName, fileType: fileType) { url, completionHandler in
            do {
                let url = try Self.checkExistingFile(url: url, fileName: fileName, strategy: existingFileStrategy)
                let data = try JSONEncoder().encode(content)
                try data.write(to: url, options: [.atomic])
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }
    
    /**
     Initializes a file promise provider that writes the specified codable type.
     
     - Parameters:
        - content: The codable type to write.
        - fileName: the drag destination file's name.
        - fileType: The file content type.
        - existingFileStrategy: The strategy for handling an existing file.
     */
    @available(macOS 11.0, *)
    public convenience init<Content: Encodable>(content: Content, fileName: String, fileType: UTType, existingFileStrategy: ExistingFileStrategy = .skip) {
        self.init(content: content, fileName: fileName, fileType: fileType.identifier, existingFileStrategy: existingFileStrategy)
    }
    
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
    
    /// File promise provider errors.
    public enum Errors: Error {
        /// The file already exists at the specified url.
        case fileExistsAlready(URL)
    }
    
    static func checkExistingFile(url: URL, fileName: String, strategy: ExistingFileStrategy) throws -> URL {
        var url = url
        var shouldWrite = true
        if FileManager.default.fileExists(at: url) {
            switch strategy {
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
        guard shouldWrite else {
            throw Errors.fileExistsAlready(url)
        }
        return url
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        return fileName
    }
    
    open func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        handler(url, completionHandler)
    }
    
    open func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
        return operationQueue
    }
}

public extension FileConvertible {
    /// Creates a file promise provider for the receiver.
    func filePromiseProvider(fileName: String, fileType: String, existingFileStrategy: FilePromiseProvider.ExistingFileStrategy = .skip) -> FilePromiseProvider {
        FilePromiseProvider(content: self, fileName: fileName, fileType: fileType, existingFileStrategy: existingFileStrategy)
    }
    
    /// Creates a file promise provider for the receiver.
    @available(macOS 11.0, *)
    func filePromiseProvider(fileName: String, fileType: UTType, existingFileStrategy: FilePromiseProvider.ExistingFileStrategy = .skip) -> FilePromiseProvider {
        FilePromiseProvider(content: self, fileName: fileName, fileType: fileType, existingFileStrategy: existingFileStrategy)
    }
}
#endif
