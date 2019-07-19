//
//  Log.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 19.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation
import CocoaLumberjack

// MARK: - Log

final class Log {

    static func info(_ message: String) {
        let newMessage = "[INFO] \(message)"
        DDLogInfo(newMessage)
    }
    static func error(_ message: String) {
        let newMessage = "[ERROR] \(message)"
        DDLogError(newMessage)
    }

    init() {
        if isInitialized {
            return
        }
        DDLog.add(DDOSLogger.sharedInstance)

        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 10
        DDLog.add(fileLogger)
        isInitialized.toggle()
    }

    // MARK: - Private

    private var isInitialized = false

}
