//
//  BestFruitsTests.swift
//  BestFruitsTests
//
//  Unit tests for the BestFruits app using Clean Architecture.
//

import XCTest
import SwiftUI
@testable import BestFruits

/// Mock repository for testing
class MockFruitRepository: FruitRepositoryProtocol {
    var shouldReturnError = false
    var mockFruits: [Fruit] = []
    
    func fetchFruits() async throws -> [Fruit] {
        if shouldReturnError {
            throw FruitRepositoryError.networkError(underlying: NSError(domain: "Test", code: 1))
        }
        return mockFruits
    }
    
    func fetchFruit(id: UUID) async throws -> Fruit? {
        return mockFruits.first { $0.id == id }
    }
    
    func searchFruits(query: String) async throws -> [Fruit] {
        return mockFruits.filter { $0.name.contains(query) }
    }
    
    func fetchFruits(by category: String) async throws -> [Fruit] {
        return mockFruits.filter { $0.categories.contains(category) }
    }
    
    func fetchFavorites() async throws -> [Fruit] {
        return mockFruits.filter { $0.isFavorite }
    }
    
    func createFruit(_ fruit: Fruit) async throws -> Fruit {
        mockFruits.append(fruit)
        return fruit
    }
    
    func updateFruit(_ fruit: Fruit) async throws -> Fruit {
        if let index = mockFruits.firstIndex(where: { $0.id == fruit.id }) {
            mockFruits[index] = fruit
            return fruit
        }
        throw FruitRepositoryError.notFound
    }
    
    func deleteFruit(id: UUID) async throws {
        mockFruits.removeAll { $0.id == id }
    }
    
    func toggleFavorite(id: UUID) async throws -> Bool {
        guard let index = mockFruits.firstIndex(where: { $00.id == id }) else {
            throw FruitRepositoryError.notFound
        }
        mockFruits[index].isFavorite.toggle()
        return mockFruits[index].isFavorite
    }
    
    func syncFruits() async throws -> [Fruit] {
        return mockFruits
    }
    
    var fruitsPublisher: AnyPublisher<[Fruit], Never> {
        Just(mockFruits).eraseToAnyPublisher()
    }
}

final class BestFruitsTests: XCTestCase {
    
    func testFetchFruitsUseCase() async throws {
        // Given
        let mockRepository = MockFruitRepository()
        let testFruit = Fruit(
            name: "Test Apple",
            description: "A test apple for unit testing"
        )
        mockRepository.mockFruits = [testFruit]
        
        let useCase = FetchFruitsUseCase(fruitRepository: mockRepository)
        
        // When
        let fruits = try await useCase.execute()
        
        // Then
        XCTAssertEqual(fruits.count, 1)
        XCTAssertEqual(fruits.first?.name, "Test Apple")
    }
    
    func testSearchFruitsUseCase() async throws {
        // Given
        let mockRepository = MockFruitRepository()
        mockRepository.mockFruits = [
            Fruit(name: "Apple", description: "Red and sweet"),
            Fruit(name: "Banana", description: "Yellow and curved"),
            Fruit(name: "Orange", description: "Citrus fruit")
        ]
        
        let useCase = SearchFruitsUseCase(fruitRepository: mockRepository)
        
        // When
        let results = try await useCase.execute(query: "Red")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Apple")
    }
    
    func testSaveProgressUseCase() async throws {
        // Given
        let mockProgressRepository = MockProgressRepository()
        let useCase = SaveProgressUseCase(progressRepository: mockProgressRepository)
        let fruitId = UUID()
        
        // When
        let progress = try await useCase.updateReadingProgress(
            fruitId: fruitId,
            progress: 0.5
        )
        
        // Then
        XCTAssertEqual(progress.progress.readingProgress, 0.5)
    }
    
    func testFruitEntityConversion() {
        // Given
        let fruit = Fruit(
            name: "Test Fruit",
            description: "Test description",
            nutritionalInfo: NutritionalInfo(calories: 50)
        )
        
        // Create Core Data entity
        let entity = FruitEntity()
        entity.updateFromDomain(fruit)
        
        // Convert back to domain
        let convertedFruit = entity.toDomain()
        
        // Then
        XCTAssertEqual(convertedFruit.name, fruit.name)
        XCTAssertEqual(convertedFruit.nutritionalInfo.calories, fruit.nutritionalInfo.calories)
    }
    
    func testFruitMapper() {
        // Given
        let fruit = Fruit(
            name: "Mango",
            description: "Sweet tropical fruit"
        )
        
        // When
        let dto = FruitMapper.toDTO(fruit)
        let convertedFruit = FruitMapper.toDomain(dto)
        
        // Then
        XCTAssertEqual(fruit.name, convertedFruit.name)
        XCTAssertEqual(fruit.description, convertedFruit.description)
        XCTAssertEqual(fruit.id, convertedFruit.id)
    }
    
    func testHTTPClientConfiguration() {
        // Given
        let httpClient = HTTPClient()
        
        // Then
        XCTAssertNotNil(httpClient)
        // Additional assertions about HTTP client configuration
    }
    
    func testConstantsValues() {
        // Then
        XCTAssertEqual(Constants.UI.cornerRadius, 12)
        XCTAssertEqual(Constants.Network.timeoutInterval, 30)
        XCTAssertEqual(Constants.Educational.minQuizScoreForCompletion, 70)
    }
    
    func testFruitModelValidation() {
        // Given
        let validFruit = Fruit(
            name: "Apple",
            description: "A sweet fruit",
            nutritionalInfo: NutritionalInfo(calories: 52)
        )
        
        let invalidFruit = Fruit(
            name: "",
            description: "",
            nutritionalInfo: NutritionalInfo(calories: -1)
        )
        
        // Then
        XCTAssertNotNil(validFruit)
        XCTAssertNotNil(invalidFruit)
        XCTAssertGreaterThanOrEqual(validFruit.nutritionalInfo.calories, 0)
    }
    
    func testCategoryPredefinedData() {
        // When
        let categories = Category.predefined()
        
        // Then
        XCTAssertGreaterThan(categories.count, 0)
        
        let tropicalCategory = categories.first { $0.name == "Tropical" }
        XCTAssertNotNil(tropicalCategory)
        XCTAssertEqual(tropicalCategory?.icon, "sun.max")
    }
    
    func testUserProgressCalculation() {
        // Given
        let progress = LearningProgress(
            readingProgress: 0.8,
            quizzesPassed: 2,
            totalQuizzes: 3
        )
        
        // Then
        XCTAssertEqual(progress.completionPercentage, 0.68, accuracy: 0.01)
        XCTAssertFalse(progress.isComplete)
        
        let completedProgress = LearningProgress(
            readingProgress: 1.0,
            quizCompleted: true,
            quizzesPassed: 3,
            totalQuizzes: 3
        )
        
        XCTAssertTrue(completedProgress.isComplete)
    }
    
    func testSearchFilters() {
        // Given
        let filters = SearchFilters(
            categories: ["Tropical"],
            minCalories: 50,
            maxCalories: 200,
            favoritesOnly: false
        )
        
        // Then
        XCTAssertEqual(filters.categories.count, 1)
        XCTAssertEqual(filters.minCalories, 50)
        XCTAssertEqual(filters.maxCalories, 200)
        XCTAssertFalse(filters.favoritesOnly)
    }
    
    func testQuizScoreGrading() {
        // Given
        let excellentScore = QuizScore(quizId: UUID(), score: 95, timeTaken: 120)
        let passingScore = QuizScore(quizId: UUID(), score: 75, timeTaken: 180)
        let failingScore = QuizScore(quizId: UUID(), score: 60, timeTaken: 240)
        
        // Then
        XCTAssertTrue(excellentScore.isPassing)
        XCTAssertTrue(passingScore.isPassing)
        XCTAssertFalse(failingScore.isPassing)
        
        XCTAssertEqual(excellentScore.gradeLetter, "A")
        XCTAssertEqual(passingScore.gradeLetter, "C")
        XCTAssertEqual(failingScore.gradeLetter, "D")
    }
}

/// Mock Progress Repository for Testing
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
        return UserProgress(userId: "test", fruitId: fruitId)
    }
    
    func addQuizScore(for fruitId: UUID, quizId: UUID, score: Int, timeTaken: TimeInterval) async throws -> UserProgress {
        return UserProgress(userId: "test", fruitId: fruitId)
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

// MARK: - Test Extensions

extension XCTestCase {
    func waitForExpectation(description: String = "Wait for expectation") -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        Task {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            expectation.fulfill()
        }
        return expectation
    }
    
    func waitForAsyncOperation<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        return try await operation()
    }
}
