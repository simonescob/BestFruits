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

/// Empty state view component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "info.circle",
        title: String = "No Data",
        message: String = "There's nothing to show here.",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }
        }
        .padding()
    }
}

/// Error state view component
struct ErrorStateView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Oops! Something went wrong",
            message: error.localizedDescription,
            actionTitle: retryAction != nil ? "Try Again" : nil,
            action: retryAction
        )
    }
}