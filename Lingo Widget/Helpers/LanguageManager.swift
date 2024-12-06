//
//  LanguageManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import Foundation

final class LanguageManager {
    static let shared = LanguageManager()
    
    private let userDefaults = UserDefaults.standard
    private let currentIndexKey = "CurrentWordIndex"
    
    let languages: [String: [Word]] = [
        "tr": Turkish.words,
        "en": English.words,
        "es": Spanish.words,
        "id": Indonesian.words
    ]
    
    // Mevcut kelime indeksini al
    private func getCurrentIndex() -> Int {
        return userDefaults.integer(forKey: currentIndexKey)
    }
    
    // Yeni rastgele kelime indeksi oluştur
    func getNewRandomIndex() -> Int {
        let newIndex = Int.random(in: 0..<getMinimumWordCount())
        userDefaults.set(newIndex, forKey: currentIndexKey)
        return newIndex
    }
    
    private func getMinimumWordCount() -> Int {
        return languages.values.map { $0.count }.min() ?? 0
    }
    
    func getDailyWordPair(from: String, to: String, nativeLanguage: String) -> (
        source: Word,
        target: Word,
        pronunciation: String
    )? {
        guard let sourceWords = languages[from],
              let targetWords = languages[to] else {
            return nil
        }
        
        let currentIndex = getCurrentIndex()
        
        guard currentIndex < sourceWords.count && currentIndex < targetWords.count else {
            return nil
        }
        
        let sourceWord = sourceWords[currentIndex]
        let targetWord = targetWords[currentIndex]
        
        let pronunciation = targetWord.pronunciations[nativeLanguage] ??
                          targetWord.pronunciations["en"] ?? ""
        
        return (sourceWord, targetWord, pronunciation)
    }
}
