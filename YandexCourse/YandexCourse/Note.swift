//
//  Note.swift
//  YandexCourse
//
//  Created by Vitaliy Pyatnikov on 01.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

// MARK: - Note

struct Note {

    // MARK: - Properties

    let title: String
    let content: String
    let importance: Importance
    let uid: String
    let color: UIColor
    let selfDestructionDate: Date?

    // MARK: - Initialisation

    init(title: String,
         content: String,
         importance: Importance,
         uid: String = UUID().uuidString,
         color: UIColor = .white,
         selfDestructionDate: Date? = nil) {
        self.title = title
        self.content = content
        self.importance = importance
        self.uid = uid
        self.color = color
        self.selfDestructionDate = selfDestructionDate
    }
}


// MARK: - Importance

enum Importance: String {

    // MARK: - Cases

    case unimportant
    case usual
    case important
}

// MARK: - CaseIterable

extension Importance: CaseIterable { }
