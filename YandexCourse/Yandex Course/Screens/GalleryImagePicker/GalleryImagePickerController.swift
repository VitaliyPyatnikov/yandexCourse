//
//  GalleryImagePickerController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 01.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - GalleryImagePickerController

final class GalleryImagePickerController: UIImagePickerController {

    // MARK: - Properties

    weak var pickerDelegate: GalleryWorker?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
    }

    private func setupPicker() {
        delegate = self
        allowsEditing = true
        mediaTypes = ["public.image", "public.movie"]
        sourceType = .photoLibrary
    }
}

// MARK: - UIImagePickerControllerDelegate

extension GalleryImagePickerController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            pickerDelegate?.add(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate

extension GalleryImagePickerController: UINavigationControllerDelegate {

}

