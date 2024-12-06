//
//  ContentView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedSourceLanguage = "tr"
    @State private var selectedTargetLanguage = "en"
    
    let languages = [
        "tr": "Türkçe",
        "en": "English",
        "es": "Español",
        // Diğer diller buraya eklenecek
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Dil seçim kontrolleri
            VStack(spacing: 16) {
                // Ana dil seçimi
                HStack() {
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
                }
                
                // Hedef dil seçimi
                HStack() {
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
                }
            }
            .padding()

            DailyWordView()
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
