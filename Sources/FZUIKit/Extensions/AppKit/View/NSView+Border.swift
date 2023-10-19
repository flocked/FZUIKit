//
//  NSView+Border.swift
//
//
//  Created by Florian Zand on 19.10.23.
//

#if os(macOS)
import AppKit

/*
extension NSView {
    /*
    /**
     The border of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    dynamic public var border: ContentConfiguration.Border {
        get { dashedBorderLayer?.configuration ?? .init(color: borderColor, width: borderWidth) }
        set {
            self.wantsLayer = true
            Self.swizzleAnimationForKey()
            var updateDashedBorderLayer = false
            if self._dashedBorderLayer != nil {
                updateDashedBorderLayer = true
            } else if newValue.needsDashedBordlerLayer {
                if self._dashedBorderLayer == nil {
                    let borderedLayer = DashedBorderLayer()
                    self.layer?.addSublayer(withConstraint: borderedLayer, insets: newValue.insets)
                    borderedLayer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                }
                updateDashedBorderLayer = true
            } else {
                self.borderColor = newValue._resolvedColor?.resolvedColor(for: self)
                self.borderWidth = newValue.width
            }
            if updateDashedBorderLayer {
                self.dashedBorderColor = newValue._resolvedColor?.resolvedColor(for: self)
                self.dashedBorderWidth = newValue.width
        
                self.dashedBorderInsetsTop = newValue.insets.top
                self.dashedBorderInsetsBottom = newValue.insets.bottom
                self.dashedBorderInsetsLeading = newValue.insets.leading
                self.dashedBorderInsetsTrailing = newValue.insets.trailing
                
                self.setupDashedPatternArray()
                Swift.print("count", self.dashedBorderLayer?.borderDashPattern.count ?? "nil")
                let newDashPattern = self.convertedDashPattern(for: newValue.dashPattern)
                Swift.print("converted", newDashPattern)
                self.dashedBorderDashPattern0 = newDashPattern[0]
                self.dashedBorderDashPattern1 = newDashPattern[1]
                self.dashedBorderDashPattern2 = newDashPattern[2]
                self.dashedBorderDashPattern3 = newDashPattern[3]
                self.dashedBorderDashPattern4 = newDashPattern[4]
                self.dashedBorderDashPattern5 = newDashPattern[5]
            }
        }
    }
     */
    
    @objc dynamic internal var dashedBorderColor: NSUIColor? {
        get { self.dashedBorderLayer?.borderColor?.nsUIColor }
        set {
            var newValue = newValue?.resolvedColor(for: effectiveAppearance)
            if newValue == nil, self.isProxy() {
                newValue = .clear
            }
            self._dashedBorderLayer?.borderColor = newValue?.cgColor }
    }
    
    @objc dynamic internal var dashedBorderWidth: CGFloat {
        get { self.dashedBorderLayer?.borderWidth ?? 0 }
        set { self._dashedBorderLayer?.borderWidth = newValue }
    }
    
    @objc dynamic internal var dashedBorderInsetsTop: CGFloat {
        get { self.dashedBorderLayer?.borderInsets.top ?? 0 }
        set { self._dashedBorderLayer?.borderInsets.top = newValue }
    }
    
    @objc dynamic internal var dashedBorderInsetsBottom: CGFloat {
        get { self.dashedBorderLayer?.borderInsets.bottom ?? 0 }
        set { self._dashedBorderLayer?.borderInsets.bottom = newValue }
    }
    
    @objc dynamic internal var dashedBorderInsetsLeading: CGFloat {
        get { self.dashedBorderLayer?.borderInsets.leading ?? 0 }
        set { self._dashedBorderLayer?.borderInsets.leading = newValue }
    }
    
    @objc dynamic internal var dashedBorderInsetsTrailing: CGFloat {
        get { self.dashedBorderLayer?.borderInsets.trailing ?? 0 }
        set { self._dashedBorderLayer?.borderInsets.trailing = newValue }
    }
    
    internal func convertedDashPattern(for values: [CGFloat]) -> [CGFloat] {
        if values.count == 0 {
            return [1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        } else if values.count == 1 {
            return [1.0, 1.0, 0.0, 0.0, 0.0, 0.0]
        } else {
            var values = values[safe: 0..<6]
            let needs = 6 - values.count
            if needs > 0 {
                values.append(contentsOf: Array(repeating: 0.0, count: needs))
            }
            return values
        }
    }
    
    internal func setupDashedPatternArray() {
        if let dashedLayer = _dashedBorderLayer {
            let patternCount = dashedLayer.borderDashPattern.count
            let needs = 6 - patternCount
            if needs > 0 {
                dashedLayer.borderDashPattern.append(contentsOf: Array(repeating: 0.0, count: needs))
            } else if needs < 0 {
                dashedLayer.borderDashPattern.removeLast(needs * -1)
            }
        }
    }
    
    @objc dynamic internal var dashedBorderDashPattern0: CGFloat {
        get { self.dashedBorderLayer?.borderDashPattern[safe: 0] ?? 0.0 }
        set { self._dashedBorderLayer?.borderDashPattern[0] = newValue }
    }
    
    internal var _dashedBorderLayer: DashedBorderLayer? {
        self.layer?.firstSublayer(type: DashedBorderLayer.self)
    }
    
   @objc dynamic internal var dashedBorderDashPattern1: CGFloat {
        get { self._dashedBorderLayer?.borderDashPattern[safe: 1] ?? 0.0 }
       set { self._dashedBorderLayer?.borderDashPattern[1] = newValue }
    }
    
    @objc dynamic internal var dashedBorderDashPattern2: CGFloat {
        get { self._dashedBorderLayer?.borderDashPattern[safe: 2] ?? 0.0 }
        set { self._dashedBorderLayer?.borderDashPattern[2] = newValue }
    }
    
    @objc dynamic internal var dashedBorderDashPattern3: CGFloat {
        get { self._dashedBorderLayer?.borderDashPattern[safe: 3] ?? 0.0 }
        set { self._dashedBorderLayer?.borderDashPattern[3] = newValue }
    }
    
    @objc dynamic internal var dashedBorderDashPattern4: CGFloat {
        get { self.dashedBorderLayer?.borderDashPattern[safe: 4] ?? 0.0 }
        set { self._dashedBorderLayer?.borderDashPattern[4] = newValue }
    }
    
    @objc dynamic internal var dashedBorderDashPattern5: CGFloat {
        get { self.dashedBorderLayer?.borderDashPattern[safe: 5] ?? 0.0 }
        set { self._dashedBorderLayer?.borderDashPattern[5] = newValue }
    }
}
 */

#endif
