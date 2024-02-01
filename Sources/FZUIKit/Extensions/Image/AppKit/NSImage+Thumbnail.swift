//
//  NSImage+Thumbnail.swift
//
//
//  Created by Florian Zand on 23.03.23.
//

import FZSwiftUtils

#if os(macOS)
    import AppKit

    public extension NSImage {
        /**
          Decodes an image synchronously and provides a new one for display in views and animations.

          The Animation Hitches [instrument](https://help.apple.com/instruments/mac/current/) measures system performance for multiple stages of preparing views for display. It can show you the exact cause of an animation hitch, which appears to the user as an interruption or jump in an animation that should be smooth. If Animation Hitches indicates that decoding an image takes too long and causes hitches, use this method to move the decoding work to the background. For more information on using Instruments, see Instruments Help.

          Avoid using this method on the main thread unless you previously started preparing an image with prepareForDisplay(completionHandler:). If you’re decoding many images, such as with a collection view, calling this method from a concurrent queue can degrade performance by demanding too many system threads. Use a serial queue instead.

          This method returns a new image object for efficient display by an image view. Assign the image object created by this method to the image property of the image view. If NSImageView can render the image without decoding, this method returns a valid image without further processing. If the system can’t decode the image, such as an image created from a CIImage, the method returns `nil`.

          AppKit doesn’t associate the prepared image with the original, or with any related variants from an asset catalog. If your app environment dynamically changes display traits, listen for changes in the trait environment and prepare new images when the environment changes.

          ```swift
         func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
              guard let imageItem = item as? ImageItem else {
                  fatalError("Expected `\(ImageItem.self)` type for reuseIdentifier \(reuseIdentifier). Check the configuration in Main.storyboard.")
              }
              let item = models[indexPath.item]
              if let image = preparedImageCache.object(forKey: item.id), imageItem.itemIdentifier == item.id {
                  // Use a cached prepared image.
                 imageItem.imageView.image = image
              } else {
                  // If the data source didn't prefetch the item, prepare the image on a serial dispatch queue.
                  serialQueue.async { [weak preparedImageCache, placeholderImage] in
                      item.loadAsset()
                      let preparedImage: NSImage = item.image.preparingForDisplay() ?? placeholderImage
                      preparedImageCache?.setObject(preparedImage, forKey: item.id)
                      DispatchQueue.main.async {
                          if imageItem.itemIdentifier == item.id {
                             imageItem.imageView.image = preparedImage
                          }
                      }
                  }
              }
          }
          ```

          - Returns: A new version of the image object for display. If the system can’t decode the image, this method returns `nil`.
          */
        func preparingForDisplay() -> NSImage? {
            guard let source = ImageSource(image: self) else { return nil }
            let options = imageOptionsForDisplaying()
            if let cgImage = source.getImage(options: options) {
                return NSImage(cgImage: cgImage)
            }
            return nil
        }
        
        /**
         Decodes an image asynchronously and provides a new one for display in views and animations.

         The Animation Hitches [instrument](https://help.apple.com/instruments/mac/current/) measures system performance for multiple stages of preparing views for display. It can show you the exact cause of an animation hitch, which appears to the user as an interruption or jump in an animation that should be smooth. If Animation Hitches indicates that decoding an image takes too long and causes hitches, use this method to move the decoding work to the background.
         
         This method creates a new image object and passes it to the completion handler. The new image is ready for efficient display by an image view. Assign the `image` this method creates to the image property of an image view. If `NSImageView` can render the image without decoding, this method passes the completion handler a valid image without further processing. If the system can’t decode the image, such as an image created from a `CIImage`, the method passes `nil` to the completion handler.
         
         AppKit doesn’t associate the prepared image with the original, or with any related variants from an asset catalog. If your app environment dynamically changes display traits, listen for changes in the trait environment and prepare new images when the environment changes.

         - Returns: A new version of the image object for display. If the system can’t decode the image, this method returns `nil.
         */
        func byPreparingForDisplay() async -> NSImage? {
            guard let source = ImageSource(image: self) else { return nil }
            let options = imageOptionsForDisplaying()
            if let cgImage = await source.image(options: options) {
                return NSImage(cgImage: cgImage)
            }
            return nil
        }

        /**
         Decodes an image asynchronously and provides a new one for display in views and animations.

         The Animation Hitches [instrument](https://help.apple.com/instruments/mac/current/) measures system performance for multiple stages of preparing views for display. It can show you the exact cause of an animation hitch, which appears to the user as an interruption or jump in an animation that should be smooth. If Animation Hitches indicates that decoding an image takes too long and causes hitches, use this method to move the decoding work to the background.
         
         This method creates a new image object and passes it to the completion handler. The new image is ready for efficient display by an image view. Assign the `image` this method creates to the image property of an image view. If `NSImageView` can render the image without decoding, this method passes the completion handler a valid image without further processing. If the system can’t decode the image, such as an image created from a `CIImage`, the method passes `nil` to the completion handler.
         
         AppKit doesn’t associate the prepared image with the original, or with any related variants from an asset catalog. If your app environment dynamically changes display traits, listen for changes in the trait environment and prepare new images when the environment changes.

         - Parameters:
            - completionHandler: The closure to call when the function finishes preparing the image. This completion handler takes one parameter:
                -  image: A new version of the image object for display. If the system can’t decode the image, the parameter value is `nil.

         ```swift
         func collectionView( _ collectionView: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            for path in indexPaths {
                let item = models[path.item]
                if preparedImageCache.object(forKey: item.id) == nil {
                    item.loadAsset()
                    item.image.prepareForDisplay { [weak preparedImageCache] preparedImage in
                        if let preparedImage = preparedImage {
                            preparedImageCache?.setObject(preparedImage, forKey: item.id)
                        }
                    }
                }
            }
         }
         ```
         */
        func prepareForDisplay(completionHandler: @escaping (NSImage?) -> Void) {
            guard let source = ImageSource(image: self) else {
                completionHandler(nil)
                return
            }
            let options = imageOptionsForDisplaying()
            source.image(options: options, completionHandler: { cgImage in
                if let cgImage = cgImage {
                    completionHandler(NSImage(cgImage: cgImage))
                } else {
                    completionHandler(nil)
                }
            })
        }

        /**
         Returns a new thumbnail image at the specified size.

         When the native image size is much larger than the bounds of the view, decoding the full size image creates unnecessary memory overhead. By creating a thumbnail image at a specified size with this method, you avoid the overhead of decoding the image at its full size.

         - Parameter size: The desired size of the thumbnail.

         ```swift
         func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath
             indexPath: NSIndexPath) -> NSCollectionViewItem {
            let item = self.collectionView.makeItemWithIdentifier("imageItem", forIndexPath: indexPath)

            let imageFile = imageFiles[indexPath.item]
            item.nameLabel?.text = imageFile.name
            let thumbnail = imageFile.image.preparingThumbnail(of: thumbnailSize)
            item.thumbnailImageView.image = thumbnail
            return item
         }
         ```
         - Returns: A new thumbnail image. Returns `nil` if the original image isn’t backed by a `CGImage` or if the image data is corrupt or malformed.
         */
        func preparingThumbnail(of size: CGSize) -> NSImage? {
            guard let source = ImageSource(image: self) else { return nil }
            let options = thumbnailOptions(for: size)
            if let cgImage = source.getThumbnail(options: options) {
                return NSImage(cgImage: cgImage)
            }
            return nil
        }

        /**
         Creates a thumbnail image at the specified size asynchronously on a background thread.
         
         When the native image size is much larger than the bounds of the view, decoding the full size image creates unnecessary memory overhead. By creating a thumbnail image at a specified size with this method, you avoid the overhead of decoding the image at its full size.
         
         This method asynchronously creates the thumbnail image on a background thread and calls the completion handler on that thread. If your app updates the UI in the completion handler, schedule the UI update on the main thread.

         - Parameter size: The desired size of the thumbnail.

         - Returns: A new thumbnail image. Returns `nil` if the original image isn’t backed by a `CGImage` or if the image data is corrupt or malformed.
         */
        func prepareThumbnail(for size: CGSize) async -> NSImage? {
            guard let source = ImageSource(image: self) else { return nil }
            let options = thumbnailOptions(for: size)
            if let cgImage = await source.thumbnail(options: options) {
                return NSImage(cgImage: cgImage)
            }
            return nil
        }

        /**
         Creates a thumbnail image at the specified size asynchronously on a background thread.

         When the native image size is much larger than the bounds of the view, decoding the full size image creates unnecessary memory overhead. By creating a thumbnail image at a specified size with this method, you avoid the overhead of decoding the image at its full size.
         This method asynchronously creates the thumbnail image on a background thread and calls the completion handler on that thread. If your app updates the UI in the completion handler, schedule the UI update on the main thread.

         - Parameters:
            - size: The desired size of the thumbnail.
            - completionHandler: The completion handler to call when the thumbnail is ready. The handler executes on a background thread. The completion handler takes the following parameters:
                -  thumbnail: A new thumbnail image. This parameter is `nil` if the original image isn’t backed by a `CGImage` or if the image data is corrupt or malformed.

         ```swift
         func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath
             indexPath: NSIndexPath) -> NSCollectionViewItem {
            let item = self.collectionView.makeItemWithIdentifier("imageItem", forIndexPath: indexPath)

            let imageFile = imageFiles[indexPath.item]
            item.nameLabel?.text = imageFile.name
            imageFile.image.prepareThumbnail(of: thumbnailSize) { thumbnail in
                DispatchQueue.main.async {
                    item.thumbnailImageView.image = thumbnail
                }
            }
            return item
         }
         ```
         */
        func preparingThumbnail(of size: CGSize, completionHandler: @escaping (_ thumbnail: NSImage?) -> Void) {
            guard let source = ImageSource(image: self) else {
                completionHandler(nil)
                return
            }
            let options = thumbnailOptions(for: size)
            source.thumbnail(options: options, completionHandler: { cgImage in
                if let cgImage = cgImage {
                    completionHandler(NSImage(cgImage: cgImage))
                } else {
                    completionHandler(nil)
                }
            })
        }

        fileprivate func imageOptionsForDisplaying() -> ImageSource.ImageOptions {
            var options = ImageSource.ImageOptions()
            options.shouldCache = true
            options.shouldDecodeImmediately = true
            options.subsampleFactor = .factor4
            return options
        }

        fileprivate func thumbnailOptions(for size: CGSize) -> ImageSource.ThumbnailOptions {
            var options = ImageSource.ThumbnailOptions()
            options.maxSize = Int(max(size.width, size.height))
            options.shouldCache = true
            options.shouldDecodeImmediately = true
            options.createOption = .always
            return options
        }
    }

#endif
