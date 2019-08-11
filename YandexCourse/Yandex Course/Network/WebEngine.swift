//
//  WebEngine.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 11.08.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import Foundation

// MARK: - RequestType

private enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
}

// MARK: - Closures

typealias UploadCompletionHandler = (_ result: SaveNotesBackendResult, _ gistId: String) -> Void
typealias LoadCompletionHandler = (_ result: LoadNotesBackendResult, _ gistId: String) -> Void
typealias RequestCompletionHandler = (Data?, URLResponse?, Error?) -> Void

// MARK: - UploadManager

protocol UploadManager {
    func upload(with data: Data, uploadCompletion: @escaping UploadCompletionHandler)
    func update(gistId: String, with data: Data, uploadCompletion: @escaping UploadCompletionHandler)
}

// MARK: - LoadManager

protocol LoadManager {
    func load(withGistId gistId: String, loadCompletion: @escaping LoadCompletionHandler)
}

// MARK: - WebEngine

final class WebEngine {

    // MARK: - Private

    private let githubAPI = "https://api.github.com"
    private let gistsPath = "gists"
    private let token = "YOUR_TOKEN_HERE"
    private let tokenError = "YOUR_TOKEN_HERE"

    private func getRequest(withGistId gistId: String, requestType: RequestType) -> URLRequest? {
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
        request.httpMethod = requestType.rawValue
        request.setValue(tokenString, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
    private func perform(request: URLRequest,
                         with data: Data,
                         requestCompletionHandler: @escaping RequestCompletionHandler) {
        let dataTask = URLSession.shared.uploadTask(
            with: request,
            from: data,
            completionHandler: requestCompletionHandler)
        dataTask.resume()
    }
    private func perform(request: URLRequest,
                         requestCompletionHandler: @escaping RequestCompletionHandler) {
        let dataTask = URLSession.shared.dataTask(
            with: request,
            completionHandler: requestCompletionHandler)
        dataTask.resume()
    }
}

// MARK: - UploadManager

extension WebEngine: UploadManager {
    func upload(with data: Data, uploadCompletion: @escaping UploadCompletionHandler) {
        Log.info("Start uploading")
        guard let uploadRequest = getRequest(withGistId: "", requestType: .post) else {
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
        guard let updateRequest = getRequest(withGistId: gistId, requestType: .patch) else {
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

// MARK: - LoadManager

extension WebEngine: LoadManager {
    func load(withGistId gistId: String, loadCompletion: @escaping LoadCompletionHandler) {
        Log.info("Start loading with gistId: \(gistId)")
        guard let loadRequest = getRequest(withGistId: gistId, requestType: .get) else {
            Log.error("Update request is nil")
            loadCompletion(.failure(.unprocessableEntity), "")
            return
        }
        perform(request: loadRequest) { [weak self] data, response, error in
            guard error == nil else {
                Log.error(String(describing: error?.localizedDescription))
                loadCompletion(.failure(.unreachable), "")
                return
            }
            guard let response = response as? HTTPURLResponse else {
                Log.error("Response is nil")
                loadCompletion(.failure(.unprocessableEntity), "")
                return
            }
            Log.info("Response status code: \(response.statusCode)")
            guard (200...299).contains(response.statusCode) else {
                loadCompletion(.failure(.serverError), "")
                Log.error("Server error")
                return
            }
            guard let data = data else {
                Log.error("Data is nil")
                return
            }
            if gistId.isEmpty {
                guard let gistInfo = try? JSONDecoder().decode(
                    [Gist].self,
                    from: data) else {
                        Log.error("Can't parse gist info")
                        let stringData = String(data: data, encoding: .utf8) ?? ""
                        Log.info(stringData)
                        loadCompletion(.failure(.unprocessableEntity), "")
                        return
                }
                var isGistFound = false
                var foundGistId: String?
                for gist in gistInfo {
                    for (_, value) in gist.files {
                        if value.filename == GistRequest.filename {
                            foundGistId = gist.id
                            isGistFound = true
                            break
                        }
                    }
                    if isGistFound {
                        break
                    }
                }
                guard let gistID = foundGistId else {
                    Log.error("Gist id not found")
                    loadCompletion(.failure(.unprocessableEntity), "")
                    return
                }
                loadCompletion(.failure(.retryNeeded), gistID)
            } else {
                guard let gist = try? JSONDecoder().decode(
                    Gist.self,
                    from: data) else {
                        Log.error("Can't parse gist info")
                        let stringData = String(data: data, encoding: .utf8) ?? ""
                        Log.info(stringData)
                        loadCompletion(.failure(.unprocessableEntity), "")
                        return
                }
                var content: String?
                for (_, value) in gist.files {
                    if value.filename == GistRequest.filename {
                        content = value.content
                        break
                    }
                }
                guard let notesAsString = content else {
                    loadCompletion(.failure(.unprocessableEntity), "")
                    return
                }
                guard let jsonArray = self?.getJSON(with: notesAsString) else {
                    Log.error("Can't parse notes")
                    loadCompletion(.failure(.unprocessableEntity), "")
                    return
                }
                var notes = [Note]()
                jsonArray.forEach {
                    if let note = Note.parse(json: $0) {
                        notes.append(note)
                    } else {
                        Log.error("Can't parse note from json \($0)")
                    }
                }
                loadCompletion(.success(notes), "")
            }

            Log.info("Load request finished")
        }
    }
    private func getJSON(with string: String) -> [[String: Any]]? {
        do {
            let jsonData = Data(string.utf8)
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData,
                                                             options: []) as? [[String: Any]]
            return jsonArray
        } catch  {
            Log.error(error.localizedDescription)
        }
        return nil
    }
}
