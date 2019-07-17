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
    ///     - note: Note whick should be added to the FileNotebook
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

// MARK: - FileNotebook

final class FileNotebook {

    // MARK: - Private

    private var storedNotes: [Note] = []

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
            print(error)
        }
        return nil
    }()
}

// MARK: - FileNotebookHandler

extension FileNotebook: FileNotebookHandler {
    var notes: [Note] {
        return storedNotes
    }

    func add(_ note: Note) {
        if !storedNotes.contains(where: { $0.uid == note.uid }) {
            storedNotes.append(note)
        }
    }
    func remove(with uid: String) {
        storedNotes.removeAll { (note) -> Bool in
            note.uid == uid
        }
    }
    func saveToFile() -> Bool {
        guard let fileURL = fileUrl else {
            return false
        }
        var jsons: [[String: Any]] = []
        storedNotes.forEach {
            jsons.append($0.json)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsons, options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return false
            }
            try jsonString.write(to: fileURL,
                                 atomically: true,
                                 encoding: String.Encoding.utf8)
        } catch  {
            print(error)
            return false
        }
        return true
    }
    func loadFromFile() -> Bool {
        guard let fileURL = fileUrl else {
            return false
        }
        guard let jsonArray = getData(with: fileURL) else {
            return false
        }
        storedNotes.removeAll()
        jsonArray.forEach {
            guard let note = Note.parse(json: $0) else {
                return
            }
            storedNotes.append(note)
        }
        return true
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
            print(error)
        }
        return nil
    }
}
