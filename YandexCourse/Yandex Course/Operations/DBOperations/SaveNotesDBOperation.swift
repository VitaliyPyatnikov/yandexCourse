//
//  SaveNotesDBOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - SaveNotesDBOperation

final class SaveNotesDBOperation: BaseDBOperation {

    // MARK: - Initialization

    init(notes: [Note], notebook: FileNotebook) {
        self.notes = notes
        super.init(notebook: notebook)
    }

    // MARK: - Life cycle

    override func main() {
        // just now result in unused
        // maybe add result as return type
        let _ = notebook.saveToFile()
        finish()
    }

    // MARK: - Private

    private let notes: [Note]
}
