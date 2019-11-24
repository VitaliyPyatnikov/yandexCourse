//
//  Requests.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 18.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Requests

final class Requests {

    static var fetchAllNotesRequest: NSFetchRequest<MyNote> {
        return Requests.myNoteRequest
    }

    static func findNote(by uid: String) -> NSFetchRequest<MyNote> {
        let predicate = NSPredicate(format: "uid == %@", uid)
        let request = Requests.myNoteRequest
        request.predicate = predicate

        return request
    }

    // MARK: - Private

    private static let myNoteRequest = NSFetchRequest<MyNote>(entityName: String(describing: MyNote.self))
}
