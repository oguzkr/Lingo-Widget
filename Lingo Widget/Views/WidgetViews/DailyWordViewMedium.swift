//
//  DailyWordViewMedium.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 13.12.2024.
//

import SwiftUI

struct DailyWordViewMedium: View {
    @StateObject private var viewModel: DailyWordViewModel
    @AppStorage("sourceLanguage") private var sourceLanguage: String = "tr"
    @AppStorage("targetLanguage") private var targetLanguage: String = "en"
    @Environment(\.colorScheme) private var colorScheme
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    // Romanized gösterim gerekiyor mu?
    private var shouldShowRomanized: Bool {
        return !viewModel.targetWord.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    // Ayraç gösterilmeli mi?
    private var shouldShowDivider: Bool {
        if shouldShowRomanized && viewModel.romanized != nil || !viewModel.pronunciation.isEmpty {
            return true
        }
        if !viewModel.exampleSentence.isEmpty {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                targetLanguageSection
                    .padding(.horizontal, 8)
                
                if shouldShowDivider {
                    Divider()
                        .padding(.vertical, 2)
                }
                
                sourceLanguageSection
                    .padding(.horizontal, 8)
                
                if !viewModel.exampleSentence.isEmpty {
                    if shouldShowDivider {
                        Divider()
                            .padding(.vertical, 2)
                    }
                    exampleSection
                        .padding(.horizontal, 8)
                }
            }
        }
        .heightAsPercentage(20.8)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
        .onAppear {
            if viewModel.targetWord.isEmpty {
                viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
            }
        }
    }
    
    private var targetLanguageSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            ViewThatFits(in: .horizontal) {
                // En geniş düzen: Hepsi tek satırda
                fullWidthLayout
                
                // Orta düzen: İlk ikisi yan yana, pronunciation altta
                mediumWidthLayout
                
                // Dar düzen: Her biri ayrı satırda
                compactLayout
            }
            .padding(.vertical, 2)
        }
    }
    
    private var fullWidthLayout: some View {
        HStack(spacing: 6) {
            // Target word ve flag
            HStack(spacing: 4) {
                Image(viewModel.targetLanguageCode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                
                Text(viewModel.targetWord)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            // Romanized varsa göster
            if shouldShowRomanized, let romanized = viewModel.romanized {
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 2)
                
                romanizedView(romanized)
            }
            
            // Telaffuz varsa göster
            if !viewModel.pronunciation.isEmpty {
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 2)
                
                pronunciationView
            }
            
            Spacer(minLength: 0)
            
            speakButton
        }
    }
    
    private var mediumWidthLayout: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                // Target word ve flag
                HStack(spacing: 4) {
                    Image(viewModel.targetLanguageCode)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                    
                    Text(viewModel.targetWord)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                // Romanized varsa göster
                if shouldShowRomanized, let romanized = viewModel.romanized {
                    Divider()
                        .frame(height: 20)
                        .padding(.horizontal, 2)
                    
                    romanizedView(romanized)
                }
                
                Spacer(minLength: 0)
                
                speakButton
            }
            
            // Telaffuz ayrı satırda
            if !viewModel.pronunciation.isEmpty {
                pronunciationView
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Target word ve flag
            HStack(spacing: 4) {
                Image(viewModel.targetLanguageCode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                
                Text(viewModel.targetWord)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
                
                speakButton
            }
            
            // Romanized varsa göster
            if shouldShowRomanized, let romanized = viewModel.romanized {
                romanizedView(romanized)
            }
            
            // Telaffuz varsa göster
            if !viewModel.pronunciation.isEmpty {
                pronunciationView
            }
        }
    }
    
    private func romanizedView(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "character.textbox")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            
            Text(text)
                .italic()
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
    
    private var pronunciationView: some View {
        Text("🗣️ \(viewModel.pronunciation)")
            .italic()
            .font(.system(size: 15, weight: .light))
            .foregroundColor(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
    
    private var speakButton: some View {
        Button {
            viewModel.speakWord(text: viewModel.targetWord)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundStyle(.blue)
        }
    }
    
    private var sourceLanguageSection: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(spacing: 4) {
                Image(viewModel.sourceLanguageCode)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                
                Text(viewModel.sourceWord)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(viewModel.exampleSentence)
                    .font(.system(size: 17))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Button {
                    viewModel.speakWord(text: viewModel.exampleSentence)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.blue)
                }
            }
            
            if shouldShowRomanized, let romanizedExample = viewModel.romanizedExample {
                Text(romanizedExample)
                    .italic()
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            if !viewModel.sourceExampleSentence.isEmpty {
                Text(viewModel.sourceExampleSentence)
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
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

#Preview {
    DailyWordViewMedium(viewModel: DailyWordViewModel())
        .padding()
}
