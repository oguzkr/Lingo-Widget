//
//  Word.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import Foundation

struct Word {
    let text: String
    let exampleSentence: String
    let pronunciations: [String: String] // [languageCode: pronunciation]
}
