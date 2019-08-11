//
//  Storage.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 11.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - Storage

final class Storage {

    // MARK: - Properties

    var gistId: String {
        get {
            return storage.string(forKey: gistIdKey) ?? ""
        }
        set {
            storage.set(newValue, forKey: gistIdKey)
        }
    }

    // MARK: - Private

    private let storage = UserDefaults.standard
    private let gistIdKey = "gistId"
}
