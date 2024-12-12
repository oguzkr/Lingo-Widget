//
//  DailyWordViewModel.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI
import AVFoundation

class DailyWordViewModel: ObservableObject {
    @Published var sourceLanguageCode: String = "" //for flag icon
    @Published var sourceWord: String = "" //text (1)
    @Published var targetWord: String = "" //text (2)
    @Published var targetLanguageCode: String = "" //for flag icon
    @Published var pronunciation: String = "" //pronunciation for targetWord (2)
    @Published var exampleSentence: String = "" //exampleSentence (1)
    @Published var sourceExampleSentence: String = "" //exampleSentence (2)
    @Published var romanized: String? // (2)
    @Published var romanizedExample: String? // (2)
    
    private let defaults: UserDefaults = UserDefaults.standard

    private var shownWordIds: [String] {
        get { defaults.array(forKey: "shownWords") as? [String] ?? [] }
        set { defaults.set(newValue, forKey: "shownWords") }
    }
    
    private var lastWordDate: Date {
        get { defaults.object(forKey: "lastWordDate") as? Date ?? Date() }
        set { defaults.set(newValue, forKey: "lastWordDate") }
    }
    
    private var currentWordId: String {
        get { defaults.string(forKey: "currentWordId") ?? "" }
        set { defaults.set(newValue, forKey: "currentWordId") }
    }
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentLanguageCode: String = "en"
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session ayarlanırken hata: \(error.localizedDescription)")
        }
    }
    
    private func selectNewWord() -> String {
        return allWordIds.randomElement() ?? "hello"
        
        let availableWords = allWordIds.filter { !shownWordIds.contains($0) }
        
        if availableWords.isEmpty {
            shownWordIds.removeAll()
            return allWordIds.randomElement() ?? "hello"
        } else {
            return availableWords.randomElement() ?? "hello"
        }
    }
    
    private func loadWord(id: String) -> Word? {
        guard let url = Bundle.main.url(forResource: id, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let word = try? JSONDecoder().decode(Word.self, from: data)
        else {
            return nil
        }
        return word
    }
    
    func fetchDailyWord(from sourceLang: String = "tr", to targetLang: String = "en") {
        currentLanguageCode = targetLang
        
        // Test aşaması için her seferinde yeni kelime
        currentWordId = selectNewWord()
        
        /* Daha sonra aktif edilecek olan günlük kelime kontrolü
        let calendar = Calendar.current
        if !calendar.isDate(lastWordDate, inSameDayAs: Date()) {
            currentWordId = selectNewWord()
            shownWordIds.append(currentWordId)
            lastWordDate = Date()
        }
        */
        
        // Kelimeyi yükle
        if let word = loadWord(id: currentWordId) {
            guard let sourceTranslation = word.translations[sourceLang],
                  let targetTranslation = word.translations[targetLang] else {
                return
            }
            
            sourceLanguageCode = sourceLang
            targetLanguageCode = targetLang
            sourceWord = sourceTranslation.text
            targetWord = targetTranslation.text
            pronunciation = targetTranslation.pronunciations[sourceLang] ?? ""
            exampleSentence = targetTranslation.exampleSentence
            sourceExampleSentence = sourceTranslation.exampleSentence
            romanized = targetTranslation.romanized
            romanizedExample = targetTranslation.romanizedExample
        }
    }
    
    func refreshWord(from sourceLang: String, to targetLang: String, nativeLanguage: String) {
        currentWordId = selectNewWord()
        fetchDailyWord(from: sourceLang, to: targetLang)
    }
    
    func speakWord(text: String? = nil) {
        let textToSpeak = text ?? targetWord
        let languageCode = convertToSpeechLanguageCode(currentLanguageCode)
        
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func convertToSpeechLanguageCode(_ code: String) -> String {
        // Her dil için standart konuşma kodları
        let conversions = [
            "tr": "tr-TR", // Türkçe
            "en": "en-US", // İngilizce
            "es": "es-ES", // İspanyolca
            "id": "id-ID", // Endonezyaca
            "fr": "fr-FR", // Fransızca
            "it": "it-IT", // İtalyanca
            "pt": "pt-PT", // Portekizce
            "zh": "zh-CN", // Çince
            "ru": "ru-RU", // Rusça
            "ja": "ja-JP", // Japonca
            "hi": "hi-IN", // Hintçe
            "fil": "fil-PH", // Filipince
            "th": "th-TH", // Tayca
            "ko": "ko-KR", // Korece
            "nl": "nl-NL", // Hollandaca
            "sv": "sv-SE", // İsveççe
            "pl": "pl-PL", // Lehçe
            "el": "el-GR", // Yunanca
            "de": "de-DE" // Almanca
        ]
        return conversions[code] ?? code
    }
    
    // Kelime listesi
    private let allWordIds: [String] = [
        // Selamlaşmalar (1-10)
        "hello",              // 1
        "good_morning",       // 2
        "good_afternoon",     // 3
        "good_evening",       // 4
        "good_night",         // 5
        "how_are_you",        // 6
        "goodbye",            // 7
        "see_you_later",      // 8
        "nice_to_meet_you",   // 9
        "take_care",          // 10
        // Teşekkür ve Özür (11-15)
        "thank_you",          // 11
        "welcome",            // 12
        "excuse_me",          // 13
        "sorry",              // 14
        "no_problem",         // 15
        // Yönler ve Yönlendirme (16-25)
        "where",              // 16
        "left",               // 17
        "right",              // 18
        "straight",           // 19
        "near",               // 20
        "far",                // 21
        "stop",               // 22
        "here",               // 23
        "there",              // 24
        "which_way",          // 25
        // Restoran ve Yemek (26-35)
        "hungry",             // 26
        "thirsty",            // 27
        "water",              // 28
        "money",               // 29
        "bill",               // 30
        "delicious",          // 31
        "spicy",              // 32
        "sweet",              // 33
        "recommend",          // 34
        "coffee",             // 35
        // Alışveriş (36-45)
        "how_much",           // 36
        "expensive",          // 37
        "cheap",              // 38
        "buy",                // 39
        "color",              // 40
        "cash",               // 41
        "card",               // 42
        "receipt",            // 43
        "bag",                // 44
        "size",               // 45
        // Seyahat ve Ulaşım (46-55)
        "bathroom",           // 46
        "hotel",              // 47
        "airport",            // 48
        "bus",                // 49
        "train",              // 50
        "subway",             // 51
        "ticket",             // 52
        "platform",           // 53
        "station",            // 54
        "how_long",           // 55
        // Zaman ve Tarih (56-65)
        "time",               // 56
        "today",              // 57
        "tomorrow",           // 58
        "yesterday",          // 59
        "morning",            // 60
        "afternoon",          // 61
        "evening",            // 62
        "now",                // 63
        "later",              // 64
        "soon",               // 65
        // Temel Duygular ve Haller (66-75)
        "happy",              // 66
        "sad",                // 67
        "tired",              // 68
        "angry",              // 69
        "excited",            // 70
        "lost",               // 71
        "fine",               // 72
        "busy",               // 73
        "free",               // 74
        "bored",              // 75
        // Acil Durumlar (76-85)
        "help",               // 76
        "police",             // 77
        "ambulance",          // 78
        "sick",               // 79
        "injured",            // 80
        "fire",               // 81
        "danger",             // 82
        "passport",           // 83
        "doctor",             // 84
        "pharmacy",           // 85
        // Günlük Kullanım (86-100)
        "yes",                // 86
        "no",                 // 87
        "maybe",              // 88
        "please",             // 89
        "understand",         // 90
        "repeat",             // 91
        "mean",               // 92
        "know",               // 93
        "name",               // 94
        "old",                // 95
        "what",               // 96
        "great",              // 97
        "awesome",            // 98
        "nice",               // 99
        "place",               // 100
        "new",                // 101
    ]
}
