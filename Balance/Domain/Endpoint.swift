//
//  WebService.swift
//  Balance
//
//  Created by Sabrina Bea on 6/5/24.
//

import Foundation

class Endpoint {
    static let baseUrl = "API_BASE_URL"
    static let apiKeyHeader = "API_KEY_HEADER" // TODO
    static let apiKey = "API_KEY" // TODO
    static let food = Endpoint(endpoint: "food")
    static let diaryEntry = Endpoint(endpoint: "diaryEntry")
    
    let endpoint: String
    let endpointUrl: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
        self.endpointUrl = Endpoint.baseUrl + endpoint
    }
    
    func fetch<T: Codable>() async -> T? {
        do {
            guard let url = URL(string: endpointUrl) else {
                throw RuntimeError.withMessage("Failed to parse API endpoint URL")
            }
            
            var request = URLRequest(url: url)
            request.setValue(Endpoint.apiKey, forHTTPHeaderField: Endpoint.apiKeyHeader)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300 else {
                throw RuntimeError.withMessage("Bad Response")
            }
            
            if let response = try? JSONDecoder().decode(T.self, from: data) {
                return response
            } else {
                if let str = String(data: data, encoding: .utf8) {
                    print("GET request to \(endpoint) returned: \(str)")
                }
                throw RuntimeError.withMessage("Failed to decode response")
            }
        } catch {
            print("Error loading data from \(endpoint): \(error)")
        }
        
        return nil
    }
    
    func put<T: Codable>(_ item: T) async -> T? {
        do {
            guard let url = URL(string: endpointUrl) else {
                throw RuntimeError.withMessage("Failed to parse API endpoint URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = try JSONEncoder().encode(item)
            request.setValue(Endpoint.apiKey, forHTTPHeaderField: Endpoint.apiKeyHeader)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300 else {
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                    print(url.absoluteString)
                }
                throw RuntimeError.withMessage("Bad Response")
            }
            
            if let response = try? JSONDecoder().decode(T.self, from: data) {
                return response
            } else {
                if let str = String(data: data, encoding: .utf8) {
                    print("PUT request to \(endpoint) returned: \(str)")
                }
                return nil
            }
        } catch {
            if let error = error as? URLError {
                print("Error putting data to \(endpoint): \(error.code)")
            } else {
                print("Error putting data to \(endpoint): \(error)")
            }
        }
        
        return nil
    }
    
    func delete<T: DatabaseObject>(_ item: T) async -> T? {
        var debugStr = endpoint
        do {
            guard let url = URL(string: endpointUrl + "/\(item.id.uuidString)") else {
                throw RuntimeError.withMessage("Failed to parse API endpoint URL")
            }
            debugStr = url.relativePath
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue(Endpoint.apiKey, forHTTPHeaderField: Endpoint.apiKeyHeader)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300 else {
                throw RuntimeError.withMessage("Bad Response")
            }
            
            if let response = try? JSONDecoder().decode(T.self, from: data) {
                return response
            } else {
                if let str = String(data: data, encoding: .utf8) {
                    print("DELETE request to \(debugStr) returned: \(str)")
                }
                return nil
            }
        } catch {
            print("Error deleting data from \(debugStr): \(error)")
        }
        
        return nil
    }
    
    func update<T: DatabaseObject>(_ item: T) async -> T? {
        do {
            guard let url = URL(string: endpointUrl + "/\(item.id.uuidString)") else {
                throw RuntimeError.withMessage("Failed to parse API endpoint URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(item)
            request.setValue(Endpoint.apiKey, forHTTPHeaderField: Endpoint.apiKeyHeader)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode < 300 else {
                throw RuntimeError.withMessage("Bad Response")
            }
            
            if let response = try? JSONDecoder().decode(T.self, from: data) {
                return response
            } else {
                if let str = String(data: data, encoding: .utf8) {
                    print("POST request to \(endpoint) returned: \(str)")
                }
                return nil
            }
        } catch {
            print("Error updating data at \(endpoint): \(error)")
        }
        
        return nil
    }
}
