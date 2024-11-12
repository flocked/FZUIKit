//
//  NSView+SystemLayoutSizeFitting.swift
//
//
//  Created by Florian Zand on 11.11.24.
//

#if os(macOS)

import AppKit

extension NSView {
    /**
     Returns the optimal size of the view based on its current constraints.
     
     This method returns a size value for the view that optimally satisfies the view's current constraints and is as close to the value in the targetSize parameter as possible. This method does not actually change the size of the view.
     
     - Parameter targetSize: The size that you prefer for the view. To obtain a view that is as small as possible, specify the constant layoutFittingCompressedSize. To obtain a view that is as large as possible, specify the constant layoutFittingExpandedSize.
     
     - Returns: The optimal size for the view.
     */
    public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        _systemLayoutSizeFitting(targetSize)
    }
    
    /**
     Returns the optimal size of the view based on its constraints and the specified fitting priorities.
     
     Use this method when you want to prioritize the view's constraints when determining the best possible size of the view. This method does not actually change the size of the view.
     
     - Parameters:
        - targetSize: The size that you prefer for the view. To obtain a view that is as small as possible, specify the constant layoutFittingCompressedSize. To obtain a view that is as large as possible, specify the constant layoutFittingExpandedSize.
        - horizontalFittingPriority: The priority for horizontal constraints. Specify fittingSizeLevel to get a width that is as close as possible to the width value of targetSize.
        - verticalFittingPriority: The priority for vertical constraints. Specify fittingSizeLevel to get a height that is as close as possible to the height value of targetSize.
     - Returns: The optimal size for the view based on the provided constraint priorities.

     */
    public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: NSLayoutConstraint.Priority, verticalFittingPriority: NSLayoutConstraint.Priority) -> CGSize {
      _systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    
    private func _systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: NSLayoutConstraint.Priority? = nil, verticalFittingPriority: NSLayoutConstraint.Priority? = nil) -> CGSize {
        var sizeConstraints: [NSLayoutConstraint] = []

        translatesAutoresizingMaskIntoConstraints = false
        
        if targetSize.width > 0 {
            let widthConstraint = widthAnchor.constraint(equalToConstant: targetSize.width)
            if let horizontalFittingPriority = horizontalFittingPriority {
                widthConstraint.priority = horizontalFittingPriority
            }
            sizeConstraints.append(widthConstraint)
        }
        
        if targetSize.height > 0 {
            let heightConstraint = heightAnchor.constraint(equalToConstant: targetSize.height)
            if let verticalFittingPriority = verticalFittingPriority {
                heightConstraint.priority = verticalFittingPriority
            }
            sizeConstraints.append(heightConstraint)
        }
        
        sizeConstraints.activate()
        layoutSubtreeIfNeeded()
        let fittingSize = fittingSize
        sizeConstraints.activate(false)
        
        return fittingSize
    }
    
    /// The option to use the smallest possible size.
    public static let layoutFittingCompressedSize = CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    
    /// The option to use the largest possible size.
    public static let layoutFittingExpandedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
}


#endif
