//
//  FruitRepositoryProtocol.swift
//  BestFruits
//
//  Protocol defining the interface for fruit data operations.
//

import Foundation
import Combine

/// Protocol for fruit repository operations
protocol FruitRepositoryProtocol {
    /// Fetch all fruits
    func fetchFruits() async throws -> [Fruit]
    
    /// Fetch fruit by ID
    func fetchFruit(id: UUID) async throws -> Fruit?
    
    /// Search fruits by query
    func searchFruits(query: String) async throws -> [Fruit]
    
    /// Fetch fruits by category
    func fetchFruits(by category: String) async throws -> [Fruit]
    
    /// Fetch favorite fruits
    func fetchFavorites() async throws -> [Fruit]
    
    /// Create new fruit
    func createFruit(_ fruit: Fruit) async throws -> Fruit
    
    /// Update existing fruit
    func updateFruit(_ fruit: Fruit) async throws -> Fruit
    
    /// Delete fruit
    func deleteFruit(id: UUID) async throws
    
    /// Toggle favorite status
    func toggleFavorite(id: UUID) async throws -> Bool
    
    /// Sync fruits with backend
    func syncFruits() async throws -> [Fruit]
    
    /// Publisher for real-time updates
    var fruitsPublisher: AnyPublisher<[Fruit], Never> { get }
}

/// Repository error types
enum FruitRepositoryError: LocalizedError {
    case notFound
    case networkError(Error)
    case invalidData
    case duplicateEntry
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Fruit not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid fruit data"
        case .duplicateEntry:
            return "Fruit already exists"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}