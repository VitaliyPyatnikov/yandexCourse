//
//  SaveNoteDBOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - SaveNoteDBOperation

final class SaveNoteDBOperation: BaseDBOperation {

    // MARK: - Initialization

    init(note: Note, notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }

    // MARK: - Life cycle

    override func main() {
        notebook.add(note)
        // just now result in unused
        // maybe add result as return type
        let _ = notebook.saveToFile()
        finish()
    }

    // MARK: - Private

    private let note: Note
}
