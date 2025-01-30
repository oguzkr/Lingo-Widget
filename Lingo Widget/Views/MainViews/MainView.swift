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
    @AppStorage("hasSeenWidgetGuide") private var hasSeenWidgetGuide = false
    
    @State private var showSettings = false
    @State private var showPremiumSheet = false
    @State private var showWidgetGuide = false
    @State private var showWidgetCard = true
    @State private var showTutorialVideo = false
    @State private var showRefreshLimitAlert = false
    @State private var isPremiumUser = false

    @EnvironmentObject var localeManager: LocaleManager
    
    @Environment(\.scenePhase) var scenePhase

    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "es"
    
    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "en"
    
    private let revenueCatManager = RevenueCatManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !hasSeenWidgetGuide && showWidgetCard {
                        WidgetGuideCard(
                            isVisible: $showWidgetCard,
                            onTutorialTap: {
                                showTutorialVideo = true // Video gösterimini tetikle
                                showWidgetGuide = true
                            }
                        )
                    }
                    
                    // Daily Word Card
                    DailyWordCard(
                        word: dailyWordViewModel.currentWord,
                        onKnowTap: {
                            hapticFeedback()
                            if dailyWordViewModel.shouldAllowRefresh() {
                                dailyWordViewModel.markCurrentWordAsKnown()
                            } else {
                                showPremiumSheet = true
                            }
                        },
                        onRefreshTap: {
                            hapticFeedback()
                            if dailyWordViewModel.shouldAllowRefresh() {
                                dailyWordViewModel.refreshWord(
                                    from: selectedSourceLanguage,
                                    to: selectedTargetLanguage,
                                    nativeLanguage: selectedSourceLanguage
                                )
                            } else {
                                showPremiumSheet = true
                            }
                        },
                        onSpeak: { text in
                            hapticFeedback()
                            dailyWordViewModel.speakWord(text: text)
                        }
                    )
                    
                    
                    if !isPremiumUser {
                        
                        if dailyWordViewModel.shouldAllowRefresh() {
                            Text("Remaining daily refreshes:".localized(language: localeManager.currentLocale) + " \(dailyWordViewModel.remainingRefreshCount)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                            
                            
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                
                                Text("You've reached today's refresh limit. Upgrade to Premium for unlimited refreshes.".localized(language: localeManager.currentLocale))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }

                        PremiumButton {
                            showPremiumSheet = true
                            hapticFeedback()
                        }
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
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                isPremiumUser = revenueCatManager.isPremiumUser
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showPremiumSheet) {
                RevenueCatPaywallView()
            }
            .fullScreenCover(isPresented: $dailyWordViewModel.showingPaywall) {
                RevenueCatPaywallView()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                print("Scene phase changed from \(oldPhase) to \(newPhase)")
                if newPhase == .active {
                    _ = UserDefaultsManager.shared.shouldAllowRefresh()
                    dailyWordViewModel.fetchCurrentWord()
                }
                if newPhase == .background {
                   exit(0)
                }
                revenueCatManager.checkProEntitlement { status in
                    print("Pro Entitlement: \(status)")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NotificationCenterManager.premiumStatusChanged)) { notification in
                if let isPremium = notification.userInfo?["isPremium"] as? Bool {
                    isPremiumUser = isPremium
                }
            }

        }
        .onAppear {
            if let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") {
                localeManager.setLocale(languageCode: sourceLanguage)
            }
            if !hasSeenWidgetGuide {
                showWidgetGuide = true
            }
        }
        .overlay {
            if showWidgetGuide {
                WidgetGuideView(
                    isPresented: $showWidgetGuide,
                    showVideo: $showTutorialVideo
                )
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
