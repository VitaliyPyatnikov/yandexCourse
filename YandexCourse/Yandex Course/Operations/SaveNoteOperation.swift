//
//  SaveNoteOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - SaveNoteOperation

final class SaveNoteOperation: AsyncOperation {

    // MARK: - Initialization

    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {

        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook)
        self.dbQueue = dbQueue

        super.init()

        saveToDb.completionBlock = {
            let saveToBackend = SaveNotesBackendOperation(notes: notebook.notes)
            saveToBackend.completionBlock = {
                guard let saveToBackendResult = saveToBackend.result else {
                    self.result = false
                    self.finish()
                    return
                }
                switch saveToBackendResult {
                case .success:
                    self.result = true
                case .failure:
                    self.result = false
                }
                self.finish()
            }
            backendQueue.addOperation(saveToBackend)
        }
    }

    // MARK: - Life cycle

    override func main() {
        dbQueue.addOperation(saveToDb)
    }

    // MARK: - Private

    private let saveToDb: SaveNoteDBOperation
    private let dbQueue: OperationQueue
    private(set) var result: Bool? = false
}
