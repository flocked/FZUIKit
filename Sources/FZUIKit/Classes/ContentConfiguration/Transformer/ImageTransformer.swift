//
//  NSConfigurationImageTransformer.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension ContentConfiguration {
    struct ImageTransformer {
        /// The transform closure of the image transformer.
        public let transform: (NSUIImage) -> NSUIImage
        /// The identifier of the image transformer.
        public let id: String
        /**
         Calls the transform closure of the image transformer.

         Using this syntax, you can call the image transformer type as if it were a closure:
         ```
         let opacityImageTransformer: NSConfigurationImageTransformer = .opacity(0.3)
         let baseImage = NSImage(named: "MyImage")
         let modifiedImage = opacityImageTransformer(baseImage)
         ```
         */
        public func callAsFunction(_ input: NSUIImage) -> NSUIImage {
            return transform(input)
        }

        /**
         Calls the transform closure of the image transformer asynchronously.

         Using this syntax, you can call the image transformer type as if it were a closure:
         ```
         let opacityImageTransformer: NSConfigurationImageTransformer = .opacity(0.3)
         let baseImage = NSImage(named: "MyImage")
         let modifiedImage = await opacityImageTransformer(baseImage)
         ```
         */
        public func callAsFunction(_ input: NSUIImage) async -> NSUIImage {
            return await withCheckedContinuation { continuation in
                self(input) { image in
                    continuation.resume(returning: image)
                }
            }
        }

        /**
         Calls the transform closure of the image transformer asynchronously.

         Using this syntax, you can call the image transformer type as if it were a closure:
         ```
         let opacityImageTransformer: NSConfigurationImageTransformer = .opacity(0.3)
         let baseImage = NSImage(named: "MyImage")
         opacityImageTransformer(baseImage, completionHandler: { image in
            let modifiedImage = image
         }
         ```
         */
        public func callAsFunction(_ input: NSUIImage, completionHandler: @escaping ((NSUIImage) -> Void)) {
            DispatchQueue.global(qos: .userInteractive).async {
                let image = self.transform(input)
                completionHandler(image)
            }
        }

        /// Creates a image transformer with the specified closure.
        public init(_ transform: @escaping (NSUIImage) -> NSUIImage) {
            self.transform = transform
            id = UUID().uuidString
        }

        /// Creates a image transformer with the specified closure.
        public init(_ id: String, _ transform: @escaping (NSUIImage) -> NSUIImage) {
            self.transform = transform
            self.id = id
        }

        public static func opacity(_ value: CGFloat) -> Self {
            return Self("opacity: \(value)") { $0.opacity(value) }
        }

        public static func tintColor(_ color: NSUIColor) -> Self {
            return Self("tintColor: \(color)") { $0.withTintColor(color) }
        }

        public static func colorImage(_ color: NSUIColor) -> Self {
            return Self("tintColor: \(color)") { _ in NSUIImage(color: color) }
        }

        @available(macOS 10.15, iOS 15.0, *)
        public static func thumbnail(size: CGSize) -> Self {
            return Self("thumbnail: \(size)") { $0.preparingThumbnail(of: size) ?? $0 }
        }

        @available(macOS 10.15, iOS 15.0, *)
        public static var preparedForDisplay: Self {
            return Self("preparedForDisplay") { $0.preparingForDisplay() ?? $0 }
        }

        public static func roundedCorners(radius: CGFloat) -> Self {
            return Self("roundedCorners: \(radius)") { $0.roundedCorners(radius: radius) }
        }

        public static var rounded: Self {
            return Self("rounded") { $0.rounded() }
        }

        public static func rotated(degree: Float) -> Self {
            return Self("rotated: \(degree)") { $0.rotated(degrees: degree) }
        }

        @available(macOS 11.0, iOS 14.0, *)
        public static func symbolConfiguration(_ value: NSUIImage.SymbolConfiguration) -> Self {
            #if os(macOS)
            return Self { $0.withSymbolConfiguration(value) ?? $0 }
            #elseif canImport(UIKit)
            return Self { $0.applyingSymbolConfiguration(value) ?? $0 }
            #endif
        }

        public static func resized(to size: CGSize) -> Self {
            #if os(macOS)
            return Self("resizedTo: \(size)") { $0.resized(to: size) }
            #elseif canImport(UIKit)
            return Self("resizedTo: \(size)") { $0.resized(to: size) ?? $0 }
            #endif
        }

        public static func resized(toFit size: CGSize) -> Self {
            #if os(macOS)
            return Self("resizedToFit: \(size)") { $0.resized(toFit: size) }
            #elseif canImport(UIKit)
            return Self("resizedToFit: \(size)") { $0.resized(toFit: size) ?? $0 }
            #endif
        }

        public static func resized(toFill size: CGSize) -> Self {
            #if os(macOS)
            return Self("resizedToFill: \(size)") { $0.resized(toFill: size) }
            #elseif canImport(UIKit)
            return Self("resizedToFill: \(size)") { $0.resized(toFill: size) ?? $0 }
            #endif
        }
    }
}

extension ContentConfiguration.ImageTransformer: Hashable {
    public static func == (lhs: ContentConfiguration.ImageTransformer, rhs: ContentConfiguration.ImageTransformer) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
