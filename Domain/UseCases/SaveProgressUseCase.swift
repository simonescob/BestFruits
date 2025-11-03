//
//  SaveProgressUseCase.swift
//  BestFruits
//
//  Use case for saving and managing user learning progress.
//

import Foundation

/// Use case for managing user learning progress
class SaveProgressUseCase {
    private let progressRepository: UserProgressRepositoryProtocol
    
    init(progressRepository: UserProgressRepositoryProtocol) {
        self.progressRepository = progressRepository
    }
    
    /// Update reading progress for a fruit
    func updateReadingProgress(
        fruitId: UUID,
        progress: Double,
        notes: String = ""
    ) async throws -> UserProgress {
        
        guard progress >= 0 && progress <= 1.0 else {
            throw ProgressError.invalidProgress
        }
        
        // Fetch existing progress or create new
        var userProgress = try await progressRepository.fetchProgress(for: fruitId) ??
            UserProgress(
                userId: "current-user", // TODO: Get from auth service
                fruitId: fruitId
            )
        
        // Update reading progress
        userProgress.progress.readingProgress = progress
        userProgress.progress.notes = notes
        userProgress.lastAccessedAt = Date()
        userProgress.updatedAt = Date()
        
        return try await progressRepository.saveProgress(userProgress)
    }
    
    /// Complete quiz and save score
    func completeQuiz(
        fruitId: UUID,
        quizId: UUID,
        score: Int,
        timeTaken: TimeInterval
    ) async throws -> UserProgress {
        
        guard score >= 0 && score <= 100 else {
            throw ProgressError.invalidScore
        }
        
        var userProgress = try await progressRepository.fetchProgress(for: fruitId) ??
            UserProgress(
                userId: "current-user", // TODO: Get from auth service
                fruitId: fruitId
            )
        
        // Add quiz score
        let quizScore = QuizScore(
            quizId: quizId,
            score: score,
            timeTaken: timeTaken
        )
        
        userProgress.quizScores.append(quizScore)
        userProgress.progress.quizCompleted = true
        userProgress.progress.quizzesPassed += score >= 70 ? 1 : 0
        userProgress.progress.totalQuizzes += 1
        userProgress.lastAccessedAt = Date()
        userProgress.updatedAt = Date()
        
        return try await progressRepository.saveProgress(userProgress)
    }
    
    /// Toggle favorite status
    func toggleFavorite(fruitId: UUID) async throws -> Bool {
        return try await progressRepository.toggleFavorite(fruitId: fruitId)
    }
    
    /// Get study statistics
    func getStudyStatistics() async throws -> StudyStatistics {
        return try await progressRepository.getStudyStatistics()
    }
    
    /// Mark fruit as studied
    func markAsStudied(fruitId: UUID) async throws -> UserProgress {
        var userProgress = try await progressRepository.fetchProgress(for: fruitId) ??
            UserProgress(
                userId: "current-user", // TODO: Get from auth service
                fruitId: fruitId
            )
        
        userProgress.progress.readingProgress = 1.0
        userProgress.lastAccessedAt = Date()
        userProgress.updatedAt = Date()
        
        return try await progressRepository.saveProgress(userProgress)
    }
}

/// Progress-related errors
enum ProgressError: LocalizedError {
    case invalidProgress
    case invalidScore
    case fruitNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidProgress:
            return "Progress must be between 0.0 and 1.0"
        case .invalidScore:
            return "Score must be between 0 and 100"
        case .fruitNotFound:
            return "Fruit not found in progress tracking"
        }
    }
}