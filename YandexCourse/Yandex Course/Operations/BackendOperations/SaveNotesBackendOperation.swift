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
    case unprocessableEntity
    case serverError
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
        self.notes = notes
        super.init()
    }

    // MARK: - Lyfe cycle

    override func main() {
        uploadNotes { [weak self] result, gistId in
            self?.updateGitsIdIfNeeded(gistId)
            self?.result = result
            self?.finish()
        }
    }

    // MARK: - Private

    private let uploadManager: UploadManager = WebEngine()
    private let storage = Storage()
    private var notes: [Note]

    private var notesForUpload: String? {
        var jsons: [[String: Any]] = []
        notes.forEach {
            jsons.append($0.json)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsons, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                Log.error("Can't parse json to string")
                return nil
            }
            return jsonString
        } catch  {
            Log.error(error.localizedDescription)
            return nil
        }
    }
    private var gistRequestData: Data? {
        guard let notesAsString = notesForUpload else {
            Log.error("Can't create string from notes")
            return nil
        }
        let content = Content(content: notesAsString)
        let filename = GistRequest.filename
        var files: [String : Content] = [:]
        files.updateValue(content, forKey: filename)
        let gistRequest = GistRequest(files: files)
        guard let encodedRequestData = try? JSONEncoder().encode(gistRequest) else {
            Log.error("Can't encode data")
            return nil
        }
        return encodedRequestData
    }
    private func uploadNotes(uploadCompletion: @escaping UploadCompletionHandler) {
        guard let dataToUpload = gistRequestData else {
            Log.error("Can't get data for upload")
            return
        }
        let gistId = storage.gistId
        if gistId.isEmpty {
            uploadManager.upload(with: dataToUpload, uploadCompletion: uploadCompletion)
        } else {
            uploadManager.update(gistId: gistId,
                                 with: dataToUpload,
                                 uploadCompletion: uploadCompletion)
        }
    }
    private func updateGitsIdIfNeeded(_ gistId: String) {
        let currentGistId = storage.gistId
        if currentGistId.isEmpty || currentGistId != gistId {
            storage.gistId = gistId
        }
    }
}
