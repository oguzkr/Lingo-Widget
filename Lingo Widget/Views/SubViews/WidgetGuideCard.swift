//
//  WidgetGuideCard.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 13.01.2025.
//

import SwiftUI

struct WidgetGuideCard: View {
    @Binding var isVisible: Bool
    @AppStorage("hasSeenWidgetGuide") private var hasSeenWidgetGuide = false
    @State private var dontShowAgain = false
    let onTutorialTap: () -> Void
    @EnvironmentObject var localeManager: LocaleManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "plusminus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
                
                Text("Add Widget to Home Screen".localized(language: localeManager.currentLocale))
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button {
                    withAnimation {
                        if dontShowAgain {
                            hasSeenWidgetGuide = true
                        }
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Description
            Text("Learn how to add the Lingo Widget to your home screen for quick access to your daily words.".localized(language: localeManager.currentLocale))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            
            // Tutorial Button
            Button(action: onTutorialTap) {
                Text("Watch Tutorial".localized(language: localeManager.currentLocale))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(.blue)
                    .cornerRadius(8)
            }
            
            // Don't show again toggle
            Toggle("Don't show this again".localized(language: localeManager.currentLocale), isOn: $dontShowAgain)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .onChange(of: dontShowAgain) { _, newValue in
                    if newValue {
                        hasSeenWidgetGuide = true
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                .shadow(color: Color.black.opacity(0.1),
                       radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

#Preview {
    WidgetGuideCard(
            isVisible: .constant(true),
            onTutorialTap: {}
        )
        .environmentObject(LocaleManager())
}

