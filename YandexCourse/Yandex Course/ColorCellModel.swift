//
//  ColorCellModel.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 20.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - ColorCellModel

struct ColorCellModel {
    let color: NoteColor
    let isSelected: Bool
}

// MARK: - NoteColor

enum NoteColor: Equatable {
    case white
    case red
    case green
    case custom(color: UIColor)

    var savedColor: UIColor {
        switch self {
        case .white:
            return .white
        case .red:
            return .red
        case .green:
            return .green
        case .custom(let color):
            return color
        }
    }
}
