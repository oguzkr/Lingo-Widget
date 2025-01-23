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
    @StateObject private var localeManager = LocaleManager()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainView()
                    .preferredColorScheme(colorScheme)
                    .environmentObject(localeManager)
                    .onOpenURL { url in
                        if url.scheme == "lingowidget" {
                            let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "es"
                            let targetLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "en"
                            
                            if url.host == "showPaywall" {
                                viewModel.postShowPaywall()
                                return
                            }
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
            } else {
                OnboardingView()
                    .preferredColorScheme(colorScheme)
                    .environmentObject(localeManager)
            }
        }
    }
    
    private var colorScheme: ColorScheme? {
            switch preferredColorScheme {
            case 1: return .light
            case 2: return .dark
            default: return nil
            }
        }
}
