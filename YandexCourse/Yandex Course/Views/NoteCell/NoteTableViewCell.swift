//
//  NoteTableViewCell.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 28.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - NoteTableViewCell

final class NoteTableViewCell: UITableViewCell {

    // MARK: - IBOutlet

    @IBOutlet weak var noteColorView: UIView!
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var noteDescriptionLabel: UILabel!

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Internal

    func setup(with model: NoteCellModel) {
        noteColorView.backgroundColor = model.color
        noteTitleLabel.text = model.title
        noteDescriptionLabel.text = model.description
    }
}
