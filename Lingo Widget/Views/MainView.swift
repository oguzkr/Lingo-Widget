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


// ContentView Preview
#Preview {
    MainView()
}


struct DailyWordViewSmall: View {
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
        VStack(spacing: 0) {
            // Üst içerik - dinamik alan
            VStack(spacing: 3) {
                topWordSection
                secondWordSection
                thirdWordSection
                bottomWordSection
            }
            .padding(.horizontal, 5)
            .padding(.top, 5)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Alt butonlar - sabit alan
            bottomButtonsSection
                .frame(height: 40)
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                isWordVisible = true
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                isExampleVisible = true
            }
            if viewModel.targetWord.isEmpty {
                viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
            }
        }
        .heightAsPercentage(20.8)
        .widthAsPercentage(41.6)
    }

    // MARK: - Subviews
    private var topWordSection: some View {
        HStack(spacing: 5) {
            Image(viewModel.targetLanguageCode)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .shadow(color: shadowColor, radius: 4)

            Text(viewModel.targetWord)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }

    private var secondWordSection: some View {
        Group {
            if let romanized = viewModel.romanized, !romanized.isEmpty {
                HStack(spacing: 5) {
                    Image(systemName: "character.textbox")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    Text(romanized)
                        .italic()
                        .font(.system(size: 18).weight(.light))
                        .foregroundColor(.secondary)
                        .opacity(isExampleVisible ? 1 : 0)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var thirdWordSection: some View {
        let pronunciation = viewModel.pronunciation
        return Group {
            if !pronunciation.isEmpty {
                HStack {
                    Text("🗣️ \(pronunciation)")
                        .italic()
                        .font(.system(size: 18, weight: .light))
                        .shadow(color: .black.opacity(0.5), radius: 5)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var bottomWordSection: some View {
        HStack(spacing: 5) {
            Image(viewModel.sourceLanguageCode)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .shadow(color: shadowColor, radius: 4)
            
            Text(viewModel.sourceWord)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomButtonsSection: some View {
        VStack(spacing: 0) {
            Divider().padding(.bottom, 2)
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        viewModel.refreshWord(from: sourceLanguage,
                                              to: targetLanguage,
                                              nativeLanguage: sourceLanguage)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                Spacer()
                Divider()
                Spacer()
                Button {
                    viewModel.speakWord(text: viewModel.targetWord)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                Spacer()
            }
            Spacer()
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
