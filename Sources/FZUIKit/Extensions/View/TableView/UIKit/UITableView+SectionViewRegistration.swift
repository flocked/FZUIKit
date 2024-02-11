//
//  SectionViewRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

public extension UITableView {
    /**
     A registration for the table view’s section header or footer views.

     Use a section view registration to register views with your table view and configure each view for display. You create a section view registration with your view type and section type as the registration’s generic parameters, passing in a registration handler to configure the view. In the registration handler, you specify how to configure the content and appearance of that type of view.

     The following example creates a section view registration for views of type `UITableViewHeaderFooterView`. Each section header views default content configuration text displays its string.

     ```swift
     let sectionViewRegistration = UITableView.SectionViewRegistration<UITableViewHeaderFooterView, String> {
     sectionView, indexPath, string in
     
        var configuration = sectionView.defaultContentConfiguration()
        configuration.text = string
        sectionView.contentConfiguration = configuration
     }
     ```

     After you create a section view registration, you pass it in to ``UIKit/UITableView/dequeueConfiguredReusableSectionView(using:section:)``, which you call from your data source’s section header view provider.

     ```swift
     dataSource.headerViewProvider = { tableView, section in
        return tableView.dequeueConfiguredReusableSectionView(using: sectionViewRegistration, section: section)
     }
     ```
     */
    struct SectionViewRegistration<SectionView, Section> where SectionView: UITableViewHeaderFooterView {
        let identifier: String
        let nib: UINib?
        let handler: Handler

        // MARK: Creating a section view registration

        /**
         Creates a section view registration with the specified registration handler.

         - Parameters:
            - handler: The handler to configurate the view.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            nib = nil
            identifier = UUID().uuidString
        }

        /**
         Creates a section view registration with the specified registration handler and nib file.

         - Parameters:
            - nib: The nib of the view.
            - handler: The handler to configurate the view.
         */
        public init(nib: UINib, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            identifier = UUID().uuidString
        }

        /// A closure that handles the section view registration and configuration.
        public typealias Handler = (_ sectionView: SectionView, _ section: Section) -> Void
        
        func makeView(_ tableView: UITableView, _ section: Section) -> SectionView {
             let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? SectionView ?? SectionView()
            handler(view, section)
            return view
        }
        
        func register(_ tableView: UITableView) {
            if tableView.registeredSectionViewIdentifiers.contains(identifier) == false {
                if let nib = nib {
                    tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
                } else {
                    tableView.register(SectionView.self, forHeaderFooterViewReuseIdentifier: identifier)
                }
            }
        }
    }
}

extension UITableView {
    /**
     Dequeues a configured reusable header or footer view object.

     - Parameters:
        - registration: The section view registration for configuring the section header or footer view object. See ``UIKit/UITableView/SectionViewRegistration``.
        - row: The index path specifying the row of the section view. The data source receives this information when it is asked for the section view and should just pass it along. This method uses the row to perform additional configuration based on the section view’s position in the table view.
        - section: The section item that provides data for the section view.

     - Returns: A configured reusable section view object.
     */
    public func dequeueConfiguredReusableSectionView<SectionView, Section>(using registration: SectionViewRegistration<SectionView, Section>, section: Section) -> SectionView {
        registration.makeView(self, section)
    }
}

extension UITableView {
    var registeredSectionViewIdentifiers: [String] {
        get { getAssociatedValue(key: "registeredSectionViewIdentifiers", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "registeredSectionViewIdentifiers", object: self) }
    }
}
#endif
