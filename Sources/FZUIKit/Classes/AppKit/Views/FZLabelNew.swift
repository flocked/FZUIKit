//
//  FZLabel.swift
//  CollectionTableView
//
//  Created by Florian Zand on 11.10.22.
//

/*
 #if os(macOS)
 import AppKit
 @available(macOS 13, *)
 public class FZLabel: NSView {
     internal var imageView = NSImageView()
     internal var textField = NonFirstResponderResizingTextField(wrappingLabelWithString: "")

     public var style: Style = .body {
          didSet { updateConfiguration() } }
     public var weight: NSFont.Weight = .regular {
          didSet { updateConfiguration() } }

     public var displayMode: DisplayMode = .titleAndIcon {
          didSet { updatePositions() } }
     public var iconScale: IconScale = .regular {
          didSet { updateConfiguration() } }
     public var iconPosition: IconPosition = .leading {
         didSet { //self.textField.alignment = iconPosition == .leading ? .left : .right
              updatePositions() } }

     public var textColor: NSColor = .labelColor {
          didSet { self.textField.textColor = textColor } }
     public var iconColor: IconColor = .monochrome(.black) {
         didSet { self.updateSymbolConfiguration() }  }

     public var focusType: VerticallyCenteredTextFieldCell.FocusType {
         get { textField.focusType }
         set { textField.focusType = newValue }
     }

     public var isEditable: Bool {
         get { self.textField.isEditable }
         set { self.textField.isEditable = newValue }
     }

     public var stopsEditingOnOutsideMouseDown: Bool {
         get { self.textField.stopsEditingOnOutsideMouseDown }
         set { self.textField.stopsEditingOnOutsideMouseDown = newValue }
     }

     public override var isSelectable: Bool {
         get { self.textField.isSelectable }
         set { self.textField.isSelectable = newValue }
     }

     public var text: String? = "" {
         didSet { textField.stringValue = self.text ?? ""
             self.updateSizes()
         } }

     public var icon: NSImage? {
          get { imageView.image }
          set { imageView.image = newValue
              if let image = self.icon, image.isSystemSymbol == false {
                  image.isTemplate = true
              }
              updateSizes() } }

     public func sizeToFit() {
          self.frame.size = fittingSize
      }

      public override var intrinsicContentSize: NSSize {
          return fittingSize
      }

     public override func becomeFirstResponder() -> Bool {
         false
     }

      public override var fittingSize: NSSize {
          let height = max(self.textField.frame.size.height, self.imageView.frame.size.height)
          var width: CGFloat = self.textField.frame.size.width + self.imageView.frame.size.width
          switch displayMode {
          case .iconOnly:
              width = self.imageView.frame.size.width
          case .titleOnly:
              width = self.textField.frame.size.width
          case .titleAndIcon:
              break
          }
          return CGSize(width: width, height: height)
      }

     internal var _displayMode: DisplayMode {
         if (isDisplayingText && isDisplayingIcon) {
             return .titleAndIcon
         }
         if (isDisplayingIcon) {
             return .iconOnly
         }
         return .titleOnly
     }

     internal var isDisplayingIcon: Bool {
         self.displayMode != .titleOnly && self.icon != nil
     }

     internal var isDisplayingText: Bool {
         self.displayMode != .iconOnly && self.text != nil
     }

     internal func textFieldSize() -> CGSize {
         textField.fittingSize
     }

     internal func imageViewSize() -> CGSize {
         guard let image = self.icon, image.isSystemSymbol else {
             return imageView.fittingSize
         }
         let height: CGFloat
         switch self.iconScale {
             case .large: height = font.lineHeight * 1.2
             case .small:  height = font.lineHeight * 0.8
             default: height = font.lineHeight * 1.0
         }

         switch imageView.imageScaling {
             case .scaleNone: return self.imageView.fittingSize
             case .scaleProportionallyDown:
            return CGSize(width: image.size.width, height: image.size.height).scaled(toHeight: height)
             default:  return CGSize(width: height, height: height)
         }
     }

    internal func updateSizes() {
         self.textField.frame.size = textFieldSize()
         self.imageView.frame.size = imageViewSize()
         self.updatePositions()
         self.sizeToFit()
     }

    internal func updatePositions() {
         textField.sizeToFit()
             switch displayMode {
             case .iconOnly:
                 imageView.frame.origin = CGPoint(0, 0)
                 imageView.isHidden = false
                 textField.isHidden = true
             case .titleOnly:
                 textField.frame.origin = CGPoint(0, 0)
                 textField.isHidden = false
                 imageView.isHidden = true
             case .titleAndIcon:
                 textField.isHidden = false
                 imageView.isHidden = false
                 switch iconPosition {
                 case .leading:
                     imageView.frame.origin = CGPoint(0, 0)
                     textField.frame.origin = CGPoint(imageView.bounds.size.width, 0)
                 case .trailing:
                     textField.frame.origin = CGPoint(0, 0)
                     imageView.frame.origin = CGPoint(textField.bounds.size.width, 0)
                 }
                 if (imageView.bounds.size.height > textField.bounds.size.height) {
                     var newCenter = textField.center
                     newCenter.y = imageView.center.y
                     textField.center = newCenter
                 } else if (textField.bounds.size.height > imageView.bounds.size.height) {
                     var newCenter = imageView.center
                     newCenter.y = textField.center.y
                     imageView.center = newCenter
                 }
             }
     }

    internal var imageScaling: NSImageScaling {
         get { imageView.imageScaling }
         set { imageView.imageScaling = newValue
             updateSizes() } }

     internal func updateConfiguration() {
         self.imageView.symbolConfiguration = self.symbolConfiguration?.toImageSymbolConfiguration()

         let weight = self.symbolConfiguration?.weight?.fontWeight() ?? .regular
         if let fontConfiguration = self.symbolConfiguration?.font {
             switch fontConfiguration  {
             case .textStyle(let style):
                 self.textField.font = .system(style).weight(weight)
             case .pointSize(let size):
                 self.textField.font = .system(size: size, weight: weight)
             }
         } else {
             self.textField.font = self.font
         }

         if let configuration = self.symbolConfiguration {
             if let font = configuration.font {
                 switch font  {
                 case .textStyle(let style):
                     self.textField.font = .system(style)
                 case .pointSize(let size):
                     self.textField.font = .system(size: size)
                 }
             } else {

             }
             configuration.font
             self.textField.font = self.sym
         }
         self.textField.font = font
         self.imageView.symbolConfiguration = symbolConfiguration
         self.updateSizes()
     }

     internal var font: NSFont {
         if let textStyle = style.textStyle {
            return .preferredFont(forTextStyle: textStyle).weight(weight)
         } else {
             return .systemFont(ofSize: style.pointSize!, weight: weight)
         }
     }

     internal func updateSymbolConfiguration() {
         switch iconColor {
         case .monochrome(let color):
             self.imageView.contentTintColor = color
             _symbolConfiguration = .monochrome()
         case .multicolor(let color):
             self.imageView.contentTintColor = color
             _symbolConfiguration = .multicolor(color)
         case .palette(let primary, let secondary, let tertiary):
             self.imageView.contentTintColor = primary
             _symbolConfiguration = .palette(primary, secondary, tertiary)
         case .hierarchical(let color):
             self.imageView.contentTintColor = color
             _symbolConfiguration = .hierarchical(color)
         }
     }

     var symbolConfiguration: ContentConfiguration.SymbolConfiguration? = nil {
         didSet {

         }
     }
     /*
     internal var _symbolConfiguration: NSImage.SymbolConfiguration = .monochrome() {
         didSet { self.updateConfiguration() }
     }

     internal var symbolConfiguration: NSImage.SymbolConfiguration {
         if let textStyle = style.textStyle {
             return  _symbolConfiguration.font(textStyle).weight(weight.symbolWeight()).scale(.init(rawValue: iconScale.rawValue))
         } else {
             return  _symbolConfiguration.font(size: style.pointSize!).weight(weight.symbolWeight()).scale(.init(rawValue: iconScale.rawValue))
         }
     }
     */

     public override init(frame frameRect: NSRect) {
         super.init(frame: frameRect)
         self.sharedInit()
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

    public init(title: String) {
         super.init(frame: .zero)
         self.text = title
         self.updateSizes()
     }

     public init(icon: NSImage) {
         super.init(frame: .zero)
         self.icon = icon
         self.updateSizes()
     }

     public init(title: String, icon: NSImage) {
         super.init(frame: .zero)
         self.text = title
         self.icon = icon
         self.updateSizes()
     }

     internal func sharedInit() {
         self.addSubview(imageView)
         self.addSubview(textField)
         imageView.imageScaling = .scaleProportionallyDown
         imageView.contentTintColor = .black
         textField.delegate = self
         textField.stopsEditingOnOutsideMouseDown = true
         updateConfiguration()
     }
 }

 @available(macOS 12, *)
 extension FZLabel: NSTextFieldDelegate {
     public func controlTextDidChange(_ obj: Notification) {
         self.updateSizes()
     }

     public func controlTextDidBeginEditing(_ obj: Notification) {

     }

     public func controlTextDidEndEditing(_ obj: Notification) {
         self.updateSizes()
     }

     public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
         return textField.control(control, textView: textView, doCommandBy: commandSelector)
     }
 }

 @available(macOS 12, *)
 extension FZLabel {
     public func sizeToFit(width toWidth: CGFloat) {
         self.sizeToFit( CGSize(width: toWidth, height: .infinity))
     }

     public func sizeToFit(height toHeight: CGFloat) {
         self.sizeToFit(CGSize(width: .infinity, height: toHeight))
     }

     public func sizeToFit(_ toSize: CGSize) {
         var toSize = toSize
         if (toSize.width == .zero) { toSize.width = .infinity }
         if (toSize.height == .zero) { toSize.height = .infinity }
         if ((toSize.width == .infinity && toSize.height == .infinity) == false) {
             var fontSize = self.font.pointSize
             let currentSize = self.frame.size
             var newSize = self.frame.size
             if (currentSize.width < toSize.width && currentSize.height < toSize.height) {
                 while (newSize.width < toSize.width && newSize.height < toSize.height) {
                     fontSize = fontSize + 1
                     newSize = self.fittingSize(for: fontSize, weight: self.weight)
                 }
             } else if (currentSize.height > toSize.height || currentSize.width > currentSize.width) {
                 while ((newSize.width > toSize.width || newSize.height > toSize.height) && fontSize > 2) {
                     fontSize = fontSize - 1
                     newSize = self.fittingSize(for: fontSize, weight: self.weight)
                 }
             }
             Swift.print("fontSize")
             Swift.print(fontSize)
             self.style = .size(fontSize)
         }
     }

     internal func fittingSize(for fontSize: CGFloat, weight: NSFont.Weight) -> CGSize {
         let imageSize = fittingImageViewSize(for: fontSize, weight: weight)
         let textSize = fittingTextFieldSize(for: fontSize, weight: weight)
         let width = imageSize.width+textSize.width
         let height = max(imageSize.height, textSize.height)
         return CGSize(width: width, height: height)
     }

     internal func fittingTextFieldSize(for fontSize: CGFloat, weight: NSFont.Weight) -> CGSize {
         let font: NSFont = .systemFont(ofSize: fontSize, weight: weight)
         self.textField.font = font
         let fittingSize = self.textField.fittingSize
         self.textField.font = self.font
         return fittingSize
     }

     internal func fittingImageViewSize(for fontSize: CGFloat, weight: NSFont.Weight) -> CGSize {
         let symbolConfiguration: NSImage.SymbolConfiguration = .init(pointSize: fontSize, weight: weight, scale: NSImage.SymbolScale(rawValue: self.iconScale.rawValue)!)
         self.imageView.symbolConfiguration = symbolConfiguration
         let fittingSize = self.imageView.fittingSize
         self.imageView.symbolConfiguration = self.symbolConfiguration
         return fittingSize
     }
 }

 @available(macOS 12, *)
 extension FZLabel {
     public enum DisplayMode {
         case iconOnly
         case titleOnly
         case titleAndIcon
     }

     public enum IconScale: Int {
         case small = 1
         case regular = 2
         case large = 3
     }

     public enum IconPosition {
         case leading
         case trailing
     }

    public enum IconColor {
         case monochrome(NSColor)
         case multicolor(NSColor)
         case palette(NSColor, NSColor, NSColor? = nil)
         case hierarchical(NSColor)
     }

     public enum Style {
         case body
         case callout
         case caption1
         case caption2
         case footnote
         case headline
         case subheadline
         case largeTitle
         case title1
         case title2
         case title3
         case size(CGFloat)

         internal var pointSize: CGFloat? {
             switch self {
             case .size(let pointSize): return pointSize
             default: return nil
             }
         }

         internal var textStyle: NSFont.TextStyle? {
             switch self {
             case .body: return .body
             case .callout: return .body
             case .caption1: return .caption1
             case .caption2: return .caption2
             case .footnote: return .footnote
             case .headline: return .headline
             case .subheadline: return .subheadline
             case .largeTitle: return .largeTitle
             case .title1: return .title1
             case .title2: return .title2
             case .title3: return .title3
             case .size( _): return nil
             }
         }
     }
 }

 internal class NonFirstResponderResizingTextField: ResizingTextField {
     override func becomeFirstResponder() -> Bool {
         return false
     }
 }
 #endif
 */
