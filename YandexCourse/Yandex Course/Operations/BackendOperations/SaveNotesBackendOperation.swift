//
//  SaveNotesBackendOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - NetworkError

enum NetworkError {

    // MARK: - Cases

    case unreachable
}

// MARK: - SaveNotesBackendResult

enum SaveNotesBackendResult {

    // MARK: - Cases

    case success
    case failure(NetworkError)
}

// MARK: - SaveNotesBackendOperation

final class SaveNotesBackendOperation: BaseBackendOperation {

    // MARK: - Properties

    var result: SaveNotesBackendResult?

    // MARK: - Initialization

    init(notes: [Note]) {
        super.init()
    }

    // MARK: - Lyfe cycle

    override func main() {
        result = .failure(.unreachable)
        finish()
    }
}
