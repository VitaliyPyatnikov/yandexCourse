//
//  LoadNotesOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - LoadNotesOperation

final class LoadNotesOperation: AsyncOperation {

    // MARK: - Initialization

    init(notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {

        loadFromBackend = LoadNotesBackendOperation()
        self.backendQueue = backendQueue

        super.init()

        loadFromBackend.completionBlock = {
            guard let loadFromBackendResult = self.loadFromBackend.result else {
                self.result = .failure(.unprocessable)
                self.finish()
                return
            }
            switch loadFromBackendResult {
            case let .success(notes):
                self.result = .success(notes)
                self.save(notes: notes, with: notebook, at: dbQueue)
             case .failure:
                self.loadFromDB(to: notebook, with: dbQueue)
            }
        }
    }

    // MARK: - Life cycle

    override func main() {
        backendQueue.addOperation(loadFromBackend)
    }

    // MARK: - Private

    private let loadFromBackend: LoadNotesBackendOperation
    private let backendQueue: OperationQueue
    private(set) var result: LoadNotesDBResult?

    private func loadFromDB(to notebook: FileNotebook, with dbQueue: OperationQueue) {
        let loadFromDB = LoadNotesDBOperation(notebook: notebook)
        loadFromDB.completionBlock = {
            guard let loadFromDBResult = loadFromDB.result else {
                self.result = .failure(.unprocessable)
                self.finish()
                return
            }
            switch loadFromDBResult {
            case let .success(notes):
                self.result = .success(notes)
                self.save(notes: notes, with: notebook, at: dbQueue)
            case .failure:
                self.result = loadFromDBResult
                self.finish()
            }
        }
        dbQueue.addOperation(loadFromDB)
    }
    private func save(notes: [Note], with notebook: FileNotebook, at dbQueue: OperationQueue) {
        let saveNotesToDB = SaveNotesDBOperation(notes: notes, notebook: notebook)
        saveNotesToDB.completionBlock = {
            self.finish()
            return
        }
        dbQueue.addOperation(saveNotesToDB)
    }
}
