//
//  BaseDBOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - BaseDBOperation

class BaseDBOperation: AsyncOperation {

    // MARK: - Properties

    let notebook: FileNotebook

    // MARK: - Initialization

    init(notebook: FileNotebook) {
        self.notebook = notebook
        super.init()
    }
}
