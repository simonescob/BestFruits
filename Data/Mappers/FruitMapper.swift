//
//  FruitMapper.swift
//  BestFruits
//
//  Mapper for converting between Fruit DTOs and domain models.
//

import Foundation

/// Mapper for converting fruit data between layers
class FruitMapper {
    
    /// Convert DTO to domain model
    static func toDomain(_ dto: FruitDTO) -> Fruit {
        return Fruit(
            id: dto.id,
            name: dto.name,
            scientificName: dto.scientificName,
            description: dto.description,
            imageURL: dto.imageURL.flatMap { URL(string: $0) },
            nutritionalInfo: NutritionalInfo(
                calories: dto.nutritionalInfo.calories,
                protein: dto.nutritionalInfo.protein,
                fiber: dto.nutritionalInfo.fiber,
                vitaminC: dto.nutritionalInfo.vitaminC,
                potassium: dto.nutritionalInfo.potassium,
                waterContent: dto.nutritionalInfo.waterContent
            ),
            origin: dto.origin,
            season: dto.season.compactMap { Season(rawValue: $0) },
            categories: dto.categories,
            funFacts: dto.funFacts,
            quizQuestions: dto.quizQuestions.map { toDomain($0) },
            isFavorite: dto.isFavorite,
            createdAt: ISO8601DateFormatter().date(from: dto.createdAt) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: dto.updatedAt) ?? Date()
        )
    }
    
    /// Convert domain model to DTO
    static func toDTO(_ fruit: Fruit) -> FruitDTO {
        let dateFormatter = ISO8601DateFormatter()
        
        return FruitDTO(
            id: fruit.id,
            name: fruit.name,
            scientificName: fruit.scientificName,
            description: fruit.description,
            imageURL: fruit.imageURL?.absoluteString,
            origin: fruit.origin,
            categories: fruit.categories,
            funFacts: fruit.funFacts,
            isFavorite: fruit.isFavorite,
            nutritionalInfo: NutritionalInfoDTO(
                calories: fruit.nutritionalInfo.calories,
                protein: fruit.nutritionalInfo.protein,
                fiber: fruit.nutritionalInfo.fiber,
                vitaminC: fruit.nutritionalInfo.vitaminC,
                potassium: fruit.nutritionalInfo.potassium,
                waterContent: fruit.nutritionalInfo.waterContent
            ),
            season: fruit.season.map { $0.rawValue },
            quizQuestions: fruit.quizQuestions.map { toDTO($0) },
            createdAt: dateFormatter.string(from: fruit.createdAt),
            updatedAt: dateFormatter.string(from: fruit.updatedAt)
        )
    }
    
    /// Convert quiz question DTO to domain model
    private static func toDomain(_ dto: QuizQuestionDTO) -> QuizQuestion {
        return QuizQuestion(
            id: dto.id,
            question: dto.question,
            options: dto.options,
            correctAnswerIndex: dto.correctAnswerIndex,
            explanation: dto.explanation,
            difficulty: Difficulty(rawValue: dto.difficulty) ?? .easy
        )
    }
    
    /// Convert quiz question domain model to DTO
    private static func toDTO(_ question: QuizQuestion) -> QuizQuestionDTO {
        return QuizQuestionDTO(
            id: question.id,
            question: question.question,
            options: question.options,
            correctAnswerIndex: question.correctAnswerIndex,
            explanation: question.explanation,
            difficulty: question.difficulty.rawValue
        )
    }
    
    /// Convert array of DTOs to domain models
    static func toDomainArray(_ dtos: [FruitDTO]) -> [Fruit] {
        return dtos.map { toDomain($0) }
    }
    
    /// Convert array of domain models to DTOs
    static func toDTOArray(_ fruits: [Fruit]) -> [FruitDTO] {
        return fruits.map { toDTO($0) }
    }
}