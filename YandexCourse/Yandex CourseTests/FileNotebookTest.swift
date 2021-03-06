//
//  FileNotebookTest.swift
//  YandexCourse
//
//  Created by Vitaliy Pyatnikov on 14.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import XCTest
import Foundation

class FileNotebookTest: XCTestCase {
    func testAddNewNote() {
        let noteOne = Note(title: "Test one",
                           content: "Content two",
                           importance: .important,
                           color: .gray,
                           selfDestructionDate: Date())
        let filesBook: FileNotebookHandler = FileNotebook()
        filesBook.add(noteOne)
        let notes = filesBook.notes
        XCTAssert(notes.count == 1, "Incorrect count of notes")
        XCTAssert(notes[0] == noteOne, "Incorrect note in array")
    }
    func testRemoveNote() {
        let uid = UUID().uuidString
        let noteOne = Note(title: "Test two",
                           content: "Content two",
                           importance: .unimportant,
                           uid: uid,
                           color: .red,
                           selfDestructionDate: Date())
        let noteTwo = Note(title: "Test two",
                           content: "Content two",
                           importance: .important,
                           color: .gray,
                           selfDestructionDate: Date())
        let filesBook: FileNotebookHandler = FileNotebook()
        filesBook.add(noteOne)
        filesBook.add(noteTwo)
        var notes = filesBook.notes
        XCTAssert(notes.count == 2, "Incorrect count of notes")
        filesBook.remove(with: uid)
        notes = filesBook.notes
        XCTAssert(notes.count == 1, "Incorrect count of notes")
        XCTAssert(!notes.contains(noteOne), "Incorrect deletion")
    }
    func testWriteAndRead() {
        let noteOne = Note(title: "Test one",
                           content: "Content one",
                           importance: .important)
        let noteTwo = Note(title: "Test two",
                           content: "Content two",
                           importance: .unimportant,
                           color: .yellow,
                           selfDestructionDate: Date())

        let filesBook: FileNotebookHandler = FileNotebook()
        filesBook.add(noteOne)
        filesBook.add(noteTwo)
        let notes = filesBook.notes

        guard filesBook.saveToFile() else {
            XCTFail("Saving failed")
            return
        }
        guard filesBook.loadFromFile() else {
            XCTFail("Loading failed")
            return
        }
        let notesFromFile = filesBook.notes

        XCTAssertEqual(notes.count, notesFromFile.count, "Incorrect count")
        for note in notes {
            XCTAssert(notes.contains(note), "FileNotebooks are not equal")
        }
    }
    func testAddTheSameNotes() {
        let noteOne = Note(title: "Test one",
                           content: "Content one",
                           importance: .important)
        let noteTwo = noteOne

        let filesBook: FileNotebookHandler = FileNotebook()
        filesBook.add(noteOne)
        filesBook.add(noteTwo)
        let notes = filesBook.notes

        XCTAssertEqual(notes.count, 1, "Incorrect count of notes, duplicate added")
    }
    func testRemoveNoteFromEmptyArray() {
        let filesBook: FileNotebookHandler = FileNotebook()
        let initialCount = filesBook.notes.count
        let uid = UUID().uuidString
        filesBook.remove(with: uid)
        let finalCount = filesBook.notes.count
        XCTAssertEqual(initialCount, finalCount, "Incorrect count of notes")
    }
}
