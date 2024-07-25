//
//  UITableView+HeaderFooterRegistration.swift
//
//
//  Created by Florian Zand on 25.07.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UITableView {
    /**
     Dequeues a configured reusable reusable header or footer view object.
     
     - Parameters:
        - registration: The registration for configuring the header or footer view object. See ``HeaderFooterRegistration``.
        - indexPath: The index path that specifies the location of the header/footer view in the table view.
        - section: The section that provides data for the header/footer view.
     
     - Returns: A configured reusable header or footer view object.
     */
    public func dequeueConfiguredReusableHeaderFooterView<Cell, Section>(using registration: HeaderFooterRegistration<Cell, Section>, for indexPath: IndexPath, section: Section) -> Cell where Cell : UITableViewHeaderFooterView {
        return registration.makeView(for: self, indexPath: indexPath, section: section)
    }
        
    /// A registration for the table view’s header/footer views.
    public class HeaderFooterRegistration<Cell, Section> where Cell: UITableViewHeaderFooterView, Section: Hashable {
        
        /// A closure that handles the cell registration and configuration.
        public typealias Handler = (_ cell: Cell, _ indexPath: IndexPath, _ sectionIdentifier: Section) -> Void

        let nib: UINib?
        let handler: Handler
        let id = UUID().uuidString
        
        /// Creates a cell registration with the specified registration handler.
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
        }
        
        /// Creates a cell registration with the specified registration handler and nib file.
        public init(nib: UINib?, handler: @escaping Handler) {
            self.handler = handler
            self.nib = nib
        }
        
        func makeView(for tableView: UITableView, indexPath: IndexPath, section: Section) -> Cell {
            register(tableView)
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as! Cell
            handler(cell, indexPath, section)
            return cell
        }
        
        func register(_ tableView: UITableView) {
            if let nib = nib, tableView.registeredHeaderFooterNibs[id] == nil {
                tableView.register(nib, forCellReuseIdentifier: id)
            } else if tableView.registeredHeaderFooterClasses[id] == nil {
                tableView.register(Cell.self, forCellReuseIdentifier: id)
            }
        }
        
        func unregister(_ tableView: UITableView) {
            let any: AnyClass? = nil
            tableView.register(any, forCellReuseIdentifier: id)
        }
    }
}

#endif

