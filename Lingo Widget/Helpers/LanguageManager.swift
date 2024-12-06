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
    private let lastUpdateKey = "LastUpdateDate"
    private let dailyIndexKey = "DailyWordIndex"
    
    let languages: [String: [Word]] = [
        "tr": Turkish.words,
        "en": English.words,
        "es": Spanish.words,
        "id": Indonesian.words
    ]
    
    func getDailyWordPair(from: String, to: String, nativeLanguage: String) -> (
            source: Word,
            target: Word,
            pronunciation: String
        )? {
            guard let sourceWords = languages[from],
                  let targetWords = languages[to] else {
                return nil
            }
            
            let randomIndex = Int.random(in: 0..<min(sourceWords.count, targetWords.count))
            let sourceWord = sourceWords[randomIndex]
            let targetWord = targetWords[randomIndex]
            
            // Kullanıcının ana diline göre telaffuz
            let pronunciation = targetWord.pronunciations[nativeLanguage] ??
                              targetWord.pronunciations["en"] ?? ""
            
            return (sourceWord, targetWord, pronunciation)
        }
    
    private func getDailyIndex() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date,
           calendar.isDate(lastUpdate, inSameDayAs: now) {
            return userDefaults.integer(forKey: dailyIndexKey)
        }
        
        let newIndex = Int.random(in: 0..<2) // şu an 2 kelime var
        userDefaults.set(now, forKey: lastUpdateKey)
        userDefaults.set(newIndex, forKey: dailyIndexKey)
        return newIndex
    }
}
