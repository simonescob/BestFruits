//
//  Constants.swift
//  BestFruits
//
//  Application constants and configuration.
//

import Foundation

/// Application constants
struct Constants {
    
    // MARK: - Network
    
    struct Network {
        static let baseURL = "https://golang-backend-example-gcp-797553522576.europe-west1.run.app"
        static let timeoutInterval: TimeInterval = 30
        static let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    }
    
    // MARK: - UserDefaults Keys
    
    struct UserDefaults {
        static let hasCompletedOnboarding = "has_completed_onboarding"
        static let userPreferences = "user_preferences"
        static let lastSyncDate = "last_sync_date"
        static let offlineMode = "offline_mode"
    }
    
    // MARK: - Cache
    
    struct Cache {
        static let imageCacheSize: Int = 50 * 1024 * 1024 // 50MB
        static let fruitDataCacheExpiration: TimeInterval = 3600 // 1 hour
        static let imageCacheExpiration: TimeInterval = 86400 // 24 hours
    }
    
    // MARK: - UI
    
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 12
        static let animationDuration: Double = 0.3
    }
    
    // MARK: - Educational Content
    
    struct Educational {
        static let minQuizScoreForCompletion = 70 // Percentage
        static let maxStudyTimePerSession: TimeInterval = 1800 // 30 minutes
        static let defaultReadingProgressIncrement = 0.25 // 25%
        static let quizTimeLimit: TimeInterval = 300 // 5 minutes
    }
    
    // MARK: - Performance
    
    struct Performance {
        static let maxConcurrentImageLoads = 4
        static let prefetchDistance = 2
        static let batchSize = 20
    }
    
    // MARK: - Feature Flags
    
    struct Features {
        static let enableOfflineMode = true
        static let enablePushNotifications = true
        static let enableAnalytics = true
        static let enableSocialFeatures = false
        static let enableAdvancedSearch = true
    }
    
    // MARK: - Error Messages
    
    struct ErrorMessages {
        static let networkError = "Network connection unavailable. Using cached data."
        static let syncError = "Failed to sync with server. Changes saved locally."
        static let genericError = "Something went wrong. Please try again."
        static let offlineMode = "Offline mode enabled. Limited functionality available."
    }
}