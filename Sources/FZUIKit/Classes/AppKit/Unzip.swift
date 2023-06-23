//
//  File.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public enum Unarchiver {
    public static let supportedFileExtensions: [String] = ["zip", "tar", "tar.gz", "tgz", "gz"]

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

    public static func extractArchive(_ archive: URL, to directory: URL? = nil, overwriteFiles: Bool = false, deleteArchiveWhenDone: Bool = false) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: archive.path) else {
            throw Errors.archiveDoesntExist
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
    enum Errors: Error {
        case unknownArchive
        case archiveDoesntExist
        case failedToExtract
    }
}

#endif
