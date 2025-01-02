//
//  LocaleManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 31.12.2024.
//


import Foundation

class LocaleManager: ObservableObject {
    @Published var currentLocale: Locale = .current
    
    init() {
        if let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") {
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
