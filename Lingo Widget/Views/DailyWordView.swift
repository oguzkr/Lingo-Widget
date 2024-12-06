//
//  DailyWordView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct DailyWordView: View {
    @StateObject private var viewModel: DailyWordViewModel
    @AppStorage("sourceLanguage") private var sourceLanguage: String = "tr"
    @AppStorage("targetLanguage") private var targetLanguage: String = "en"
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Hedef Kelime, Ses Butonu ve Yenileme Butonu
            HStack {
                Text(viewModel.targetWord)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                
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
            
            // Telaffuz
            Text(viewModel.pronunciation)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.secondary)
            
            // Ana dildeki karşılığı
            Text(viewModel.sourceWord)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.secondary)
            
            // Ayırıcı çizgi
            Divider()
                .padding(.vertical, 4)
            
            // Örnek cümleler ve ses butonu
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(viewModel.exampleSentence)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                    
                    Button(action: {
                        viewModel.speakWord(text: viewModel.exampleSentence)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.blue)
                    }
                }
                
                if !viewModel.sourceExampleSentence.isEmpty {
                    Text(viewModel.sourceExampleSentence)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview("English Native - Learning Turkish") {
    DailyWordView(viewModel: DailyWordViewModel(previewData: (
        source: "goodbye",
        target: "hoşçakal",
        pronunciation: "hosh-cha-kal",  // İngilizce konuşanlar için telaffuz
        example: "Hoşçakal, görüşürüz!"
    )))
    .padding()
    .background(Color(uiColor: .systemGray6))
}

#Preview("Turkish Native - Learning English") {
    DailyWordView(viewModel: DailyWordViewModel(previewData: (
        source: "hoşçakal",
        target: "goodbye",
        pronunciation: "gud-bay",  // Türkçe konuşanlar için telaffuz
        example: "Goodbye, see you later!"
    )))
    .padding()
    .background(Color(uiColor: .systemGray6))
}
