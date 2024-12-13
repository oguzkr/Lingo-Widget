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
}
