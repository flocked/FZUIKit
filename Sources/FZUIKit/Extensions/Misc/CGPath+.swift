//
//  CGPath+.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

#if canImport(CoreGraphics)
import CoreGraphics

extension CGPath {
    public func trimmedPath(from start: CGFloat, to end: CGFloat) -> CGPath {
        let mutablePath = CGMutablePath()
        let length = length()
        let trimStart = start * length
        let trimEnd = end * length
        var currentLength: CGFloat = 0

        applyWithBlock { element in
            let points = element.pointee.points
            switch element.pointee.type {
            case .moveToPoint:
                mutablePath.move(to: points[0])
            case .addLineToPoint:
                let segmentLength = points[0].distance(to: mutablePath.currentPoint)
                if currentLength + segmentLength > trimStart {
                    let startPoint = mutablePath.currentPoint.interpolate(to: points[0], by: (trimStart - currentLength) / segmentLength)
                    let endPoint = mutablePath.currentPoint.interpolate(to: points[0], by: (trimEnd - currentLength) / segmentLength)
                    mutablePath.move(to: startPoint)
                    mutablePath.addLine(to: endPoint)
                }
                currentLength += segmentLength
            default:
                break
            }
        }
        return mutablePath
    }

    private func length() -> CGFloat {
        var length: CGFloat = 0
        self.applyWithBlock { element in
            let points = element.pointee.points
            if element.pointee.type == .addLineToPoint {
                length += points[0].distance(to: currentPoint)
            }
        }
        return length
    }
}

fileprivate extension CGPoint {
    func interpolate(to: CGPoint, by amount: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + (to.x - self.x) * amount, y: self.y + (to.y - self.y) * amount)
    }

    func distance(to: CGPoint) -> CGFloat {
        return hypot(to.x - self.x, to.y - self.y)
    }
}
#endif
