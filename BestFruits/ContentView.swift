//
//  ContentView.swift
//  BestFruits
//
//  Main content view for the educational fruit app.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FruitListViewModel()
    @State private var selectedFruit: Fruit? = nil
    @State private var showingFruitDetail = false
    @State private var selectedCategory: String? = nil
    
    let categories = Category.predefined()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search and filters
                SearchBarView(
                    searchText: $viewModel.searchQuery,
                    isFilterVisible: .constant(false), // TODO: Implement filter toggle
                    selectedCategory: $selectedCategory,
                    showFavoritesOnly: $viewModel.showFavoritesOnly,
                    sortOption: Binding(
                        get: { viewModel.selectedSortOption },
                        set: { newValue in
                            Task {
                                await viewModel.changeSortOption(newValue)
                            }
                        }
                    ),
                    categories: categories.map { $0.name },
                    onSearch: { query in
                        Task {
                            await viewModel.searchFruits(query: query)
                        }
                    },
                    onFilter: {
                        // TODO: Implement filter action
                    }
                )
                
                // Content
                contentView
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingFruitDetail) {
            if let fruit = selectedFruit {
                FruitDetailView(viewModel: FruitDetailViewModel(fruit: fruit))
            }
        }
        .task {
            await viewModel.loadFruits()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BestFruits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Learn about fruits")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Stats display
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.filteredCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("fruits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Categories bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.id) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category.name
                        ) {
                            selectedCategory = category.name
                            Task {
                                await viewModel.filterByCategory(category.name)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(message: "Loading fruits...", isFullScreen: true)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(error: NSError(domain: "FruitError", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])) {
                    Task {
                        await viewModel.refresh()
                    }
                }
            } else if viewModel.fruits.isEmpty {
                EmptyStateView(
                    icon: "leaf",
                    title: "No Fruits Found",
                    message: "Try adjusting your search or filters to find fruits.",
                    actionTitle: "Clear Filters"
                ) {
                    selectedCategory = nil
                    viewModel.searchQuery = ""
                    Task {
                        await viewModel.refresh()
                    }
                }
            } else {
                // Fruit list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.fruits) { fruit in
                            FruitCardView(
                                fruit: fruit,
                                onTap: {
                                    selectedFruit = fruit
                                    showingFruitDetail = true
                                },
                                onFavoriteToggle: {
                                    Task {
                                        await viewModel.toggleFavorite(fruit: fruit)
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

// MARK: - Category Button Component

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        ContentView()
            .preferredColorScheme(.dark)
    }
}