# FZUIKit

A framework with Swift AppKit and UIKit extensions, classes & utilities.

**For a full documentation take a look at the included documentation located at */Documentation*. Opening the file launches Xcode's documentation browser.**

## Notable Extensions & Classes

### NSContentConfiguration & NSContentView

A port of `UIContentConfiguration` & `UIContentView` to AppKit.

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

### NSView properties

- `backgroundColor`: The background color of a view that automatically adjusts on light/dark mode changes and can be animated via `animator()`.
```
view.backgroundColor = .systemRed
```

- `mask`: Masks a view with another view whose alpha channel is used for masking.
```
view.mask = roundedView
```

- Properties that can be all animated via the views `animator()`:
    - `cornerRadius: CGFloat`
    - `cornerCurve: CALayerCornerCurve`
    - `roundedCorners: CACornerMask`
    - `borderWidth: CGFloat`
    - `borderColor: NSColor? `
    - `center: CGPoint`
    - `transform: CGAffineTransform`
    - `transform3D: CATransform3D`
    - `anchorPoint: CGPoint`
    - NSTextField: `fontSize: CGFloat`

- Convenience way of animating view properties:
```
view.animate(duration: 0.5) {
    $0.cornerRadius = 4.0
    $0.borderWidth = 2.0
    $0.borderColor = .controlAccentColor
}
```

### NSImage prepareForDisplay & prepareThumbnail

An `UIImage port for generating thumbnails and to prepare and decode images to provide much better performance displaying them. It offers synchronous and asynchronous (either via asyc/await or completionHandler) implementations.

```
// prepared decoded image for better performance
let preparedImage = await image.preparingForDisplay() 

// thumbnail image
let maxThumbnailSize = CGSize(width: 512, height: 512)
image.prepareThumbnail(of: maxThumbnailSize) { thumbnailImage in
    // thumbnailImage…
}
```

### ContentConfiguration

Configurates several aspects of views, windows, etc. Examples:

- VisualEffect
```
window.visualEffect = .darkAqua()
view.visualEffect = .vibrantLight(material: .sidebar)
```

- Shadow/InnerShadow:
```
let shadow = ShadowConfiguration(color: .controlAccentColor, opacity: 0.5, radius: 2.0)
view.outerShadow = shadow

// inner shadow
view.innerShadow = shadow
```

- Border
```
let border = BorderConfiguration(color: .black, width: 1.0)
view.border = border

let dashedBorder: BorderConfiguration = .dashed(color: .red)
view.border = dashedBorder
```

- SymbolConfiguration: A simplified version of UIImage/NSImage.SymbolConfiguration.
```
let symbolConfiguration: ImageSymbolConfiguration = .hierarchical(color: .red)
symbolConfiguration.font = .body
symbolConfiguration.imageScaling = .large
imageView.configurate(using: symbolConfiguration)
```

- Text
```
var textConfiguration = TextConfiguration()
textConfiguration.font = .body
textConfiguration.color = .systemRed
textConfiguration.numberOfLines = 1
textConfiguration.adjustsFontSizeToFitWidth = true
textField.configurate(using: textConfiguration)
```

### NSSegmentedControl Segments

Configurates the segments of a NSSegmentedControl:

```
let segmentedControl = NSSegmentedControl() {
    Segment("Segment 1").isSelected(true)
    Segment("Segment 2"), 
    Segment(NSImage(named: "myImage")!)
    Segment(symbolName: "photo")
}
```

### NSTextField

- `adjustsFontSizeToFitWidth` & `minimumScaleFactor` (Port of UILabel)

```swift
textField.adjustsFontSizeToFitWidth = true
textField.minimumScaleFactor = 0.7
```

- `minimumNumberOfCharacters`, `maximumNumberOfCharacters` & `allowedCharacters`

```swift
textField.maximumNumberOfCharacters = 20
textField.allowedCharacters = [.lowercaseLetters, .digits, .emojis]
```

- `actionOnEnterKeyDown`, `actionOnEscapeKeyDown` & `endEditingOnOutsideMouseDown`:

```swift
// Ends editing on enter/return.
textField.actionOnEnterKeyDown = .endEditing
// Cancels editing on escape and resets the text to the previous state.
textField.actionOnEscapeKeyDown = .endEditingAndReset
// Ends editing when the user clicks outside the text field.
textField.endEditingOnOutsideMouseDown = true
```

- `EditingHandlers`:

```swift
textField.editingHandlers.didBegin {
    // Editing of the text did begin
}
textField.editingHandlers.didEdit {
    // Text did change
}
textField.editingHandlers.shouldEdit { 
    newText in 
    return true
}
```

### NSToolbar
Configurate the items of a NSToolbar.

```swift
let toolbar = Toolbar("ToolbarIdentifier") {
        Button("OpenItem", title: "Open…")
            .onAction() { /// Button pressed }
        FlexibleSpace()
        Segmented("SegmentedItem") {
            Segment("Segment 1", isSelected: true)
            Segment("Segment 2"),
        }.onAction() { /// Segmented pressed }
        Space()
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
```

### ImageView

An advanced `NSImageView` that supports scaleToFill, multiple images, gif animation speed, etc.

```
let imageView = ImageView()
imageView.image = myGifImage
imageView.imageScaling = .resizeAspectFill
imageView.animationDuration = 3.0 /// gif animation speed
imageView.animationPlaybackOption = .mouseHover /// animation plays on mouse hover
imageView.animationPlaybackOption = .mouseDown /// toggle playback via mouse click
```

### AVPlayer extensions

- `isLooping`: Easy looping of the playing item.

```
player.isLooping = true
```

- `state`: The current playback state of the player: .isPlaying, .isPaused, .isStopped, .error(Error)
- `seek(toPercentage: Double)`

### NSMagnificationGestureRecognizer extension

- Velocity: The velocity of the magnification in scale factor per second.

### DisplayLinkeTimer

A much more precise `Timer` which time interval can be changed without invalidating the timer.

```
let timer = DisplayLinkTimer.scheduledTimer(timeInterval: .seconds(3.0), action: {
    // some action
})
timer.timeInterval = .minutes(1)
```
