//
//  MainView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject private var dailyWordViewModel = DailyWordViewModel()
    @State private var showSettings = false
    @State private var showPremiumSheet = false
    
    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "es"
    
    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "en"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Word Card
                    DailyWordCard(
                        word: dailyWordViewModel.currentWord,
                        onKnowTap: {
                            dailyWordViewModel.markCurrentWordAsKnown()
                        },
                        onRefreshTap: {
                            dailyWordViewModel.refreshWord(
                                from: selectedSourceLanguage,
                                to: selectedTargetLanguage,
                                nativeLanguage: selectedSourceLanguage
                            )
                        },
                        onSpeak: { text in
                            dailyWordViewModel.speakWord(text: text)
                        }
                    )
                    
                    // Premium Button
                    Button(action: { showPremiumSheet = true }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Try Premium for Free")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    KnownWordsList(words: dailyWordViewModel.getKnownWordsForCurrentLanguages())
                }
                .padding(.top)
            }
            .navigationTitle("Lingo Widget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumView()
            }
        }
    }
}

struct KnownWordsList: View {
    let words: [Word]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Words I Learned")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(words.count) words")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Manage") {
                    // Manage action
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if words.isEmpty {
                Text("Mark words as known to see them here")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(words, id: \.id) { word in
                    KnownWordRow(word: word)
                }
            }
        }
        .padding(.top)
    }
}

struct KnownWordRow: View {
    let word: Word
    
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
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if shouldShowRomanized,
                       let romanized = word.translations[targetLanguage]?.romanized {
                        HStack(spacing: 4) {
                            Image(systemName: "character.textbox")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            
                            Text(romanized)
                                .italic()
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let sourceText = word.translations[sourceLanguage]?.text {
                    Text(sourceText)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 20))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
}
 
#Preview {
    MainView()
}
