//
//  LoadNotesDBOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - DBError

enum DBError {

    // MARK: - Cases

    case unprocessable
}

// MARK: - LoadNotesDBResult

enum LoadNotesDBResult {

    // MARK: - Cases

    case success([Note])
    case failure(DBError)
}

// MARK: - LoadNotesDBOperation

final class LoadNotesDBOperation: BaseDBOperation {

    // MARK: - Properties

    var result: LoadNotesDBResult?

    // MARK: - Initialization

    override init(notebook: FileNotebook) {
        super.init(notebook: notebook)
    }

    // MARK: - Life cycle

    override func main() {
        let isLoaded = notebook.loadFromFile()
        if isLoaded {
            let notes = notebook.notes
            result = .success(notes)
        } else {
            result = .failure(.unprocessable)
        }
        finish()
    }
}
