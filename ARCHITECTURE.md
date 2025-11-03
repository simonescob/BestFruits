# BestFruits Educational App - Clean Architecture

## Overview
A scalable iOS educational app for learning about fruits, built with Clean Architecture + MVVM and integrated with a Go backend.

## Architecture Layers

### 1. Domain Layer (Enterprise Business Logic)
**Purpose**: Contains business logic and rules that are independent of any framework.

**Components**:
- **Entities**: Core business objects (Fruit, Category, Quiz, UserProgress)
- **Use Cases**: Application business logic
- **Repository Protocols**: Abstract interfaces for data operations

**Files Structure**:
```
Domain/
├── Entities/
│   ├── Fruit.swift
│   ├── Category.swift
│   ├── Quiz.swift
│   └── UserProgress.swift
├── UseCases/
│   ├── FetchFruitsUseCase.swift
│   ├── FetchCategoriesUseCase.swift
│   ├── SaveProgressUseCase.swift
│   └── SearchFruitsUseCase.swift
└── Repositories/
    ├── FruitRepositoryProtocol.swift
    └── UserProgressRepositoryProtocol.swift
```

### 2. Data Layer (Data Management)
**Purpose**: Manages data from various sources (Core Data, Network, etc.)

**Components**:
- **Repositories**: Implement repository protocols from Domain
- **Data Sources**: Core Data and Network implementations
- **Models**: Data transfer objects for API communication
- **Mappers**: Convert between domain entities and data models

**Files Structure**:
```
Data/
├── Repositories/
│   ├── FruitRepository.swift
│   └── UserProgressRepository.swift
├── DataSources/
│   ├── Core/
│   │   ├── CoreDataStack.swift
│   │   ├── FruitCoreData.swift
│   │   └── UserProgressCoreData.swift
│   └── Network/
│       ├── HTTPClient.swift
│       ├── APIClient.swift
│       └── Endpoints/
├── Models/
│   ├── FruitDTO.swift
│   └── NetworkResponse.swift
└── Mappers/
    ├── FruitMapper.swift
    └── CategoryMapper.swift
```

### 3. Presentation Layer (UI Layer)
**Purpose**: Handles UI and user interactions with MVVM pattern

**Components**:
- **Views**: SwiftUI views for user interface
- **ViewModels**: State management and business logic coordination
- **Components**: Reusable UI components
- **Navigation**: App navigation logic

**Files Structure**:
```
Presentation/
├── Views/
│   ├── ContentView.swift
│   ├── FruitListView.swift
│   ├── FruitDetailView.swift
│   ├── CategoryView.swift
│   ├── QuizView.swift
│   └── ProgressView.swift
├── ViewModels/
│   ├── ContentViewModel.swift
│   ├── FruitListViewModel.swift
│   ├── FruitDetailViewModel.swift
│   └── CategoryViewModel.swift
├── Components/
│   ├── FruitCardView.swift
│   ├── SearchBarView.swift
│   ├── ProgressIndicatorView.swift
│   └── LoadingView.swift
└── Navigation/
    ├── AppCoordinator.swift
    └── Route.swift
```

### 4. Infrastructure Layer (External Dependencies)
**Purpose**: Handles external concerns like HTTP clients, image loading, etc.

**Components**:
- **Network**: HTTP client implementation
- **Storage**: Image caching and file management
- **Configuration**: App configuration and constants

**Files Structure**:
```
Infrastructure/
├── Network/
│   ├── URLSession+Extension.swift
│   └── ImageLoader.swift
├── Storage/
│   └── ImageCache.swift
└── Configuration/
    ├── Constants.swift
    └── Environment.swift
```

## Data Flow

1. **User Interaction**: User taps a button in SwiftUI View
2. **View**: SwiftUI View calls ViewModel method
3. **ViewModel**: ViewModel executes UseCase
4. **UseCase**: UseCase calls Repository method
5. **Repository**: Repository coordinates between DataSources
6. **DataSources**: Fetch data from Core Data or Network
7. **Result**: Data flows back up through layers to update UI

## Key Design Principles

### 1. Dependency Inversion
- High-level modules don't depend on low-level modules
- Both depend on abstractions (protocols)
- UseCases depend on Repository protocols, not implementations

### 2. Single Responsibility
- Each class has one reason to change
- Views handle UI only
- ViewModels handle state and coordination
- UseCases handle business logic
- Repositories handle data management

### 3. Open/Closed Principle
- Open for extension, closed for modification
- Easy to add new fruits, categories, or features
- No modification to existing, tested code

### 4. Interface Segregation
- Small, focused interfaces
- Clients depend only on methods they use
- Repository protocols are specific to use cases

### 5. Dependency Injection
- Dependencies are injected, not created internally
- Easier testing with mock implementations
- Flexible architecture

## Integration with Go Backend

### API Endpoints
- `GET /fruits` - Fetch all fruits
- `GET /fruits/:id` - Fetch specific fruit
- `POST /fruits` - Create new fruit
- `PUT /fruits/:id` - Update fruit
- `DELETE /fruits/:id` - Delete fruit
- `GET /categories` - Fetch categories
- `POST /progress` - Save user progress

### Sync Strategy
1. **Offline First**: Core Data as primary source
2. **Background Sync**: Sync with backend when online
3. **Conflict Resolution**: Last-write-wins for simple conflicts
4. **Incremental Updates**: Only sync changed data

## Testing Strategy

### Unit Tests
- Domain Layer: Test UseCases with mock repositories
- Data Layer: Test mappers and repository implementations
- Presentation Layer: Test ViewModels

### Integration Tests
- End-to-end data flow testing
- Core Data + Network integration
- Repository integration tests

### UI Tests
- SwiftUI view interactions
- Navigation flow testing
- User experience validation

## Scalability Features

### 1. Modular Design
- Each feature can be developed independently
- Clear separation of concerns
- Easy to add new features

### 2. Performance Optimizations
- Core Data for efficient local storage
- Image caching for fast loading
- Lazy loading for large datasets
- Background sync for better UX

### 3. Maintainability
- Clear code organization
- Extensive documentation
- Consistent naming conventions
- Error handling throughout

### 4. Future Extensibility
- Easy to add new fruit types
- Simple to implement new educational features
- Social features can be added later
- Analytics and user insights integration ready

## Configuration

### Development
- Use mock data for UI development
- Enable detailed logging
- DebugCore Data queries

### Production
- Real API integration
- Optimized performance
- Crash reporting
- Analytics integration