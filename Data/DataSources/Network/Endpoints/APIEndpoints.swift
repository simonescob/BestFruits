//
//  APIEndpoints.swift
//  BestFruits
//
//  API endpoints for the Go backend integration.
//

import Foundation

/// API endpoints for fruit operations
enum FruitAPI {
    case getAllFruits
    case getFruit(id: UUID)
    case createFruit(FruitDTO)
    case updateFruit(id: UUID, FruitDTO)
    case deleteFruit(id: UUID)
    case getCategories
    case searchFruits(query: String)
    case toggleFavorite(id: UUID)
}

extension FruitAPI: APIEndpoint {
    var path: String {
        switch self {
        case .getAllFruits, .createFruit:
            return "/fruits"
        case .getFruit(let id), .updateFruit(let id), .deleteFruit(let id), .toggleFavorite(let id):
            return "/fruits/\(id.uuidString)"
        case .getCategories:
            return "/categories"
        case .searchFruits(let query):
            return "/fruits/search"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .searchFruits(let query):
            return [URLQueryItem(name: "q", value: query)]
        default:
            return nil
        }
    }
}

/// API endpoints for user progress operations
enum ProgressAPI {
    case getProgress(fruitId: UUID)
    case saveProgress(UserProgressDTO)
    case getAllProgress
    case getStatistics
}

extension ProgressAPI: APIEndpoint {
    var path: String {
        switch self {
        case .getProgress(let fruitId):
            return "/progress/\(fruitId.uuidString)"
        case .saveProgress:
            return "/progress"
        case .getAllProgress:
            return "/progress/all"
        case .getStatistics:
            return "/progress/statistics"
        }
    }
}

/// API endpoints for health and status
enum SystemAPI {
    case health
    case hello
}

extension SystemAPI: APIEndpoint {
    var path: String {
        switch self {
        case .health:
            return "/health"
        case .hello:
            return "/hello"
        }
    }
}

/// Convenience enum for all API endpoints
enum APIEndpointCase: APIEndpoint {
    case fruits(FruitAPI)
    case progress(ProgressAPI)
    case system(SystemAPI)
    
    var path: String {
        switch self {
        case .fruits(let api):
            return api.path
        case .progress(let api):
            return api.path
        case .system(let api):
            return api.path
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .fruits(let api):
            return api.queryItems
        default:
            return nil
        }
    }
}