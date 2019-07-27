//
//  ColorPickerViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 21.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - ColorPickerViewController

final class ColorPickerViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var colorPlaceholderView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var brightnessSlider: UISlider!

    // MARK: - IBActions

    @IBAction func brightnessSliderMoved(_ sender: UISlider) {
    }

    @IBAction func doneTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        colorizeImageView()
    }

    // MARK: - Private
    /// Identifies spectre lines direction
    private var hueHorizontal = true

    // MARK: - Color Image view

    private func colorizeImageView() {
        let size = colorImageView.bounds.size
        colorImageView.image = foregroundImage(with: size)
    }

    /// Colorize image view
    private func foregroundImage(with size: CGSize) -> UIImage {
        let intWidth = Int(size.width)
        let intHeight = Int(size.height)
        var imageData = [UInt8](repeating: 1, count: (4 * intWidth * intHeight))
        for i in 0 ..< intWidth {
            for j in 0 ..< intHeight {
                let index = 4 * (i + j * intWidth)
                let (hue, saturation) = hueAndSaturation(at: CGPoint(x: i, y: j), size: size) // rendering image transforms it as it it was mirrored around x = -y axis - adjusting for it by switching i and j here
                let (r, g, b) = UIColor.rgbFrom(hue: hue, saturation: saturation, brightness: 1)
                imageData[index] = UIColor.getUInt8Value(fromColorComponent: r)
                imageData[index + 1] = UIColor.getUInt8Value(fromColorComponent: g)
                imageData[index + 2] = UIColor.getUInt8Value(fromColorComponent: b)
                imageData[index + 3] = 255
            }
        }
        return UIImage(rgbaBytes: imageData, width: intWidth, height: intHeight) ?? UIImage()
    }
    /// Get hue color
    private func hueAndSaturation(at point: CGPoint, size: CGSize) -> (hue: CGFloat, saturation: CGFloat) {
        let hue = hueHorizontal ? point.x / size.width : point.y / size.height
        let saturation = hueHorizontal ? point.y / size.height : point.x / size.width
        return (max (0, min(1, hue)), 1 - max(0, min(1, saturation)))
    }
}
