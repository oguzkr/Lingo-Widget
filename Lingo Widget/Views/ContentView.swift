//
//  ContentView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct ContentView: View {
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
                    .padding(.horizontal)
            }
        }.preferredColorScheme(isDarkMode ? .dark : .light)
    }
}


// ContentView Preview
#Preview {
    ContentView()
}

struct DailyWordViewMedium: View {
    @StateObject private var viewModel: DailyWordViewModel
    @AppStorage("sourceLanguage") private var sourceLanguage: String = "tr"
    @AppStorage("targetLanguage") private var targetLanguage: String = "en"
    @Environment(\.colorScheme) private var colorScheme
    
    // Animation states
    @State private var isWordVisible = false
    @State private var isExampleVisible = false
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Header Section
            wordSection
            // MARK: - Romanized Section
            romanizedSection
            
            // MARK: - Pronunciation & Source
            detailsSection
            
            Divider()
                .padding(.vertical, 4)
            
            // MARK: - Example Sentences
            exampleSection
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
        .heightAsPercentage(20.8)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                isWordVisible = true
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                isExampleVisible = true
            }
            if viewModel.targetWord.isEmpty {
                viewModel.fetchDailyWord(from: sourceLanguage, to: targetLanguage)
            }
        }
    }
    
    // MARK: - Subviews
    private var wordSection: some View {
        VStack(alignment: .center) {
            HStack {
                Image(viewModel.targetLanguageCode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .shadow(color: shadowColor, radius: 4)
                    
                
                Text(viewModel.targetWord)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .opacity(isWordVisible ? 1 : 0)
                
                Spacer()
                
               let romanized = viewModel.pronunciation
                Text("(\(romanized))")
                    .font(.system(size: 11, weight: .light, design: .rounded))
                
                
                Button {
                    viewModel.speakWord(text: viewModel.targetWord)
                } label: {
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(viewModel.sourceLanguageCode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .shadow(color: shadowColor, radius: 4)
                
                Text(viewModel.sourceWord)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(isWordVisible ? 1 : 0)
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var romanizedSection: some View {
        HStack {
            if let pronunciation = viewModel.romanized {
                Image(systemName: "character.textbox")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                
                Text(pronunciation)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .opacity(isExampleVisible ? 1 : 0)
            }
        }
    }
    
    
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !viewModel.exampleSentence.isEmpty {
                HStack {
                    Text(viewModel.exampleSentence)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(1)
                    
                    Spacer(minLength: 8)
                    
                    Button {
                        viewModel.speakWord(text: viewModel.exampleSentence)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 14))
                            .foregroundStyle(.blue)
                    }
                }
                .opacity(isExampleVisible ? 1 : 0)
            }
            
            if let romanizedExample = viewModel.romanizedExample {
                Text(romanizedExample)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .opacity(isExampleVisible ? 1 : 0)
            }
            
            if !viewModel.sourceExampleSentence.isEmpty {
                Text(viewModel.sourceExampleSentence)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .opacity(isExampleVisible ? 1 : 0)
            }
        }
    }
    
    // MARK: - Styling
    private var backgroundGradient: some ShapeStyle {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(white: 0.2) : .white,
                colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.97)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.5)
    }
}
