//
//  FruitDTO.swift
//  BestFruits
//
//  Data Transfer Objects for API communication with Go backend.
//

import Foundation

/// DTO for fruit data transfer
struct FruitDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let scientificName: String?
    let description: String
    let imageURL: String?
    let origin: String
    let categories: [String]
    let funFacts: [String]
    let isFavorite: Bool
    let nutritionalInfo: NutritionalInfoDTO
    let season: [String]
    let quizQuestions: [QuizQuestionDTO]
    let createdAt: String
    let updatedAt: String
}

/// DTO for nutritional information
struct NutritionalInfoDTO: Codable {
    let calories: Int
    let protein: Double
    let fiber: Double
    let vitaminC: Double
    let potassium: Double
    let waterContent: Double
}

/// DTO for quiz questions
struct QuizQuestionDTO: Codable, Identifiable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let difficulty: String
}

/// DTO for category data
struct CategoryDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let color: String
    let fruitCount: Int
    let isActive: Bool
    let sortOrder: Int
    let createdAt: String
}

/// DTO for user progress
struct UserProgressDTO: Codable, Identifiable {
    let id: UUID
    let userId: String
    let fruitId: UUID
    let readingProgress: Double
    let quizCompleted: Bool
    let quizzesPassed: Int
    let totalQuizzes: Int
    let favoriteStatus: Bool
    let notes: String
    let quizScores: [QuizScoreDTO]
    let studyTime: Double
    let lastAccessedAt: String
    let createdAt: String
    let updatedAt: String
}

/// DTO for quiz scores
struct QuizScoreDTO: Codable, Identifiable {
    let id: UUID
    let quizId: UUID
    let score: Int
    let timeTaken: Double
    let completedAt: String
}

/// DTO for study statistics
struct StudyStatisticsDTO: Codable {
    let totalStudyTime: Double
    let fruitsStudied: Int
    let quizzesTaken: Int
    let averageQuizScore: Double
    let currentStreak: Int
    let bestStreak: Int
    let favoriteCategory: String?
    let lastStudyDate: String?
}

/// DTO for API responses
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

/// DTO for batch operations
struct BatchOperationDTO<T: Codable>: Codable {
    let operation: String
    let items: [T]
    let timestamp: String
}