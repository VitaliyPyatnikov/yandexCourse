//
//  UIImageExtension.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 27.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

extension UIImage {
    public convenience init?(rgbaBytes: [UInt8], width: Int, height: Int) {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let data = Data(rgbaBytes)
        let mutableData = UnsafeMutableRawPointer.init(mutating: (data as NSData).bytes)
        let context = CGContext(data: mutableData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue)
        guard let cgImage = context?.makeImage() else {
            return nil
        }
        self.init(cgImage: cgImage)
    }

    public static func drawImage(ofSize size: CGSize, path: UIBezierPath, fillColor: UIColor) -> UIImage? {
        let imageRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(fillColor.cgColor)
        context?.addPath(path.cgPath)
        context?.drawPath(using: .fill)
        defer {
            UIGraphicsEndImageContext()
        }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        return nil
    }
}
