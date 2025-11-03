//
//  FruitCardView.swift
//  BestFruits
//
//  Reusable fruit card component for displaying fruit information.
//

import SwiftUI

/// Reusable fruit card component
struct FruitCardView: View {
    let fruit: Fruit
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image section
            ZStack {
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
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(Constants.UI.cornerRadius)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                
                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onFavoriteToggle) {
                            Image(systemName: fruit.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(fruit.isFavorite ? .red : .white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                )
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 8) {
                // Name and scientific name
                VStack(alignment: .leading, spacing: 4) {
                    Text(fruit.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    if let scientificName = fruit.scientificName {
                        Text(scientificName)
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Categories
                if !fruit.categories.isEmpty {
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
                
                // Nutritional info preview
                HStack {
                    VStack {
                        Text("\(fruit.nutritionalInfo.calories)")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("cal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    VStack {
                        Text("\(Int(fruit.nutritionalInfo.vitaminC))mg")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Vitamin C")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    VStack {
                        Text("\(fruit.nutritionalInfo.fiber, specifier: "%.1f")g")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Fiber")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress indicator (if user has progress)
                ProgressView(value: fruit.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
            }
        }
        .padding(Constants.UI.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

struct FruitCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFruit = Fruit(
            name: "Apple",
            scientificName: "Malus domestica",
            description: "A sweet and crunchy fruit that's perfect for snacking.",
            origin: "Central Asia",
            categories: ["Apples & Pears", "Temperate"],
            season: [.autumn, .winter],
            nutritionalInfo: NutritionalInfo(
                calories: 52,
                protein: 0.3,
                fiber: 2.4,
                vitaminC: 4.6,
                potassium: 107,
                waterContent: 86
            )
        )
        
        FruitCardView(
            fruit: sampleFruit,
            onTap: { print("Tapped fruit card") },
            onFavoriteToggle: { print("Toggled favorite") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}