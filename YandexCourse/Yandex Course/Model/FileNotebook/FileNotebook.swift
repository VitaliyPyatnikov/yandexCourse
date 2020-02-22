//
//  FileNotebook.swift
//  YandexCourse
//
//  Created by Vitaliy Pyatnikov on 14.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - FileNotebookHandler

protocol FileNotebookHandler {
    /// Array of notes in the FileNotebook
    var notes: [Note] { get }
    /// Add new note to the FileNotebook
    /// - Parameters:
    ///     - note: Note which should be added to the FileNotebook
    func add(_ note: Note)
    /// Remove note with specified uid from FileNotebook
    /// - Parameters:
    ///     - uid: UID with which the note should be deleted
    func remove(with uid: String)
    /// Save FileNotebook to the storage
    /// - Returns: **true** if saving successfully completed,
    /// otherwise —- **false**
    func saveToFile() -> Bool
    /// Load FileNotebook from the storage
    /// - Returns: **true** if loading successfully completed,
    /// otherwise —- **false**
    func loadFromFile() -> Bool
}

private enum StorageType {
    case file
    case coreData
}

// MARK: - FileNotebook

final class FileNotebook {

    func initializeStorage(completion: @escaping () -> Void) {
        dataStorage.setupCoreDataStack(completion: completion)
    }

    // MARK: - Private

    private var storedNotes: [Note] = []
    private let dataStorage = DataStorage()
    private let storageType = StorageType.file

    private lazy var fileUrl: URL? = {
        let name = "FileNotebook"
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: false)
            let fileURL = documentDirectory.appendingPathComponent(name)
            return fileURL
        } catch {
            Log.error(error.localizedDescription)
        }
        return nil
    }()
}

// MARK: - FileNotebookHandler

extension FileNotebook: FileNotebookHandler {
    var notes: [Note] {
        switch storageType {
        case .file:
            return storedNotes
        case .coreData:
            return dataStorage.loadNotes()
        }
    }
    func syncContexts(notification: Notification, completion: @escaping EmptyCompletion) {
        dataStorage.mergeContexts(notification: notification, completion: completion)
    }
    func add(_ note: Note) {
        switch storageType {
        case .file:
            if !storedNotes.contains(where: { $0.uid == note.uid }) {
                Log.info("Successfully add new note with uid: \(note.uid)")
                storedNotes.append(note)
            } else {
                // bad decision
                replace(editedNote: note, with: note.uid)
            }
        case .coreData:
            dataStorage.saveNote(note)
        }
    }
    func save(notes: [Note]) {
        switch storageType {
        case .file:
            notes.forEach { add($0) }
        case .coreData:
            dataStorage.save(notes)
        }
    }
    func remove(with uid: String) {
        switch storageType {
        case .file:
            storedNotes.removeAll { (note) -> Bool in
                if note.uid == uid {
                    Log.info("Remove note with uid: \(uid)")
                    return true
                }
                return false
            }
        case .coreData:
            dataStorage.removeNote(with: uid)
        }
    }
    func saveToFile() -> Bool {
        switch storageType {
        case .file:
            guard let fileURL = fileUrl else {
                Log.error("Can't save to file, fileURL is nil")
                return false
            }
            var jsons: [[String: Any]] = []
            storedNotes.forEach {
                jsons.append($0.json)
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsons, options: [])
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    Log.error("Can't parse json to string")
                    return false
                }
                try jsonString.write(to: fileURL,
                                     atomically: true,
                                     encoding: String.Encoding.utf8)
            } catch  {
                Log.error(error.localizedDescription)
                return false
            }
            Log.info("Successfully save to file")
            return true
        default:
            return true
        }
    }
    func loadFromFile() -> Bool {
        switch storageType {
        case .file:
            guard let fileURL = fileUrl else {
                Log.error("Can't fileURL is nil")
                return false
            }
            guard let jsonArray = getData(with: fileURL) else {
                Log.error("Can't get data from link \(fileURL)")
                return false
            }
            storedNotes.removeAll()
            jsonArray.forEach {
                guard let note = Note.parse(json: $0) else {
                    Log.error("Can't parse note from json \($0)")
                    return
                }
                storedNotes.append(note)
            }
            Log.info("Successfully load from file")
            return true
        case .coreData:
            storedNotes.removeAll()
            storedNotes = dataStorage.loadNotes()
            return true
        }
    }

    // MARK: - Private

    private func getData(with url: URL) -> [[String: Any]]? {
        do {
            let jsonString = try String(contentsOf: url)
            let jsonData = Data(jsonString.utf8)
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData,
                                                             options: []) as? [[String: Any]]
            return jsonArray
        } catch  {
            Log.error(error.localizedDescription)
        }
        return nil
    }
    private func replace(editedNote: Note, with uid: String) {
        // TODO: - add tests for that
        var indexToUpdate: Int?
        for (index, note) in storedNotes.enumerated() {
            if note.uid == uid {
                indexToUpdate = index
                break
            }
        }
        guard let editedIndex = indexToUpdate else {
            return
        }
        storedNotes[editedIndex] = editedNote
    }
}
