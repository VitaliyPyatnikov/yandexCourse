//
//  LoadNotesBackendOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - LoadNotesBackendResult

enum LoadNotesBackendResult {

    // MARK: - Cases

    case success([Note])
    case failure(NetworkError)
}

// MARK: - LoadNotesBackendOperation


final class LoadNotesBackendOperation: BaseBackendOperation {

    // MARK: - Properties

    var result: LoadNotesBackendResult?

    // MARK: - Initialization

    override init() {
        super.init()
    }

    // MARK: - Lyfe cycle

    override func main() {
        result = .failure(.unreachable)
        finish()
    }
}
