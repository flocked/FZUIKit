//
//  UILabel+.swift
//
//
//  Created by Florian Zand on 17.08.23.
//

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

public extension UILabel {
    /// The font size of the label.
    @objc var fontSize: CGFloat {
        get { font.pointSize }
        set { font = font?.withSize(newValue) }
    }

    /// Returns the number of visible lines.
    var numberOfVisibleLines: Int {
        guard let font = font else { return -1 }
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }
    
    /// Sets the color of the text.
    @discardableResult
    func textColor(_ color: UIColor!) -> Self {
        self.textColor = color
        return self
    }
    
    /// Sets the font of the text.
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        self.font = font
        return self
    }
    
    /// Sets the technique for aligning the text.
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    /// Sets maximum number of lines for rendering text.
    @discardableResult
    func numberOfLines(_ numberOfLines: Int) -> Self {
        self.numberOfLines = numberOfLines
        return self
    }
}
#endif
