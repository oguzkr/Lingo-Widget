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

    private let recentWordsKey = "recentWords"
    private let maxRecentWords = 2

    private let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!

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

    private func loadRecentWords() {
        if let data = defaults.data(forKey: recentWordsKey),
           let words = try? JSONDecoder().decode([Word].self, from: data) {
            recentWords = words
        } else {
            recentWords = []
        }
    }

    private func saveRecentWords() {
        if let encoded = try? JSONEncoder().encode(recentWords) {
            defaults.set(encoded, forKey: recentWordsKey)
        }
    }

    private func selectNewWord() -> String {
        var availableWords = allWordIds.filter { !shownWordIds.contains($0) }

        // Eğer hiç yeni kelime kalmadıysa, bütün kelimeleri tekrar gösterilebilir hale getir
        if availableWords.isEmpty {
            shownWordIds.removeAll()
            availableWords = allWordIds.filter { $0 != currentWordId }
            if availableWords.isEmpty {
                // Tek kelime varsa mecburen onu seçeceğiz.
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

    private func addToRecents(_ word: Word) {
        // Eğer recentWords boş ya da en üstteki kelime bu kelime değilse ekle
        if recentWords.isEmpty || recentWords.first?.id != word.id {
            recentWords.insert(word, at: 0)
            if recentWords.count > maxRecentWords {
                recentWords.removeLast()
            }
            saveRecentWords()
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

        // Önce yeni bir kelime seç
        var newId = selectNewWord()

        // Yeni kelime yüklenemezse tekrar dene (çok nadir bir durum)
        var tryCount = 0
        var newWord: Word? = nil
        while tryCount < 5 {
            if let w = loadWord(id: newId) {
                newWord = w
                break
            } else {
                newId = selectNewWord()
                tryCount += 1
            }
        }

        guard let loadedNewWord = newWord else {
            print("Yeni kelime yüklenemedi.")
            return
        }

        // Eğer önceki kelime varsa recent'e ekle
        if !currentWordId.isEmpty, let oldWord = loadWord(id: currentWordId) {
            addToRecents(oldWord)
        }

        currentWordId = newId
        if !shownWordIds.contains(newId) {
            shownWordIds.append(newId)
        }
        lastWordDate = Date()

        // UI Güncelle
        updateUI(with: loadedNewWord, sourceLang: sourceLang, targetLang: targetLang)
        
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
