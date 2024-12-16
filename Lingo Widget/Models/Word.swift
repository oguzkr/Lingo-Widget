//
//  Word.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import Foundation

struct Word: Codable {
    let id: String
    let translations: [String: Translation]
    
    struct Translation: Codable {
        let text: String
        let exampleSentence: String
        let romanized: String?
        let romanizedExample: String?
        let pronunciations: [String: String]
    }
}


extension Word {
    static let placeholder: Word = {
        let sourceTranslation = Translation(
            text: "Merhaba",
            exampleSentence: "Merhaba, nasılsın?",
            romanized: nil,
            romanizedExample: nil,
            pronunciations: [
                "en": "mer·ha·ba"
            ]
        )
        
        let targetTranslation = Translation(
            text: "Hello",
            exampleSentence: "Hello, how are you?",
            romanized: nil,
            romanizedExample: nil,
            pronunciations: [
                "tr": "he·lou"
            ]
        )
        
        return Word(
            id: "hello",
            translations: [
                "tr": sourceTranslation,
                "en": targetTranslation
            ]
        )
    }()
}
