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
public typealias NSUICollectionViewLayout = NSCollectionViewLayout
public typealias NSUICollectionViewLayoutAttributes = NSCollectionViewLayoutAttributes
public typealias NSUICollectionLayoutSectionOrthogonalScrollingBehavior = NSCollectionLayoutSectionOrthogonalScrollingBehavior
public typealias NSUIColor = NSColor
public typealias NSUIEdgeInsets = NSEdgeInsets
public typealias NSUIFont = NSFont
public typealias NSUIFontDescriptor = NSFontDescriptor
public typealias NSUIImage = NSImage
public typealias NSUIStoryboard = NSStoryboard
public typealias NSUIView = NSView
public typealias NSUITextField = NSTextField
public typealias NSUINib = NSNib
public typealias NSUIViewController = NSViewController
public typealias NSUIHostingController = NSHostingController
public typealias NSUIStackView = NSStackView
public typealias NSUILayoutGuide = NSLayoutGuide
public typealias NSUILayoutPriority = NSLayoutConstraint.Priority
public typealias NSUIUserInterfaceLayoutOrientation = NSUserInterfaceLayoutOrientation
public typealias NSUIViewRepresentable = NSViewRepresentable
public typealias NSUIResponder = NSResponder
public typealias NSUIImageView = NSImageView
public typealias NSUITextView = NSTextView
public typealias NSUIGestureRecognizer = NSGestureRecognizer
public typealias NSUIMagnificationGestureRecognizer = NSMagnificationGestureRecognizer
public typealias NSUIPanGestureRecognizer = NSPanGestureRecognizer
public typealias NSUIButton = NSButton
public typealias NSUICollectionViewLayoutInvalidationContext = NSCollectionViewLayoutInvalidationContext
public typealias NSUIControl = NSControl
public typealias NSUIVisualEffectView = NSVisualEffectView
public typealias NSUISymbolWeight = NSFont.Weight
public typealias NSUICollectionViewFlowLayout = NSCollectionViewFlowLayout
@available(macOS 10.15.1, *)
public typealias NSUICollectionViewDiffableDataSource = NSCollectionViewDiffableDataSource
@available(macOS 11.0, *)
public typealias NSUITableViewDiffableDataSource = NSTableViewDiffableDataSource
public typealias NSUICollectionViewUpdateItem = NSCollectionViewUpdateItem
public typealias NSUICollectionViewDelegateFlowLayout = NSCollectionViewDelegateFlowLayout
public typealias NSUIViewProtocol = NSViewProtocol
#elseif canImport(UIKit)
import UIKit
public typealias NSUIBezierPath = UIBezierPath
public typealias NSUIColor = UIColor
public typealias NSUIEdgeInsets = UIEdgeInsets
public typealias NSUIFont = UIFont
public typealias NSUIFontDescriptor = UIFontDescriptor
public typealias NSUIImage = UIImage
public typealias NSUISymbolWeight = UIImage.SymbolWeight
#endif

#if os(iOS) || os(tvOS)
public typealias NSUICollectionView = UICollectionView
public typealias NSUICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout
public typealias NSUICollectionViewCompositionalLayoutConfiguration = UICollectionViewCompositionalLayoutConfiguration
public typealias NSUICollectionViewLayout = UICollectionViewLayout
public typealias NSUICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes
public typealias NSUICollectionLayoutSectionOrthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehavior
public typealias NSUIView = UIView
public typealias NSUIViewProtocol = UIViewProtocol
public typealias NSUIStoryboard = UIStoryboard
public typealias NSUINib = UINib
public typealias NSUIViewController = UIViewController
public typealias NSUIStackView = UIStackView
public typealias NSUIHostingController = UIHostingController
public typealias NSUILayoutGuide = UILayoutGuide
public typealias NSUILayoutPriority = UILayoutPriority
public typealias NSUIUserInterfaceLayoutOrientation = NSLayoutConstraint.Axis
public typealias NSUIViewRepresentable = UIViewRepresentable
public typealias NSUIResponder = UIResponder
public typealias NSUIImageView = UIImageView
public typealias NSUITextField = UITextField
public typealias NSUITextView = UITextView
public typealias NSUIPanGestureRecognizer = UIPanGestureRecognizer
public typealias NSUIGestureRecognizer = UIGestureRecognizer
public typealias NSUIButton = UIButton
#if os(iOS)
public typealias NSUIMagnificationGestureRecognizer = UIPinchGestureRecognizer
#endif
public typealias NSUICollectionViewLayoutInvalidationContext = UICollectionViewLayoutInvalidationContext
public typealias NSUIControl = UIControl
public typealias NSUIVisualEffectView = UIVisualEffectView
public typealias NSUICollectionViewFlowLayout = UICollectionViewFlowLayout
public typealias NSUICollectionViewDiffableDataSource = UICollectionViewDiffableDataSource
public typealias NSUITableViewDiffableDataSource = UITableViewDiffableDataSource
public typealias NSUICollectionViewUpdateItem = UICollectionViewUpdateItem
public typealias NSUICollectionViewDelegateFlowLayout = UICollectionViewDelegateFlowLayout
#endif
