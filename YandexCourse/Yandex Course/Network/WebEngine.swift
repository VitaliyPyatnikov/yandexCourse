//
//  WebEngine.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 11.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - Closures

typealias UploadCompletionHandler = (_ result: SaveNotesBackendResult, _ gistId: String) -> Void
typealias RequestCompletionHandler = (Data?, URLResponse?, Error?) -> Void

// MARK: - UploadManager

protocol UploadManager {
    func upload(with data: Data, uploadCompletion: @escaping UploadCompletionHandler)
    func update(gistId: String, with data: Data, uploadCompletion: @escaping UploadCompletionHandler)
}

// MARK: - WebEngine

final class WebEngine {

    // MARK: - Private

    private let githubAPI = "https://api.github.com"
    private let gistsPath = "gists"
    private let token = "YOUR_TOKEN_HERE"
    private let tokenError = "YOUR_TOKEN_HERE"

    private func uploadRequest(withGistId gistId: String) -> URLRequest? {
        if token == tokenError {
            Log.error("Please setup correct token")
            return nil
        }
        let tokenString = "token \(token)"
        guard let baseURL = URL(string: githubAPI) else {
            Log.error("Can't create url from \(githubAPI)")
            return nil
        }
        let finalURL: URL
        if gistId.isEmpty {
            finalURL = baseURL.appendingPathComponent(gistsPath)
        } else {
            finalURL = baseURL.appendingPathComponent(gistsPath).appendingPathComponent(gistId)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = gistId.isEmpty ? "POST" : "PATCH"
        request.setValue(tokenString, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
    private func perform(request: URLRequest,
                         with data: Data,
                         requestCompletionHandler: @escaping RequestCompletionHandler) {
        let dataTask = URLSession.shared.uploadTask(
            with: request,
            from: data) { (data, response, error) in
                requestCompletionHandler(data, response, error)
        }
        dataTask.resume()
    }
}

// MARK: - UploadManager

extension WebEngine: UploadManager {
    func upload(with data: Data, uploadCompletion: @escaping UploadCompletionHandler) {
        Log.info("Start uploading")
        guard let uploadRequest = uploadRequest(withGistId: "") else {
            Log.error("Upload request is nil")
            uploadCompletion(.failure(.unprocessableEntity), "")
            return
        }
        perform(request: uploadRequest, with: data) { [weak self] data, response, error in
            self?.parseUpload(data: data,
                              response: response,
                              error: error,
                              uploadCompletion: uploadCompletion)
        }
    }
    func update(gistId: String, with data: Data, uploadCompletion: @escaping UploadCompletionHandler) {
        Log.info("Start updating")
        guard let updateRequest = uploadRequest(withGistId: gistId) else {
            Log.error("Update request is nil")
            uploadCompletion(.failure(.unprocessableEntity), "")
            return
        }
        perform(request: updateRequest, with: data) { [weak self] data, response, error in
            self?.parseUpload(data: data,
                              response: response,
                              error: error,
                              uploadCompletion: uploadCompletion)
        }
    }

    // MARK: - Private

    private func parseUpload(data: Data?,
                             response: URLResponse?,
                             error: Error?,
                             uploadCompletion: @escaping UploadCompletionHandler) {
        guard error == nil else {
            Log.error(String(describing: error?.localizedDescription))
            uploadCompletion(.failure(.unreachable), "")
            return
        }
        guard let response = response as? HTTPURLResponse else {
            Log.error("Response is nil")
            uploadCompletion(.failure(.unprocessableEntity), "")
            return
        }
        Log.info("Response status code: \(response.statusCode)")
        guard (200...299).contains(response.statusCode) else {
            uploadCompletion(.failure(.serverError), "")
            Log.error("Server error")
            return
        }
        guard let data = data else {
            Log.error("Data is nil")
            return
        }
        guard let gistResponse = try? JSONDecoder().decode(
            GistResponse.self,
            from: data) else {
                Log.error("Can't parse gist info")
                let stringData = String(data: data, encoding: .utf8) ?? ""
                Log.info(stringData)
                uploadCompletion(.failure(.unprocessableEntity), "")
                return
        }
        Log.info("Upload request finished")
        uploadCompletion(.success, gistResponse.id)
    }
}

