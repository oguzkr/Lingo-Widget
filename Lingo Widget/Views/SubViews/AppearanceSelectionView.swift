//
//  AppearanceSelectionView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 30.12.2024.
//

import SwiftUI

struct AppearanceSelectionView: View {
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0
    @Environment(\.colorScheme) private var currentColorScheme
    @EnvironmentObject var localeManager: LocaleManager
    
    private var previewColorScheme: ColorScheme? {
        switch preferredColorScheme {
        case 1: return .light
        case 2: return .dark
        default: return currentColorScheme
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Theme".localized(language: localeManager.currentLocale))
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top)
            
            Text("Select your preferred app appearance".localized(language: localeManager.currentLocale))
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            HStack(spacing: 20) {
                // System theme option
                ThemeOptionCard(
                    title: "System".localized(language: localeManager.currentLocale),
                    icon: "iphone",
                    isSelected: preferredColorScheme == 0,
                    colorScheme: nil
                ) {
                    hapticFeedback()
                    withAnimation {
                        preferredColorScheme = 0
                    }
                }
                
                // Light theme option
                ThemeOptionCard(
                    title: "Light".localized(language: localeManager.currentLocale),
                    icon: "sun.max.fill",
                    isSelected: preferredColorScheme == 1,
                    colorScheme: .light
                ) {
                    hapticFeedback()
                    withAnimation {
                        preferredColorScheme = 1
                    }
                }
                
                // Dark theme option
                ThemeOptionCard(
                    title: "Dark".localized(language: localeManager.currentLocale),
                    icon: "moon.fill",
                    isSelected: preferredColorScheme == 2,
                    colorScheme: .dark
                ) {
                    hapticFeedback()
                    withAnimation {
                        preferredColorScheme = 2
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .preferredColorScheme(previewColorScheme)
    }
}

struct ThemeOptionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let colorScheme: ColorScheme?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(backgroundColor)
                        .frame(height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(isSelected ? .blue : .gray)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(white: 0.2)
        case .light:
            return Color(white: 0.95)
        case .none:
            return Color.gray.opacity(0.1)
        }
    }
}

#Preview {
    AppearanceSelectionView()
        .environmentObject(LocaleManager())
        
}
