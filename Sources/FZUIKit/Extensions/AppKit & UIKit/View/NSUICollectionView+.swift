//
//  NSUICollectionView+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUICollectionView {
    enum ElementKind {
        public static let itemTopSeperator: String = "ElementKindItemTopSeperator"
        public static let itemBottomSeperator: String = "ElementKindBottomSeperator"
        public static let itemBackground: String = "ElementKindItemBackground"
        public static let groupBackground: String = "ElementKindGroumBackground"
        public static let sectionBackground: String = "ElementKindSectionBackground"
        public static var sectionHeader: String {
            return NSUICollectionView.elementKindSectionHeader
        }
        
        public static var sectionFooter: String {
            return NSUICollectionView.elementKindSectionFooter
        }
    }
}
