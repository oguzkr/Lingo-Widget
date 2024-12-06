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
    @State private var dailyWordViewModel = DailyWordViewModel()
    
    let languages = [
        "tr": "Türkçe",
        "en": "English",
        "es": "Español",
        "id": "Bahasa Indonesia"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack {
                    Text("Ana Dil")
                        .font(.headline)
                    Picker("Ana Dil", selection: $selectedSourceLanguage) {
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
                    Text("Öğrenilecek Dil")
                        .font(.headline)
                    Picker("Öğrenilecek Dil", selection: $selectedTargetLanguage) {
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
            .padding()

            DailyWordView(viewModel: dailyWordViewModel)
                .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(uiColor: .systemGray6))
    }
}


// ContentView Preview
#Preview {
    ContentView()
}
