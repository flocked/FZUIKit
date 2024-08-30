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
            setZoomScale(scale, centeredAt: point, animated: animated, view: view)
        } else {
            let zoomFactor = 1.0 / zoomScale
            let scale = scale.clamped(to: minimumZoomScale...maximumZoomScale)
            let point = CGPoint(contentOffset.x * zoomFactor, contentOffset.y * zoomFactor)
            
            var destinationRect: CGRect = .zero
            destinationRect.size.width = frame.width / scale
            destinationRect.size.height = frame.height / scale
            destinationRect.origin.x = point.x - destinationRect.width * 0.5
            destinationRect.origin.y = point.y - destinationRect.height * 0.5
            
            zoom(to: destinationRect, animated: animated)
        }
    }
    
    func setZoomScale(_ scale: CGFloat, centeredAt point: CGPoint, animated: Bool, view: UIView) {
        let contentCenter = convert(point, to: view)

        let visibleWidth = frame.width / scale
        let visibleHeight = frame.height / scale

        let leftX = (contentCenter.x - (visibleWidth / 2))
        let topY = (contentCenter.y - (visibleHeight / 2))

        zoom(to: CGRect(x: leftX, y: topY, width: visibleWidth, height: visibleHeight), animated: animated)
        }
}

#endif
