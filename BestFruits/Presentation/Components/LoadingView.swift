//
//  LoadingView.swift
//  BestFruits
//
//  Reusable loading and state management components.
//

import SwiftUI

/// Loading indicator component
struct LoadingView: View {
    let message: String
    let isFullScreen: Bool
    
    init(message: String = "Loading...", isFullScreen: Bool = false) {
        self.message = message
        self.isFullScreen = isFullScreen
    }
    
    var body: some View {
        if isFullScreen {
            fullScreenView
        } else {
            compactView
        }
    }
    
    private var fullScreenView: some View {
        ZStack {
            Color(.systemBackground).opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var compactView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// EmptyStateView and ErrorStateView are defined in separate files