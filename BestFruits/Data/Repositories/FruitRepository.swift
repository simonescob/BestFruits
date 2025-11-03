//
//  FruitRepository.swift
//  BestFruits
//
//  Implementation of FruitRepositoryProtocol for data operations.
//

import Foundation
import CoreData
import Combine

/// Repository implementation for fruit data operations
class FruitRepository: FruitRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let httpClient: HTTPClient
    private let subjects = CurrentValueSubject<[Fruit], Never>([])
    
    init(
        coreDataStack: CoreDataStack = CoreDataStack.shared,
        httpClient: HTTPClient = HTTPClient.shared
    ) {
        self.coreDataStack = coreDataStack
        self.httpClient = httpClient
    }
    
    var fruitsPublisher: AnyPublisher<[Fruit], Never> {
        subjects.eraseToAnyPublisher()
    }
    
    func fetchFruits() async throws -> [Fruit] {
        // Try network first, fallback to local
        do {
            let fruits = try await fetchFromNetwork()
            await cacheFruitsLocally(fruits)
            subjects.send(fruits)
            return fruits
        } catch {
            return try await fetchFromLocal()
        }
    }
    
    func fetchFruit(id: UUID) async throws -> Fruit? {
        do {
            let endpoint = FruitAPI.getFruit(id: id)
            let response: APIResponse<FruitDTO> = try await httpClient.request(endpoint: endpoint)
            return response.data.flatMap { FruitMapper.toDomain($0) }
        } catch {
            return try await fetchFromLocal(id: id)
        }
    }
    
    func searchFruits(query: String) async throws -> [Fruit] {
        do {
            let endpoint = FruitAPI.searchFruits(query: query)
            let response: APIResponse<[FruitDTO]> = try await httpClient.request(endpoint: endpoint)
            return response.data.flatMap { FruitMapper.toDomainArray($0) } ?? []
        } catch {
            return try await searchLocally(query: query)
        }
    }
    
    func fetchFruits(by category: String) async throws -> [Fruit] {
        let allFruits = try await fetchFruits()
        return allFruits.filter { $0.categories.contains(category) }
    }
    
    func fetchFavorites() async throws -> [Fruit] {
        let allFruits = try await fetchFruits()
        return allFruits.filter { $0.isFavorite }
    }
    
    func createFruit(_ fruit: Fruit) async throws -> Fruit {
        let fruitDTO = FruitMapper.toDTO(fruit)
        let endpoint = FruitAPI.createFruit(fruitDTO)
        let response: APIResponse<FruitDTO> = try await httpClient.request(endpoint: endpoint, method: .post, body: fruitDTO)
        
        guard let createdFruitDTO = response.data else {
            throw FruitRepositoryError.invalidData
        }
        
        let createdFruit = FruitMapper.toDomain(createdFruitDTO)
        await cacheFruitLocally(createdFruit)
        subjects.send(try await fetchFromLocal())
        
        return createdFruit
    }
    
    func updateFruit(_ fruit: Fruit) async throws -> Fruit {
        let fruitDTO = FruitMapper.toDTO(fruit)
        let endpoint = FruitAPI.updateFruit(id: fruit.id, fruitDTO)
        let response: APIResponse<FruitDTO> = try await httpClient.request(endpoint: endpoint, method: .put, body: fruitDTO)
        
        guard let updatedFruitDTO = response.data else {
            throw FruitRepositoryError.invalidData
        }
        
        let updatedFruit = FruitMapper.toDomain(updatedFruitDTO)
        await updateLocalCache(updatedFruit)
        subjects.send(try await fetchFromLocal())
        
        return updatedFruit
    }
    
    func deleteFruit(id: UUID) async throws {
        let endpoint = FruitAPI.deleteFruit(id: id)
        struct DeleteResponse: Decodable {}
        _ = try await httpClient.request(endpoint: endpoint, method: .delete) as DeleteResponse
        
        await removeFromLocalCache(id: id)
        subjects.send(try await fetchFromLocal())
    }
    
    func toggleFavorite(id: UUID) async throws -> Bool {
        guard var fruit = try await fetchFruit(id: id) else {
            throw FruitRepositoryError.notFound
        }
        
        // Create new fruit with toggled favorite status
        let updatedFruit = Fruit(
            id: fruit.id,
            name: fruit.name,
            scientificName: fruit.scientificName,
            description: fruit.description,
            imageURL: fruit.imageURL,
            nutritionalInfo: fruit.nutritionalInfo,
            origin: fruit.origin,
            season: fruit.season,
            categories: fruit.categories,
            funFacts: fruit.funFacts,
            quizQuestions: fruit.quizQuestions,
            isFavorite: !fruit.isFavorite,
            createdAt: fruit.createdAt,
            updatedAt: Date()
        )
        
        _ = try await updateFruit(updatedFruit)
        return updatedFruit.isFavorite
    }
    
    func syncFruits() async throws -> [Fruit] {
        let fruits = try await fetchFromNetwork()
        await cacheFruitsLocally(fruits)
        subjects.send(fruits)
        return fruits
    }
    
    // MARK: - Private Methods
    
    private func fetchFromNetwork() async throws -> [Fruit] {
        let endpoint = FruitAPI.getAllFruits
        let response: APIResponse<[FruitDTO]> = try await httpClient.request(endpoint: endpoint)
        
        guard let fruitDTOs = response.data else {
            throw FruitRepositoryError.invalidData
        }
        
        return FruitMapper.toDomainArray(fruitDTOs)
    }
    
    private func fetchFromLocal() async throws -> [Fruit] {
        let coreDataStack = CoreDataStack.shared
        return try coreDataStack.fetchFruitEntities().map { $0.toDomain() }
    }
    
    private func fetchFromLocal(id: UUID) async throws -> Fruit? {
        let coreDataStack = CoreDataStack.shared
        return coreDataStack.fetchFruitEntity(id: id)?.toDomain()
    }
    
    private func searchLocally(query: String) async throws -> [Fruit] {
        let fruits = try await fetchFromLocal()
        let lowercasedQuery = query.lowercased()
        
        return fruits.filter { fruit in
            fruit.name.lowercased().contains(lowercasedQuery) ||
            fruit.description.lowercased().contains(lowercasedQuery) ||
            (fruit.scientificName?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
    
    private func cacheFruitsLocally(_ fruits: [Fruit]) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.coreDataStack.performBackgroundTask { context in
                    do {
                        // Clear existing data
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FruitEntity")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        try context.execute(deleteRequest)
                        
                        // Insert new fruits
                        for fruit in fruits {
                            let entity = FruitEntity(context: context)
                            entity.updateFromDomain(fruit)
                        }
                        
                        try context.save()
                    } catch {
                        print("Error saving fruits to Core Data: \(error)")
                    }
                }
            }
        }
    }
    
    private func cacheFruitLocally(_ fruit: Fruit) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.coreDataStack.performBackgroundTask { context in
                    let entity = FruitEntity(context: context)
                    entity.updateFromDomain(fruit)
                    
                    do {
                        try context.save()
                    } catch {
                        print("Error saving fruit to Core Data: \(error)")
                    }
                }
            }
        }
    }
    
    private func updateLocalCache(_ fruit: Fruit) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.coreDataStack.performBackgroundTask { context in
                    let fetchRequest = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
                    fetchRequest.predicate = NSPredicate(format: "id == %@", fruit.id as CVarArg)
                    
                    do {
                        if let existingEntity = try context.fetch(fetchRequest).first {
                            existingEntity.updateFromDomain(fruit)
                            try context.save()
                        }
                    } catch {
                        print("Error updating fruit in Core Data: \(error)")
                    }
                }
            }
        }
    }
    
    private func removeFromLocalCache(id: UUID) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.coreDataStack.performBackgroundTask { context in
                    let fetchRequest = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
                    fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    
                    do {
                        if let entity = try context.fetch(fetchRequest).first {
                            context.delete(entity)
                            try context.save()
                        }
                    } catch {
                        print("Error removing fruit from Core Data: \(error)")
                    }
                }
            }
        }
    }
}

