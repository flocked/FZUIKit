//
//  NSUI Typealias.swift
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
    public typealias NSUICollectionLayoutSectionOrthogonalScrollingBehavior = NSCollectionLayoutSectionOrthogonalScrollingBehavior
    public typealias NSUIColor = NSColor
    public typealias NSUIEdgeInsets = NSEdgeInsets
    public typealias NSUIFont = NSFont
    public typealias NSUIFontDescriptor = NSFontDescriptor
    @available(macOS 11.0, *)
    public typealias NSUIFontTextStyle = NSFont.TextStyle
    public typealias NSUIImage = NSImage
    public typealias NSUIStoryboard = NSStoryboard
    public typealias NSUIView = NSView
    public typealias NSUITextField = NSTextField
    public typealias NSUISegmentedControl = NSSegmentedControl
    public typealias NSUINib = NSNib
    public typealias NSUIViewController = NSViewController
    public typealias NSUIHostingController = NSHostingController
    public typealias NSUIStackView = NSStackView
    public typealias NSUIRectCorner = NSRectCorner
    @available(macOS 11.0, *)
    public typealias NSUIImageSymbolScale = NSImage.SymbolScale
    @available(macOS 11.0, *)
    public typealias NSUIImageSymbolWeight = NSImage.SymbolWeight
    public typealias NSUILayoutGuide = NSLayoutGuide
    public typealias NSUICollectionViewItem = NSCollectionViewItem
    public typealias NSUILayoutPriority = NSLayoutConstraint.Priority
    public typealias NSUIUserInterfaceLayoutOrientation = NSUserInterfaceLayoutOrientation
    public typealias NSUIViewRepresentable = NSViewRepresentable
    public typealias NSUIResponder = NSResponder
    public typealias NSUIControl = NSControl
    public typealias NSUIImageView = NSImageView
    public typealias NSUIScrollView = NSScrollView
    public typealias NSUITextView = NSTextView
    public typealias NSUIScreen = NSScreen
    public typealias NSUIGestureRecognizer = NSGestureRecognizer
    public typealias NSUIMagnificationGestureRecognizer = NSMagnificationGestureRecognizer
    public typealias NSUIPanGestureRecognizer = NSPanGestureRecognizer
    public typealias NSUIButton = NSButton
    public typealias NSUIPasteboard = NSPasteboard

#elseif canImport(UIKit)
    import UIKit
    public typealias NSUIBezierPath = UIBezierPath
    public typealias NSUIColor = UIColor
    public typealias NSUIEdgeInsets = UIEdgeInsets
    public typealias NSUIFont = UIFont
    public typealias NSUIFontDescriptor = UIFontDescriptor
    public typealias NSUIFontTextStyle = UIFont.TextStyle
    public typealias NSUIImage = UIImage
    public typealias NSUIRectCorner = UIRectCorner
    public typealias NSUIImageSymbolScale = UIImage.SymbolScale
    public typealias NSUIImageSymbolWeight = UIImage.SymbolWeight
#endif

#if os(iOS) || os(tvOS)
    public typealias NSUICollectionView = UICollectionView
    public typealias NSUICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout
    public typealias NSUICollectionViewCompositionalLayoutConfiguration = UICollectionViewCompositionalLayoutConfiguration
    public typealias NSUICollectionViewDelegate = UICollectionViewDelegate
    public typealias NSUICollectionViewLayout = UICollectionViewLayout
    public typealias NSUICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes
    public typealias NSUICollectionLayoutSectionOrthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehavior
    public typealias NSUIView = UIView
    public typealias NSUISegmentedControl = UISegmentedControl
    public typealias NSUIStoryboard = UIStoryboard
    public typealias NSUINib = UINib
    public typealias NSUIViewController = UIViewController
    public typealias NSUIStackView = UIStackView
    public typealias NSUIHostingController = UIHostingController
    public typealias NSUILayoutGuide = UILayoutGuide
    public typealias NSUICollectionViewItem = UICollectionViewCell
    public typealias NSUILayoutPriority = UILayoutPriority
    public typealias NSUIUserInterfaceLayoutOrientation = NSLayoutConstraint.Axis
    public typealias NSUIViewRepresentable = UIViewRepresentable
    public typealias NSUIResponder = UIResponder
    public typealias NSUIControl = UIControl
    public typealias NSUIImageView = UIImageView
    public typealias NSUITextField = UITextField
    public typealias NSUIScrollView = UIScrollView
    public typealias NSUITextView = UITextView
    public typealias NSUIPanGestureRecognizer = UIPanGestureRecognizer
    public typealias NSUIScreen = UIScreen
    public typealias NSUIGestureRecognizer = UIGestureRecognizer
    public typealias NSUIButton = UIButton
    #if os(iOS)
    public typealias NSUIPasteboard = UIPasteboard
    public typealias NSUIMagnificationGestureRecognizer = UIPinchGestureRecognizer
    #endif
#endif
