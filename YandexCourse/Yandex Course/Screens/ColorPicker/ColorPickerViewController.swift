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

    @IBAction func doneTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
