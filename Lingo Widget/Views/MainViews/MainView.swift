//
//  MainView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 6.12.2024.
//
//https://youtube.com/shorts/tlK7d-w7naQ

import SwiftUI

struct MainView: View {
    @StateObject private var dailyWordViewModel = DailyWordViewModel()
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0

    
    @State private var showSettings = false
    @State private var showPremiumSheet = false
    
    @EnvironmentObject var localeManager: LocaleManager
    @Environment(\.scenePhase) var scenePhase

    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "es"
    
    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "en"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Word Card
                    DailyWordCard(
                        word: dailyWordViewModel.currentWord,
                        onKnowTap: {
                            dailyWordViewModel.markCurrentWordAsKnown()
                        },
                        onRefreshTap: {
                            dailyWordViewModel.refreshWord(
                                from: selectedSourceLanguage,
                                to: selectedTargetLanguage,
                                nativeLanguage: selectedSourceLanguage
                            )
                        },
                        onSpeak: { text in
                            dailyWordViewModel.speakWord(text: text)
                        }
                    )
                    
                    PremiumButton {
                        showPremiumSheet = true
                    }
                    
                    KnownWordsList(viewModel: dailyWordViewModel)
                }
                .padding(.top)
            }
            .navigationTitle("Lingo Widget")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumView()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                print("Scene phase changed from \(oldPhase) to \(newPhase)")
                if newPhase == .active {
                    dailyWordViewModel.fetchCurrentWord()
                }
                if newPhase == .background {
                    exit(0)
                }
            }
        }
        .onAppear {
            if let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") {
                localeManager.setLocale(languageCode: sourceLanguage)
            }
        }
        .environmentObject(dailyWordViewModel)
        .preferredColorScheme(colorScheme)
    }
    
    private var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
}
 
#Preview {
    MainView()
        .environmentObject(LocaleManager())
}
