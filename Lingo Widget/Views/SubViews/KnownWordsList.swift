//
//  KnownWordsList.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 29.12.2024.
//

import SwiftUI

struct KnownWordsList: View {
    @ObservedObject var viewModel: DailyWordViewModel
    @State private var showingManageWords = false
    @EnvironmentObject var localeManager: LocaleManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Words I Learned".localized(language: localeManager.currentLocale))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)

                    Text(localizedWordCountText())
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Manage".localized(language: localeManager.currentLocale)) {
                    showingManageWords = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if viewModel.getKnownWordsForCurrentLanguages().isEmpty {
                Text("Mark words as known to see them here".localized(language: localeManager.currentLocale))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.getKnownWordsForCurrentLanguages(), id: \.id) { word in
                    KnownWordRow(word: word)
                }
            }
        }
        .padding(.top)
        .sheet(isPresented: $showingManageWords) {
            ManageKnownWordsView(viewModel: viewModel)  // Pass the viewModel
        }
    }
    
    private func localizedWordCountText() -> String {
        let wordCount = viewModel.getKnownWordsForCurrentLanguages().count
        var localizedWordText = "words".localized(language: localeManager.currentLocale)
        if localeManager.currentLocale.identifier == "en" && wordCount < 2 {
            localizedWordText = "word"
        }
        return "\(wordCount) \(localizedWordText)"
    }
}

#Preview {
    KnownWordsList(viewModel: .init())
        .environmentObject(LocaleManager())
}
