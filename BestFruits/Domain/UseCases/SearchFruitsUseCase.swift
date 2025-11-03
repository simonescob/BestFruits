//
//  SearchFruitsUseCase.swift
//  BestFruits
//
//  Use case for searching fruits with various criteria.
//

import Foundation

/// Use case for searching fruits with advanced filtering options
class SearchFruitsUseCase {
    private let fruitRepository: FruitRepositoryProtocol
    
    init(fruitRepository: FruitRepositoryProtocol) {
        self.fruitRepository = fruitRepository
    }
    
    /// Execute search with comprehensive criteria
    func execute(
        query: String,
        filters: SearchFilters = SearchFilters()
    ) async throws -> [Fruit] {
        
        // Fetch all fruits first (could be optimized with server-side search)
        var fruits = try await fruitRepository.fetchFruits()
        
        // Apply text search across multiple fields
        if !query.isEmpty {
            fruits = applyTextSearch(fruits, query: query)
        }
        
        // Apply filters
        fruits = applyFilters(fruits, filters: filters)
        
        // Apply sorting
        fruits = applySorting(fruits, sortBy: filters.sortBy)
        
        return fruits
    }
    
    /// Apply text search across name, description, and other fields
    private func applyTextSearch(_ fruits: [Fruit], query: String) -> [Fruit] {
        let lowercasedQuery = query.lowercased()
        
        return fruits.filter { fruit in
            fruit.name.lowercased().contains(lowercasedQuery) ||
            fruit.description.lowercased().contains(lowercasedQuery) ||
            (fruit.scientificName?.lowercased().contains(lowercasedQuery) ?? false) ||
            fruit.categories.contains { category in
                category.lowercased().contains(lowercasedQuery)
            } ||
            fruit.funFacts.contains { fact in
                fact.lowercased().contains(lowercasedQuery)
            }
        }
    }
    
    /// Apply search filters
    private func applyFilters(_ fruits: [Fruit], filters: SearchFilters) -> [Fruit] {
        var filteredFruits = fruits
        
        // Category filter
        if !filters.categories.isEmpty {
            filteredFruits = filteredFruits.filter { fruit in
                !fruit.categories.isEmpty && filters.categories.contains(fruit.categories[0])
            }
        }
        
        // Season filter
        if !filters.seasons.isEmpty {
            filteredFruits = filteredFruits.filter { fruit in
                !fruit.season.isEmpty && filters.seasons.contains(fruit.season[0])
            }
        }
        
        // Nutritional range filters
        if let minCalories = filters.minCalories {
            filteredFruits = filteredFruits.filter { $0.nutritionalInfo.calories >= minCalories }
        }
        
        if let maxCalories = filters.maxCalories {
            filteredFruits = filteredFruits.filter { $0.nutritionalInfo.calories <= maxCalories }
        }
        
        // Vitamin C filter
        if let minVitaminC = filters.minVitaminC {
            filteredFruits = filteredFruits.filter { $0.nutritionalInfo.vitaminC >= minVitaminC }
        }
        
        // Fiber filter
        if let minFiber = filters.minFiber {
            filteredFruits = filteredFruits.filter { $0.nutritionalInfo.fiber >= minFiber }
        }
        
        // Favorites only
        if filters.favoritesOnly {
            filteredFruits = filteredFruits.filter { $0.isFavorite }
        }
        
        // Difficulty filter for quizzes
        if !filters.difficulties.isEmpty {
            filteredFruits = filteredFruits.filter { fruit in
                !fruit.quizQuestions.isEmpty && fruit.quizQuestions.contains { question in
                    filters.difficulties.contains(question.difficulty)
                }
            }
        }
        
        return filteredFruits
    }
    
    /// Apply sorting
    private func applySorting(_ fruits: [Fruit], sortBy: SortOption) -> [Fruit] {
        switch sortBy {
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

/// Advanced search filters
struct SearchFilters: Equatable {
    let categories: [String]
    let seasons: [Season]
    let minCalories: Int?
    let maxCalories: Int?
    let minVitaminC: Double?
    let minFiber: Double?
    let favoritesOnly: Bool
    let difficulties: [Difficulty]
    let sortBy: SortOption
    
    init(
        categories: [String] = [],
        seasons: [Season] = [],
        minCalories: Int? = nil,
        maxCalories: Int? = nil,
        minVitaminC: Double? = nil,
        minFiber: Double? = nil,
        favoritesOnly: Bool = false,
        difficulties: [Difficulty] = [],
        sortBy: SortOption = .name
    ) {
        self.categories = categories
        self.seasons = seasons
        self.minCalories = minCalories
        self.maxCalories = maxCalories
        self.minVitaminC = minVitaminC
        self.minFiber = minFiber
        self.favoritesOnly = favoritesOnly
        self.difficulties = difficulties
        self.sortBy = sortBy
    }
}