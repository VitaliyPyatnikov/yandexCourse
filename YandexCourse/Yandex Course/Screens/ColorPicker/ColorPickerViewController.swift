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
        colorizeImageView()
        let currentPoint = CGPoint(x: selectionViewConstraintX.constant,
                                   y: selectionViewConstraintY.constant)
        updateUI(at: currentPoint)
    }
    @IBAction func doneTapped(_ sender: UIButton) {
        let currentPoint = CGPoint(x: selectionViewConstraintX.constant,
                                   y: selectionViewConstraintY.constant)
        let color = getColor(at: currentPoint)
        editNoteWorker?.setCustomColor(color)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Properties

    weak var editNoteWorker: EditNoteColorWorker?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider()
        colorizeImageView()
        setupColorSelectionView()
        setupColorView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            updateUI(withTouch: touch)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            updateUI(withTouch: touch)
        }
    }

    // MARK: - Private

    /// Identifies spectre lines direction
    private var hueHorizontal = true
    private var colorSelectionView: UIView = UIView()
    private var selectionViewConstraintX: NSLayoutConstraint = NSLayoutConstraint()
    private var selectionViewConstraintY: NSLayoutConstraint = NSLayoutConstraint()

    private func updateUI(withTouch touch: UITouch) {
        let point = touch.location(in: colorImageView)
        updateUI(at: point)
    }
    private func updateUI(at point: CGPoint) {
        if colorImageView.point(inside: point, with: nil) {
            updatePositionOfSelectorView(withPoint: point)
            let color = getColor(at: point)
            updateColorSelectionBackgroundColor(with: color)
            updateColorView(with: color)
        }
    }
    private func updateColorView(with color: UIColor) {
        colorView.backgroundColor = color
        let colorHexValue = color.hexValue()
        colorLabel.text = colorHexValue
    }
    private func setupSlider() {
        brightnessSlider.value = 1.0
    }
    private func setupColorView() {
        colorPlaceholderView.layer.cornerRadius = 5.0
        colorView.layer.cornerRadius = 5.0
        colorPlaceholderView.layer.borderWidth = 1.0
        colorPlaceholderView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1.0
        colorView.layer.borderColor = UIColor.black.cgColor
        colorPlaceholderView.backgroundColor = .white
        let color = getColor(at: CGPoint(x: 0, y: 0))
        colorView.backgroundColor = color
        let colorHexValue = color.hexValue()
        colorLabel.text = colorHexValue
    }

    // MARK: - Color Image view

    private func colorizeImageView() {
        let size = colorImageView.bounds.size
        colorImageView.image = foregroundImage(with: size)
    }
    private func updateColorSelectionBackgroundColor(with color: UIColor) {
        colorSelectionView.backgroundColor = color
    }
    private func getColor(at point: CGPoint) -> UIColor {
        let (hue, saturation) = hueAndSaturation(at: point, size: colorImageView.bounds.size)
        let brightness = CGFloat(brightnessSlider.value)
        return UIColor(hue: hue,
                       saturation: saturation,
                       brightness: brightness,
                       alpha: 1.0)
    }

    /// Colorize image view
    private func foregroundImage(with size: CGSize) -> UIImage {
        let intWidth = Int(size.width)
        let intHeight = Int(size.height)
        var imageData = [UInt8](repeating: 1, count: (4 * intWidth * intHeight))
        for i in 0 ..< intWidth {
            for j in 0 ..< intHeight {
                let index = 4 * (i + j * intWidth)
                // rendering image transforms it as it it was mirrored around x = -y axis - adjusting for it by switching i and j here
                let (hue, saturation) = hueAndSaturation(at: CGPoint(x: i, y: j), size: size)
                let brightness = CGFloat(brightnessSlider.value)
                let (r, g, b) = UIColor.rgbFrom(hue: hue, saturation: saturation, brightness: brightness)
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

    // MARK: - Color selection view

    private func setupColorSelectionView() {
        colorSelectionView.translatesAutoresizingMaskIntoConstraints = false
        colorImageView.addSubview(colorSelectionView)
        // setup preview
        colorSelectionView.layer.masksToBounds = true
        colorSelectionView.layer.borderWidth = 4.0
        colorSelectionView.layer.borderColor = UIColor.gray.cgColor
        colorSelectionView.layer.cornerRadius = 10.0
        colorSelectionView.alpha = 1.0
        colorSelectionView.backgroundColor = .clear

        setupConstraintsForSelectionView()
    }
    private func setupConstraintsForSelectionView() {
        selectionViewConstraintX = NSLayoutConstraint(item: colorSelectionView,
                                                      attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: colorImageView,
                                                      attribute: .left,
                                                      multiplier: 1,
                                                      constant: 0)
        selectionViewConstraintY = NSLayoutConstraint(item: colorSelectionView,
                                                      attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: colorImageView,
                                                      attribute: .top,
                                                      multiplier: 1,
                                                      constant: 0)
        let widthConstraint = NSLayoutConstraint(item: colorSelectionView,
                                                 attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 20)
        let heightConstraint = NSLayoutConstraint(item: colorSelectionView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 20)
        NSLayoutConstraint.activate([selectionViewConstraintX,
                                     selectionViewConstraintY,
                                     widthConstraint,
                                     heightConstraint])
    }
    private func updatePositionOfSelectorView(withPoint point: CGPoint) {
        selectionViewConstraintX.constant = point.x
        selectionViewConstraintY.constant = point.y
    }
}
