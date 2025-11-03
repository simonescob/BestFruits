//
//  ErrorStateView.swift
//  BestFruits
//
//  Error state component for displaying error messages with retry action.
//

import SwiftUI

/// Error state view with retry functionality
struct ErrorStateView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Oops! Something went wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Retry button
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16))
                    
                    Text("Try Again")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .background(Color.primary.opacity(0.05))
    }
}

// MARK: - Preview

struct ErrorStateView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorStateView(error: NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "This is a test error message"])) {
            print("Retry tapped")
        }
        .preferredColorScheme(.light)
        
        ErrorStateView(error: NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "This is a test error message"])) {
            print("Retry tapped")
        }
        .preferredColorScheme(.dark)
    }
}