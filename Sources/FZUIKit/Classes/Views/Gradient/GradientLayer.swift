//
//  self.swift
//  NewPrrooo
//
//  Created by Florian Zand on 16.09.21.
//

/*
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
    
    /*
    func setGradient(_ colorGradient: GradientPreset) {
        self.gradientColors = colorGradient.colors
        self.type = .axial
        self.locations = calculateLocations(amount: self.gradientColors.count)
        updateGradient()
    }

    func random() {
        let randomColorGradient = GradientPreset.allCases.randomElement()!
        self.setGradient(randomColorGradient)
    }
     */
    

    
    public var gradient: Gradient {
        get {
            let colors = (self.colors as? [CGColor])?.compactMap({$0.nsColor}) ?? []
            let locations = self.locations?.compactMap({CGFloat($0.floatValue)}) ?? []
            colors.enumerated().compactMap({ Gradient.Stop(color: $0.element, location: locations[safe: $0.offset]) })
            
            self.colors?.compactMap({($0 as CGColor).nsColor})
            
            return Gradient(colors: self.gradientColors, locations: self.colorLocations, direction: self.direction)
        }
        set {
            if let gradientColors = newValue.colors {
                self.gradientColors = gradientColors
            } else {
                self.gradientColors = [NSColor]()
            }
            if let direction = newValue.direction {
                self.direction = direction
            }
            if let colorLocations = newValue.locations {
                self.colorLocations = colorLocations
            }
            self.updateGradient()
        }
    }

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
    
}

#endif
*/
