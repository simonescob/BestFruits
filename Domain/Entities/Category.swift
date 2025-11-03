//
//  Category.swift
//  BestFruits
//
//  Domain entity for fruit categories in the educational app.
//

import Foundation

/// Domain entity for fruit categories
struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String // SF Symbol name
    let color: String // Hex color
    let fruitCount: Int
    let isActive: Bool
    let sortOrder: Int
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        color: String = "#007AFF",
        fruitCount: Int = 0,
        isActive: Bool = true,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.fruitCount = fruitCount
        self.isActive = isActive
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
    
    /// Predefined categories for fruits
    static func predefined() -> [Category] {
        return [
            Category(
                name: "Tropical",
                description: "Exotic fruits from tropical regions",
                icon: "sun.max",
                color: "#FF6B35",
                sortOrder: 1
            ),
            Category(
                name: "Citrus",
                description: "Citrus fruits rich in vitamin C",
                icon: "lemon",
                color: "#FFD23F",
                sortOrder: 2
            ),
            Category(
                name: "Berries",
                description: "Small, colorful, and nutritious berries",
                icon: "drop.fill",
                color: "#8B5CF6",
                sortOrder: 3
            ),
            Category(
                name: "Stone Fruits",
                description: "Fruits with a single hard stone",
                icon: "circle.fill",
                color: "#F97316",
                sortOrder: 4
            ),
            Category(
                name: "Melons",
                description: "Large, juicy fruits perfect for summer",
                icon: "circle.lefthalf.filled",
                color: "#10B981",
                sortOrder: 5
            ),
            Category(
                name: "Apples & Pears",
                description: "Classic temperate zone fruits",
                icon: "square.fill",
                color: "#EF4444",
                sortOrder: 6
            ),
            Category(
                name: "Exotic",
                description: "Rare and unusual fruits from around the world",
                icon: "sparkles",
                color: "#8B5CF6",
                sortOrder: 7
            ),
            Category(
                name: "Dried",
                description: "Dehydrated fruits for snacks and recipes",
                icon: "cloud.sun.fill",
                color: "#F59E0B",
                sortOrder: 8
            )
        ]
    }
}