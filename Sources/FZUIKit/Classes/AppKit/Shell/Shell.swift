//
//  Shell.swift
//
//
//  Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
//

#if os(macOS)
    import Foundation
    import FZSwiftUtils

    public enum Shell {
        public enum ShellType: String {
            case bash
            case zsh
        }

        @discardableResult public static func run(_ executable: String, _ args: Any ..., combineOutput: Bool = false) -> RunOutput {
            mainContext.run(executable, args, combineOutput: combineOutput)
        }

        public static func runAsync(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncCommand {
            mainContext.runAsync(executable, args, file: file, line: line)
        }

        public static func runAsyncAndPrint(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> PrintedAsyncCommand {
            mainContext.runAsyncAndPrint(executable, args, file: file, line: line)
        }

        public static func runAndPrint(_ executable: String, _ args: Any ...) throws {
            try mainContext.runAndPrint(executable, args)
        }

        @discardableResult public static func run(_ type: ShellType, _ args: [String], combineOutput: Bool = false, atPath path: String? = nil) -> RunOutput {
            let args: [String] = "-c" + ((path != nil) ? ["cd \(path!.escapingSpaces) &&"] : []) + args.joined(separator: " ")
            return run("/bin/\(type.rawValue)", args, combineOutput: combineOutput)
        }

        public static func runAsync(_ type: ShellType, _ args: [String], file: String = #file, line: Int = #line, atPath path: String? = nil) -> AsyncCommand {
            let args: [String] = "-c" + ((path != nil) ? ["cd \(path!.escapingSpaces) &&"] : []) + args.joined(separator: " ")
            return runAsync("/bin/\(type.rawValue)", args, file: file, line: line)
        }

        public static func runAsyncAndPrint(_ type: ShellType, _ args: [String], file: String = #file, line: Int = #line, atPath path: String? = nil) -> PrintedAsyncCommand {
            let args: [String] = "-c" + ((path != nil) ? ["cd \(path!.escapingSpaces) &&"] : []) + args.joined(separator: " ")
            return runAsyncAndPrint("/bin/\(type.rawValue)", args, file: file, line: line)
        }

        public static func runAndPrint(_ type: ShellType, _ args: [String], atPath path: String? = nil) throws {
            let args: [String] = "-c" + ((path != nil) ? ["cd \(path!.escapingSpaces) &&"] : []) + args.joined(separator: " ")
            try runAndPrint("/bin/\(type.rawValue)", args)
        }
    }

    public extension Shell {
        @discardableResult static func run(_ type: ShellType, _ args: String..., combineOutput: Bool = false, atPath path: String? = nil) -> RunOutput {
            run(type, args, combineOutput: combineOutput, atPath: path)
        }

        static func runAsync(_ type: ShellType, _ args: String..., file: String = #file, line: Int = #line, atPath path: String? = nil) -> AsyncCommand {
            runAsync(type, args, file: file, line: line, atPath: path)
        }

        static func runAsyncAndPrint(_ type: ShellType, _ args: String..., file: String = #file, line: Int = #line, atPath _: String? = nil) -> PrintedAsyncCommand {
            runAsyncAndPrint(type, args, file: file, line: line)
        }

        static func runAndPrint(_ type: ShellType, _ args: String..., atPath path: String? = nil) throws {
            try runAndPrint(type, args, atPath: path)
        }
    }

    extension String {
        var escapingSpaces: String {
            replacingOccurrences(of: " ", with: "\\ ")
        }
    }
#endif
