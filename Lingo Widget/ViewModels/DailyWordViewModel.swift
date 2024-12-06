//
//  DailyWordViewModel.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI
import AVFoundation

class DailyWordViewModel: ObservableObject {
    @Published var sourceWord: String = ""
    @Published var targetWord: String = ""
    @Published var pronunciation: String = ""
    @Published var exampleSentence: String = ""
    @Published var sourceExampleSentence: String = ""

    private let languageManager = LanguageManager.shared
    private let synthesizer = AVSpeechSynthesizer()
    private var currentLanguageCode: String = "en"
    
    // Preview için başlangıç değerleri atayabilen init ekleyelim
    init(previewData: (source: String, target: String, pronunciation: String, example: String)? = nil) {
        if let data = previewData {
            self.sourceWord = data.source
            self.targetWord = data.target
            self.pronunciation = data.pronunciation
            self.exampleSentence = data.example
        }
    }
    
    func fetchDailyWord(from sourceLang: String = "tr", to targetLang: String = "en", nativeLanguage: String = "tr") {
        if let wordPair = languageManager.getDailyWordPair(from: sourceLang, to: targetLang, nativeLanguage: nativeLanguage) {
            sourceWord = wordPair.source.text
            targetWord = wordPair.target.text
            pronunciation = wordPair.pronunciation
            exampleSentence = wordPair.target.exampleSentence
            sourceExampleSentence = wordPair.source.exampleSentence
            currentLanguageCode = targetLang
        }
    }
    
    func speakWord() {
        // Dil kodlarını AVSpeechSynthesizer formatına çevirme
        let languageCode = convertToSpeechLanguageCode(currentLanguageCode)
        
        let utterance = AVSpeechUtterance(string: targetWord)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.4  // Yavaş telaffuz için
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func convertToSpeechLanguageCode(_ code: String) -> String {
        // Dil kodlarını AVSpeechSynthesizer formatına çevirme
        let conversions = [
            "en": "en-US",
            "tr": "tr-TR",
            "es": "es-ES",
            "fr": "fr-FR",
            "de": "de-DE",
            "it": "it-IT",
            "pt": "pt-PT",
            "ru": "ru-RU",
            "ja": "ja-JP",
            "ko": "ko-KR",
            "zh": "zh-CN",
            // Diğer diller için gerekli dönüşümler eklenebilir
        ]
        return conversions[code] ?? code
    }
}
