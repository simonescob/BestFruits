//
//  FruitRepository.swift
//  BestFruits
//
//  Implementation of FruitRepositoryProtocol for data operations.
//

import Foundation
import Combine

/// Repository implementation for fruit data operations
class FruitRepository: FruitRepositoryProtocol {
    private let coreDataStack: CoreDataStack
    private let httpClient: HTTPClient
    private let fruitMapper: FruitMapper
    private let subjects = CurrentValueSubject<[Fruit], Never>([])
    
    init(
        coreDataStack: CoreDataStack = CoreDataStack.shared,
        httpClient: HTTPClient = HTTPClient.shared,
        fruitMapper: FruitMapper = FruitMapper()
    ) {
        self.coreDataStack = coreDataStack
        self.httpClient = httpClient
        self.fruitMapper = fruitMapper
    }
    
    var fruitsPublisher: AnyPublisher<[Fruit], Never> {
        subjects.eraseToAnyPublisher()
    }
    
    func fetchFruits() async throws -> [Fruit] {
        do {
            // Try to fetch from network first
            let fruits = try await fetchFromNetwork()
            
            // Cache locally
            await cacheFruitsLocally(fruits)
            
            // Update publisher
            subjects.send(fruits)
            
            return fruits
        } catch {
            // Fallback to local storage
            return try await fetchFromLocal()
        }
    }
    
    func fetchFruit(id: UUID) async throws -> Fruit? {
        do {
            // Try network first
            let endpoint = FruitAPI.getFruit(id: id)
            let response: APIResponse<FruitDTO> = try await httpClient.request(endpoint: .fruits(endpoint))
            
            if let fruitDTO = response.data {
                return fruitMapper.toDomain(fruitDTO)
            }
            
            return nil
        } catch {
            // Fallback to local storage
            return try await fetchFromLocal(id: id)
        }
    }
    
    func searchFruits(query: String) async throws -> [Fruit] {
        do {
            // Try network search first
            let endpoint = FruitAPI.searchFruits(query: query)
            let response: APIResponse<[FruitDTO]> = try await httpClient.request(endpoint: .fruits(endpoint))
            
            if let fruitDTOs = response.data {
                return fruitMapper.toDomainArray(fruitDTOs)
            }
            
            return []
        } catch {
            // Fallback to local search
            return try await searchLocally(query: query)
        }
    }
    
    func fetchFruits(by category: String) async throws -> [Fruit] {
        // This could be optimized with server-side filtering
        let allFruits = try await fetchFruits()
        return allFruits.filter { $0.categories.contains(category) }
    }
    
    func fetchFavorites() async throws -> [Fruit] {
        let allFruits = try await fetchFruits()
        return allFruits.filter { $0.isFavorite }
    }
    
    func createFruit(_ fruit: Fruit) async throws -> Fruit {
        let fruitDTO = fruitMapper.toDTO(fruit)
        let endpoint = FruitAPI.createFruit(fruitDTO)
        let response: APIResponse<FruitDTO> = try await httpClient.request(endpoint: .fruits(endpoint), method: .post, body: fruitDTO)
        
        guard let createdFruitDTO = response.data else {
            throw FruitRepositoryError.invalidData
        }
        
        let createdFruit = fruitMapper.toDomain(createdFruitDTO)
        
        // Cache locally
        await cacheFruitLocally(createdFruit)
        
        // Update publisher
        subjects.send(try await fetchFromLocal())
        
        return createdFruit
    }
    
    func updateFruit(_ fruit: Fruit) async throws -> Fruit {
        let fruitDTO = fruitMapper.toDTO(fruit)
        let endpoint = FruitAPI.updateFruit(id: fruit.id, fruitDTO)
        let response: APIResponse<FruitDTO> = try await httpClient.request(endpoint: .fruits(endpoint), method: .put, body: fruitDTO)
        
        guard let updatedFruitDTO = response.data else {
            throw FruitRepositoryError.invalidData
        }
        
        let updatedFruit = fruitMapper.toDomain(updatedFruitDTO)
        
        // Update local cache
        await updateLocalCache(updatedFruit)
        
        // Update publisher
        subjects.send(try await fetchFromLocal())
        
        return updatedFruit
    }
    
    func deleteFruit(id: UUID) async throws {
        let endpoint = FruitAPI.deleteFruit(id: id)
        _ = try await httpClient.request(endpoint: .fruits(endpoint), method: .delete)
        
        // Remove from local cache
        await removeFromLocalCache(id: id)
        
        // Update publisher
        subjects.send(try await fetchFromLocal())
    }
    
    func toggleFavorite(id: UUID) async throws -> Bool {
        // First get the current fruit
        guard var fruit = try await fetchFruit(id: id) else {
            throw FruitRepositoryError.notFound
        }
        
        // Toggle favorite status
        fruit.isFavorite = !fruit.isFavorite
        
        // Update both locally and on server
        _ = try await updateFruit(fruit)
        
        return fruit.isFavorite
    }
    
    func syncFruits() async throws -> [Fruit] {
        // Force network sync
        let fruits = try await fetchFromNetwork()
        await cacheFruitsLocally(fruits)
        subjects.send(fruits)
        return fruits
    }
    
    // MARK: - Private Methods
    
    private func fetchFromNetwork() async throws -> [Fruit] {
        let endpoint = FruitAPI.getAllFruits
        let response: APIResponse<[FruitDTO]> = try await httpClient.request(endpoint: .fruits(endpoint))
        
        guard let fruitDTOs = response.data else {
            throw FruitRepositoryError.invalidData
        }
        
        return fruitMapper.toDomainArray(fruitDTOs)
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
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                // Clear existing data
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FruitEntity.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                } catch {
                    print("Error clearing existing fruits: \(error)")
                }
                
                // Insert new fruits
                for fruit in fruits {
                    let entity = FruitEntity(context: context)
                    entity.updateFromDomain(fruit)
                }
                
                do {
                    try context.save()
                    continuation.resume()
                } catch {
                    print("Error saving fruits to Core Data: \(error)")
                    continuation.resume()
                }
            }
        }
    }
    
    private func cacheFruitLocally(_ fruit: Fruit) async {
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let entity = FruitEntity(context: context)
                entity.updateFromDomain(fruit)
                
                do {
                    try context.save()
                    continuation.resume()
                } catch {
                    print("Error saving fruit to Core Data: \(error)")
                    continuation.resume()
                }
            }
        }
    }
    
    private func updateLocalCache(_ fruit: Fruit) async {
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<FruitEntity> = FruitEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", fruit.id as CVarArg)
                
                do {
                    if let existingEntity = try context.fetch(fetchRequest).first {
                        existingEntity.updateFromDomain(fruit)
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    print("Error updating fruit in Core Data: \(error)")
                    continuation.resume()
                }
            }
        }
    }
    
    private func removeFromLocalCache(id: UUID) async {
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<FruitEntity> = FruitEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                do {
                    if let entity = try context.fetch(fetchRequest).first {
                        context.delete(entity)
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    print("Error removing fruit from Core Data: \(error)")
                    continuation.resume()
                }
            }
        }
    }
}