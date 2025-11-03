//
//  BestFruitsApp.swift
//  BestFruits
//
//  Created by Simon on 11/2/25.
//

import SwiftUI

@main
struct BestFruitsApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
