//
//  HTTPClient.swift
//  BestFruits
//
//  HTTP client for API communication with Go backend.
//

import Foundation

/// HTTP client for making API requests
class HTTPClient {
    static let shared = HTTPClient()
    
    private let session: URLSession
    private let baseURL: String
    
    init(baseURL: String = "https://golang-backend-example-gcp-797553522576.europe-west1.run.app") {
        self.baseURL = baseURL
        
        // Configure session with timeout and caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: configuration)
    }
    
    /// Generic HTTP request method
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        
        // Construct URL
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw HTTPError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw HTTPError.encodingFailed
            }
        }
        
        // Make request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Check response status
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    // Success
                    break
                case 400:
                    throw HTTPError.badRequest
                case 401:
                    throw HTTPError.unauthorized
                case 403:
                    throw HTTPError.forbidden
                case 404:
                    throw HTTPError.notFound
                case 500...599:
                    throw HTTPError.serverError(statusCode: httpResponse.statusCode)
                default:
                    throw HTTPError.unknown(statusCode: httpResponse.statusCode)
                }
            }
            
            // Decode response
            if T.self == String.self {
                // Handle string responses
                guard let stringResponse = String(data: data, encoding: .utf8) as? T else {
                    throw HTTPError.decodingFailed
                }
                return stringResponse
            } else {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw HTTPError.decodingFailed
                }
            }
            
        } catch let error as HTTPError {
            throw error
        } catch {
            throw HTTPError.networkError(underlying: error)
        }
    }
    
    /// Upload file or data
    func upload<T: Decodable>(
        endpoint: APIEndpoint,
        data: Data,
        filename: String,
        mimeType: String = "application/octet-stream"
    ) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw HTTPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add file data
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        
        // Add boundary
        body.appendString("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (responseData, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw HTTPError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: responseData)
        } catch {
            throw HTTPError.decodingFailed
        }
    }
}

/// HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// API endpoint protocol
protocol APIEndpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

/// HTTP errors
enum HTTPError: LocalizedError {
    case invalidURL
    case encodingFailed
    case decodingFailed
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case networkError(underlying: Error)
    case unknown(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingFailed:
            return "Failed to encode request body"
        case .decodingFailed:
            return "Failed to decode response"
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .unknown(let statusCode):
            return "Unknown error: \(statusCode)"
        }
    }
}

/// Data extension for HTTP multipart form data
extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}