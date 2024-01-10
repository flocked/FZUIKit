//
//  Shell+.swift
//
//
//  Created by Florian Zand on 24.02.23.
//

#if os(macOS)
    import Foundation
    import FZSwiftUtils

    public extension Shell {
        static func totalSize(for path: String) -> DataSize? {
            let result = Shell.run(.bash, "du", "-s", "-k", atPath: path)
            if let first = result.stdout.split(separator: "\t").first, let kBytes = Int(first) {
                let bytes = kBytes * 1024
                return DataSize(bytes)
            }
            return nil
        }
    }
#endif
