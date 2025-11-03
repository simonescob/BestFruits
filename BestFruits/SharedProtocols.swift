//
//  SharedProtocols.swift
//  BestFruits
//
//  Shared protocols and types used across all layers.
//

import Foundation

/// API endpoint protocol
protocol APIEndpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

/// HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
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

/// HTTP client protocol
protocol HTTPClientProtocol {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?,
        headers: [String: String]
    ) async throws -> T
}