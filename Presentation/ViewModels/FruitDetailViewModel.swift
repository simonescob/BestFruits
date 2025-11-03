//
//  FruitDetailViewModel.swift
//  BestFruits
//
//  ViewModel for managing fruit detail state and operations.
//

import Foundation
import Combine

/// ViewModel for fruit detail view
@MainActor
class FruitDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var fruit: Fruit? = nil
    @Published var userProgress: UserProgress? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentQuizQuestionIndex: Int = 0
    @Published var quizAnswers: [Int: Int] = [:] // questionIndex: answerIndex
    @Published var quizStartTime: Date? = nil
    @Published var studyStartTime: Date? = nil
    @Published var notesText: String = ""
    
    // MARK: - Private Properties
    
    private let fruitRepository: FruitRepositoryProtocol
    private let saveProgressUseCase: SaveProgressUseCase
    private let fetchFruitUseCase: FetchFruitsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        fruit: Fruit? = nil,
        fruitRepository: FruitRepositoryProtocol? = nil,
        saveProgressUseCase: SaveProgressUseCase? = nil
    ) {
        self.fruit = fruit
        self.fruitRepository = fruitRepository ?? FruitRepository()
        self.saveProgressUseCase = saveProgressUseCase ?? Self.defaultSaveProgressUseCase()
        self.fetchFruitUseCase = FetchFruitsUseCase(fruitRepository: self.fruitRepository)
        
        if fruit != nil {
            loadUserProgress()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load fruit data by ID
    func loadFruit(id: UUID) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            if let loadedFruit = try await fruitRepository.fetchFruit(id: id) {
                await MainActor.run {
                    self.fruit = loadedFruit
                    isLoading = false
                }
                await loadUserProgress()
            } else {
                await MainActor.run {
                    errorMessage = "Fruit not found"
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    /// Start reading session
    func startReading() {
        studyStartTime = Date()
    }
    
    /// Update reading progress
    func updateReadingProgress(_ progress: Double) async {
        guard let fruit = fruit else { return }
        
        do {
            let updatedProgress = try await saveProgressUseCase.updateReadingProgress(
                fruitId: fruit.id,
                progress: progress,
                notes: notesText
            )
            
            await MainActor.run {
                userProgress = updatedProgress
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Start quiz
    func startQuiz() {
        quizStartTime = Date()
        currentQuizQuestionIndex = 0
        quizAnswers.removeAll()
    }
    
    /// Submit quiz answer
    func submitAnswer(_ answerIndex: Int) {
        guard fruit?.quizQuestions.indices.contains(currentQuizQuestionIndex) == true else { return }
        quizAnswers[currentQuizQuestionIndex] = answerIndex
    }
    
    /// Move to next question
    func nextQuestion() {
        guard let fruit = fruit else { return }
        if currentQuizQuestionIndex < fruit.quizQuestions.count - 1 {
            currentQuizQuestionIndex += 1
        }
    }
    
    /// Move to previous question
    func previousQuestion() {
        if currentQuizQuestionIndex > 0 {
            currentQuizQuestionIndex -= 1
        }
    }
    
    /// Complete quiz and calculate score
    func completeQuiz() async {
        guard let fruit = fruit, let quizStartTime = quizStartTime else { return }
        
        let timeTaken = Date().timeIntervalSince(quizStartTime)
        var correctAnswers = 0
        
        // Calculate score
        for (questionIndex, answerIndex) in quizAnswers {
            if questionIndex < fruit.quizQuestions.count,
               answerIndex == fruit.quizQuestions[questionIndex].correctAnswerIndex {
                correctAnswers += 1
            }
        }
        
        let score = fruit.quizQuestions.isEmpty ? 0 : (correctAnswers * 100) / fruit.quizQuestions.count
        
        do {
            // Save quiz score for each question
            for question in fruit.quizQuestions {
                _ = try await saveProgressUseCase.completeQuiz(
                    fruitId: fruit.id,
                    quizId: question.id,
                    score: score,
                    timeTaken: timeTaken
                )
            }
            
            await loadUserProgress()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Toggle favorite status
    func toggleFavorite() async {
        guard let fruit = fruit else { return }
        
        do {
            let isFavorite = try await saveProgressUseCase.toggleFavorite(fruitId: fruit.id)
            
            await MainActor.run {
                self.fruit?.isFavorite = isFavorite
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Save notes
    func saveNotes() async {
        guard let fruit = fruit else { return }
        
        let currentProgress = userProgress?.progress.readingProgress ?? 0.0
        
        do {
            _ = try await saveProgressUseCase.updateReadingProgress(
                fruitId: fruit.id,
                progress: currentProgress,
                notes: notesText
            )
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Load user progress for this fruit
    func loadUserProgress() async {
        guard let fruit = fruit else { return }
        
        do {
            let progress = try await saveProgressUseCase.progressRepository.fetchProgress(for: fruit.id)
            await MainActor.run {
                userProgress = progress
                notesText = progress?.progress.notes ?? ""
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Current quiz question
    var currentQuizQuestion: QuizQuestion? {
        guard let fruit = fruit, fruit.quizQuestions.indices.contains(currentQuizQuestionIndex) else {
            return nil
        }
        return fruit.quizQuestions[currentQuizQuestionIndex]
    }
    
    /// Quiz progress percentage
    var quizProgress: Double {
        guard let fruit = fruit, !fruit.quizQuestions.isEmpty else { return 0 }
        return Double(quizAnswers.count) / Double(fruit.quizQuestions.count)
    }
    
    /// Reading progress percentage
    var readingProgress: Double {
        return userProgress?.progress.readingProgress ?? 0.0
    }
    
    /// Is quiz complete
    var isQuizComplete: Bool {
        guard let fruit = fruit else { return false }
        return quizAnswers.count == fruit.quizQuestions.count
    }
    
    /// Can go to next question
    var canGoNext: Bool {
        guard let fruit = fruit else { return false }
        return currentQuizQuestionIndex < fruit.quizQuestions.count - 1
    }
    
    /// Can go to previous question
    var canGoPrevious: Bool {
        return currentQuizQuestionIndex > 0
    }
    
    /// Quiz completion status
    var isQuizCompleted: Bool {
        return userProgress?.progress.quizCompleted ?? false
    }
    
    /// Learning completion status
    var isLearningComplete: Bool {
        return userProgress?.progress.isComplete ?? false
    }
    
    // MARK: - Private Methods
    
    private func defaultSaveProgressUseCase() -> SaveProgressUseCase {
        // This would use a real progress repository in production
        let mockRepository = MockProgressRepository()
        return SaveProgressUseCase(progressRepository: mockRepository)
    }
}

// MARK: - Mock Progress Repository (placeholder)

private class MockProgressRepository: UserProgressRepositoryProtocol {
    func fetchProgress(for fruitId: UUID) async throws -> UserProgress? {
        return nil
    }
    
    func fetchAllProgress() async throws -> [UserProgress] {
        return []
    }
    
    func saveProgress(_ progress: UserProgress) async throws -> UserProgress {
        return progress
    }
    
    func updateLearningProgress(for fruitId: UUID, readingProgress: Double, quizCompleted: Bool, notes: String) async throws -> UserProgress {
        return UserProgress(userId: "mock", fruitId: fruitId)
    }
    
    func addQuizScore(for fruitId: UUID, quizId: UUID, score: Int, timeTaken: TimeInterval) async throws -> UserProgress {
        return UserProgress(userId: "mock", fruitId: fruitId)
    }
    
    func toggleFavorite(fruitId: UUID) async throws -> Bool {
        return true
    }
    
    func getFavorites() async throws -> [UUID] {
        return []
    }
    
    func getStudyStatistics() async throws -> StudyStatistics {
        return StudyStatistics()
    }
    
    func syncProgress() async throws -> [UserProgress] {
        return []
    }
    
    var progressPublisher: AnyPublisher<[UserProgress], Never> {
        Just([]).eraseToAnyPublisher()
    }
}