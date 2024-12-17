//
//  MainView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct MainView: View {
    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "es"

    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "en"
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @StateObject private var dailyWordViewModel = DailyWordViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    let languages = [
        "tr": "Türkçe (Turkish)",
        "en": "English",
        "es": "Español (Spanish)",
        "id": "Bahasa (Indonesian)",
        "fr": "Français (French)",
        "it": "Italiano (Italian)",
        "pt": "Português (Portuguese)",
        "zh": "中文 (Chinese)",
        "ru": "Русский (Russian)",
        "ja": "日本語 (Japanese)",
        "hi": "हिन्दी (Hindi)",
        "fil": "Filipino",
        "th": "ไทย (Thai)",
        "ko": "한국어 (Korean)",
        "nl": "Nederlands (Dutch)",
        "sv": "Svenska (Swedish)",
        "pl": "Polski (Polish)",
        "el": "Ελληνικά (Greek)",
        "de": "Deutsch (German)"
    ]
    
    var body: some View {
        ZStack {
            Color(uiColor: isDarkMode ? .darkGray : .gray)
                .ignoresSafeArea()
            
            ScrollView {
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .padding()
                VStack(spacing: 16) {
                    HStack {
                        Text("Native Language")
                            .font(.headline)
                        Picker("Choose", selection: $selectedSourceLanguage) {
                            ForEach(Array(languages.keys.sorted()), id: \.self) { key in
                                Text(languages[key] ?? key)
                                    .tag(key)
                            }
                        }
                        .pickerStyle(.menu)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(uiColor: .systemBackground))
                        )
                        .onChange(of: selectedSourceLanguage) {
                            dailyWordViewModel.fetchDailyWord(from: selectedSourceLanguage, to: selectedTargetLanguage)
                        }
                    }
                    
                    HStack {
                        Text("Language to learn")
                            .font(.headline)
                        Picker("Choose", selection: $selectedTargetLanguage) {
                            ForEach(Array(languages.keys.sorted()), id: \.self) { key in
                                Text(languages[key] ?? key)
                                    .tag(key)
                            }
                        }
                        .pickerStyle(.menu)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(uiColor: .systemBackground))
                        )
                        .onChange(of: selectedTargetLanguage) {
                            dailyWordViewModel.fetchDailyWord(
                                from: selectedSourceLanguage,
                                to: selectedTargetLanguage
                            )
                        }
                    }
                }
                
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            dailyWordViewModel.fetchDailyWord(
                from: selectedSourceLanguage,
                to: selectedTargetLanguage
            )
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("Scene phase changed from \(oldPhase) to \(newPhase)")
            if newPhase == .active {
                dailyWordViewModel.fetchCurrentWord()
            }
            if newPhase == .background {
                exit(0)
            }
        }
    }
}
 
#Preview {
    MainView()
}
