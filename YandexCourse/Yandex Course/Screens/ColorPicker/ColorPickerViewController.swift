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
    }
}
