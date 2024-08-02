//
//  NSHostingConfiguration.swift
//
//
//  Created by Florian Zand on 01.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
    import SwiftUI
    /**
     A content configuration suitable for hosting a hierarchy of SwiftUI views.

     Use a value of this type, which conforms to the NSContentConfiguration protocol, with a NSCollectionViewItem or NSTableCellView to host a hierarchy of SwiftUI views in a collection or table view, respectively. For example, the following shows a stack with an image and text inside the cell:

     ```swift
     myItem.contentConfiguration = NSHostingConfiguration {
         HStack {
             Image(systemName: "star").foregroundStyle(.purple)
             Text("Favorites")
             Spacer()
         }
     }
     ```

     You can also customize the background of the containing item. The following example draws a blue background:

     ```swift
     myItem.contentConfiguration = NSHostingConfiguration {
         HStack {
             Image(systemName: "star").foregroundStyle(.purple)
             Text("Favorites")
             Spacer()
         }
     }
     .background {
         Color.blue
     }
     ```
     */
    public struct NSHostingConfiguration<Content, Background>: NSContentConfiguration where Content: View, Background: View {
        let content: Content
        let background: Background
        var margins: NSDirectionalEdgeInsets = .zero
        var minWidth: CGFloat? = nil
        var minHeight: CGFloat? = nil

        /**
         Creates a hosting configuration with the given contents.

         - Parameter content: The contents of the SwiftUI hierarchy to be shown inside the view.
         */
        public init(@ViewBuilder content: () -> Content) where Background == EmptyView {
            self.content = content()
            self.background = EmptyView()
        }

        init(content: Content, background: Background, margins: NSDirectionalEdgeInsets, minWidth: CGFloat?, minHeight: CGFloat?) {
            self.content = content
            self.background = background
            self.margins = margins
            self.minWidth = minWidth
            self.minHeight = minHeight
        }
        

        /**
         Sets the background contents for the hosting configuration’s enclosing cell.

         The following example sets a custom view to the background of the cell:

         ```swift
         NSHostingConfiguration {
             Text("My Contents")
         }
         .background(Color.blue)
         ```

         - Parameter style: The shape style to be used as the background of the cell.
         */
        public func background<S>(_ style: S) -> NSHostingConfiguration<Content, _NSHostingConfigurationBackgroundView<S>> where S: ShapeStyle {
            NSHostingConfiguration<Content, _NSHostingConfigurationBackgroundView<S>>(
                content: content,
                background: .init(style: style),
                margins: margins,
                minWidth: minWidth,
                minHeight: minHeight
            )
        }

        /**
         Sets the background contents for the hosting configuration’s enclosing cell.

         The following example sets a custom view to the background of the cell:

         ```swift
         NSHostingConfiguration {
             Text("My Contents")
         }
         .background {
             MyBackgroundView()
         }
         ```

         - Parameter background: The contents of the SwiftUI hierarchy to be shown inside the background of the cell.
         */
        public func background<B>(@ViewBuilder content: () -> B) -> NSHostingConfiguration<Content, B> where B: View {
            NSHostingConfiguration<Content, B>(
                content: self.content,
                background: content(),
                margins: margins,
                minWidth: minWidth,
                minHeight: minHeight
            )
        }

        /**
         Sets the margins around the content of the configuration.

         Use this modifier to set the default margins applied to the root of the configuration. The following example creates 10 points of space between the content and the background on the leading edge and 20 points of space on the trailing edge:

         ```swift
         NSHostingConfiguration {
             Text("My Contents")
         }
         .margins(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
         ```

         - Parameters:
            - edges: The edges to apply the insets. Any edges not specified will use the system default values.
            - insets: The insets to apply.
         */
        public func margins(_ edges: Edge.Set = .all, _ insets: EdgeInsets) -> NSHostingConfiguration<Content, Background> {
            var configuration = self
            configuration.margins.top = edges.contains(.top) ? insets.top : 0
            configuration.margins.leading = edges.contains(.leading) ? insets.leading : 0
            configuration.margins.bottom = edges.contains(.bottom) ? insets.bottom : 0
            configuration.margins.trailing = edges.contains(.trailing) ? insets.trailing : 0
            return configuration
        }

        /**
         Sets the margins around the content of the configuration.

         Use this modifier to set the default margins applied to the content of the configuration. The following example creates 20 points of space between the content and the background on the horizontal edges.

         ```swift
         NSHostingConfiguration {
             Text("My Contents")
         }
         .margins(.horizontal, 20.0)
         ```

         - Parameters:
            - edges: The edges to apply the insets. Any edges not specified will use the system default values.
            - length: The amount to apply.
         */
        public func margins(_ edges: Edge.Set = .all, _ length: CGFloat) -> NSHostingConfiguration<Content, Background> {
            margins(edges, EdgeInsets(length))
        }

        /**
         Sets the minimum size for the configuration.

         Use this modifier to indicate that a configuration’s associated cell can be resized to a specific minimum. The following example allows the cell to be compressed to zero size:

         ```swift
         NSHostingConfiguration {
             Text("My Contents")
         }
         .minSize(width: 0, height: 0)
         ```

         - Parameters:
            - width: The value to use for the width dimension. A value of nil indicates that the system default should be used.
            - height: The value to use for the height dimension. A value of nil indicates that the system default should be used.
         */
        public func minSize(width: CGFloat? = nil, height: CGFloat? = nil) -> NSHostingConfiguration<Content, Background> {
            var configuration = self
            configuration.minWidth = width
            configuration.minHeight = height
            return configuration
        }
        
        @available(macOS 13.0, *)
        /// The options for how the content view creates and updates constraints based on the size of its `SwiftUI content.
        public var sizingOptions: NSHostingSizingOptions {
            get { _sizingOptions as? NSHostingSizingOptions ?? .standardBounds }
            set { _sizingOptions = newValue }
        }
        
        var _sizingOptions: Any? = nil

        public func updated(for _: NSConfigurationState) -> NSHostingConfiguration {
            self
        }

        public func makeContentView() -> NSView & NSContentView {
            NSHostingContentView<Content, Background>(configuration: self)
        }
    }

#endif
