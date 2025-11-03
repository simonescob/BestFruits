//
//  UserProgress.swift
//  BestFruits
//
//  Domain entity for tracking user educational progress.
//

import Foundation

/// Domain entity for tracking user learning progress
struct UserProgress: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: String
    let fruitId: UUID
    let progress: LearningProgress
    let quizScores: [QuizScore]
    let bookmarks: [UUID] // Fruit IDs
    let studyTime: TimeInterval // in seconds
    let lastAccessedAt: Date
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        userId: String,
        fruitId: UUID,
        progress: LearningProgress = LearningProgress(),
        quizScores: [QuizScore] = [],
        bookmarks: [UUID] = [],
        studyTime: TimeInterval = 0,
        lastAccessedAt: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.fruitId = fruitId
        self.progress = progress
        self.quizScores = quizScores
        self.bookmarks = bookmarks
        self.studyTime = studyTime
        self.lastAccessedAt = lastAccessedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Learning progress tracking
struct LearningProgress: Codable, Equatable {
    let readingProgress: Double // 0.0 to 1.0
    let quizCompleted: Bool
    let quizzesPassed: Int
    let totalQuizzes: Int
    let favoriteStatus: Bool
    let notes: String
    
    init(
        readingProgress: Double = 0.0,
        quizCompleted: Bool = false,
        quizzesPassed: Int = 0,
        totalQuizzes: Int = 0,
        favoriteStatus: Bool = false,
        notes: String = ""
    ) {
        self.readingProgress = min(max(readingProgress, 0.0), 1.0) // Clamp between 0 and 1
        self.quizCompleted = quizCompleted
        self.quizzesPassed = quizzesPassed
        self.totalQuizzes = totalQuizzes
        self.favoriteStatus = favoriteStatus
        self.notes = notes
    }
    
    /// Calculate completion percentage
    var completionPercentage: Double {
        let readingWeight: Double = 0.4
        let quizWeight: Double = 0.6
        
        let readingScore = readingProgress * readingWeight
        let quizScore = totalQuizzes > 0 ? (Double(quizzesPassed) / Double(totalQuizzes)) * quizWeight : 0
        
        return readingScore + quizScore
    }
    
    /// Check if learning is complete
    var isComplete: Bool {
        return readingProgress >= 1.0 && quizCompleted && quizScores.isEmpty == false
    }
}

/// Quiz score tracking
struct QuizScore: Codable, Equatable {
    let id: UUID
    let quizId: UUID
    let score: Int // percentage 0-100
    let timeTaken: TimeInterval
    let completedAt: Date
    
    init(
        id: UUID = UUID(),
        quizId: UUID,
        score: Int,
        timeTaken: TimeInterval,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.quizId = quizId
        self.score = max(0, min(score, 100)) // Clamp between 0 and 100
        self.timeTaken = timeTaken
        self.completedAt = completedAt
    }
    
    /// Determine if score is passing
    var isPassing: Bool {
        return score >= 70 // 70% passing grade
    }
    
    /// Get grade letter
    var gradeLetter: String {
        switch score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

/// Achievement tracking
struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let targetValue: Int
    let currentValue: Int
    let isUnlocked: Bool
    let unlockedAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        targetValue: Int,
        currentValue: Int = 0,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
    
    /// Progress percentage toward unlocking
    var progressPercentage: Double {
        return targetValue > 0 ? Double(currentValue) / Double(targetValue) : 0
    }
    
    /// Check if achievement should be unlocked
    mutating func checkUnlock() {
        if !isUnlocked && currentValue >= targetValue {
            isUnlocked = true
            unlockedAt = Date()
        }
    }
}

/// Achievement categories
enum AchievementCategory: String, Codable, CaseIterable {
    case learning = "Learning"
    case quiz = "Quiz"
    case exploration = "Exploration"
    case social = "Social"
    case consistency = "Consistency"
    
    var displayName: String {
        return self.rawValue
    }
}