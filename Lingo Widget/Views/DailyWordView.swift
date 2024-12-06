//
//  DailyWordView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct DailyWordView: View {
    @StateObject private var viewModel: DailyWordViewModel
    
    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Hedef Kelime ve Ses Butonu
            HStack {
                Text(viewModel.targetWord)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                
                Button(action: {
                    viewModel.speakWord()
                }) {
                    Image(systemName: "speaker.wave.2.fill")
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
            
            // Örnek cümleler
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.exampleSentence)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                
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
                viewModel.fetchDailyWord()
            }
        }
    }
}


#Preview {
    DailyWordView(viewModel: .init(previewData: (
        source: "hello",
        target: "merhaba",
        pronunciation: "mɜːrˈhɑː.bə",
        example: "Hello, how are you?"
    )))
}
