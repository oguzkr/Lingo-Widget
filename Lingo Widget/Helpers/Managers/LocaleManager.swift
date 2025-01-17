//
//  LocaleManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 31.12.2024.
//


import Foundation

class LocaleManager: ObservableObject {
    @Published var currentLocale: Locale = .current
    
    static let supportedLanguageCodes = [
        "tr", "en", "es", "id", "fr", "it", "pt", "zh", "ru", "ja",
        "hi", "fil", "th", "ko", "nl", "sv", "pl", "el", "de"
    ]
    
    init() {
        initializeAppLanguage()
    }
    
    func initializeAppLanguage() {
        let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")
        
        // If no language was previously selected
        
        if defaults?.string(forKey: "sourceLanguage") == nil {
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            let selectedLanguage = LocaleManager.supportedLanguageCodes.contains(systemLanguage) ? systemLanguage : "en"
            defaults?.set(selectedLanguage, forKey: "sourceLanguage")
        }
        
        // Set locale
        
        if let sourceLanguage = defaults?.string(forKey: "sourceLanguage") {
            setLocale(languageCode: sourceLanguage)
        }
    }
    
    func setLocale(languageCode: String) {
        let locale = Locale(identifier: languageCode)
        DispatchQueue.main.async {
            self.currentLocale = locale
        }
    }
}
