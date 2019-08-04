//
//  AsyncOperation.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 04.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - AsyncOperation

class AsyncOperation: Operation {

    // MARK: - Life cycle

    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        return privateIsExecuting
    }
    override var isFinished: Bool {
        return privateIsFinished
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        willChangeValue(forKey: isExecutingKey)
        privateIsExecuting = true
        main()
        didChangeValue(forKey: isExecutingKey)
    }
    override func main() {
        fatalError("Should be overriden")
    }

    func finish() {
        willChangeValue(forKey: isFinishedKey)
        privateIsFinished = true
        didChangeValue(forKey: isFinishedKey)
    }

    // MARK: - Private

    private var privateIsExecuting = false
    private var privateIsFinished = false
    private let isExecutingKey = "isExecuting"
    private let isFinishedKey = "isFinished"
}
