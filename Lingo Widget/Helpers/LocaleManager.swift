//
//  LocaleManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 31.12.2024.
//


import Foundation

class LocaleManager: ObservableObject {
    @Published var currentLocale: Locale = .current

    func setLocale(languageCode: String) {
        let locale = Locale(identifier: languageCode)
        currentLocale = locale
    }
}
