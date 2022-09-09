//
//  Api.swift
//  Learn Borsch
//
//  Created by Yuriy Lisovskiy on 08.09.2022.
//

import Foundation

let ApiV1Url: String = "http://0.0.0.0:8080/api/v1"

struct PlaygroundApi {
    
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
        
        // Create URL
        guard let url = URL(string: ApiV1Url + "/jobs") else {
            completion(.failure(ResponseError(message: "invalid url")))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"

        let form = CreateJobForm(languageVersion: langVersion, sourceCode: sourceCode)
        request.httpBody = try! JSONEncoder().encode(form)
        
        // Create URL session data task
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {                                                               // check for fundamental networking error
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            // Check for http errors
            guard (200 ... 299) ~= response.statusCode else {
                do {
                    let decodedErr = try JSONDecoder().decode(ResponseError.self, from: data)
                    completion(.failure(ResponseError(message: decodedErr.message)))
                }
                catch {
                    completion(.failure(error))
                }
                
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            // Parse response data
            do {
                let createJobResult = try JSONDecoder().decode(CreateJobResult.self, from: data)
                completion(.success(createJobResult))
            }
            catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func getOutput(jobId: String, offset: Int, completion: @escaping (Result<ResponseOutput, Error>) -> Void) {
        // Create URL
        guard let url = URL(string: "\(ApiV1Url)/jobs/\(jobId)/output?offset=\(offset)") else {
            completion(.failure(ResponseError(message: "invalid url")))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                // check for fundamental networking error
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                // check for http errors
                do {
                    let decodedErr = try JSONDecoder().decode(ResponseError.self, from: data)
                    completion(.failure(ResponseError(message: decodedErr.message)))
                }
                catch {
                    completion(.failure(error))
                }
                
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            do {
                let outputResult = try JSONDecoder().decode(ResponseOutput.self, from: data)
                completion(.success(outputResult))
            }
            catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
