# FZUIKit

Swift AppKit/UIKit extensions and useful Classes & utilities.

**For a full documentation take a look at the included documentation accessible via Xcode's documentation browser.**

## Notable Extensions & Classes

### NSContentConfiguration & NSContentView
A port of UIContentConfiguration & UIContentView to AppKit.

#### NSHostingConfiguration
A content configuration suitable for hosting a hierarchy of SwiftUI views.

```
let configuration = NSHostingConfiguration() {
    Label("Your account", systemImage: "folder.circle")
}

collectionViewItem.contentConfiguration = configuration
```

#### NSBackgroundConfiguration
A content configuration suitable for backgrounds.

```
var configuration = NSBackgroundConfiguration()

configuration.backgroundColor = .controlAccentColor
configuration.cornerRadius = 6.0
configuration.shadow = .black
configuration.imageProperties.tintColor = .purple

let backgroundView = NSBackgroundView(configuration: configuration)
```

#### NSContentUnavailableConfiguration
A content configuration for a content-unavailable view. It is a composable description of a view that indicates your app can’t display content. Using a content-unavailable configuration, you can obtain system default styling for a variety of different empty states. 

```
let configuration = NSContentUnavailableConfiguration.loading() // A loading view that is displaying a spinning indicator.

configuration.text = "Loading…"
configuration.secondaryText = "The database is getting loaded."

let loadingView = NSContentUnavailableView(configuration: configuration)
```

### NSView backgroundColor
A background color of the view that automatically adjusts on light/dark mode changes.

```
view.backgroundColor = .systemRed
```

### NSView additional properties
Additional `NSView` properties that can be all animated via the views `animator()`:
- `cornerRadius: CGFloat`
- `cornerCurve: CALayerCornerCurve`
- `roundedCorners: CACornerMask`
- `borderWidth: CGFloat`
- `borderColor: NSColor? `
- `mask: NSView?`
- `center: CGPoint`
- `transform: CGAffineTransform`
- `transform3D: CATransform3D`
- `anchorPoint: CGPoint`
- `animate(duration: TimeInterval, timingFunction: CAMediaTimingFunction, animations: @escaping (Self) -> Void, completion: (() -> Void)?)`
Animates the views properties
```
view.animate(duration: 0.5) {
    $0.cornerRadius = 4.0
    $0.borderWidth = 2.0
    $0.borderColor = .controlAccentColor
}
```

### AVPlayer looping
Easy looping of `AVPlayer`.

```
player.isLooping = true
```

### NSImage preparingForDisplay & preparingThumbnail
An UIImage port for generating thumbnails and to prepare and decode images to provide much better performance displaying them. It offers synchronous and asynchronous (either via asyc/await or completionHandler) implementations.

```
// prepared decoded image for better performance
if let preparedImage = await image.preparingForDisplay() {
    //
}

// thumbnail image
let maxThumbnailSize = CGSize(width: 512, height: 512)
image.preparingThumbnail(of: maxThumbnailSize) { thumbnailImage in
    if let thumbnailImage = thumbnailImage {
    //
    }
}
```

### ContentConfiguration
Configurates several aspects of views, windows, etc. Examples:
- VisualEffect
```
window.visualEffect = .darkAqua()
view.visualEffect = .vibrantLight()
```
- Shadow/InnerShadow:
```
let shadow = ContentConfiguration.Shadow(color: .black, opacity: 0.5, radius: 2.0)
view.configurate(using: shadow)
```
- Border
```
let border = ContentConfiguration.Border(color: .black, width: 1.0)
view.configurate(using: border)
```
- SymbolConfiguration: A simplified version UIImage/NSImage.SymbolConfiguration
```
let symbolConfiguration: ContentConfiguration.SymbolConfiguration = .hierarchical(.red).font(.body).imageScale(.large)
imageView.configurate(using: symbolConfiguration)
```
- Text
```
let text = ContentConfiguration.Text(font: .ystemFont(ofSize: 12), color: .red, numberOfLines: 1)
textField.configurate(using: text)
```

### NSSegmentedControl Segments
Configurates the segments of a NSSegmentedControl.
```
let segmentedControl = NSSegmentedControl() {
    Segment("Segment 1").isSelected(true)
    Segment("Segment 2"), 
    Segment(NSImage(named: "myImage")!)
    Segment(symbolName: "photo")
}
```

### NSToolbar
Configurate the items of a NSToolbar.
```
let toolbar = Toolbar("ToolbarIdentifier") {
        Button("OpenItem", title: "Open…")
            .onAction() { /// Button pressed }
        FlexibleSpace()
        Segmented("SegmentedItem") {
            Segment("Segment 1", isSelected: true)
            Segment("Segment 2"), 
        }
        Space()
            .onAction() { /// Segmented pressed }
        Search("SearchItem")
            .onSearch() { searchField, stringValue, state in /// Searching }
}
toolbar.attachedWindow = window
```

### NSMenu
Configurate the items of a Menu.
```
let menu = NSMenu() {
        MenuItem("Open…")
            .onSelect() { // Open item Pressed }
        MenuItem("Delete")
            .onSelect() { // Delete item Pressed }
        SeparatorItem()
        MenuItemHostingView() {
            HStack {
                Circle().forgroundColor(.red)
                Circle().forgroundColor(.blue)
            }
        }
    }
```

### DateTextFieldLabel
A text field with a date property that automatically updates its string baased on date. It can show the date absolute or relative.
```
let textField = DateTextField(date: Date())
textField.dateDisplayMode = .relative // It displays e.g. "2 mins ago"
textField.dateDisplayMode = .absolute // It displays e.g. "04.04.2023 10:20pm"
```

### ResizingTextField
A `NSTextField` that automatically resizes to fit it's text.
```
let textField = ResizingTextField(string: "Some string")
textField.automaticallyResizesToFit = true
textField.maxWidth = 200 // The max width of the text field when resizing.
textField.editingStateHandler // A handler that gets called whenever the state of editing changes
textField.allowedCharacters = [.alphanumerics, .emojis] // The allowed characters when editing the string
textField.minAmountChars = 5 // The minimum amount of characters when editing the string
```

### ImageView
An advanced `NSImageView` that supports scaleToFill, multiple images, gif animation speed, etc.
```
let imageView = ImageView()
imageView.image = myGifImage
imageView.imageScaling = .resizeAspectFill // scaleToFill
imageView.animationDuration = 3.0 /// gif animation speed

```
