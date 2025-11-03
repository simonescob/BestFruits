//
//  APIEndpoints.swift
//  BestFruits
//
//  API endpoints for the Go backend integration.
//

import Foundation
import CoreGraphics

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
        case .getFruit(let id):
            return "/fruits/\(id.uuidString)"
        case .updateFruit(let id, _):
            return "/fruits/\(id.uuidString)"
        case .deleteFruit(let id):
            return "/fruits/\(id.uuidString)"
        case .toggleFavorite(let id):
            return "/fruits/\(id.uuidString)"
        case .getCategories:
            return "/categories"
        case .searchFruits:
            return "/fruits"
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
            return "/progress"
        case .getStatistics:
            return "/progress"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        default:
            return nil
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
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}