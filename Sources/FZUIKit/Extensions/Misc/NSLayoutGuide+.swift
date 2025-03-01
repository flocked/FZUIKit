//
//  NSLayoutGuide+.swift
//
//
//  Created by Florian Zand on 01.03.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUILayoutGuide {
    /**
     Constrains the layout guide to its owning view's edges, with optional inset values, and returns an array of the constraints.

     - Parameter insets: The inset values to apply to the layout guide's edges relative to the owning view. Default is `.zero`.

     - Returns: The layout constraints that constrain the layout guide to the owning view's edges.  In the following order: `leading`, `bottom`, `trailing` and `top`.

     - Note: This method will assert if the guide is not yet added to a view. It constraints the layout guide to the view's edges, with the given insets for each side, and returns these constraints as an array.
     */
    @discardableResult
    public func constrainToOwningView(insets: NSUIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let view = owningView else {
            assertionFailure("The guide must be added to a view before constraining the layout guide.")
            return []
        }
        return [
            leftAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            rightAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
        ].activate()
    }
}

extension NSUIView {
    /**
     Constraits the view's frame to the specified layout guide.
     
     - Parameters:
        - guide: The layout guide to be constraint to.
        - mode: The mode for constraining the subview's frame.
     
     - Returns: The layout constraints in the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    func constraint(to guide: NSUILayoutGuide, insets: NSUIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        return [
            leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -insets.bottom),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: guide.topAnchor, constant: insets.top),
        ].activate()
    }
    
    /**
     Adds a layout guide to the view and constrains it to the view's edges with optional insets,  returning the created constraints.

     - Parameters:
        - guide: The `NSLayoutGuide` to add to the view.
        - insets: The inset values to apply to the layout guide's edges relative to the owning view. Default is `.zero`.
     
     - Returns: The layout constraints that constrain the layout guide to the view's edges.  In the following order: `leading`, `bottom`, `trailing` and `top`.
     */
    @discardableResult
    func addLayoutGuide(withConstraint guide: NSUILayoutGuide, insets: NSUIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        addLayoutGuide(guide)
        return guide.constrainToOwningView(insets: insets)
    }
}
#endif
