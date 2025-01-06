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
    
    /// Current word being displayed
    @Published var currentWord: Word = .placeholder
    
    /// List of words marked as known by the user
    @Published var knownWords: [WordWithLanguages] = []
    
    /// List of recently shown words
    @Published var recentWords: [Word] = []
    
    // UI related properties
    @Published var sourceLanguageCode: String = ""
    @Published var targetLanguageCode: String = ""
    @Published var sourceWord: String = ""
    @Published var targetWord: String = ""
    @Published var pronunciation: String = ""
    @Published var exampleSentence: String = ""
    @Published var sourceExampleSentence: String = ""
    @Published var romanized: String?
    @Published var romanizedExample: String?
    
    // MARK: - Private Properties
    private let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!
    private let synthesizer = AVSpeechSynthesizer()
    private var currentLanguageCode: String = "en"
    
    private let recentWordsKey = "recentWords"
    private let knownWordsKey = "knownWords"
    
    // MARK: - Computed Properties
    
    /// Current word's ID stored in UserDefaults
    var currentWordId: String {
        get { defaults.string(forKey: "currentWordId") ?? "" }
        set { defaults.set(newValue, forKey: "currentWordId") }
    }
    
    /// Last word update date
    var lastWordDate: Date {
        get { defaults.object(forKey: "lastWordDate") as? Date ?? Date(timeIntervalSince1970: 0) }
        set { defaults.set(newValue, forKey: "lastWordDate") }
    }
    
    // MARK: - Initialization
    
    /// Initialize the view model and load necessary data
    init() {
        setupAudioSession()
        loadRecentWords()
        loadKnownWords()
        fetchCurrentWord()
    }
    
    // MARK: - Word Selection and Management
    
    /// Select a new word that hasn't been shown recently
    private func selectNewWord() -> String {
        var availableWords = allWordIds
        
        // If we've shown all words, reset the recent words
        if recentWords.count >= allWordIds.count - 1 {
            recentWords.removeAll()
            availableWords = allWordIds.filter { $0 != currentWordId }
        } else {
            // Filter out recently shown words and current word
            let recentWordIds = recentWords.map { $0.id }
            availableWords = allWordIds.filter { !recentWordIds.contains($0) && $0 != currentWordId }
        }
        
        return availableWords.randomElement() ?? allWordIds[0]
    }
    
    /// Load a word from the bundle by its ID
    private func loadWord(id: String) -> Word? {
        let url = Bundle.main.url(forResource: id, withExtension: "json")
        print("Trying to load word with id: \(id)")
        print("URL found: \(url != nil)")
        
        guard let url = url,
              let data = try? Data(contentsOf: url) else {
            print("Failed to load data for id: \(id)")
            return nil
        }
        
        do {
            let word = try JSONDecoder().decode(Word.self, from: data)
            return word
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Missing key: \(key.stringValue) in \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            return nil
        } catch {
            print("Failed to decode word: \(error)")
            return nil
        }
    }
    
    /// Update the UI with the new word data
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
    
    // MARK: - Public Word Management Methods
    
    /// Refresh the current word with a new one
    func refreshWord(from sourceLang: String, to targetLang: String, nativeLanguage: String) {
        currentLanguageCode = targetLang
        let newId = selectNewWord()
        
        guard let newWord = loadWord(id: newId) else {
            print("Failed to load new word")
            return
        }
        
        currentWord = newWord
        currentWordId = newId
        lastWordDate = Date()
        
        addToRecentWords(newWord)
        updateUI(with: newWord, sourceLang: sourceLang, targetLang: targetLang)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Fetch the current word or load a new one if needed
    func fetchCurrentWord() {
        let sourceLang = defaults.string(forKey: "sourceLanguage") ?? "es"
        let targetLang = defaults.string(forKey: "targetLanguage") ?? "en"
        currentLanguageCode = targetLang
        
        if let word = loadWord(id: currentWordId) {
            currentWord = word
            updateUI(with: word, sourceLang: sourceLang, targetLang: targetLang)
        } else {
            fetchDailyWord(from: sourceLang, to: targetLang)
        }
    }
    
    /// Fetch the daily word, checking if it needs to be updated
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
    
    // MARK: - Recent Words Management
    
    /// Load recently shown words from storage
    private func loadRecentWords() {
        if let data = defaults.data(forKey: recentWordsKey),
           let decoded = try? JSONDecoder().decode([Word].self, from: data) {
            recentWords = decoded
        } else if recentWords.isEmpty {
            createInitialRecentWords()
        }
    }
    
    /// Create initial recent words if none exist
    private func createInitialRecentWords() {
        let randomWords = Array(allWordIds.shuffled().prefix(2))
        for wordId in randomWords {
            if let word = loadWord(id: wordId) {
                recentWords.append(word)
            }
        }
        saveRecentWords()
    }
    
    /// Save recent words to storage
    private func saveRecentWords() {
        if let encoded = try? JSONEncoder().encode(recentWords) {
            defaults.set(encoded, forKey: recentWordsKey)
        }
    }
    
    /// Add a word to recent words list
    private func addToRecentWords(_ word: Word) {
        recentWords.removeAll { $0.id == word.id }
        recentWords.insert(word, at: 0)
        while recentWords.count > allWordIds.count - 1 {
            recentWords.removeLast()
        }
        saveRecentWords()
    }
    
    // MARK: - Known Words Management
    
    /// Mark the current word as known and refresh to a new word
    func markCurrentWordAsKnown() {
        let sourceLanguage = defaults.string(forKey: "sourceLanguage") ?? "en"
        let targetLanguage = defaults.string(forKey: "targetLanguage") ?? "es"
        
        // Daha detaylı kontrol - hem ID hem de dil çifti kontrolü
        let isAlreadyKnown = knownWords.contains { word in
            word.word.id == currentWord.id &&
            word.sourceLanguage == sourceLanguage &&
            word.targetLanguage == targetLanguage
        }
        
        print("Checking word: \(currentWord.id)")
        print("Source Language: \(sourceLanguage)")
        print("Target Language: \(targetLanguage)")
        print("Is Already Known: \(isAlreadyKnown)")
        print("Current Known Words: \(knownWords.map { "\($0.word.id) (\($0.sourceLanguage)-\($0.targetLanguage))" })")
        
        if !isAlreadyKnown {
            let wordWithLangs = WordWithLanguages(
                word: currentWord,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            )
            
            knownWords.insert(wordWithLangs, at: 0)
            saveKnownWords()
            
            // Update recent words list
            if let index = recentWords.firstIndex(where: { $0.id == currentWord.id }) {
                recentWords.remove(at: index)
                saveRecentWords()
            }
            
            print("Word successfully marked as known")
            
            refreshWord(
                from: sourceLanguage,
                to: targetLanguage,
                nativeLanguage: sourceLanguage
            )
            
        } else {
            print("This word is already known for the current language pair")
            // Yine de yeni kelime göster
            refreshWord(
                from: sourceLanguage,
                to: targetLanguage,
                nativeLanguage: sourceLanguage
            )
        }
    }
    
    /// Get known words for the current language pair
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
    
    /// Load known words from storage
    private func loadKnownWords() {
        if let data = defaults.data(forKey: knownWordsKey),
           let decoded = try? JSONDecoder().decode([WordWithLanguages].self, from: data) {
            knownWords = decoded
        }
    }
    
    /// Save known words to storage
    func saveKnownWords() {
        if let encoded = try? JSONEncoder().encode(knownWords) {
            defaults.set(encoded, forKey: knownWordsKey)
        }
    }
    
    // MARK: - Audio Management
    
    /// Set up the audio session for speech
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
        }
    }
    
    /// Speak the provided text or current target word
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
    
    /// Convert language code to speech synthesis format
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
}

// MARK: - Available Words
extension DailyWordViewModel {
    private var allWordIds: [String] {
        [
            // Greetings and Basic Interactions
            "hello", "good_morning", "good_afternoon", "good_evening", "good_night",
            "how_are_you", "goodbye", "see_you_later", "nice_to_meet_you", "take_care",
            "thank_you", "welcome", "excuse_me", "sorry", "no_problem",
            
            // Directions and Location
            "where", "left", "right", "straight", "near",
            "far", "stop", "here", "there", "which_way",
            
            // Time and Schedule
            "time", "today", "tomorrow", "yesterday", "morning",
            "afternoon", "evening", "now", "later", "soon", "early", "late",
            "how_long",  // Eklendi
            
            // Feelings and States
            "happy", "sad", "tired", "angry", "excited",
            "lost", "busy", "free", "bored", "sleepy", "clean", "dirty",
            
            // Emergency and Health
            "help", "police", "ambulance", "sick", "injured",
            "fire", "danger", "hospital", "pharmacy", "embassy",
            
            // Transportation and Places
            "bathroom", "hotel", "airport", "bus", "train",
            "subway", "ticket", "station", "car",
            
            // Shopping and Money
            "how_much", "expensive", "cheap", "buy", "color",
            "cash", "card", "receipt", "bag", "size",
            
            // Food, Drinks and Dining
            "hungry", "thirsty", "water", "money", "bill",
            "delicious", "spicy", "sweet", "recommend", "coffee",
            
            // Basic Communication
            "listen", "forget", "understand", "repeat", "please",
            "same", "place", "young", "new", "nice", "old", "maybe",
            
            // Objects and Descriptions
            "table" //, "chair", "book", "pen", "paper",
        ]
    }
}
