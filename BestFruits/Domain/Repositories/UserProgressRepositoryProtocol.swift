//
//  UserProgressRepositoryProtocol.swift
//  BestFruits
//
//  Protocol defining the interface for user progress operations.
//

import Foundation
import Combine

/// Protocol for user progress repository operations
protocol UserProgressRepositoryProtocol {
    /// Fetch user progress for a specific fruit
    func fetchProgress(for fruitId: UUID) async throws -> UserProgress?
    
    /// Fetch all progress for user
    func fetchAllProgress() async throws -> [UserProgress]
    
    /// Save user progress
    func saveProgress(_ progress: UserProgress) async throws -> UserProgress
    
    /// Update learning progress
    func updateLearningProgress(
        for fruitId: UUID,
        readingProgress: Double,
        quizCompleted: Bool,
        notes: String
    ) async throws -> UserProgress
    
    /// Add quiz score
    func addQuizScore(
        for fruitId: UUID,
        quizId: UUID,
        score: Int,
        timeTaken: TimeInterval
    ) async throws -> UserProgress
    
    /// Toggle favorite status
    func toggleFavorite(fruitId: UUID) async throws -> Bool
    
    /// Get favorite fruit IDs
    func getFavorites() async throws -> [UUID]
    
    /// Get study statistics
    func getStudyStatistics() async throws -> StudyStatistics
    
    /// Sync progress with backend
    func syncProgress() async throws -> [UserProgress]
    
    /// Publisher for progress updates
    var progressPublisher: AnyPublisher<[UserProgress], Never> { get }
}

/// Study statistics for user analytics
struct StudyStatistics: Codable, Equatable {
    let totalStudyTime: TimeInterval
    let fruitsStudied: Int
    let quizzesTaken: Int
    let averageQuizScore: Double
    let currentStreak: Int
    let bestStreak: Int
    let favoriteCategory: String?
    let lastStudyDate: Date?
    
    init(
        totalStudyTime: TimeInterval = 0,
        fruitsStudied: Int = 0,
        quizzesTaken: Int = 0,
        averageQuizScore: Double = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        favoriteCategory: String? = nil,
        lastStudyDate: Date? = nil
    ) {
        self.totalStudyTime = totalStudyTime
        self.fruitsStudied = fruitsStudied
        self.quizzesTaken = quizzesTaken
        self.averageQuizScore = averageQuizScore
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.favoriteCategory = favoriteCategory
        self.lastStudyDate = lastStudyDate
    }
}