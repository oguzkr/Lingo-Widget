//
//  KnownWordRow.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 29.12.2024.
//

import SwiftUI

struct KnownWordRow: View {
    let word: Word
    
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "en"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "ru"
    }
    
    private var shouldShowRomanized: Bool {
        guard let targetTranslation = word.translations[targetLanguage] else { return false }
        return !targetTranslation.text.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if shouldShowRomanized,
                       let romanized = word.translations[targetLanguage]?.romanized {
                        HStack(spacing: 4) {
                            Image(systemName: "character.textbox")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            
                            Text(romanized)
                                .italic()
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let sourceText = word.translations[sourceLanguage]?.text {
                    Text(sourceText)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 20))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .primary.opacity(0.4), radius: 5)
        .padding(.horizontal)
    }
}

#Preview {
    KnownWordRow(word: .placeholder)
}
