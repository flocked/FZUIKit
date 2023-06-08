//
//  File.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUIView {
    class func view<T: NSUIView>(with owner: AnyObject?,
                               bundle: Bundle = Bundle.main) throws -> T {
        let className = String(describing: self)
        return try self.view(from: className, owner: owner, bundle: bundle)
    }

    class func view<T: NSUIView>(from nibName: String,
                               owner: AnyObject?,
                               bundle: Bundle = Bundle.main) throws -> T {
        #if os(macOS)
        var topLevelObjects: NSArray? = []
        guard bundle.loadNibNamed(NSNib.Name(nibName), owner: owner, topLevelObjects: &topLevelObjects) else {
                throw NibLoadingError.nibNotFound
        }
        let objects = topLevelObjects
        #else
        if bundle.path(forResource: nibName, ofType: "nib") == nil {
            throw NibLoadingError.nibNotFound
        }
        let objects = bundle.loadNibNamed(nibName, owner: owner, options: nil) as [AnyObject]?
        #endif

        let views = objects?.filter { object in object is NSUIView }
        
        if let views = views, views.count > 1 {
            throw NibLoadingError.multipleTopLevelObjectsFound
        }
        
        guard let view = views?.first as? T else {
            throw NibLoadingError.topLevelObjectNotFound
        }
        
        return view
    }
}

public enum NibLoadingError: Error {
    case nibNotFound
    case topLevelObjectNotFound
    case multipleTopLevelObjectsFound
}
