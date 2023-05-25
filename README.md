# FZUIKit

Swift AppKit/UIKit extensions and useful Classes & utilities.

## Notable Extensions & Classes
- NSView/CALayer backgroundColor
    - Automatically adjusts on light/dark mode changes
    
- AVPlayer: Easy looping of AVPlayerItems
```
player.isLooping = true
```
- NSTableView cell registration via classes `register(_ forIdentifier:)` (NSTableView usually only offers registration via NSNib)
```
tableView.register(MyTableViewCellClass.self, forIdentifier: "MyCellClassIdentifier")
```

### QuicklookPanel
Present files in a Quicklook panel simliar to Finder`s Quicklook. 
```
QuicklookPanel.shared.present(fileURLs)
```
If a NSCollectionViewItem/NSTableCellView conforms to the protocol QLPreviable and provides a previewURL, it also provides easy quicklock of selected items/cells.
```
collectionView.quicklookSelectedItems()
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
Configurate several aspects of views, windows, etc. Examples:
- VisualEffect
```
window.visualEffect = .darkAqua
```
- Shadow
```
let view = NSView()
let shadowConfiguration = ContentConfiguration.Shadow(opacity: 0.5, radius: 2.0)
            view.configurate(using: shadowConfiguration)
```
- Border
```
let borderConfiguration = ContentConfiguration.Border(color: .black, width: 1.0)
view.configurate(using: borderConfiguration)
```
- Text
```
let textField = NSTextField()
let textConfiguration = ContentConfiguration.Text(font: .ystemFont(ofSize: 12), textColor: .red, numberOfLines: 1)
textField.configurate(using: textConfiguration)
