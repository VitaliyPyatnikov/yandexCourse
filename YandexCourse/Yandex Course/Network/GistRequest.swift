//
//  GistRequest.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 11.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - GistRequest

struct GistRequest: Codable {
    let description: String
    let `public`: Bool
    let files: [String: Content]

    init(description: String = "ios-course-notes-db",
         `public`: Bool = true,
         files: [String: Content]) {
        self.description = description
        self.`public` = `public`
        self.files = files
    }

    static let filename = "ios-course-notes-db"
}

// MARK: - Content

struct Content: Codable {
    let content: String
}
