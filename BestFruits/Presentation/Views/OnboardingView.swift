//
//  OnboardingView.swift
//  BestFruits
//
//  Onboarding view that introduces users to the app.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    let onboardingPages = [
        OnboardingPage(
            title: "Ready to Explore?",
            description: "Unlock amazing fun facts and trivia to spark your curiosity and become a true fruit expert.",
            imageName: "lightbulb.and.strawberry"
        ),
        OnboardingPage(
            title: "Learn & Discover",
            description: "Explore detailed information about different fruits, their origins, and fascinating facts.",
            imageName: "book.fill"
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Keep track of your favorite fruits and the facts you've learned.",
            imageName: "checkmark.circle.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: skipOnboarding) {
                        Text("Skip")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        if index == currentPage {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 24, height: 8)
                        } else {
                            Circle()
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.bottom, 24)
                
                // Action buttons
                VStack(spacing: 12) {
                    if currentPage == onboardingPages.count - 1 {
                        Button(action: completeOnboarding) {
                            Text("Let's Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: nextPage) {
                            Text("Let's Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func nextPage() {
        if currentPage < onboardingPages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    private func skipOnboarding() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Illustration placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 280)
                
                VStack(spacing: 0) {
                    if page.imageName == "lightbulb.and.strawberry" {
                        HStack(spacing: 40) {
                            // Lightbulb with rays
                            VStack(spacing: 20) {
                                // Rays
                                HStack(spacing: 12) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.yellow)
                                        .offset(x: -30, y: -40)
                                    
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.yellow)
                                        .offset(y: -40)
                                    
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.yellow)
                                        .offset(x: 30, y: -40)
                                }
                                
                                // Lightbulb
                                VStack(spacing: 0) {
                                    Image(systemName: "lightbulb.2.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            // Strawberry
                            Image(systemName: "strawberry.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                                .offset(y: 20)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                    } else if page.imageName == "book.fill" {
                        Image(systemName: "book.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Title and description
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
