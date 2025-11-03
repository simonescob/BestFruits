//
//  FruitCoreData.swift
//  BestFruits
//
//  Core Data entity for Fruit.
//

import Foundation
import CoreData

@objc(FruitEntity)
public class FruitEntity: NSManagedObject {
    
}

@objc(FruitEntity)
extension FruitEntity {
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var scientificName: String?
    @NSManaged public var fruitDescription: String
    @NSManaged public var imageURL: String?
    @NSManaged public var origin: String
    @NSManaged public var categories: [String]
    @NSManaged public var funFacts: [String]
    @NSManaged public var isFavorite: Bool
    @NSManaged public var calories: Int
    @NSManaged public var protein: Double
    @NSManaged public var fiber: Double
    @NSManaged public var vitaminC: Double
    @NSManaged public var potassium: Double
    @NSManaged public var waterContent: Double
    @NSManaged public var season: [String]
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var quizData: Data? // Encoded quiz questions
}

// MARK: - Fruit Entity Extension

extension FruitEntity {
    /// Convert to domain model
    func toDomain() -> Fruit {
        var quizQuestions: [QuizQuestion] = []
        
        if let quizData = self.quizData {
            do {
                quizQuestions = try JSONDecoder().decode([QuizQuestion].self, from: quizData)
            } catch {
                print("Error decoding quiz questions: \(error)")
            }
        }
        
        return Fruit(
            id: self.id,
            name: self.name,
            scientificName: self.scientificName,
            description: self.fruitDescription,
            imageURL: self.imageURL.flatMap { URL(string: $0) },
            nutritionalInfo: NutritionalInfo(
                calories: self.calories,
                protein: self.protein,
                fiber: self.fiber,
                vitaminC: self.vitaminC,
                potassium: self.potassium,
                waterContent: self.waterContent
            ),
            origin: self.origin,
            season: self.season.compactMap { Season(rawValue: $0) },
            categories: self.categories,
            funFacts: self.funFacts,
            quizQuestions: quizQuestions,
            isFavorite: self.isFavorite,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    /// Update from domain model
    func updateFromDomain(_ fruit: Fruit) {
        self.id = fruit.id
        self.name = fruit.name
        self.scientificName = fruit.scientificName
        self.fruitDescription = fruit.description
        self.imageURL = fruit.imageURL?.absoluteString
        self.origin = fruit.origin
        self.categories = fruit.categories
        self.funFacts = fruit.funFacts
        self.isFavorite = fruit.isFavorite
        self.calories = fruit.nutritionalInfo.calories
        self.protein = fruit.nutritionalInfo.protein
        self.fiber = fruit.nutritionalInfo.fiber
        self.vitaminC = fruit.nutritionalInfo.vitaminC
        self.potassium = fruit.nutritionalInfo.potassium
        self.waterContent = fruit.nutritionalInfo.waterContent
        self.season = fruit.season.map { $0.rawValue }
        self.createdAt = fruit.createdAt
        self.updatedAt = fruit.updatedAt
        
        // Encode quiz questions
        if !fruit.quizQuestions.isEmpty {
            do {
                self.quizData = try JSONEncoder().encode(fruit.quizQuestions)
            } catch {
                print("Error encoding quiz questions: \(error)")
                self.quizData = nil
            }
        } else {
            self.quizData = nil
        }
    }
}