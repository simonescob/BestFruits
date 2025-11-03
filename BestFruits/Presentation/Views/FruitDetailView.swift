//
//  FruitDetailView.swift
//  BestFruits
//
//  Detailed view for individual fruit with educational features.
//

import SwiftUI

struct FruitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FruitDetailViewModel
    @State private var selectedTab = 0 // 0: Info, 1: Quiz, 2: Notes
    
    init(viewModel: FruitDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let fruit = viewModel.fruit {
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero section
                        heroSection(fruit)
                        
                        // Progress section
                        progressSection
                        
                        // Tab navigation
                        tabNavigation
                        
                        // Tab content
                        tabContent
                    }
                    .padding()
                }
            } else {
                LoadingView(message: "Loading fruit details...", isFullScreen: true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: viewModel.fruit?.isFavorite == true ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.fruit?.isFavorite == true ? .red : .blue)
                }
            }
        }
        .task {
            if let fruit = viewModel.fruit {
                viewModel.startReading()
            }
        }
    }
    
    // MARK: - Hero Section
    
    private func heroSection(_ fruit: Fruit) -> some View {
        VStack(spacing: 16) {
            // Fruit image
            if let imageURL = fruit.imageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(16)
            }
            
            // Fruit info
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fruit.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let scientificName = fruit.scientificName {
                        Text(scientificName)
                            .font(.title3)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(fruit.description)
                    .font(.body)
                    .foregroundColor(.primary)
                
                // Categories and seasons
                if !fruit.categories.isEmpty || !fruit.season.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        if !fruit.categories.isEmpty {
                            Text("Categories")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(fruit.categories, id: \.self) { category in
                                        Text(category)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        if !fruit.season.isEmpty {
                            Text("Available Seasons")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                ForEach(fruit.season, id: \.self) { season in
                                    Text(season.displayName)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Origin
                if !fruit.origin.isEmpty {
                    Text("Origin: \(fruit.origin)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Learning Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(viewModel.readingProgress * 100))%")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: viewModel.readingProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
            
            if viewModel.isLearningComplete {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Learning Complete!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Tab Navigation
    
    private var tabNavigation: some View {
        HStack {
            ForEach(0..<3) { index in
                Button {
                    selectedTab = index
                } label: {
                    Text(tabTitle(for: index))
                        .font(.subheadline)
                        .fontWeight(selectedTab == index ? .semibold : .medium)
                        .foregroundColor(selectedTab == index ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTab == index ? Color.blue : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Info"
        case 1: return "Quiz"
        case 2: return "Notes"
        default: return ""
        }
    }
    
    // MARK: - Tab Content
    
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case 0:
                nutritionalInfoTab
            case 1:
                quizTab
            case 2:
                notesTab
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Tab: Nutritional Info
    
    private var nutritionalInfoTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutritional Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let fruit = viewModel.fruit {
                VStack(spacing: 12) {
                    nutritionRow(title: "Calories", value: "\(fruit.nutritionalInfo.calories) kcal")
                    nutritionRow(title: "Protein", value: "\(fruit.nutritionalInfo.protein, specifier: "%.1f") g")
                    nutritionRow(title: "Fiber", value: "\(fruit.nutritionalInfo.fiber, specifier: "%.1f") g")
                    nutritionRow(title: "Vitamin C", value: "\(fruit.nutritionalInfo.vitaminC, specifier: "%.1f") mg")
                    nutritionRow(title: "Potassium", value: "\(fruit.nutritionalInfo.potassium, specifier: "%.1f") mg")
                    nutritionRow(title: "Water Content", value: "\(fruit.nutritionalInfo.waterContent, specifier: "%.1f")%")
                }
            }
            
            // Fun facts
            if let fruit = viewModel.fruit, !fruit.funFacts.isEmpty {
                Text("Fun Facts")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(fruit.funFacts, id: \.self) { fact in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            
                            Text(fact)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }
    
    private func nutritionRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Tab: Quiz
    
    private var quizTab: some View {
        Group {
            if let fruit = viewModel.fruit, fruit.quizQuestions.isEmpty {
                EmptyStateView(
                    icon: "questionmark.circle",
                    title: "No Quiz Available",
                    message: "Quiz questions for this fruit are not available yet."
                )
            } else if let fruit = viewModel.fruit, !fruit.quizQuestions.isEmpty {
                quizContent(fruit)
            }
        }
    }
    
    private func quizContent(_ fruit: Fruit) -> some View {
        VStack(spacing: 16) {
            if viewModel.currentQuizQuestion != nil {
                quizQuestionView
            } else {
                quizStartView
            }
        }
    }
    
    private var quizStartView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Ready to test your knowledge?")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Answer questions about \(fruit?.name ?? "this fruit")")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Quiz includes \(fruit?.quizQuestions.count ?? 0) questions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("70% or higher to pass")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            
            Button("Start Quiz") {
                viewModel.startQuiz()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private var quizQuestionView: some View {
        VStack(spacing: 16) {
            // Progress
            HStack {
                Text("Question \(viewModel.currentQuizQuestionIndex + 1) of \(fruit?.quizQuestions.count ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(viewModel.quizProgress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: viewModel.quizProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
            
            // Question
            if let question = viewModel.currentQuizQuestion {
                VStack(alignment: .leading, spacing: 12) {
                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(question.options.indices, id: \.self) { index in
                            Button {
                                viewModel.submitAnswer(index)
                            } label: {
                                HStack {
                                    Text(Character(UnicodeScalar(65 + index)!).description)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(question.options[index])
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            viewModel.quizAnswers[viewModel.currentQuizQuestionIndex] == index 
                                            ? Color.blue : Color.gray.opacity(0.3),
                                            lineWidth: 2
                                        )
                                        .fill(
                                            viewModel.quizAnswers[viewModel.currentQuizQuestionIndex] == index 
                                            ? Color.blue.opacity(0.1) : Color.clear
                                        )
                                )
                            }
                        }
                    }
                }
                
                // Navigation
                HStack {
                    if viewModel.canGoPrevious {
                        Button("Previous") {
                            viewModel.previousQuestion()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if viewModel.canGoNext {
                        Button("Next") {
                            viewModel.nextQuestion()
                        }
                        .buttonStyle(.borderedProminent)
                    } else if viewModel.isQuizComplete {
                        Button("Submit Quiz") {
                            Task {
                                await viewModel.completeQuiz()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("Select an answer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Tab: Notes
    
    private var notesTab: some View {
        VStack(spacing: 16) {
            Text("Your Notes")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $viewModel.notesText)
                .font(.body)
                .frame(minHeight: 200)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            HStack {
                Spacer()
                
                Button("Save Notes") {
                    Task {
                        await viewModel.saveNotes()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var fruit: Fruit? {
        return viewModel.fruit
    }
}

// MARK: - Preview

struct FruitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFruit = Fruit(
            name: "Apple",
            scientificName: "Malus domestica",
            description: "A sweet and crunchy fruit that's perfect for snacking.",
            origin: "Central Asia",
            categories: ["Apples & Pears"],
            season: [.autumn, .winter],
            nutritionalInfo: NutritionalInfo(
                calories: 52,
                protein: 0.3,
                fiber: 2.4,
                vitaminC: 4.6,
                potassium: 107,
                waterContent: 86
            ),
            funFacts: [
                "Apples float because they are 25% air",
                "There are over 7,500 varieties of apples worldwide"
            ]
        )
        
        FruitDetailView(viewModel: FruitDetailViewModel(fruit: sampleFruit))
    }
}