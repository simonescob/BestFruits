//
//  FruitListViewModel.swift
//  BestFruits
//
//  ViewModel for managing fruit list state and operations.
//

import Foundation
import Combine

/// ViewModel for fruit list view
@MainActor
class FruitListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var fruits: [Fruit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""
    @Published var selectedCategory: String? = nil
    @Published var selectedSortOption: SortOption = .name
    @Published var showFavoritesOnly: Bool = false
    @Published var isOfflineMode: Bool = false
    
    // MARK: - Private Properties
    
    private let fetchFruitsUseCase: FetchFruitsUseCase
    private let searchFruitsUseCase: SearchFruitsUseCase
    private let saveProgressUseCase: SaveProgressUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        fetchFruitsUseCase: FetchFruitsUseCase? = nil,
        searchFruitsUseCase: SearchFruitsUseCase? = nil,
        saveProgressUseCase: SaveProgressUseCase? = nil
    ) {
        self.fetchFruitsUseCase = fetchFruitsUseCase ?? Self.defaultFetchFruitsUseCase()
        self.searchFruitsUseCase = searchFruitsUseCase ?? Self.defaultSearchFruitsUseCase()
        self.saveProgressUseCase = saveProgressUseCase ?? Self.defaultSaveProgressUseCase()
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Load fruits with current filters
    func loadFruits() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fruits = try await fetchFruitsUseCase.execute(
                category: selectedCategory,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                favoritesOnly: showFavoritesOnly,
                sortBy: selectedSortOption
            )
            
            await MainActor.run {
                self.fruits = fruits
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
                isOfflineMode = true
            }
        }
    }
    
    /// Search fruits with query
    func searchFruits(query: String) async {
        await MainActor.run {
            searchQuery = query
            isLoading = true
            errorMessage = nil
        }
        
        guard !query.isEmpty else {
            await loadFruits()
            return
        }
        
        do {
            let filteredFruits = try await searchFruitsUseCase.execute(
                query: query,
                filters: SearchFilters(
                    categories: selectedCategory.flatMap { [$0] } ?? [],
                    favoritesOnly: showFavoritesOnly,
                    sortBy: selectedSortOption
                )
            )
            
            await MainActor.run {
                self.fruits = filteredFruits
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    /// Filter by category
    func filterByCategory(_ category: String?) async {
        await MainActor.run {
            selectedCategory = category
        }
        await loadFruits()
    }
    
    /// Toggle favorites filter
    func toggleFavoritesFilter() async {
        await MainActor.run {
            showFavoritesOnly = !showFavoritesOnly
        }
        await loadFruits()
    }
    
    /// Change sort option
    func changeSortOption(_ sortOption: SortOption) async {
        await MainActor.run {
            selectedSortOption = sortOption
        }
        await loadFruits()
    }
    
    /// Toggle favorite status for a fruit
    func toggleFavorite(fruit: Fruit) async {
        do {
            let isFavorite = try await saveProgressUseCase.toggleFavorite(fruitId: fruit.id)
            
            // Update local fruit object
            if let index = fruits.firstIndex(where: { $0.id == fruit.id }) {
                await MainActor.run {
                    self.fruits[index].isFavorite = isFavorite
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Refresh data (force network sync)
    func refresh() async {
        // This would typically trigger a force sync with the network
        await loadFruits()
    }
    
    /// Get filtered fruits count
    var filteredCount: Int {
        return fruits.count
    }
    
    /// Get total fruits count
    var totalCount: Int {
        return fruits.count
    }
    
    /// Check if any filters are active
    var hasActiveFilters: Bool {
        return !searchQuery.isEmpty || 
               selectedCategory != nil || 
               showFavoritesOnly ||
               selectedSortOption != .name
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Setup any Combine bindings if needed
    }
    
    private static func defaultFetchFruitsUseCase() -> FetchFruitsUseCase {
        let fruitRepository = FruitRepository()
        return FetchFruitsUseCase(fruitRepository: fruitRepository)
    }
    
    private static func defaultSearchFruitsUseCase() -> SearchFruitsUseCase {
        let fruitRepository = FruitRepository()
        return SearchFruitsUseCase(fruitRepository: fruitRepository)
    }
    
    private static func defaultSaveProgressUseCase() -> SaveProgressUseCase {
        // This would typically be implemented with a proper progress repository
        // For now, using a placeholder implementation
        let progressRepository = MockProgressRepository()
        return SaveProgressUseCase(progressRepository: progressRepository)
    }
}

// MARK: - Mock Progress Repository (placeholder)

private class MockProgressRepository: UserProgressRepositoryProtocol {
    func fetchProgress(for fruitId: UUID) async throws -> UserProgress? {
        return nil
    }
    
    func fetchAllProgress() async throws -> [UserProgress] {
        return []
    }
    
    func saveProgress(_ progress: UserProgress) async throws -> UserProgress {
        return progress
    }
    
    func updateLearningProgress(for fruitId: UUID, readingProgress: Double, quizCompleted: Bool, notes: String) async throws -> UserProgress {
        return UserProgress(userId: "mock", fruitId: fruitId)
    }
    
    func addQuizScore(for fruitId: UUID, quizId: UUID, score: Int, timeTaken: TimeInterval) async throws -> UserProgress {
        return UserProgress(userId: "mock", fruitId: fruitId)
    }
    
    func toggleFavorite(fruitId: UUID) async throws -> Bool {
        return true
    }
    
    func getFavorites() async throws -> [UUID] {
        return []
    }
    
    func getStudyStatistics() async throws -> StudyStatistics {
        return StudyStatistics()
    }
    
    func syncProgress() async throws -> [UserProgress] {
        return []
    }
    
    var progressPublisher: AnyPublisher<[UserProgress], Never> {
        Just([]).eraseToAnyPublisher()
    }
}