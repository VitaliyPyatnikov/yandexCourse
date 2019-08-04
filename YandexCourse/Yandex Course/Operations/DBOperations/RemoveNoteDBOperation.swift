//
//  RemoveNoteDBOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - RemoveNoteDBResult

enum RemoveNoteDBResult {

    // MARK: - Cases

    case success
    case failure(DBError)
}

// MARK: - RemoveNoteDBOperation

final class RemoveNoteDBOperation: BaseDBOperation {

    // MARK: - Properties

    var result: RemoveNoteDBResult?

    // MARK: - Initialization

    init(note: Note, notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }

    // MARK: - Life cycle

    override func main() {
        let uid = note.uid
        notebook.remove(with: uid)
        // just now result in unused
        // maybe add result as return type
        let _ = notebook.saveToFile()
        finish()
    }

    // MARK: - Private

    private let note: Note
}
