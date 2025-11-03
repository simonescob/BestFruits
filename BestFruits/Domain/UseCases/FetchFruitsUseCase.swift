//
//  FetchFruitsUseCase.swift
//  BestFruits
//
//  Use case for fetching fruits with various filtering options.
//

import Foundation
import Combine

/// Use case for fetching fruits with filtering and sorting options
class FetchFruitsUseCase {
    private let fruitRepository: FruitRepositoryProtocol
    
    init(fruitRepository: FruitRepositoryProtocol) {
        self.fruitRepository = fruitRepository
    }
    
    /// Execute the use case with optional filters
    func execute(
        category: String? = nil,
        searchQuery: String? = nil,
        favoritesOnly: Bool = false,
        sortBy: SortOption = .name
    ) async throws -> [Fruit] {
        
        var fruits: [Fruit]
        
        // Determine which fruits to fetch based on filters
        if let category = category {
            fruits = try await fruitRepository.fetchFruits(by: category)
        } else if favoritesOnly {
            fruits = try await fruitRepository.fetchFavorites()
        } else {
            fruits = try await fruitRepository.fetchFruits()
        }
        
        // Apply search filter
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            fruits = try await fruitRepository.searchFruits(query: searchQuery)
        }
        
        // Apply sorting
        fruits = sortFruits(fruits, by: sortBy)
        
        return fruits
    }
    
    /// Sort fruits based on the specified option
    private func sortFruits(_ fruits: [Fruit], by sortOption: SortOption) -> [Fruit] {
        switch sortOption {
        case .name:
            return fruits.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .category:
            return fruits.sorted {
                let category1 = $0.categories.first ?? ""
                let category2 = $1.categories.first ?? ""
                return category1.localizedCompare(category2) == .orderedAscending
            }
        case .season:
            return fruits.sorted { $0.season.first?.rawValue ?? "" < $1.season.first?.rawValue ?? "" }
        case .nutritionalValue:
            return fruits.sorted { $0.nutritionalInfo.calories < $1.nutritionalInfo.calories }
        case .favorite:
            return fruits.sorted { $0.isFavorite && !$1.isFavorite }
        }
    }
}

/// Sorting options for fruits
enum SortOption: String, CaseIterable {
    case name = "Name"
    case category = "Category"
    case season = "Season"
    case nutritionalValue = "Nutritional Value"
    case favorite = "Favorites First"
    
    var displayName: String {
        return self.rawValue
    }
}