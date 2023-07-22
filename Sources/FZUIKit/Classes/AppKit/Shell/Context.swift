//
//  Shell+Context.swift
//
//
//  Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
//

#if os(macOS)
import Foundation

public protocol ShellContext: CustomDebugStringConvertible {
    var env: [String: String] { get set }
    var stdin: ReadableStream { get set }
    var stdout: WritableStream { get set }
    var stderror: WritableStream { get set }

    /**
     The current working directory.

     Must be used instead of `run("cd", "...")` because all the `run` commands are executed in a
     separate process and changing the directory there will not affect the rest of the Swift script.
     */
    var currentdirectory: String { get set }
}

public extension ShellContext {
    /** A textual representation of this instance, suitable for debugging. */
    var debugDescription: String {
        var result = ""
        debugPrint("stdin:", stdin, "stdout:", stdout, "stderror:", stderror, "currentdirectory:", currentdirectory, to: &result)
        debugPrint("env:", env, to: &result)
        return result
    }
}

public struct CustomContext: ShellContext, CommandRunning {
    public var env: [String: String]
    public var stdin: ReadableStream
    public var stdout: WritableStream
    public var stderror: WritableStream

    /**
     The current working directory.

     Must be used instead of `run("cd", "...")` because all the `run` commands are executed in a
     separate process and changing the directory there will not affect the rest of the Swift script.
     */
    public var currentdirectory: String

    /** Creates a blank CustomContext where env and stdin are empty, stdout and stderror discard everything and
     currentdirectory is the current working directory. */
    public init() {
        let encoding = String.Encoding.utf8
        env = [String: String]()
        stdin = FileHandleStream(FileHandle.nullDevice, encoding: encoding)
        stdout = FileHandleStream(FileHandle.nullDevice, encoding: encoding)
        stderror = FileHandleStream(FileHandle.nullDevice, encoding: encoding)
        currentdirectory = mainContext.currentdirectory
    }

    /** Creates an identical copy of another Context. */
    public init(_ context: ShellContext) {
        env = context.env
        stdin = context.stdin
        stdout = context.stdout
        stderror = context.stderror
        currentdirectory = context.currentdirectory
    }
}

private func createTempdirectory() -> String {
    let name = URL(fileURLWithPath: mainContext.path).lastPathComponent
    let tempdirectory = URL(fileURLWithPath: NSTemporaryDirectory()) + (name + "-" + ProcessInfo.processInfo.globallyUniqueString)
    do {
        try FileManager.default.createDirectory(atPath: tempdirectory.path, withIntermediateDirectories: true, attributes: nil)
        return tempdirectory.path + "/"
    } catch let error as NSError {
        Swift.print("Could not create new temporary directory \(tempdirectory)", error)
    } catch {
        Swift.print("Unexpected error", error)
    }
    //  FileManager.default.temporaryDirectory
    return "/"
}

extension CommandLine {
    /** Workaround for nil crash in CommandLine.arguments when run in Xcode. */
    static var safeArguments: [String] {
        argc == 0 ? [] : arguments
    }
}

public final class MainContext: ShellContext, CommandRunning {
    /// The default character encoding used throughout SwiftShell.
    /// Only affects stdin, stdout and stderror if they have not been used yet.
    public var encoding = String.Encoding.utf8 // TODO: get encoding from environmental variable LC_CTYPE.

    public lazy var env = ProcessInfo.processInfo.environment as [String: String]
    public lazy var stdin: ReadableStream = FileHandleStream(FileHandle.standardInput, encoding: self.encoding)

    public lazy var stdout: WritableStream = {
        let stdout = StdoutStream.default
        stdout.encoding = self.encoding
        return stdout
    }()

    public lazy var stderror: WritableStream = FileHandleStream(FileHandle.standardError, encoding: self.encoding)

    /**
     The current working directory.

     Must be used instead of `run("cd", "...")` because all the `run` commands are executed in
     separate processes and changing the directory there will not affect the rest of the Swift script.

     This directory is also used as the base for relative URLs.
     */
    public var currentdirectory: String {
        get { return FileManager.default.currentDirectoryPath + "/" }
        set {
            if !FileManager.default.changeCurrentDirectoryPath(newValue) {
                Swift.print("Could not change the working directory to \(newValue)")
                //       exit(errormessage: "Could not change the working directory to \(newValue)")
            }
        }
    }

    /**
     The tempdirectory is unique each time a script is run and is created the first time it is used.
     It lies in the user's temporary directory and will be automatically deleted at some point.
     */
    public private(set) lazy var tempdirectory: String = createTempdirectory()

    /** The arguments this executable was launched with. Use main.path to get the path. */
    public private(set) lazy var arguments: [String] = Array(CommandLine.safeArguments.dropFirst())

    /** The path to the currently running executable. Will be empty in playgrounds. */
    public private(set) lazy var path: String = CommandLine.safeArguments.first ?? ""

    fileprivate init() {}
}

public let mainContext = MainContext()

internal func + (leftpath: URL, rightpath: String) -> URL {
    leftpath.appendingPathComponent(rightpath)
}
#endif
