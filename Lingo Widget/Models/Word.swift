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
