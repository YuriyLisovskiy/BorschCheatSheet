//
//  Api.swift
//  Learn Borsch
//
//  Created by Yuriy Lisovskiy on 08.09.2022.
//

import Foundation

let ApiV1Url: String = "http://0.0.0.0:8080/api/v1"

struct PlaygroundApi {
    
    enum RequestMethod {
        case get, post, put, delete
        
        func toString() -> String {
            switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .delete:
                return "DELETE"
            }
        }
    }
    
    private static func sendRequest(url: String, method: RequestMethod, body: Data?, completion: @escaping (Result<(HTTPURLResponse, Data?), Error>) -> Void) {
        guard let urlObj = URL(string: url) else {
            completion(.failure(ResponseError(message: "invalid url")))
            return
        }
        
        var request = URLRequest(url: urlObj)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.toString()

        if body != nil {
            request.httpBody = body
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            completion(.success((response, data)))
        }.resume()
    }
    
    static func get_(url: String, completion: @escaping (Result<(HTTPURLResponse, Data?), Error>) -> Void) {
        PlaygroundApi.sendRequest(url: url, method: .get, body: nil, completion: completion)
    }
    
    static func post(url: String, body: Data, completion: @escaping (Result<(HTTPURLResponse, Data?), Error>) -> Void) {
        PlaygroundApi.sendRequest(url: url, method: .post, body: body, completion: completion)
    }
    
    static func put(url: String, body: Data, completion: @escaping (Result<(HTTPURLResponse, Data?), Error>) -> Void) {
        PlaygroundApi.sendRequest(url: url, method: .put, body: body, completion: completion)
    }
    
    static func delete(url: String, completion: @escaping (Result<(HTTPURLResponse, Data?), Error>) -> Void) {
        PlaygroundApi.sendRequest(url: url, method: .delete, body: nil, completion: completion)
    }
    
    struct CreateJobForm: Encodable {
        var languageVersion: String
        var sourceCode: String
        
        enum CodingKeys: CodingKey {
          case lang_v, source_code
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(languageVersion, forKey: .lang_v)
            try container.encode(sourceCode, forKey: .source_code)
        }
    }

    struct CreateJobResult: Decodable {
        let jobId: String
        let outputUrl: String
        
        enum CodingKeys: CodingKey {
          case job_id, output_url
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            jobId = try container.decode(String.self, forKey: .job_id)
            outputUrl = try container.decode(String.self, forKey: .output_url)
        }
    }

    struct ResponseOutputRow: Decodable {
        let id: Int64
        let createdAt: String
        let text: String
        
        enum CodingKeys: CodingKey {
          case id, created_at, text
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int64.self, forKey: .id)
            createdAt = try container.decode(String.self, forKey: .created_at)
            text = try container.decode(String.self, forKey: .text)
        }
    }

    struct ResponseOutput: Decodable {
        let exitCode: Int64?
        let rows: [ResponseOutputRow]
        
        enum CodingKeys: CodingKey {
          case exit_code, rows
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            exitCode = try container.decode(Int64?.self, forKey: .exit_code)
            rows = try container.decode([ResponseOutputRow].self, forKey: .rows)
        }
    }

    struct ResponseError: Decodable, Error {
        let message: String
    }
    
    static func createJob(langVersion: String, sourceCode: String, completion: @escaping (Result<CreateJobResult, Error>) -> Void) {
        let form = CreateJobForm(languageVersion: langVersion, sourceCode: sourceCode)
        let body = try! JSONEncoder().encode(form)
        PlaygroundApi.post(url: ApiV1Url + "/jobs", body: body) { result in
            switch result {
            case .success(let obj):
                if obj.0.statusCode != 201 {
                    do {
                        let decodedErr = try JSONDecoder().decode(ResponseError.self, from: obj.1!)
                        completion(.failure(ResponseError(message: decodedErr.message)))
                    }
                    catch {
                        completion(.failure(error))
                    }
                    
                    return
                }
                
                do {
                    let createJobResult = try JSONDecoder().decode(CreateJobResult.self, from: obj.1!)
                    completion(.success(createJobResult))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    static func getOutput(jobId: String, offset: Int, completion: @escaping (Result<ResponseOutput, Error>) -> Void) {
        PlaygroundApi.get_(url: "\(ApiV1Url)/jobs/\(jobId)/output?offset=\(offset)") { result in
            switch result {
            case .success(let obj):
                if obj.0.statusCode != 200 {
                    do {
                        let decodedErr = try JSONDecoder().decode(ResponseError.self, from: obj.1!)
                        completion(.failure(ResponseError(message: decodedErr.message)))
                    }
                    catch {
                        completion(.failure(error))
                    }
                    
                    return
                }
                
                do {
                    let outputResult = try JSONDecoder().decode(ResponseOutput.self, from: obj.1!)
                    completion(.success(outputResult))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}
