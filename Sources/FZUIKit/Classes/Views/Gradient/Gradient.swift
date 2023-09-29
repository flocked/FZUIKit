//
//  Gradient.swift
//  FZViewTest
//
//  Created by Florian Zand on 13.05.22.
//

/*
#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public struct Gradient {
    public struct Stop {
        public var color: NSUIColor
        public var location: CGFloat?
        public init(color: NSUIColor, location: CGFloat? = nil) {
            self.color = color
            self.location = location
        }
    }
    
    public var direction: Direction = .down
    public var stops: [Stop] = []
    
    public init(colors: [NSUIColor], direction: Direction = .down) {
        if colors.count == 1 {
            self.stops.append(Stop(color: colors[0], location: 0.0))
        } else if colors.count > 1 {
            let split = 1.0 / CGFloat(colors.count - 1)
            for i in 0..<colors.count {
                self.stops.append(Stop(color: colors[i], location: split*CGFloat(i)))
            }
        }
        self.direction = .downRight
    }
    
    public init(stops: [Stop], direction: Direction = .down) {
        self.stops = stops
        self.direction = direction
    }
    
    /*
    init(_ preset: GradientPreset, direction: Direction? = nil) {
        self.colors = preset.colors
        self.locations = nil
        self.direction = direction
    }
     */
    
    public enum Direction: Int {
       case up
       case upRight
       case right
       case downRight
       case down
       case downLeft
       case left
       case upLeft
       
       internal var startPoint: CGPoint {
           let result: CGPoint
           switch self {
           case .up:
               result = CGPoint(x: 0.5, y: 1.0)
           case .upRight:
               result = CGPoint(x: 0.0, y: 1.0)
           case .right:
               result = CGPoint(x: 0.0, y: 0.5)
           case .downRight:
               result = CGPoint(x: 0.0, y: 0.0)
           case .down:
               result = CGPoint(x: 0.5, y: 0.0)
           case .downLeft:
               result = CGPoint(x: 1.0, y: 0.0)
           case .left:
               result = CGPoint(x: 1.0, y: 0.5)
           case .upLeft:
               result = CGPoint(x: 1.0, y: 1.0)
           }
           return result
       }
       
       internal var endPoint: CGPoint {
           let result: CGPoint
           switch self {
           case .up:
               result = CGPoint(x: 0.5, y: 0.0)
           case .upRight:
               result = CGPoint(x: 1.0, y: 0.0)
           case .right:
               result = CGPoint(x: 1.0, y: 0.5)
           case .downRight:
               result = CGPoint(x: 1.0, y: 1.0)
           case .down:
               result = CGPoint(x: 0.5, y: 1.0)
           case .downLeft:
               result = CGPoint(x: 0.0, y: 1.0)
           case .left:
               result = CGPoint(x: 0.0, y: 0.5)
           case .upLeft:
               result = CGPoint(x: 0.0, y: 0.0)
           }
           return result
       }
   }
}

#endif
*/
