//
//  Gist.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 11.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - Gist

struct Gist: Decodable {
    let files: [String: GistFile]
    let owner: Owner
    let comments: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case files
        case owner
        case comments
        case createdAt = "created_at"
    }
}

// MARK: - Owner

struct Owner: Decodable {
    let login: String
}

// MARK: - GistFile

struct GistFile: Decodable {
    let filename: String
    let type: String
    let language: String
    let rawUrl: String
    let size: Int

    enum CodingKeys: String, CodingKey {
        case filename
        case type
        case language
        case rawUrl = "raw_url"
        case size
    }
}
