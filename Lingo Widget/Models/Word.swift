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
            text: "How are you?",
            exampleSentence: "How are you doing today?",
            romanized: nil,
            romanizedExample: nil,
            pronunciations: [
                "es": "hau ar yu"
            ]
        )
        
        let targetTranslation = Translation(
            text: "¿Cómo estás?",
            exampleSentence: "¿Cómo estás hoy?",
            romanized: nil,
            romanizedExample: nil,
            pronunciations: [
                "en": "koh-moh es-tahs"
            ]
        )
        
        return Word(
            id: "how_are_you",
            translations: [
                "en": sourceTranslation,
                "es": targetTranslation
            ]
        )
    }()
}


