//
//  UILabel+.swift
//  
//
//  Created by Florian Zand on 17.08.23.
//

#if canImport(UIKit)
import UIKit

extension UILabel {
    /// Returns the number of lines.
    var currentNumberOfLines: Int {
        guard let font = self.font else { return -1 }
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
#endif
