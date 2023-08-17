//
//  Unarchiver.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public enum Unarchiver {
    ///The supported file extensions for extracting files.
    public static let supportedFileExtensions: [String] = ["zip", "tar", "tar.gz", "tgz", "gz"]

    /**
     Extracts the specified archive.
     
     - Parameters:
        - archive: The url to the file.
        - directory: The destionation directory where the files of the archive should be extracted to or nil if the files should be extracted to the same directory the archive is located at.
        - overwriteFiles: A Boolean value that indicates whether existing files that get extracted from the archive should be overwritten.
        - deleteArchiveWhenDone: A Boolean value that indicates whether the archive should be deleted when it's files got extracted.
        - completionHandler: The handler to be called whenever the extracting is done returning the urls to the extracted files and an error if the extraction failed.
     */
    public static func extractArchive(_ archive: URL, to directory: URL? = nil, overwriteFiles: Bool = false, deleteArchiveWhenDone: Bool = false, completionHandler: @escaping (([URL]?, Error?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fileURLs = try self.extractArchive(archive, to: directory, overwriteFiles: overwriteFiles, deleteArchiveWhenDone: deleteArchiveWhenDone)
                DispatchQueue.main.async {
                    completionHandler(fileURLs, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
    }

    /**
     Extracts the specified archive.
     
     - Parameters:
        - archive: The url to the file.
        - directory: The destionation directory where the files of the archive should be extracted to or nil if the files should be extracted to the same directory the archive is located at.
        - overwriteFiles: A Boolean value that indicates whether existing files that get extracted from the archive should be overwritten
        - deleteArchiveWhenDone: A Boolean value that indicates whether the archive should be deleted when it's files got extracted.
     
     - Throws: Throws if the archive or destionation directory doesn't exist or if the extraction failes.
     - Returns: The urls of the extracted files.
     */
    public static func extractArchive(_ archive: URL, to directory: URL? = nil, overwriteFiles: Bool = false, deleteArchiveWhenDone: Bool = false) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: archive.path) else {
            throw Errors.archiveDoesntExist
        }
        
        if let directory = directory {
            guard FileManager.default.fileExists(atPath: directory.path) else {
                throw Errors.directoryDoesntExist
            }
        }

        guard supportedFileExtensions.contains(archive.pathExtension.lowercased()) else {
            throw Errors.unknownArchive
        }

        let directory = directory ?? archive.deletingLastPathComponent()
        let arguments = try arguments(for: archive, directory: directory, overwriteFiles: overwriteFiles)
        let output = Shell.run(.bash, arguments)
        if let error = output.error {
            throw error
        }
        let fileURLs = postProcess(for: archive, directory: directory, deleteArchiveWhenDone: deleteArchiveWhenDone, stdout: output.stdout)
        return fileURLs
    }

    internal static func postProcess(for archive: URL, directory: URL,
                                     deleteArchiveWhenDone: Bool = false, stdout: String) -> [URL]
    {
        let archivePath = archive.path
        let fileExtension = archive.pathExtension.lowercased()

        if deleteArchiveWhenDone {
            do {
                try FileManager.default.removeItem(atPath: archivePath)
            } catch {
                print("Could not remove archive, error: \(error)")
            }
        }

        var stdout = stdout
        if fileExtension == "zip" {
            stdout = Shell.run(.bash, ["unzip", "-l", archive.path]).stdout
        }
        let fileNames = extractFilenames(for: archive, stdout: stdout)
        let fileURLs = fileNames.compactMap { directory.appendingPathComponent($0) }
        return fileURLs
    }

    internal static func extractFilenames(for url: URL, stdout: String) -> [String] {
        let fileExtension = url.pathExtension
        switch fileExtension {
        case "gz":
            return []
        case "tar", "tar.gz", "tgz":
            return stdout.matches(regex: #"x \s*([^\n\r]*)"#).compactMap({$0.string})
        case "zip":
            return stdout.matches(regex: #"\d{2}-\d{2}-\d{4}\s+\d{2}:\d{2}\s+\s*([^\n\r]*)"#).compactMap({$0.string})
        default:
            return []
        }
    }

    internal static func arguments(for archive: URL, directory: URL, overwriteFiles: Bool) throws -> [String] {
        switch archive.pathExtension.lowercased() {
        case "gz":
            if overwriteFiles {
                return ["gunzip", archive.path]
            } else {
                return ["gunzip", "-k", archive.path]
            }
        case "tar":
            return ["tar", (overwriteFiles == true) ? "xfv" : "xfvk", archive.path, "-C", directory.path]
        case "tar.gz", "tgz":
            return ["tar", (overwriteFiles == true) ? "xzf" : "xzfk", archive.path, "-C", directory.path]
        case "zip":
            if overwriteFiles {
                return ["unzip", "-o", archive.path, "-d", directory.path]
            } else {
                return ["unzip", archive.path, "-d", directory.path]
            }
        default:
            throw Errors.unknownArchive
        }
    }
}

public extension Unarchiver {
    /// Extraction Errors.
    enum Errors: Error {
        /// An unknown archive format.
        case unknownArchive
        /// The archive doesn't exist.
        case archiveDoesntExist
        /// The destionationDirectory doesn't exist.
        case directoryDoesntExist
        /// Failed to extract the archive.
        case failedToExtract
    }
}

#endif
