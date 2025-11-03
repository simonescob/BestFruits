//  README.md
//  BestFruits Educational App
//
//  Scalable iOS educational app with Clean Architecture + MVVM
//  Integrated with Go backend at: https://golang-backend-example-gcp-797553522576.europe-west1.run.app/

# BestFruits Educational App

A scalable iOS educational application for learning about fruits, built with Clean Architecture principles and MVVM pattern, fully integrated with a Go backend API.

## 🏗️ Architecture Overview

This project implements a **Clean Architecture + MVVM** pattern with the following key principles:

- **Separation of Concerns**: Clear layers for Domain, Data, and Presentation
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Modular Design**: Easy to add new features without affecting existing code
- **Offline-First**: Core Data for local storage + Network sync with Go backend

## 📁 Project Structure

```
BestFruits/
├── Domain/                          # Enterprise Business Logic
│   ├── Entities/                    # Core business objects
│   │   ├── Fruit.swift
│   │   ├── Category.swift
│   │   └── UserProgress.swift
│   ├── UseCases/                    # Application business logic
│   │   ├── FetchFruitsUseCase.swift
│   │   ├── SearchFruitsUseCase.swift
│   │   └── SaveProgressUseCase.swift
│   └── Repositories/                # Repository protocols
│       ├── FruitRepositoryProtocol.swift
│       └── UserProgressRepositoryProtocol.swift
├── Data/                            # Data Management
│   ├── Repositories/                # Repository implementations
│   │   └── FruitRepository.swift
│   ├── DataSources/                 # Core Data & Network
│   │   ├── Core/
│   │   │   ├── CoreDataStack.swift
│   │   │   └── FruitCoreData.swift
│   │   └── Network/Endpoints/
│   │       └── APIEndpoints.swift
│   ├── Models/                      # Data Transfer Objects
│   │   └── FruitDTO.swift
│   └── Mappers/                     # Data transformation
│       └── FruitMapper.swift
├── Presentation/                    # UI Layer (MVVM)
│   ├── Views/                       # SwiftUI Views
│   │   ├── ContentView.swift
│   │   ├── FruitDetailView.swift
│   │   └── [other views]
│   ├── ViewModels/                  # State management
│   │   ├── FruitListViewModel.swift
│   │   └── FruitDetailViewModel.swift
│   └── Components/                  # Reusable UI components
│       ├── FruitCardView.swift
│       ├── SearchBarView.swift
│       └── LoadingView.swift
└── Infrastructure/                  # External Dependencies
    ├── Network/                     # HTTP client & utilities
    │   └── HTTPClient.swift
    ├── Storage/                     # Image caching & file management
    └── Configuration/               # App constants & settings
        └── Constants.swift
```

## 🚀 Features

### Core Educational Features
- **Fruit Catalog**: Browse fruits with detailed information
- **Categories**: Organize fruits by types (Tropical, Citrus, Berries, etc.)
- **Nutritional Information**: Comprehensive nutritional data
- **Interactive Quizzes**: Test knowledge with adaptive quizzes
- **Progress Tracking**: Monitor learning progress and achievements
- **Personal Notes**: Add and save personal study notes
- **Favorites**: Mark and manage favorite fruits

### Advanced Features
- **Search & Filter**: Advanced search with multiple criteria
- **Offline Mode**: Full functionality without internet connection
- **Data Sync**: Automatic synchronization with Go backend
- **Offline Caching**: Local storage with intelligent caching
- **Responsive UI**: Optimized for various screen sizes
- **Dark/Light Mode**: Automatic theme support

### Integration with Go Backend
- **Full CRUD Operations**: Create, read, update, delete fruits
- **Real-time Sync**: Background synchronization with server
- **Error Handling**: Graceful degradation when offline
- **Progress Backup**: Save user progress to backend
- **Content Management**: Server-side content updates

## 🔧 Setup Instructions

### Prerequisites
- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+
- Core Data framework

### 1. Project Setup
```bash
# Clone the repository
git clone <repository-url>
cd BestFruits

# Open in Xcode
open BestFruits.xcodeproj
```

### 2. Configuration
Update the backend URL in `Infrastructure/Configuration/Constants.swift`:
```swift
struct Constants {
    struct Network {
        static let baseURL = "https://your-go-backend-url.com"
    }
}
```

### 3. Core Data Setup
The project includes Core Data models. Ensure the `BestFruitsModel.xcdatamodeld` is properly configured in your Xcode project.

### 4. Dependencies
No external dependencies required - uses native SwiftUI and Core Data frameworks.

## 🧪 Testing

### Running Tests
```bash
# Run unit tests
xcodebuild test -project BestFruits.xcodeproj -scheme BestFruits -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -project BestFruits.xcodeproj -scheme BestFruits -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BestFruitsUITests
```

### Test Structure
```
BestFruitsTests/                   # Unit tests
├── Domain/                       # Domain layer tests
├── Data/                         # Data layer tests
└── Presentation/                 # ViewModels tests
BestFruitsUITests/                # UI integration tests
```

## 🔄 API Integration

### Backend Requirements
Your Go backend should provide these endpoints:

#### Fruit Operations
- `GET /fruits` - Get all fruits
- `GET /fruits/:id` - Get specific fruit
- `POST /fruits` - Create new fruit
- `PUT /fruits/:id` - Update fruit
- `DELETE /fruits/:id` - Delete fruit
- `GET /categories` - Get fruit categories
- `GET /fruits/search?q=query` - Search fruits

#### Progress Operations
- `GET /progress/:fruitId` - Get user progress
- `POST /progress` - Save user progress
- `GET /progress/statistics` - Get study statistics

### Response Format
```json
{
  "success": true,
  "data": {
    // Fruit or progress data
  },
  "message": "Success message",
  "error": null
}
```

## 📱 Usage

### Basic Usage
1. **Launch App**: Open the app to see the main fruit catalog
2. **Browse**: Scroll through fruits or use search/filter
3. **Learn**: Tap a fruit to view detailed information
4. **Quiz**: Take quizzes to test knowledge
5. **Progress**: Track your learning progress

### Advanced Features
1. **Offline Mode**: App works without internet connection
2. **Sync**: Data automatically syncs when back online
3. **Categories**: Filter by fruit categories
4. **Favorites**: Mark fruits as favorites
5. **Notes**: Add personal study notes

## 🎨 Customization

### Adding New Fruit Types
1. Update `Domain/Entities/Fruit.swift`
2. Add validation in repository implementations
3. Update UI components if needed

### New Educational Features
1. Create new Use Cases in `Domain/UseCases/`
2. Implement repository methods
3. Create ViewModels for new features
4. Build corresponding SwiftUI Views

### Theme Customization
Update colors and styling in `Constants.swift`:
```swift
struct Constants {
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let primaryColor = Color.blue
        // ... other styling constants
    }
}
```

## 🚀 Performance Optimization

### Implemented Optimizations
- **Lazy Loading**: Efficient memory usage for large datasets
- **Core Data**: Optimized local storage and queries
- **Image Caching**: Intelligent image loading and caching
- **Background Sync**: Non-blocking data synchronization
- **Pagination**: Efficient loading for large datasets

### Best Practices
- Use `@MainActor` for UI updates
- Implement proper error handling
- Use Combine for reactive programming
- Follow SwiftUI best practices

## 🔧 Troubleshooting

### Common Issues

#### Core Data Errors
- Ensure Core Data model is properly configured
- Check entity relationships
- Verify attribute types match

#### Network Issues
- Verify backend URL is correct
- Check API endpoint responses
- Ensure proper error handling

#### Performance Issues
- Use Instruments for profiling
- Check memory usage with large datasets
- Optimize image loading

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the architecture guide

## 🔮 Future Enhancements

- **Social Features**: Share achievements and progress
- **Push Notifications**: Study reminders and updates
- **Analytics**: Learning analytics and insights
- **Multi-language**: Internationalization support
- **Voice Integration**: Text-to-speech for accessibility
- **AR Features**: Augmented reality fruit identification
- **Machine Learning**: Personalized learning recommendations