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
    
    @State private var isWordVisible = false
    @State private var isExampleVisible = false
    @State private var isCompactLayout: Bool = false
    @State private var showPronunciationInline: Bool = false
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    private var shouldShowRomanized: Bool {
        guard let romanized = viewModel.romanized else { return false }
        return !viewModel.targetWord.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    private var shouldShowDivider: Bool {
        if viewModel.romanized != nil || !viewModel.pronunciation.isEmpty {
            return true
        }
        if !viewModel.exampleSentence.isEmpty {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                targetLanguageSection
                    .padding(.horizontal, 8)
                
                if !showPronunciationInline && !viewModel.pronunciation.isEmpty {
                    pronunciationSection
                        .padding(.horizontal, 8)
                }
                
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
            setupInitialState()
        }
    }
    
    private var targetLanguageSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                ViewThatFits(in: .horizontal) {
                    // 1. Deneme: Her şey yan yana
                    HStack(spacing: 6) {
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
                        
                        if shouldShowRomanized, let romanized = viewModel.romanized {
                            Divider()
                                .frame(height: 20)
                                .padding(.horizontal, 2)
                            
                            romanizedView(romanized)
                        }
                        
                        if !viewModel.pronunciation.isEmpty {
                            Divider()
                                .frame(height: 20)
                                .padding(.horizontal, 2)
                            
                            pronunciationView
                        }
                    }
                    .onAppear {
                        isCompactLayout = false
                        showPronunciationInline = true
                    }
                    
                    // 2. Deneme: Sadece kelime
                    targetWordView
                        .onAppear {
                            isCompactLayout = true
                            showPronunciationInline = false
                        }
                }
                
                Spacer(minLength: 0)
                
                speakButton
            }
            
            if isCompactLayout && shouldShowRomanized, let romanized = viewModel.romanized {
                romanizedView(romanized)
                    .padding(.top, 2)
            }
        }
    }
    
    private var targetWordView: some View {
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
    
    private var pronunciationSection: some View {
        Text("🗣️ \(viewModel.pronunciation)")
            .italic()
            .font(.system(size: 15, weight: .light))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
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
                withAnimation {
                    viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
                }
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
            
            if let romanizedExample = viewModel.romanizedExample {
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
    }
    
    private func setupInitialState() {
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
