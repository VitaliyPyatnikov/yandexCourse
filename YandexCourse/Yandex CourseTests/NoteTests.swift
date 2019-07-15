//
//  NoteTests.swift
//  YandexCourseUnitTests
//
//  Created by Vitaliy Pyatnikov on 14.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import XCTest
import Foundation

class NoteTests: XCTestCase {

    enum NoteError: Error {
        case invalidJSON
    }

    func testDefaultNoteCreation() {
        let note = Note(title: "Test", content: "Test content", importance: .important)

        XCTAssert(note.color == .white, "Incorrect default color")
        XCTAssert(note.uid != "", "UID is not defined")
        XCTAssert(note.selfDestructionDate == nil, "Incorrect initialization of selfDestructionDate")
    }
    func testCustomColorNoteCreation() {
        let note = Note(title: "Test", content: "Test content", importance: .important, color: .yellow)

        XCTAssert(note.color == .yellow, "Incorrect initialized color")
    }
    func testCustomUidNoteCreation() {
        let uid = UUID().uuidString
        let note = Note(title: "Test", content: "Test content", importance: .important, uid: uid)

        XCTAssert(note.uid == uid, "Incorrect initialized uid")
    }
    func testCustomDateNoteCreation() {
        let date = Date()
        let note = Note(title: "Test", content: "Test content", importance: .important, selfDestructionDate: date)

        XCTAssert(note.selfDestructionDate == date, "Incorrect initialized selfDestructionDate")
    }
    func testTitleNoteCreation() {
        let title = "Test"
        let note = Note(title: title, content: "Test content", importance: .usual)

        XCTAssert(note.title == title, "Incorrect initialized title")
    }
    func testContentNoteCreation() {
        let content = "Test content"
        let note = Note(title: "Test", content: content, importance: .usual)

        XCTAssert(note.content == content, "Incorrect initialized content")
    }
    func testImportanceNoteCreation() {
        Importance.allCases.forEach({ importance in
            let note = Note(title: "Test", content: "Test content", importance: importance)

            XCTAssert(note.importance == importance, "Incorrect initialized importance")
        })
    }
    func testNoteCreationFromFullJson() {
        let jsonString = """
        {
          "uid": "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB",
          "title": "Main",
          "color": {
            "red": 1,
            "green": 1,
            "blue": 1,
            "alpha": 1
          },
          "content": "Test",
          "importance": "important",
          "selfDestructionDate": 1563099214
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note!.uid == "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB", "Incorrect uid")
            XCTAssert(note!.title == "Main", "Incorrect title")
            XCTAssert(note!.color == UIColor(red: 1, green: 1, blue: 1, alpha: 1), "Incorrect color")
            XCTAssert(note!.content == "Test", "Incorrect content")
            XCTAssert(note!.importance == Importance.important, "Incorrect importance")
            XCTAssert(note!.selfDestructionDate == Date(timeIntervalSince1970: 1563099214), "Incorrect date")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testNoteCreationFromJsonWithoudDate() {
        let jsonString = """
        {
          "uid": "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB",
          "title": "Main",
          "color": {
            "red": 1,
            "green": 1,
            "blue": 1,
            "alpha": 1
          },
          "content": "Test",
          "importance": "important"
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note!.uid == "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB", "Incorrect uid")
            XCTAssert(note!.title == "Main", "Incorrect title")
            XCTAssert(note!.color == UIColor(red: 1, green: 1, blue: 1, alpha: 1), "Incorrect color")
            XCTAssert(note!.content == "Test", "Incorrect content")
            XCTAssert(note!.importance == Importance.important, "Incorrect importance")
            XCTAssert(note!.selfDestructionDate == nil, "Incorrect date")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testNoteCreationFromJsonWithoutImportance() {
        let jsonString = """
        {
          "uid": "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB",
          "title": "Main",
          "color": {
            "red": 1,
            "green": 1,
            "blue": 1,
            "alpha": 1
          },
          "content": "Test",
          "selfDestructionDate": 1563099214
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note!.uid == "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB", "Incorrect uid")
            XCTAssert(note!.title == "Main", "Incorrect title")
            XCTAssert(note!.color == UIColor(red: 1, green: 1, blue: 1, alpha: 1), "Incorrect color")
            XCTAssert(note!.content == "Test", "Incorrect content")
            XCTAssert(note!.importance == Importance.usual, "Incorrect importance")
            XCTAssert(note!.selfDestructionDate == Date(timeIntervalSince1970: 1563099214), "Incorrect date")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testNoteCreationFromJsonWithoutColor() {
        let jsonString = """
        {
          "uid": "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB",
          "title": "Main",
          "content": "Test",
          "importance": "important",
          "selfDestructionDate": 1563099214
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note!.uid == "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB", "Incorrect uid")
            XCTAssert(note!.title == "Main", "Incorrect title")
            XCTAssert(note!.color == .white, "Incorrect color")
            XCTAssert(note!.content == "Test", "Incorrect content")
            XCTAssert(note!.importance == Importance.important, "Incorrect importance")
            XCTAssert(note!.selfDestructionDate == Date(timeIntervalSince1970: 1563099214), "Incorrect date")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testNoteCreationFromJsonWithoutUID() {
        let jsonString = """
        {
          "title": "Main",
          "color": {
            "red": 1,
            "green": 1,
            "blue": 1,
            "alpha": 1
          },
          "content": "Test",
          "importance": "important",
          "selfDestructionDate": 1563099214
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note == nil, "Incorrect initialization")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testNoteCreationFromJsonWithoutContent() {
        let jsonString = """
        {
          "uid": "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB",
          "title": "Main",
          "color": {
            "red": 1,
            "green": 1,
            "blue": 1,
            "alpha": 1
          },
          "importance": "important",
          "selfDestructionDate": 1563099214
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note == nil, "Incorrect note initialization")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testNoteCreationFromJsonWithoutTitle() {
        let jsonString = """
        {
          "uid": "ADAF9B69-7E2B-4036-8071-BFDD2A5EF8FB",
          "color": {
            "red": 1,
            "green": 1,
            "blue": 1,
            "alpha": 1
          },
          "content": "Test",
          "importance": "important",
          "selfDestructionDate": 1563099214
        }
        """
        let jsonData = Data(jsonString.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                XCTFail("Incorrect JSON data")
                throw NoteError.invalidJSON
            }
            let note = Note.parse(json: json)
            XCTAssert(note == nil, "Incorrect note initialization")
        } catch {
            XCTFail("Error occurs")
        }
    }
    func testJSONCreationFromNote() {
        let title = "Test title"
        let content = "Test content"
        let uid = UUID().uuidString
        let color = UIColor.yellow
        let importance = Importance.unimportant
        let date = Date()

        let note = Note(title: title,
                        content: content,
                        importance: importance,
                        uid: uid,
                        color: color,
                        selfDestructionDate: date)
        let json = note.json
        let jsonTitle = json["title"] as! String
        let jsonContent = json["content"] as! String
        let jsonUID = json["uid"] as! String
        let jsonColor = json["color"] as! [String: Any]
        let jsonColorRed = jsonColor["red"] as! CGFloat
        let jsonColorGreen = jsonColor["green"] as! CGFloat
        let jsonColorBlue = jsonColor["blue"] as! CGFloat
        let jsonColorAlpha = jsonColor["alpha"] as! CGFloat
        let colorFromJson = UIColor(red: jsonColorRed,
                                    green: jsonColorGreen,
                                    blue: jsonColorBlue,
                                    alpha: jsonColorAlpha)
        let jsonImportance = json["importance"] as! String
        let jsonDate = json["selfDestructionDate"] as! Double

        XCTAssert(note.uid == jsonUID, "Incorrect uid")
        XCTAssert(note.title == jsonTitle, "Incorrect title")
        XCTAssert(note.color == colorFromJson, "Incorrect color")
        XCTAssert(note.content == jsonContent, "Incorrect content")
        XCTAssert(note.importance.rawValue == jsonImportance, "Incorrect importance")
        XCTAssert(note.selfDestructionDate?.timeIntervalSince1970 == jsonDate, "Incorrect date")
    }
    func testJSONCreationFromNoteDefaultWhite() {
        let title = "Test title"
        let content = "Test content"
        let uid = UUID().uuidString
        let importance = Importance.unimportant
        let date = Date()

        let note = Note(title: title,
                        content: content,
                        importance: importance,
                        uid: uid,
                        selfDestructionDate: date)
        let json = note.json

        let jsonColor = json["color"] as? [String: Any]

        XCTAssert(jsonColor == nil, "Incorrectly created json")
    }
    func testJSONCreationFromNoteDefaultImportance() {
        let title = "Test title"
        let content = "Test content"
        let importance = Importance.usual

        let note = Note(title: title,
                        content: content,
                        importance: importance)
        let json = note.json

        let jsonImportance = json["importance"] as? String

        XCTAssert(jsonImportance == nil, "Incorrectly created json")
    }

    func testJSONCreationFromNoteAndBack() {
        let title = "Test title"
        let content = "Test content"
        let uid = UUID().uuidString
        let color = UIColor.yellow
        let importance = Importance.unimportant
        let date = Date()

        let note = Note(title: title,
                        content: content,
                        importance: importance,
                        uid: uid,
                        color: color,
                        selfDestructionDate: date)
        let json = note.json

        let finalNote = Note.parse(json: json)

        XCTAssert(note.uid == finalNote!.uid, "Incorrect uid")
        XCTAssert(note.title == finalNote!.title, "Incorrect title")
        XCTAssert(note.color == finalNote!.color, "Incorrect color")
        XCTAssert(note.content == finalNote!.content, "Incorrect content")
        XCTAssert(note.importance == finalNote!.importance, "Incorrect importance")
        XCTAssert(note.selfDestructionDate?.timeIntervalSince1970 == finalNote!.selfDestructionDate?.timeIntervalSince1970,
                  "Incorrect date")
    }
    func testJSONCreationFromNoteAndBackWhiteColor() {
        let title = "Test title"
        let content = "Test content"
        let uid = UUID().uuidString
        let importance = Importance.unimportant
        let date = Date()

        let note = Note(title: title,
                        content: content,
                        importance: importance,
                        uid: uid,
                        selfDestructionDate: date)
        let json = note.json

        let finalNote = Note.parse(json: json)

        XCTAssert(note.uid == finalNote!.uid, "Incorrect uid")
        XCTAssert(note.title == finalNote!.title, "Incorrect title")
        XCTAssert(note.color == finalNote!.color, "Incorrect color")
        XCTAssert(note.content == finalNote!.content, "Incorrect content")
        XCTAssert(note.importance == finalNote!.importance, "Incorrect importance")
        XCTAssert(note.selfDestructionDate?.timeIntervalSince1970 == finalNote!.selfDestructionDate?.timeIntervalSince1970,
                  "Incorrect date")
    }

    func testJSONCreationFromNoteAndBackUsualImportance() {
        let title = "Test title"
        let content = "Test content"
        let importance = Importance.usual
        let uid = UUID().uuidString
        let date = Date()

        let note = Note(title: title,
                        content: content,
                        importance: importance,
                        uid: uid,
                        selfDestructionDate: date)
        let json = note.json

        let finalNote = Note.parse(json: json)

        XCTAssert(note.uid == finalNote!.uid, "Incorrect uid")
        XCTAssert(note.title == finalNote!.title, "Incorrect title")
        XCTAssert(note.color == finalNote!.color, "Incorrect color")
        XCTAssert(note.content == finalNote!.content, "Incorrect content")
        XCTAssert(note.importance == finalNote!.importance, "Incorrect importance")
        XCTAssert(note.selfDestructionDate?.timeIntervalSince1970 == finalNote!.selfDestructionDate?.timeIntervalSince1970,
                  "Incorrect date")
    }
    func testJSONCreationFromNoteAndBackDefaultUid() {
        let title = "Test title"
        let content = "Test content"
        let importance = Importance.important
        let date = Date()

        let note = Note(title: title,
                        content: content,
                        importance: importance,
                        selfDestructionDate: date)
        let json = note.json

        let finalNote = Note.parse(json: json)

        XCTAssert(note.uid == finalNote!.uid, "Incorrect uid")
        XCTAssert(note.title == finalNote!.title, "Incorrect title")
        XCTAssert(note.color == finalNote!.color, "Incorrect color")
        XCTAssert(note.content == finalNote!.content, "Incorrect content")
        XCTAssert(note.importance == finalNote!.importance, "Incorrect importance")
        XCTAssert(note.selfDestructionDate?.timeIntervalSince1970 == finalNote!.selfDestructionDate?.timeIntervalSince1970,
                  "Incorrect date")
    }

    func testJSONCreationFromNoteAndBackEmptyDate() {
        let title = "Test title"
        let content = "Test content"
        let importance = Importance.important

        let note = Note(title: title,
                        content: content,
                        importance: importance)
        let json = note.json

        let finalNote = Note.parse(json: json)

        XCTAssert(note.uid == finalNote!.uid, "Incorrect uid")
        XCTAssert(note.title == finalNote!.title, "Incorrect title")
        XCTAssert(note.color == finalNote!.color, "Incorrect color")
        XCTAssert(note.content == finalNote!.content, "Incorrect content")
        XCTAssert(note.importance == finalNote!.importance, "Incorrect importance")
        XCTAssert(note.selfDestructionDate?.timeIntervalSince1970 == finalNote!.selfDestructionDate?.timeIntervalSince1970,
                  "Incorrect date")
    }
}
