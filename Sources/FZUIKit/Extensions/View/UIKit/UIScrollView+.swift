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
    func setZoomScale(_ scale: CGFloat, centeredAt point: CGPoint) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, minimumZoomScale)
        var translatedZoomPoint: CGPoint = .zero
        translatedZoomPoint.x = point.x + contentOffset.x
        translatedZoomPoint.y = point.y + contentOffset.y

        let zoomFactor = 1.0 / zoomScale

        translatedZoomPoint.x *= zoomFactor
        translatedZoomPoint.y *= zoomFactor

        var destinationRect: CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
        destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5

        zoom(to: destinationRect, animated: false)
    }
}

#endif
