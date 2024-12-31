//
//  StringExtension.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 13.12.2024.
//

import Foundation

extension String {
    /// Sadece harflerden oluşan bir String döndürür.
    /// - Returns: Sadece harfleri içeren bir String.
    func extractLetters() -> String {
        self.unicodeScalars.filter { CharacterSet.letters.contains($0) }.map { String($0) }.joined()
    }
    
    func localized(language: Locale) -> String {
        guard let languageCode = language.language.languageCode?.identifier,
              let bundlePath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let languageBundle = Bundle(path: bundlePath) else {
            return NSLocalizedString(self, comment: "")
        }
        return NSLocalizedString(self, bundle: languageBundle, comment: "")
    }
}
