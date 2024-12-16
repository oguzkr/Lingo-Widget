//
//  Lingo_WidgetApp.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//

import SwiftUI

@main
struct Lingo_WidgetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = DailyWordViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    if url.scheme == "lingowidget" {
                        switch url.host {
                        case "speak":
                            let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "es"
                            let targetLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "en"

                            viewModel.fetchDailyWord(from: sourceLanguage, to: targetLanguage)
                            viewModel.speakWord()
                        default:
                            break
                        }
                    }
                }
        }
    }
}
