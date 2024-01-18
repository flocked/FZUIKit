# UIImage

Extensions for `UIImage`.

## Topics

### Creating and initializing image objects

- ``AppKit/NSImage/init(cgImage:)``
- ``AppKit/NSImage/init?(size:actions:)``

### Getting the image data

- ``AppKit/NSImage/cgImage``
- ``AppKit/NSImage/ciImage``
- ``AppKit/NSImage/cgImageSource``

### Accessing image attributes

- ``AppKit/NSImage/orientation``

### Loading images for display

- ``AppKit/NSImage/preparingForDisplay()``
- ``AppKit/NSImage/prepareForDisplay(completionHandler:)``
- ``AppKit/NSImage/preparingThumbnail(of:)``
- ``AppKit/NSImage/prepareThumbnail(of:completionHandler:)``


/// A Boolean value that indicates whether the image is a symbol.
@available(macOS 11.0, *)
var isSymbolImage: Bool {
    (self.value(forKey: "_isSymbolImage") as? Bool) ??
        (symbolName != nil)
}

