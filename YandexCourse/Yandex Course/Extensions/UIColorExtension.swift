//
//  UIColorExtension.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 27.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: - Initialization

    convenience init?(hexRGBA: String?) {
        guard let rgba = hexRGBA,
            let val = Int(rgba.replacingOccurrences(of: "#", with: ""), radix: 16) else {
                return nil
        }
        self.init(red: CGFloat((val >> 24) & 0xff) / 255.0,
                  green: CGFloat((val >> 16) & 0xff) / 255.0,
                  blue: CGFloat((val >> 8) & 0xff) / 255.0,
                  alpha: CGFloat(val & 0xff) / 255.0)
    }
    convenience init?(hexRGB: String?) {
        guard let rgb = hexRGB else {
            return nil
        }
        self.init(hexRGBA: rgb + "ff") // Add alpha = 1.0
    }

    // MARK: - Properties

    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let (red, green, blue, _) = rgba
        return (red, green, blue)
    }

    // MARK: - Functions

    func hexValue(alwaysIncludeAlpha: Bool = false) -> String {
        let (red, green, blue, alpha) = rgba
        let r = colorComponentToUInt8(red)
        let g = colorComponentToUInt8(green)
        let b = colorComponentToUInt8(blue)
        let a = colorComponentToUInt8(alpha)

        if alpha == 1 && !alwaysIncludeAlpha {
            return String(format: "%02lX%02lX%02lX", r, g, b)
        }
        return String(format: "%02lX%02lX%02lX%02lX", r, g, b, a)
    }

    // MARK: - Static Functions

    static func getUInt8Value(fromColorComponent component: CGFloat) -> UInt8 {
        return UInt8(max(0, min(255, round(255 * component))))
    }
    /// Translates color from HSB system to RGB, given constant Brightness value of 1.
    /// - Parameters:
    ///   - hue: hue Hue value in range from 0 to 1 (inclusive).
    ///   - saturation: saturation Saturation value in range from 0 to 1 (inclusive).
    ///   - brightness: brightness Brightness value in range from 0 to 1 (inclusive).
    static func rgbFrom(hue: CGFloat,
                        saturation: CGFloat,
                        brightness: CGFloat)
        -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
            let hPrime = Int(hue * 6)
            let f = hue * 6 - CGFloat(hPrime)
            let p = brightness * (1 - saturation)
            let q = brightness * (1 - f * saturation)
            let t = brightness * (1 - (1 - f) * saturation)

            switch hPrime % 6 {
            case 0:
                return (brightness, t, p)
            case 1:
                return (q, brightness, p)
            case 2:
                return (p, brightness, t)
            case 3:
                return (p, q, brightness)
            case 4:
                return (t, p, brightness)
            default:
                return (brightness, p, q)
            }
    }

    // MARK: - Private

    private func colorComponentToUInt8(_ component: CGFloat) -> UInt8 {
        return UInt8(max(0, min(255, round(255 * component))))
    }
}


