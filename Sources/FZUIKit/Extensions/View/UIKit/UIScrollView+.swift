//
//  UIScrollView+.swift
//  
//
//  Created by Florian Zand on 30.08.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UIScrollView {
    /// Scale the content by the given amount and center the result on the given point.
    public func setZoomScale(_ scale: CGFloat, centeredAt point: CGPoint, animated: Bool = false) {
        if let view = delegate?.viewForZooming?(in: self) {
            setZoomScale(scale, center: convert(point, to: view), animated: animated)
        } else {
            let zoomFactor = 1.0 / zoomScale
            let scale = scale.clamped(to: minimumZoomScale...maximumZoomScale)
            let point = CGPoint(contentOffset.x * zoomFactor, contentOffset.y * zoomFactor)
            setZoomScale(scale, center: point, animated: animated)
        }
    }
    
    func setZoomScale(_ scale: CGFloat, center: CGPoint, animated: Bool) {
        var destinationRect: CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = center.x - (destinationRect.width / 2.0)
        destinationRect.origin.y = center.y - (destinationRect.height / 2.0)
        zoom(to: destinationRect, animated: animated)
    }
}

#endif
