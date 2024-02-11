//
//  UICollectionViewLayout+Layout.swift
//
//
//  Created by Florian Zand on 11.02.24.
//

#if os(iOS)
import UIKit

extension UICollectionViewLayout {
    /**
     Creates a compositional layout that contains only list sections.
     
     - Parameters:
        - appearance: The overall appearance of the list.
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - footerMode: The type of footer to use for the list.
     */
    public static func list(_ appearance: UICollectionLayoutListConfiguration.Appearance, showsSeparators: Bool = true, headerMode: UICollectionLayoutListConfiguration.HeaderMode = .none, footerMode: UICollectionLayoutListConfiguration.FooterMode = .none) -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: appearance)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    /**
     Creates a compositional layout that contains only list sections.
     
     - Parameters:
        - appearance: The overall appearance of the list.
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - headerTopPadding: The header top padding.
        - footerMode: The type of footer to use for the list.
     */
    @available(iOS 15.0, tvOS 15.0, *)
    public static func list(_ appearance: UICollectionLayoutListConfiguration.Appearance, showsSeparators: Bool = true, headerMode: UICollectionLayoutListConfiguration.HeaderMode = .none, headerTopPadding: CGFloat?, footerMode: UICollectionLayoutListConfiguration.FooterMode = .none) -> UICollectionViewCompositionalLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: appearance)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        configuration.headerTopPadding = headerTopPadding
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

extension UICollectionLayoutListConfiguration {
    /**
     A configuration for creating a plain list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - footerMode: The type of footer to use for the list.
     */
    public static func plain(showsSeparators: Bool = false, headerMode: HeaderMode = .none, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        return configuration
    }
    
    /**
     A configuration for creating a grouped list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - footerMode: The type of footer to use for the list.
     */
    public static func grouped(showsSeparators: Bool = false, headerMode: HeaderMode = .none, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        return configuration
    }
    
    /**
     A configuration for creating an inset grouped list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - footerMode: The type of footer to use for the list.
     */
    public static func insetGrouped(showsSeparators: Bool = false, headerMode: HeaderMode = .none, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        return configuration
    }
    
    /**
     A configuration for creating a sidebar list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - footerMode: The type of footer to use for the list.
     */
    public static func sidebar(showsSeparators: Bool = false, headerMode: HeaderMode = .none, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        return configuration
    }
    
    /**
     A configuration for creating a plain sidebar list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - footerMode: The type of footer to use for the list.
     */
    public static func sidebarPlain(showsSeparators: Bool = false, headerMode: HeaderMode = .none, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        return configuration
    }
}

@available(iOS 15.0, tvOS 15.0, *)
extension UICollectionLayoutListConfiguration {
    /**
     A configuration for creating a plain list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - headerTopPadding: The header top padding.
        - footerMode: The type of footer to use for the list.
     */
    public static func plain(showsSeparators: Bool = false, headerMode: HeaderMode = .none, headerTopPadding: CGFloat?, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        configuration.headerTopPadding = headerTopPadding
        return configuration
    }
    
    /**
     A configuration for creating a grouped list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - headerTopPadding: The header top padding.
        - footerMode: The type of footer to use for the list.
     */
    public static func grouped(showsSeparators: Bool = false, headerMode: HeaderMode = .none, headerTopPadding: CGFloat?, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        configuration.headerTopPadding = headerTopPadding
        return configuration
    }
    
    /**
     A configuration for creating an inset grouped list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - headerTopPadding: The header top padding.
        - footerMode: The type of footer to use for the list.
     */
    public static func insetGrouped(showsSeparators: Bool = false, headerMode: HeaderMode = .none, headerTopPadding: CGFloat?, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        configuration.headerTopPadding = headerTopPadding
        return configuration
    }
    
    /**
     A configuration for creating a sidebar list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - headerTopPadding: The header top padding.
        - footerMode: The type of footer to use for the list.
     */
    public static func sidebar(showsSeparators: Bool = false, headerMode: HeaderMode = .none, headerTopPadding: CGFloat?, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        configuration.headerTopPadding = headerTopPadding
        return configuration
    }
    
    /**
     A configuration for creating a plain sidebar list layout.
     
     - Parameters:
        - showsSeparators: A Boolean value that determines whether the list shows separators between cells.
        - headerMode: The type of header to use for the list.
        - headerTopPadding: The header top padding.
        - footerMode: The type of footer to use for the list.
     */
    public static func sidebarPlain(showsSeparators: Bool = false, headerMode: HeaderMode = .none, headerTopPadding: CGFloat?, footerMode: FooterMode = .none) -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        configuration.showsSeparators = showsSeparators
        configuration.headerMode = headerMode
        configuration.footerMode = footerMode
        configuration.headerTopPadding = headerTopPadding
        return configuration
    }
}
#endif
