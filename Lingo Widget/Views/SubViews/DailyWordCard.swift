//
//  DailyWordCard.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 26.12.2024.
//


import SwiftUI

struct DailyWordCard: View {
    let word: Word
    let onKnowTap: () -> Void
    let onRefreshTap: () -> Void
    let onSpeak: (String) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var localeManager: LocaleManager
    
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "en"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "ru"
    }
    
    private var shouldShowRomanized: Bool {
        guard let targetTranslation = word.translations[targetLanguage] else { return false }
        return !targetTranslation.text.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Target Language Section
            VStack(alignment: .leading, spacing: 12) {
                // Target Word
                HStack(alignment: .center) {
                    Image(targetLanguage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    if let targetText = word.translations[targetLanguage]?.text {
                        Text(targetText)
                            .font(.system(size: 32, weight: .bold))
                            .padding(.horizontal, 4)
                    }
                    
                    Spacer()
                    
                    speakerButton {
                        if let text = word.translations[targetLanguage]?.text {
                            onSpeak(text)
                        }
                    }
                }
                
                // Target Word Details
                if shouldShowRomanized,
                   let romanized = word.translations[targetLanguage]?.romanized {
                    HStack(spacing: 6) {
                        Image(systemName: "character.textbox")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        
                        Text(romanized)
                            .font(.system(size: 18, weight: .regular))
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 4)
                }
                
                if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage] {
                    Text("🗣️ \(pronunciation)")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
            }
            .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, -20)
            
            // Source Language Section
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    Image(sourceLanguage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    if let sourceText = word.translations[sourceLanguage]?.text {
                        Text(sourceText)
                            .font(.system(size: 32, weight: .bold))
                            .padding(.horizontal, 4)
                    }
                }
                
                // Example Sentences Section
                if let targetExample = word.translations[targetLanguage]?.exampleSentence,
                   let sourceExample = word.translations[sourceLanguage]?.exampleSentence {
                    VStack(alignment: .leading, spacing: 10) {
                        // Target Example with Speaker
                        HStack(alignment: .center) {
                            Text(targetExample)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 4)
                            
                            Spacer(minLength: 8)
                            
                            speakerButton {
                                onSpeak(targetExample)
                            }
                        }
                        
                        // Romanized Example if needed
                        if shouldShowRomanized,
                           let romanizedExample = word.translations[targetLanguage]?.romanizedExample {
                            Text(romanizedExample)
                                .font(.system(size: 16))
                                .italic()
                                .foregroundStyle(.secondary.opacity(0.8))
                                .padding(.leading, 4)
                        }
                        
                        // Source Example without Speaker
                        Text(sourceExample)
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 4)
                    }
                }
            }
            .padding(.vertical, 16)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: onKnowTap) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.medium)
                        Text("I know this word".localized(language: localeManager.currentLocale))
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: onRefreshTap) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.blue)
                        .frame(width: 46, height: 46)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(white: 0.15) : .white)
                .shadow(color: Color.black.opacity(0.3),
                       radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
    
    private func speakerButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
        }
    }
}

#Preview {
    DailyWordCard(word: .placeholder, onKnowTap: {
        print("I know this word")
    }, onRefreshTap: {
        print("Refresh")
    }, onSpeak: { _ in
        print("Speak")
    })
    .environmentObject(LocaleManager())
}
