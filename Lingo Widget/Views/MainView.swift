//
//  MainView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct MainView: View {
    @AppStorage("sourceLanguage") private var selectedSourceLanguage = "tr"
    @AppStorage("targetLanguage") private var selectedTargetLanguage = "en"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var dailyWordViewModel = DailyWordViewModel()
    
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
                            dailyWordViewModel.fetchDailyWord(
                                from: selectedSourceLanguage,
                                to: selectedTargetLanguage
                            )
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
                Text("Widget Designs")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                    DailyWordViewMedium(viewModel: dailyWordViewModel)
                        .padding()
                
                    DailyWordViewSmall(viewModel: dailyWordViewModel)
                
            }
        }.preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
 
#Preview {
    MainView()
}