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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Words I Learned")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.getKnownWordsForCurrentLanguages().count) words")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Manage") {
                    showingManageWords = true
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if viewModel.getKnownWordsForCurrentLanguages().isEmpty {
                Text("Mark words as known to see them here")
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
}

#Preview {
    KnownWordsList(viewModel: .init())
}
