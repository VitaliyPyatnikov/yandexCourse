//
//  DataStorage.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 18.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Closures

typealias CoreDataContainerInitializationClosure = (NSPersistentContainer) -> ()
typealias CoreDataInitializationClosure = (_ mainContext: NSManagedObjectContext?,
    _ backgroundContext: NSManagedObjectContext?) -> ()
typealias EmptyCompletion = () -> Void

// MARK: - DataStorage

final class DataStorage {

    func setupCoreDataStack(completion: @escaping EmptyCompletion) {
        createContainer { [weak self] container in
            self?.setupContexts(with: container)
            completion()
        }
    }
    func save(_ notes: [Note]) {
        guard let saveContext = saveContext else {
            return
        }
        for note in notes {
            let newNote: MyNote
            if let objectID = noteObjectIdIfExists(with: note.uid),
                let note = saveContext.object(with: objectID) as? MyNote {
                newNote = note
            } else {
                newNote = MyNote(context: saveContext)
            }
            newNote.title = note.title
            newNote.content = note.content
            newNote.importance = note.importance.rawValue
            newNote.uid = note.uid
            newNote.color = note.color.hexValue(alwaysIncludeAlpha: true)
            newNote.selfDestructionDate = note.selfDestructionDate
        }
        saveContext.performAndWait {
            do {
                try saveContext.save()
            } catch {
                Log.error("Error during saving: \(error.localizedDescription)")
            }
        }
    }
    func saveNote( _ note: Note) {
        guard let saveContext = saveContext else {
            return
        }
        let newNote: MyNote
        if let objectID = noteObjectIdIfExists(with: note.uid),
            let note = saveContext.object(with: objectID) as? MyNote {
            newNote = note
        } else {
             newNote = MyNote(context: saveContext)
        }

        newNote.title = note.title
        newNote.content = note.content
        newNote.importance = note.importance.rawValue
        newNote.uid = note.uid
        newNote.color = note.color.hexValue(alwaysIncludeAlpha: true)
        newNote.selfDestructionDate = note.selfDestructionDate

        saveContext.performAndWait {
            do {
                try saveContext.save()
            } catch {
                Log.error("Error during saving: \(error.localizedDescription)")
            }
        }
    }
    func removeNote( _ note: Note) {
        guard let saveContext = saveContext else {
            return
        }
        let request = Requests.findNote(by: note.uid)
        do {
            let fetchedNotes = try saveContext.fetch(request)
            guard let fetchedNote = fetchedNotes.first else {
                return
            }
            saveContext.delete(fetchedNote)
            try saveContext.save()
        } catch {
            Log.error("Error during fetching: \(error.localizedDescription)")
        }
    }
    func removeNote(with uid: String) {
        guard let saveContext = saveContext else {
            return
        }
        let request = Requests.findNote(by: uid)
        do {
            let fetchedNotes = try saveContext.fetch(request)
            guard let fetchedNote = fetchedNotes.first else {
                return
            }
            saveContext.delete(fetchedNote)
            try saveContext.save()
        } catch {
            Log.error("Error during fetching: \(error.localizedDescription)")
        }
    }
    func loadNotes() -> [Note] {
        let storageNotes = privateLoadNotes()
        let notes = convertToNotes(coreDataNotes: storageNotes)
        return notes
    }
    func mergeContexts(notification: Notification, completion: @escaping EmptyCompletion) {
        context?.perform {
            self.context?.mergeChanges(fromContextDidSave: notification)
            completion()
        }
    }

    // MARK: - Private

    private var loadContext: NSManagedObjectContext?
    private var saveContext: NSManagedObjectContext?
    private var readContext: NSManagedObjectContext?
    private var context: NSManagedObjectContext?

    private func createContainer(completion: @escaping CoreDataContainerInitializationClosure) {
        let container = NSPersistentContainer(name: "MyNotebook")
        container.loadPersistentStores(completionHandler: { _, error in
            guard error == nil else {
                fatalError("Failed to load store")
            }
            DispatchQueue.main.async {
                completion(container)
            }
        })
    }
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil)
    }
    @objc private func managedObjectContextDidSave(notification: Notification) {
        context?.perform {
            self.context?.mergeChanges(fromContextDidSave: notification)
        }
    }
    private func setupContexts(with container: NSPersistentContainer) {
        context = container.viewContext
        context?.mergePolicy = NSOverwriteMergePolicy

        loadContext = container.newBackgroundContext()
        saveContext = container.newBackgroundContext()
        readContext = container.newBackgroundContext()
    }
    private func privateLoadNotes() -> [MyNote] {
        guard let loadContext = loadContext else {
            return []
        }
        let request = Requests.fetchAllNotesRequest
        do {
            let fetchedNotes = try loadContext.fetch(request)
            return fetchedNotes
        } catch {
            Log.error("Error during fetching: \(error.localizedDescription)")
        }
        return []
    }
    private func convertToNotes(coreDataNotes: [MyNote]) -> [Note] {
        var notes = [Note]()
        for note in coreDataNotes {
            let newNote = convert(myNote: note)
            notes.append(newNote)
        }
        return notes
    }
    private func convert(myNote: MyNote) -> Note {
        let importace = Importance(rawValue: myNote.importance ?? Importance.usual.rawValue) ?? Importance.usual
        let color = UIColor(hexRGBA: myNote.color) ?? .white
        let uid = myNote.uid ?? UUID().uuidString
        let newNote = Note(title: myNote.title ?? "",
                           content: myNote.content ?? "",
                           importance: importace,
                           uid: uid,
                           color: color,
                           selfDestructionDate: myNote.selfDestructionDate)

        return newNote
    }
    private func fetchNote(with uid: String) -> MyNote? {
        guard let readContext = readContext else {
            return nil
        }
        let request = Requests.findNote(by: uid)
        do {
            let fetchedNotes = try readContext.fetch(request)
            guard let fetchedNote = fetchedNotes.first else {
                return nil
            }
            return fetchedNote
        } catch {
            Log.error("Error during fetch: \(error.localizedDescription)")
        }
        return nil
    }
    private func noteObjectIdIfExists(with uid: String) -> NSManagedObjectID? {
        if let note = fetchNote(with: uid) {
            return note.objectID
        }
        return nil
    }
}

