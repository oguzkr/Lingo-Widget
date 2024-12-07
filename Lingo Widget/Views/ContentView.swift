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
        "tr": "Türkçe",
        "en": "English",
        "es": "Español",
        "id": "Bahasa Indonesia"
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
                HStack {
                    DailyWordViewSmall(viewModel: dailyWordViewModel)
                        .padding(.leading)
                    Spacer()
                }
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
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Hedef kelime için esnek yapı
                ViewThatFits(in: .vertical) {
                    Text(viewModel.targetWord)
                        .font(.system(size: 28, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(viewModel.targetWord)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Button(action: {
                    viewModel.speakWord(text: viewModel.targetWord)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
            }
            
            ViewThatFits(in: .vertical) {
                Text(viewModel.pronunciation)
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.pronunciation)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            ViewThatFits(in: .vertical) {
                Text(viewModel.sourceWord)
                    .font(.system(size: 22, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.sourceWord)
                    .font(.system(size: 18, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .padding(.vertical, 0)
            
            // Örnek cümleler
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ViewThatFits(in: .vertical) {
                        Text(viewModel.exampleSentence)
                            .font(.system(size: 20))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(viewModel.exampleSentence)
                            .font(.system(size: 18))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Button(action: {
                        viewModel.speakWord(text: viewModel.exampleSentence)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.blue)
                    }
                }
                
                if !viewModel.sourceExampleSentence.isEmpty {
                    ViewThatFits(in: .vertical) {
                        Text(viewModel.sourceExampleSentence)
                            .font(.system(size: 20))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(viewModel.sourceExampleSentence)
                            .font(.system(size: 18))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .heightAsPercentage(20.8)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            if viewModel.targetWord.isEmpty {
                viewModel.fetchDailyWord(from: sourceLanguage, to: targetLanguage)
            }
        }

    }
}


struct DailyWordViewSmall: View {
    @StateObject private var viewModel: DailyWordViewModel
    @AppStorage("sourceLanguage") private var sourceLanguage: String = "tr"
    @AppStorage("targetLanguage") private var targetLanguage: String = "en"
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                ViewThatFits(in: .vertical) {
                    Text(viewModel.targetWord)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(viewModel.targetWord)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                Button(action: {
                    viewModel.speakWord(text: viewModel.targetWord)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
            }
            
            ViewThatFits(in: .vertical) {
                Text(viewModel.pronunciation)
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.pronunciation)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack {
                ViewThatFits(in: .vertical) {
                    Text(viewModel.sourceWord)
                        .font(.system(size: 20, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(viewModel.sourceWord)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
            }
            
            // Örnek cümleler (eğer iki satırda gösteremezse font küçülüyor)
            if !viewModel.exampleSentence.isEmpty || !viewModel.sourceExampleSentence.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ViewThatFits(in: .vertical) {
                            Text(viewModel.exampleSentence)
                                .font(.system(size: 14))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(viewModel.exampleSentence)
                                .font(.system(size: 12))
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.speakWord(text: viewModel.exampleSentence)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    if !viewModel.sourceExampleSentence.isEmpty {
                        ViewThatFits(in: .vertical) {
                            Text(viewModel.sourceExampleSentence)
                                .font(.system(size: 14))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(viewModel.sourceExampleSentence)
                                .font(.system(size: 12))
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding()
        .heightAsPercentage(20.8)
        .widthAsPercentage(43.5)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear {
            if viewModel.targetWord.isEmpty {
                viewModel.fetchDailyWord(from: sourceLanguage, to: targetLanguage)
            }
        }
    }
}
