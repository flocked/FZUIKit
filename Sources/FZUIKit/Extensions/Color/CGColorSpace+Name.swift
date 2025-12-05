//
//  CGColorSpace+Name.swift
//
//
//  Created by Florian Zand on 09.03.25.
//

import CoreGraphics
import FZSwiftUtils

/// Constants that specify color space names.
public struct CGColorSpaceName: ExpressibleByStringLiteral {
    public let rawValue: String
    
    /// The color space model of the color space.
    public let model: CGColorSpaceModel
    
    ///The number of color components in the color space.
    public var numberOfComponents: Int {
        model.numberOfComponents
    }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.model = .rgb
    }
    
    public init(rawValue: CFString, model: CGColorSpaceModel) {
        self.rawValue = rawValue as String
        self.model = model
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
        self.model = .rgb
    }
    
    init(_ rawValue: CFString, model: CGColorSpaceModel = .rgb) {
        self.rawValue = rawValue as String
        self.model = model
    }
        
    // MARK: - RGB color spaces
    
    /// The Academy Color Encoding System color space with a linear transfer function.
    public static let acescgLinear = Self(CGColorSpace.acescgLinear)
    
    /// The Adobe RGB (1998) color space.
    public static let adobeRGB1998 = Self(CGColorSpace.adobeRGB1998)
    
    /// The color space that represents a calibrated or device-dependent RGB color space.
    public static let deviceRGB = Self("kCGColorSpaceDeviceRGB")
    
    /// The extended linear sRGB color space.
    public static let extendedLinearSRGB = Self(CGColorSpace.extendedLinearSRGB)
    
    /// The extended range sRGB color space.
    public static let extendedSRGB = Self(CGColorSpace.extendedSRGB)
    
    /// The generic RGB color space.
    public static let genericRGB = Self("kCGColorSpaceGenericRGB")
    
    /// The generic linear RGB color space.
    public static let genericRGBLinear = Self(CGColorSpace.genericRGBLinear)
    
    /// The linear sRGB color space.
    public static let linearSRGB = Self(CGColorSpace.linearSRGB)
    
    /// The ROMM RGB color space.
    public static let rommRGB = Self(CGColorSpace.rommrgb)
    
    /// The standard sRGB color space.
    public static let sRGB = Self(CGColorSpace.sRGB)
    
    // MARK: - P3 color spaces
    
    /// The Digital Cinema Initiatives P3 (DCI-P3) color space.
    public static let dcip3 = Self(CGColorSpace.dcip3)
    
    /// The Display P3 color space.
    public static let displayP3 = Self(CGColorSpace.displayP3)
    
    /// The Display P3 color space with Hybrid Log-Gamma (HLG) transfer function.
    public static let displayP3_HLG = Self(CGColorSpace.displayP3_HLG)
    
    /// The Display P3 color space with Perceptual Quantizer (PQ) transfer function.
    @available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *)
    public static let displayP3_PQ = Self(CGColorSpace.displayP3_PQ)
    
    /// The extended range version of the Display P3 color space.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static let extendedDisplayP3 = Self(CGColorSpace.extendedDisplayP3)
    
    /// The extended linear Display P3 color space.
    public static let extendedLinearDisplayP3 = Self(CGColorSpace.extendedLinearDisplayP3)
    
    /// The linear Display P3 color space.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public static let linearDisplayP3 = Self(CGColorSpace.linearDisplayP3)
    
    // MARK: - Grayscale color spaces
        
    /// The color space that represents a calibrated or device-dependent gray color space.
    public static let deviceGray = Self("kCGColorSpaceDeviceGray" as CFString, model: .monochrome)
    
    /// The extended range grayscale color space.
    public static let extendedGray = Self(CGColorSpace.extendedGray, model: .monochrome)
    
    /// The extended linear grayscale color space.
    public static let extendedLinearGray = Self(CGColorSpace.extendedLinearGray, model: .monochrome)
    
    /// The generic grayscale color space.
    public static let genericGray = Self("kCGColorSpaceGenericGray" as CFString, model: .monochrome)
    
    /// The generic grayscale color space with a gamma of 2.2.
    public static let genericGrayGamma2_2 = Self(CGColorSpace.genericGrayGamma2_2, model: .monochrome)
    
    /// The linear grayscale color space.
    public static let linearGray = Self(CGColorSpace.linearGray, model: .monochrome)
    
    // MARK: - ITUR color spaces
    
    /// The ITU-R BT.2020 color space.
    public static let itur_2020 = Self(CGColorSpace.itur_2020)
    
    /// The linear ITU-R BT.2020 color space.
    @available(macOS 12.0, iOS 15.1, tvOS 15.1, watchOS 8.1, *)
    public static let linearITUR_2020 = Self(CGColorSpace.linearITUR_2020)
    
    /// The extended range ITU-R BT.2020 color space.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static let extendedITUR_2020 = Self(CGColorSpace.extendedITUR_2020)
    
    /// The extended linear ITU-R BT.2020 color space.
    public static let extendedLinearITUR_2020 = Self(CGColorSpace.extendedLinearITUR_2020)
    
    /// The ITU-R BT.2020 color space with an sRGB transfer function.
    @available(macOS 12.0, iOS 15.1, tvOS 15.1, watchOS 8.1, *)
    public static let itur_2020_sRGBGamma = Self(CGColorSpace.itur_2020_sRGBGamma)
    
    /// The ITU-R BT.2100 color space with Hybrid Log-Gamma (HLG) transfer function.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static let itur_2100_HLG = Self(CGColorSpace.itur_2100_HLG)
    
    /// The ITU-R BT.2100 color space with Perceptual Quantizer (PQ) transfer function.
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public static let itur_2100_PQ = Self(CGColorSpace.itur_2100_PQ)
    
    /// The ITU-R BT.709 color space.
    public static let itur_709 = Self(CGColorSpace.itur_709)
    
    /// The ITU-R BT.709 color space with Hybrid Log-Gamma (HLG) transfer function.
    @available(macOS 12.0, iOS 15.1, tvOS 15.1, watchOS 8.1, *)
    public static let itur_709_HLG = Self(CGColorSpace.itur_709_HLG)
    
    /// The ITU-R BT.709 color space with Perceptual Quantizer (PQ) transfer function.
    @available(macOS 12.0, iOS 15.1, tvOS 15.1, watchOS 8.1, *)
    public static let itur_709_PQ = Self(CGColorSpace.itur_709_PQ)
    
    // MARK: - Other color spaces

    /// The generic CMYK color space.
    public static let genericCMYK = Self(CGColorSpace.genericCMYK, model: .cmyk)
    
    /// The color space that represents a calibrated or device-dependent CMYK color space.
    public static let deviceCMYK = Self("kCGColorSpaceDeviceCMYK" as CFString, model: .cmyk)
    
    /// The generic CIE Lab color space.
    public static let genericLab = Self(CGColorSpace.genericLab, model: .lab)
    
    /// The generic XYZ color space.
    public static let genericXYZ = Self(CGColorSpace.genericXYZ, model: .XYZ)
    
    /// Returns the names of all available color spaces with the specified model.
    public static func availableNames(with model: CGColorSpaceModel) -> [Self] {
        availableNames.filter({ $0.model == model })
    }
    
    /// Returns the names of all available color spaces.
    public static let availableNames: [CGColorSpaceName] = {
        var colorSpaceNames: [CGColorSpaceName] = [.acescgLinear, .adobeRGB1998, .deviceRGB, .extendedLinearSRGB, .extendedSRGB, .genericRGB, .genericRGBLinear, .linearSRGB, .rommRGB, .sRGB, .dcip3, .displayP3, .displayP3_HLG, .extendedLinearDisplayP3, .deviceGray, .extendedGray, .extendedLinearGray, .genericGray, .genericGrayGamma2_2, .linearGray, .extendedLinearITUR_2020, .itur_2020, .itur_709, .genericCMYK, .deviceCMYK, .genericLab, .genericXYZ]
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            colorSpaceNames += .displayP3_PQ
        }
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            colorSpaceNames += [.extendedDisplayP3, .extendedITUR_2020, .itur_2100_HLG, .itur_2100_PQ]
        }
        if #available(macOS 12.0, iOS 15.1, tvOS 15.1, watchOS 8.1, *) {
            colorSpaceNames += [.linearDisplayP3, .itur_2020_sRGBGamma, .itur_709_HLG, .itur_709_PQ, .linearITUR_2020]
        }
        let modalColorSpaces = Dictionary(grouping: colorSpaceNames, by: \.model.rawValue)
        return modalColorSpaces.keys.sorted(.smallestFirst).flatMap({ (modalColorSpaces[$0] ?? []).sorted(by: \.rawValue) })
    }()
}

extension CFType where Self == CGColorSpace {
    /// Creates a color space with the specified name.
    public init?(name: CGColorSpaceName) {
        self.init(CGColorSpace(name: name.rawValue as CFString))
    }
}
