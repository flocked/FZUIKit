//
//  ContentConfiguration+Size.swift
//
//
//  Created by Florian Zand on 09.09.22.
//

import CoreGraphics
import Foundation

/*
 protocol SizeProperty {
     func apply(to size: CGSize) -> CGSize
 }

 extension CGSize: SizeProperty {
     func apply(to size: CGSize) -> CGSize {
         return self
     }
 }
 */

public extension ContentConfiguration {
    struct Resize: Hashable {
        internal var option: SizeOption = .size
        public var value: CGSize
        public var resizing: Option = .resizing

        internal init(value: CGSize, resizeBy option: Option) {
            self.option = .size
            self.value = value
            resizing = option
        }

        internal init(option: SizeOption, value: CGSize, resizing: Option) {
            self.option = option
            self.value = value
            self.resizing = resizing
        }

        public static func min(size: CGSize, resizing option: Option) -> Self {
            return self.init(option: .min, value: size, resizing: option)
        }

        public static func min(width: CGFloat, resizing option: Option) -> Self {
            return self.init(option: .min, value: CGSize(width: width, height: .infinity), resizing: option)
        }

        public static func min(height: CGFloat, resizing option: Option) -> Self {
            return self.init(option: .min, value: CGSize(width: .infinity, height: height), resizing: option)
        }

        public static func max(size: CGSize, resizing option: Option) -> Self {
            return self.init(option: .max, value: size, resizing: option)
        }

        public static func max(width: CGFloat, resizing option: Option) -> Self {
            return self.init(option: .max, value: CGSize(width: width, height: .infinity), resizing: option)
        }

        public static func max(height: CGFloat, resizing option: Option) -> Self {
            return self.init(option: .max, value: CGSize(width: .infinity, height: height), resizing: option)
        }

        public static func size(_ size: CGSize, resizing option: Option) -> Self {
            return self.init(option: .size, value: size, resizing: option)
        }

        public static func size(width: CGFloat, resizing option: Option) -> Self {
            return self.init(option: .size, value: CGSize(width: width, height: .infinity), resizing: option)
        }

        public static func size(height: CGFloat, resizing option: Option) -> Self {
            return self.init(option: .size, value: CGSize(width: .infinity, height: height), resizing: option)
        }

        internal enum SizeOption: Hashable {
            case min
            case max
            case size
        }

        public enum SizeValue: Hashable {
            case size(CGSize)
            case width(CGFloat)
            case height(CGFloat)
        }

        public enum Option: Hashable {
            case scaledToFill
            case scaledToFit
            case scaledToFitWidth
            case scaledToFitHeight
            case resizing
        }
    }
}

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIView {
    func configurate(using sizeProperty: ContentConfiguration.Resize) {
        var size = sizeProperty.value
        if size.width == .infinity {
            size.width = frame.width
        }
        if size.height == .infinity {
            size.height = frame.height
        }

        var shouldResize = false
        switch sizeProperty.option {
        case .min:
            shouldResize = (frame.size.width < size.width || frame.size.height < size.height)
        case .max:
            shouldResize = (frame.size.width > size.width || frame.size.height > size.height)
        case .size:
            shouldResize = true
        }

        if shouldResize == true {
            switch sizeProperty.resizing {
            case .scaledToFill:
                frame = frame.scaled(toFill: size)
            case .scaledToFit:
                frame = frame.scaled(toFit: size)
            case .resizing:
                frame = frame.scaled(toFit: size)
            case .scaledToFitWidth:
                frame = frame.scaled(toWidth: size.width)
            case .scaledToFitHeight:
                frame = frame.scaled(toHeight: size.height)
            }
        }
    }
}
