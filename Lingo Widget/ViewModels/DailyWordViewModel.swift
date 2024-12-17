//
//  DailyWordViewModel.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI
import AVFoundation
import WidgetKit

class DailyWordViewModel: ObservableObject {
    
    @Published var sourceLanguageCode: String = ""
    @Published var sourceWord: String = ""
    @Published var targetWord: String = ""
    @Published var targetLanguageCode: String = ""
    @Published var pronunciation: String = ""
    @Published var exampleSentence: String = ""
    @Published var sourceExampleSentence: String = ""
    @Published var romanized: String?
    @Published var romanizedExample: String?

    @Published var recentWords: [Word] = []
    
    private let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!
    
    private let recentWordsKey = "recentWords"
    private let maxRecentWords = 2
    
    var shownWordIds: [String] {
        get { defaults.array(forKey: "shownWords") as? [String] ?? [] }
        set { defaults.set(newValue, forKey: "shownWords") }
    }

    var lastWordDate: Date {
        get { defaults.object(forKey: "lastWordDate") as? Date ?? Date(timeIntervalSince1970: 0) }
        set { defaults.set(newValue, forKey: "lastWordDate") }
    }

    var currentWordId: String {
        get { defaults.string(forKey: "currentWordId") ?? "" }
        set { defaults.set(newValue, forKey: "currentWordId") }
    }

    private let synthesizer = AVSpeechSynthesizer()
    private var currentLanguageCode: String = "en"

    init() {
        setupAudioSession()
        loadRecentWords()
    }
    
    private func loadRecentWords() {
        if let data = defaults.data(forKey: recentWordsKey),
           let decoded = try? JSONDecoder().decode([Word].self, from: data) {
            recentWords = decoded
        } else if recentWords.isEmpty {
            createInitialRecentWords()
        }
    }
    
    private func createInitialRecentWords() {
        let randomWords = Array(allWordIds.shuffled().prefix(2))
        for wordId in randomWords {
            if let word = loadWord(id: wordId) {
                recentWords.append(word)
            }
        }
        saveRecentWords()
    }
    
    private func saveRecentWords() {
        if let encoded = try? JSONEncoder().encode(recentWords) {
            defaults.set(encoded, forKey: recentWordsKey)
        }
    }
    
    private func addToRecentWords(_ word: Word) {
        // Eğer kelime zaten recentWords'de varsa, onu kaldır
        recentWords.removeAll { $0.id == word.id }
        
        // Yeni kelimeyi başa ekle
        recentWords.insert(word, at: 0)
        
        // Maksimum sayıyı kontrol et
        if recentWords.count > maxRecentWords {
            recentWords.removeLast()
        }
        
        saveRecentWords()
    }
        

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                             mode: .default,
                                                             options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session ayarlanırken hata: \(error.localizedDescription)")
        }
    }

    private func selectNewWord() -> String {
        var availableWords = allWordIds.filter { !shownWordIds.contains($0) }

        if availableWords.isEmpty {
            shownWordIds.removeAll()
            availableWords = allWordIds.filter { $0 != currentWordId }
            if availableWords.isEmpty {
                availableWords = allWordIds
            }
        }
        
        return availableWords.randomElement() ?? allWordIds[0]
    }
    
    private func loadWord(id: String) -> Word? {
        guard let url = Bundle.main.url(forResource: id, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let word = try? JSONDecoder().decode(Word.self, from: data) else {
            return nil
        }
        return word
    }
    
    func fetchCurrentWord() {
        let sourceLang = defaults.string(forKey: "sourceLanguage") ?? "es"
        let targetLang = defaults.string(forKey: "targetLanguage") ?? "en"
        currentLanguageCode = targetLang

        // Always reload the currentWordId from shared storage
        let currentWordId = defaults.string(forKey: "currentWordId") ?? ""

        // Load the current word if available
        if let currentWord = loadWord(id: currentWordId) {
            updateUI(with: currentWord, sourceLang: sourceLang, targetLang: targetLang)
        } else {
            // If no word is available, fetch a new one
            fetchDailyWord(from: sourceLang, to: targetLang)
        }
    }

    func fetchDailyWord(from sourceLang: String = "tr", to targetLang: String = "en") {
        print("fetchDailyWord: \(sourceLang) -> \(targetLang)")
        currentLanguageCode = targetLang
        let calendar = Calendar.current

        // Yeni gün mü veya mevcut kelime yok mu?
        if currentWordId.isEmpty || !calendar.isDate(lastWordDate, inSameDayAs: Date()) {
            refreshWord(from: sourceLang, to: targetLang, nativeLanguage: sourceLang)
            return
        }

        if let currentWord = loadWord(id: currentWordId) {
            // Mevcut kelimeyi göster
            updateUI(with: currentWord, sourceLang: sourceLang, targetLang: targetLang)
        } else {
            // Mevcut kelime yüklenemiyor, yeni bir kelime seç
            refreshWord(from: sourceLang, to: targetLang, nativeLanguage: sourceLang)
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }

    func refreshWord(from sourceLang: String, to targetLang: String, nativeLanguage: String) {
        currentLanguageCode = targetLang
        let newId = selectNewWord()
        guard let newWord = loadWord(id: newId) else {
            print("Widget: Yeni kelime yüklenemedi.")
            return
        }
        
        currentWordId = newId
        defaults.set(currentWordId, forKey: "currentWordId")
        lastWordDate = Date()
        
        addToRecentWords(newWord)
        updateUI(with: newWord, sourceLang: sourceLang, targetLang: targetLang)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    

    private func updateUI(with word: Word, sourceLang: String, targetLang: String) {
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
        let conversions = [
            "tr": "tr-TR",
            "en": "en-US",
            "es": "es-ES",
            "id": "id-ID",
            "fr": "fr-FR",
            "it": "it-IT",
            "pt": "pt-PT",
            "zh": "zh-CN",
            "ru": "ru-RU",
            "ja": "ja-JP",
            "hi": "hi-IN",
            "fil": "fil-PH",
            "th": "th-TH",
            "ko": "ko-KR",
            "nl": "nl-NL",
            "sv": "sv-SE",
            "pl": "pl-PL",
            "el": "el-GR",
            "de": "de-DE"
        ]
        return conversions[code] ?? code
    }

    // Kelime listesi
    private let allWordIds: [String] = [
        "hello", "good_morning", "good_afternoon", "good_evening", "good_night",
        "how_are_you", "goodbye", "see_you_later", "nice_to_meet_you", "take_care",
        "thank_you", "welcome", "excuse_me", "sorry", "no_problem",
        "where", "left", "right", "straight", "near",
        "far", "stop", "here", "there", "which_way",
        "hungry", "thirsty", "water", "money", "bill",
        "delicious", "spicy", "sweet", "recommend", "coffee",
        "how_much", "expensive", "cheap", "buy", "color",
        "cash", "card", "receipt", "bag", "size",
        "bathroom", "hotel", "airport", "bus", "train",
        "subway", "ticket", "platform", "station", "how_long",
        "time", "today", "tomorrow", "yesterday", "morning",
        "afternoon", "evening", "now", "later", "soon",
        "happy", "sad", "tired", "angry", "excited",
        "lost", "fine", "busy", "free", "bored",
        "help", "police", "ambulance", "sick", "injured",
        "fire", "danger", "passport", "doctor", "pharmacy",
        "yes", "no", "maybe", "please", "understand",
        "repeat", "mean", "know", "name", "old",
        "what", "great", "awesome", "nice", "place",
        "new"
    ]
}
