//
//  File.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import SwiftUI

#if os(macOS)
    import AppKit
    public typealias NSUIBezierPath = NSBezierPath
    public typealias NSUICollectionView = NSCollectionView
    public typealias NSUICollectionViewCompositionalLayout = NSCollectionViewCompositionalLayout
    public typealias NSUICollectionViewCompositionalLayoutConfiguration = NSCollectionViewCompositionalLayoutConfiguration
    public typealias NSUICollectionViewDelegate = NSCollectionViewDelegate
    public typealias NSUICollectionViewLayout = NSCollectionViewLayout
    public typealias NSUICollectionViewLayoutAttributes = NSCollectionViewLayoutAttributes
    public typealias NSUIColor = NSColor
    public typealias NSUIConfigurationColorTransformer = NSConfigurationColorTransformer
    public typealias NSUIEdgeInsets = NSEdgeInsets
    public typealias NSUIFont = NSFont
    public typealias NSUIFontDescriptor = NSFontDescriptor
    @available(macOS 11.0, *)
    public typealias NSUIFontTextStyle = NSFont.TextStyle
    public typealias NSUIImage = NSImage
    public typealias NSUIStoryboard = NSStoryboard
    public typealias NSUIView = NSView
    public typealias NSUISegmentedControl = NSSegmentedControl
    public typealias NSUINib = NSNib
    public typealias NSUIViewController = NSViewController
    public typealias NSUIHostingController = NSHostingController
    public typealias NSUIStackView = NSStackView
    public typealias NSUIRectCorner = NSRectCorner
    @available(macOS 11.0, *)
    public typealias NSUIImageSymbolConfiguration = NSImage.SymbolConfiguration
    @available(macOS 11.0, *)
    public typealias NSUIImageSymbolScale = NSImage.SymbolScale
    @available(macOS 11.0, *)
    public typealias NSUIImageSymbolWeight = NSImage.SymbolWeight
    public typealias NSUILayoutGuide = NSLayoutGuide
    public typealias NSUICollectionViewItem = NSCollectionViewItem
#elseif canImport(UIKit)
    import UIKit
    public typealias NSUIBezierPath = UIBezierPath
    public typealias NSUICollectionView = UICollectionView
    public typealias NSUICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout
    public typealias NSUICollectionViewCompositionalLayoutConfiguration = UICollectionViewCompositionalLayoutConfiguration
    public typealias NSUICollectionViewDelegate = UICollectionViewDelegate
    public typealias NSUICollectionViewLayout = UICollectionViewLayout
    public typealias NSUICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes
    public typealias NSUIColor = UIColor
    @available(iOS 14.0, *)
    public typealias NSUIConfigurationColorTransformer = HashableUIConfigurationColorTransformer
    public typealias NSUIEdgeInsets = UIEdgeInsets
    public typealias NSUIFont = UIFont
    public typealias NSUIFontDescriptor = UIFontDescriptor
    public typealias NSUIFontTextStyle = UIFont.TextStyle
    public typealias NSUIImage = UIImage
    public typealias NSUIView = UIView
    public typealias NSUISegmentedControl = UISegmentedControl
    public typealias NSUIStoryboard = UIStoryboard
    public typealias NSUINib = UINib
    public typealias NSUIViewController = UIViewController
    public typealias NSUIStackView = UIStackView
    public typealias NSUIHostingController = UIHostingController
    public typealias NSUIRectCorner = UIRectCorner
    public typealias NSUIImageSymbolConfiguration = UIImage.SymbolConfiguration
    public typealias NSUIImageSymbolScale = UIImage.SymbolScale
    public typealias NSUIImageSymbolWeight = UIImage.SymbolWeight
    public typealias NSUILayoutGuide = UILayoutGuide
    public typealias NSUICollectionViewItem = UICollectionViewCell
#endif
