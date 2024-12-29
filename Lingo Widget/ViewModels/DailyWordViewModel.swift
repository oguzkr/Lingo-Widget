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
    // MARK: - Published Properties
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
    @Published var currentWord: Word = .placeholder
    @Published var knownWords: [WordWithLanguages] = []
    
    // MARK: - Private Properties
    private let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!
    private let recentWordsKey = "recentWords"
    private let knownWordsKey = "knownWords"
    private let synthesizer = AVSpeechSynthesizer()
    private var currentLanguageCode: String = "en"
    
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
    
    // MARK: - Initialization
    init() {
        setupAudioSession()
        loadRecentWords()
        loadKnownWords()
        fetchCurrentWord() // Initialize currentWord
    }
    
    // MARK: - Known Words Management
    private func loadKnownWords() {
        if let data = defaults.data(forKey: knownWordsKey),
           let decoded = try? JSONDecoder().decode([WordWithLanguages].self, from: data) {
            knownWords = decoded
        }
    }
    
    func saveKnownWords() {
        if let encoded = try? JSONEncoder().encode(knownWords) {
            defaults.set(encoded, forKey: knownWordsKey)
        }
    }
    
    func markCurrentWordAsKnown() {
        let sourceLanguage = defaults.string(forKey: "sourceLanguage") ?? "en"
        let targetLanguage = defaults.string(forKey: "targetLanguage") ?? "es"
        
        let isAlreadyKnown = knownWords.contains { word in
            word.word.id == currentWord.id &&
            word.sourceLanguage == sourceLanguage &&
            word.targetLanguage == targetLanguage
        }
        
        guard !isAlreadyKnown else { return }
        
        let wordWithLangs = WordWithLanguages(
            word: currentWord,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        
        // Yeni kelimeyi listenin başına ekliyoruz
        knownWords.insert(wordWithLangs, at: 0)
        saveKnownWords()
        
        refreshWord(
            from: sourceLanguage,
            to: targetLanguage,
            nativeLanguage: sourceLanguage
        )
    }
    
    func getKnownWordsForCurrentLanguages() -> [Word] {
            let sourceLanguage = defaults.string(forKey: "sourceLanguage") ?? "en"
            let targetLanguage = defaults.string(forKey: "targetLanguage") ?? "es"
            
            return knownWords
                .filter { word in
                    word.sourceLanguage == sourceLanguage &&
                    word.targetLanguage == targetLanguage
                }
                .map { $0.word }
        }
    
    // MARK: - Recent Words Management
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
        recentWords.removeAll { $0.id == word.id }
        recentWords.insert(word, at: 0)
        while recentWords.count > 3 {
            recentWords.removeLast()
        }
        saveRecentWords()
    }
    
    // MARK: - Word Loading and Management
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
    
    // MARK: - UI Update and Word Fetching
    func fetchCurrentWord() {
        let sourceLang = defaults.string(forKey: "sourceLanguage") ?? "es"
        let targetLang = defaults.string(forKey: "targetLanguage") ?? "en"
        currentLanguageCode = targetLang
        
        let currentWordId = defaults.string(forKey: "currentWordId") ?? ""
        
        if let word = loadWord(id: currentWordId) {
            currentWord = word
            updateUI(with: word, sourceLang: sourceLang, targetLang: targetLang)
        } else {
            fetchDailyWord(from: sourceLang, to: targetLang)
        }
    }
    
    func fetchDailyWord(from sourceLang: String = "tr", to targetLang: String = "en") {
        currentLanguageCode = targetLang
        let calendar = Calendar.current
        
        if currentWordId.isEmpty || !calendar.isDate(lastWordDate, inSameDayAs: Date()) {
            refreshWord(from: sourceLang, to: targetLang, nativeLanguage: sourceLang)
            return
        }
        
        if let word = loadWord(id: currentWordId) {
            currentWord = word
            updateUI(with: word, sourceLang: sourceLang, targetLang: targetLang)
        } else {
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
        
        currentWord = newWord
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
        currentWord = word
    }
    
    // MARK: - Audio
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
            "tr": "tr-TR", "en": "en-US", "es": "es-ES",
            "id": "id-ID", "fr": "fr-FR", "it": "it-IT",
            "pt": "pt-PT", "zh": "zh-CN", "ru": "ru-RU",
            "ja": "ja-JP", "hi": "hi-IN", "fil": "fil-PH",
            "th": "th-TH", "ko": "ko-KR", "nl": "nl-NL",
            "sv": "sv-SE", "pl": "pl-PL", "el": "el-GR",
            "de": "de-DE"
        ]
        return conversions[code] ?? code
    }
    
    // MARK: - Word IDs
    private let allWordIds: [String] = [
        // Greetings and Basic Interactions
        "hello", "good_morning", "good_afternoon", "good_evening", "good_night",
        "how_are_you", "goodbye", "see_you_later", "nice_to_meet_you", "take_care",
        "thank_you", "welcome", "excuse_me", "sorry", "no_problem",
        
        // Directions and Location
        "where", "left", "right", "straight", "near",
        "far", "stop", "here", "there", "which_way",
        
        // Food, Drinks and Dining
        "hungry", "thirsty", "water", "money", "bill",
        "delicious", "spicy", "sweet", "recommend", "coffee",
        
        // Shopping and Money
        "how_much", "expensive", "cheap", "buy", "color",
        "cash", "card", "receipt", "bag", "size",
        
        // Transportation and Places
        "bathroom", "hotel", "airport", "bus", "train",
        "subway", "ticket", "platform", "station", "how_long",
        
        // Time and Schedule
        "time", "today", "tomorrow", "yesterday", "morning",
        "afternoon", "evening", "now", "later", "soon",
        
        // Feelings and States
        "happy", "sad", "tired", "angry", "excited",
        "lost", "fine", "busy", "free", "bored",
        
        // Emergency and Health
        "help", "police", "ambulance", "sick", "injured",
        "fire", "danger", "passport", "doctor", "pharmacy",
        
        // Basic Communication
        "yes", "no", "maybe", "please", "understand",
        "repeat", "mean", "know", "name", "old",
        "what", "great", "awesome", "nice", "place",
        "new"
    ]
}
