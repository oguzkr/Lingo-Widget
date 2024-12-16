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
                        let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "es"
                        let targetLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "en"
                        
                        viewModel.fetchDailyWord(from: sourceLanguage, to: targetLanguage)
                        
                        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                           let textType = components.queryItems?.first(where: { $0.name == "text" })?.value {
                            switch textType {
                            case "word":
                                viewModel.speakWord()
                            case "example":
                                let example = viewModel.exampleSentence
                                viewModel.speakWord(text: example)
                            default:
                                break
                            }
                        }
                    }
                }
        }
    }
}
