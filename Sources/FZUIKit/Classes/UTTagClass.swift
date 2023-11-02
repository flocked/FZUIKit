import Foundation
import CoreServices
import UniformTypeIdentifiers

    /**
     A type representing tag classes.

     A tag class is a "kind" of label that describes a type in another type
     system, such as a filename extension or MIME type. A tag is a specific
     instance of a tag class: for example, `"txt"` is a tag, and that tag is an
     instance of the tag class `.filenameExtension` that represents the
     same type as `UTType.plainText`.

     Older API that does not use `UTTagClass` typically uses an untyped `String`
     or `CFString` to refer to a tag class as a string. To get the string
     representation of a tag class, use its `rawValue` property.
     */
@available(macOS, deprecated: 11.0, message: "macOS 14 provides UTType")
@available(watchOS, deprecated: 7.0, message: "watchOS 7 provides UTType")
@available(iOS, deprecated:14.0, message: "iOS 14 provides UTType")
@available(tvOS, deprecated: 14.0, message: "tvOS 14 provides UTType")
    public struct UTTagClass: RawRepresentable, Codable, Hashable, CustomStringConvertible, CustomDebugStringConvertible, Sendable {
        public var rawValue: String
        public var description: String { rawValue }
        public var debugDescription: String {
            String(describing: self)
        }
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /**
         The tag class for filename extensions such as `"txt"`.

         The leading period character is not part of the filename extension and
         should not be included in the tag.

         The raw value of this tag class is `"public.filename-extension"`.
         */
        public static var filenameExtension: Self {
            .init(rawValue: String(kUTTagClassFilenameExtension))
        }

        /**
         The tag class for MIME types such as `"text/plain"`.

         The raw value of this tag class is `"public.mime-type"`.
         */
        public static var mimeType: Self {
            .init(rawValue: String(kUTTagClassMIMEType))
        }
    }

