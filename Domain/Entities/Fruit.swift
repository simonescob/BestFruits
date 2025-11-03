//
//  Fruit.swift
//  BestFruits
//
//  Domain entity representing a fruit in the educational app.
//

import Foundation

/// Domain entity for a fruit with educational content
struct Fruit: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let scientificName: String?
    let description: String
    let imageURL: URL?
    let nutritionalInfo: NutritionalInfo
    let origin: String
    let season: [Season]
    let categories: [String] // Category IDs
    let funFacts: [String]
    let quizQuestions: [QuizQuestion]
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        scientificName: String? = nil,
        description: String,
        imageURL: URL? = nil,
        nutritionalInfo: NutritionalInfo = NutritionalInfo(),
        origin: String = "",
        season: [Season] = [],
        categories: [String] = [],
        funFacts: [String] = [],
        quizQuestions: [QuizQuestion] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.scientificName = scientificName
        self.description = description
        self.imageURL = imageURL
        self.nutritionalInfo = nutritionalInfo
        self.origin = origin
        self.season = season
        self.categories = categories
        self.funFacts = funFacts
        self.quizQuestions = quizQuestions
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Nutritional information for fruits
struct NutritionalInfo: Codable, Equatable {
    let calories: Int
    let protein: Double // grams
    let fiber: Double // grams
    let vitaminC: Double // mg
    let potassium: Double // mg
    let waterContent: Double // percentage
    
    init(
        calories: Int = 0,
        protein: Double = 0,
        fiber: Double = 0,
        vitaminC: Double = 0,
        potassium: Double = 0,
        waterContent: Double = 0
    ) {
        self.calories = calories
        self.protein = protein
        self.fiber = fiber
        self.vitaminC = vitaminC
        self.potassium = potassium
        self.waterContent = waterContent
    }
}

/// Seasonal availability of fruits
enum Season: String, Codable, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
    
    var displayName: String {
        return self.rawValue
    }
}

/// Quiz questions related to fruits
struct QuizQuestion: Codable, Equatable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let difficulty: Difficulty
    
    init(
        id: UUID = UUID(),
        question: String,
        options: [String],
        correctAnswerIndex: Int,
        explanation: String = "",
        difficulty: Difficulty = .easy
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.difficulty = difficulty
    }
}

/// Difficulty levels for quiz questions
enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}