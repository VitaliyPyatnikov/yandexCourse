//
//  GalleryCollectionViewCell.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 01.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - GalleryCollectionViewCell

final class GalleryCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(with image: UIImage) {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        imageView.image = image
    }
}
