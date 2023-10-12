//
//  GradientLayer.swift
//  
//
//  Created by Florian Zand on 16.09.21.
//


#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public class GradientLayer: CAGradientLayer {
    public convenience init(gradient: Gradient) {
        self.init()
        self.gradient = gradient
    }
    
    override init() {
        super.init()
        self.sharedInit()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    private func sharedInit() {
        self.masksToBounds = true
    }
    
    public var gradient: Gradient {
        get {
            let colors = (self.colors as? [CGColor])?.compactMap({$0.nsUIColor}) ?? []
            let locations = self.locations?.compactMap({CGFloat($0.floatValue)}) ?? []
            let stops = colors.enumerated().compactMap({ Gradient.Stop(color: $0.element, location: locations[$0.offset]) })
            let direction = Gradient.Direction(start: startPoint, end: endPoint)
            return Gradient(stops: stops, direction: direction)
        }
        set {
            self.colors = newValue.stops.compactMap({$0.color.cgColor})
            self.locations = newValue.stops.compactMap({NSNumber($0.location)})
            self.startPoint = newValue.direction.startPoint
            self.endPoint = newValue.direction.endPoint
        }
    }

    /*
   private var gradientColors = [NSColor]()
    private  var colorLocations: [CGFloat]? {
        didSet {
            updateGradient()
        }
    }
    
    private var direction: Gradient.Direction = .down {
        didSet {
            updateGradient()
        }
    }
    
    private  func calculateLocations(amount: Int) -> [NSNumber] {
        0.0
        0.3
        0.6

        1.0
        var locations: [Float] = []
        if amount == 2 {
            locations = [0.0, 1.0]
        } else if amount > 2 {
            let split = 1.0 / Float(amount - 1)
            for i in 0..<amount
        }
        
          var newLocations = [NSNumber]()
         let split = 1.0 / Double(amount)
          for i in 0..<amount {
              var newNumber = split * Double(i)
              if (i == amount-1) {
                  newNumber = 1.0
              }
              newLocations.append(NSNumber(floatLiteral: newNumber))
          }
          
          return newLocations
      }
    
    private func updateGradient() {
        self.masksToBounds = true
        self.colors = self.gradientColors.map({$0.cgColor})
        self.startPoint = direction.startPoint
        self.endPoint = direction.endPoint
        
        if let colorLocations = self.colorLocations {
            self.locations = colorLocations.map({NSNumber(floatLiteral: Double($0))})
        } else {
            self.locations = calculateLocations(amount: gradientColors.count)
        }
    }
    */
    
}

#endif

