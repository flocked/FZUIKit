//
//  File 2.swift
//  
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import FZUIKitTests
#endif

public class RatingViewNew: NSView {
    
    public var numberOfSteps: Int = 5 {
        didSet { if isApplyingConfiguration == false, oldValue != numberOfSteps {
            updateConfiguration() } } }
        
    public var hasHalfSteps: Bool = false {
        didSet { if isApplyingConfiguration == false, oldValue != hasHalfSteps {
            updateConfiguration() } } }
    
    public var stepSystemImageName: String = "star.filled" {
        didSet { if isApplyingConfiguration == false, oldValue != stepSystemImageName {
            updateConfiguration() } } }
        
    public var stepBorderWidth: CGFloat = 0.0 {
        didSet { if isApplyingConfiguration == false, oldValue != stepBorderWidth {
            updateConfiguration() } } }
        
    public var stepBorderColor: NSUIColor? = nil {
        didSet { if isApplyingConfiguration == false, oldValue != stepBorderColor {
            updateConfiguration() } } }
        
    public var stepColor: NSUIColor = .systemYellow {
        didSet { if isApplyingConfiguration == false, oldValue != stepColor {
            updateConfiguration() } } }
        
    public var stepEmptyColor: NSUIColor = .systemGray {
        didSet { if isApplyingConfiguration == false, oldValue != stepEmptyColor {
            updateConfiguration() } } }
        
    public var stepShadow: ContentConfiguration.Shadow = .none() {
        didSet { if isApplyingConfiguration == false, oldValue != stepShadow {
            updateConfiguration() } } }
    
    public var configuration: RatingViewNew.Configuration {
        get {
            RatingViewNew.Configuration(numberOfSteps: numberOfSteps, hasHalfSteps: hasHalfSteps, stepSystemImageName: stepSystemImageName, stepBorderWidth: stepBorderWidth, stepColor: stepColor, stepEmptyColor: stepEmptyColor, stepShadow: stepShadow )
        }
        set {
            guard self.configuration != newValue else { return }
            self.isApplyingConfiguration = true
            self.numberOfSteps = newValue.numberOfSteps
            self.hasHalfSteps = newValue.hasHalfSteps
            self.stepSystemImageName = newValue.stepSystemImageName
            self.stepBorderWidth = newValue.stepBorderWidth
            self.stepBorderColor = newValue.stepBorderColor
            self.stepColor = newValue.stepColor
            self.stepEmptyColor = newValue.stepEmptyColor
            self.stepShadow = newValue.stepShadow
            self.isApplyingConfiguration = false
            self.updateConfiguration()
        }
    }
    
    internal var isApplyingConfiguration: Bool = false
    internal func updateConfiguration() {
        
    }
}
