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
                    
                    // Known Words List
                    KnownWordsList(words: dailyWordViewModel.knownWords)
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
                Text("Words I Know")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Manage") {
                    // Manage action
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if words.isEmpty {
                Text("Mark words as known to see them here")
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.translations["targetLanguage"]?.text ?? "")
                    .font(.system(size: 17, weight: .semibold))
                Text(word.translations["sourceLanguage"]?.text ?? "")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
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
