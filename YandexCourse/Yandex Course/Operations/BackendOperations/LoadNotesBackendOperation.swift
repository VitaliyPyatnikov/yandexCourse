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
        loadNotes { [weak self] (result, gistId) in
            self?.result = result
            self?.finish()
        }
    }

    // MARK: - Private

    private let loadManager: LoadManager = WebEngine()
    private let storage = Storage()

    private func loadNotes(completionHandler: @escaping LoadCompletionHandler) {
        let gistId = storage.gistId
        loadManager.load(withGistId: gistId) { [weak self] result, gistId in
            switch result {
            case .failure(.retryNeeded):
                if !gistId.isEmpty {
                    self?.storage.gistId = gistId
                    self?.loadManager.load(withGistId: gistId, loadCompletion: completionHandler)
                }
            default:
                completionHandler(result, "")
            }
        }
    }
}
