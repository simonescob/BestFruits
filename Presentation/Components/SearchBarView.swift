//
//  SearchBarView.swift
//  BestFruits
//
//  Reusable search bar component with filtering options.
//

import SwiftUI

/// Reusable search bar component with filter options
struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isFilterVisible: Bool
    @Binding var selectedCategory: String?
    @Binding var showFavoritesOnly: Bool
    @Binding var sortOption: SortOption
    
    let categories: [String]
    let onSearch: (String) -> Void
    let onFilter: () -> Void
    
    @State private var isSearchActive = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main search bar
            HStack {
                // Search text field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Search fruits...", text: $searchText)
                        .onSubmit {
                            onSearch(searchText)
                            isSearchActive = false
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            onSearch("")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Filter button
                Button(action: onFilter) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16))
                        .foregroundColor(isFilterVisible ? .blue : .secondary)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            
            // Filter panel (collapsible)
            if isFilterVisible {
                filterPanel
                    .transition(.slide)
            }
            
            // Active filters display
            if hasActiveFilters {
                activeFiltersView
                    .transition(.slide)
            }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Filter Panel
    
    private var filterPanel: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Filters")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Category filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(["All"] + categories, id: \.self) { category in
                            FilterChip(
                                title: category,
                                isSelected: selectedCategory == category || (category == "All" && selectedCategory == nil),
                                action: {
                                    if category == "All" {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = category
                                    }
                                    onFilter()
                                }
                            )
                        }
                    }
                }
            }
            
            // Favorites filter
            HStack {
                Text("Show favorites only")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Toggle("", isOn: $showFavoritesOnly)
                    .labelsHidden()
                    .onChange(of: showFavoritesOnly) { _ in
                        onFilter()
                    }
            }
            
            // Sort options
            VStack(alignment: .leading, spacing: 8) {
                Text("Sort by")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            FilterChip(
                                title: option.displayName,
                                isSelected: sortOption == option,
                                action: {
                                    sortOption = option
                                    onFilter()
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Active Filters Display
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let category = selectedCategory {
                    FilterTag(title: "Category: \(category)") {
                        selectedCategory = nil
                        onFilter()
                    }
                }
                
                if showFavoritesOnly {
                    FilterTag(title: "Favorites") {
                        showFavoritesOnly = false
                        onFilter()
                    }
                }
                
                if searchText.isEmpty == false {
                    FilterTag(title: "Search: \"\(searchText)\"") {
                        searchText = ""
                        onSearch("")
                    }
                }
                
                // Clear all filters button
                if hasActiveFilters {
                    Button("Clear All") {
                        searchText = ""
                        selectedCategory = nil
                        showFavoritesOnly = false
                        sortOption = .name
                        onFilter()
                        onSearch("")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        return selectedCategory != nil || 
               showFavoritesOnly || 
               !searchText.isEmpty ||
               sortOption != .name
    }
}

// MARK: - Supporting Views

/// Filter chip component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Filter tag component
struct FilterTag: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
            
            Button(action: action) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SearchBarView(
                searchText: .constant(""),
                isFilterVisible: .constant(false),
                selectedCategory: .constant(nil),
                showFavoritesOnly: .constant(false),
                sortOption: .constant(.name),
                categories: ["Tropical", "Citrus", "Berries"],
                onSearch: { print("Searching for: \($0)") },
                onFilter: { print("Filter applied") }
            )
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}