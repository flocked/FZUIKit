//
//  DockTile.swift
//
//
//  Created by Florian Zand on 01.11.23.
//

/*
 #if os(macOS)
 import AppKit

 public class DockTile {
     internal var dockTile: NSDockTile {
         NSApp.dockTile
     }

     /// The badge label of the string.
     public var badgeLabel: String? {
         get { dockTile.badgeLabel }
         set { dockTile.badgeLabel = newValue }
     }

     /// Sets the badge label of the string.
     @discardableResult
     public func badgeLabel(_ label: String?) -> Self {
         self.badgeLabel = label
         return self
     }

     public func display() {
         if dockTile.contentView != nil {
             dockTile.contentView = nil
         }
         dockTile.display()
     }
 }

 extension DockTile {
     public class BaseTile {
         internal var dockTile: NSDockTile {
             NSApp.dockTile
         }

         /// The badge label of the string.
         public var badgeLabel: String? {
             get { dockTile.badgeLabel }
             set { dockTile.badgeLabel = newValue }
         }

         /// Sets the badge label of the string.
         @discardableResult
         public func badgeLabel(_ label: String?) -> Self {
             self.badgeLabel = label
             return self
         }

         public func display() {
             if dockTile.contentView != nil {
                 dockTile.contentView = nil
             }
             dockTile.display()
         }
     }
 }

 extension DockTile {
     public class ContentConfiguration: BaseTile {
         internal var view: ContentDisplayView

         public var configuration: NSContentConfiguration {
             get { view.configuration }
             set { view.configuration = newValue }
         }

         @discardableResult
         public func configuration(_ configuration: NSContentConfiguration) -> Self {
             self.configuration = configuration
             return self
         }

         public init(_ configuration: NSContentConfiguration) {
             view = ContentDisplayView(configuration: configuration)
         }

         public override func display() {
             if dockTile.contentView != view {
                 dockTile.contentView = view
             }
             dockTile.display()
         }

         internal class ContentDisplayView: NSView {
             /// The current configuration of the view.
             public var configuration: NSContentConfiguration {
                 didSet {
                     updateConfiguration()
                 }
             }

             var contentView: (NSView & NSContentView)? = nil

             func updateConfiguration() {
                 if contentView?.supports(configuration) == true {
                     contentView?.configuration = configuration
                 } else {
                     contentView?.removeFromSuperview()
                     contentView = configuration.makeContentView()
                     self.addSubview(withConstraint: contentView!)
                 }
             }

             init(configuration: NSContentConfiguration) {
                 self.configuration = configuration
                 super.init(frame: .zero)
                 updateConfiguration()
             }

             required init?(coder: NSCoder) {
                 fatalError("init(coder:) has not been implemented")
             }
         }
     }
 }

 #endif
 */
