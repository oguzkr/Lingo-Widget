//
//  OnboardingView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 24.12.2024.
//


import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var localeManager: LocaleManager

    @State private var currentPage = 0
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0
    
    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "" {
        didSet {
            nextButtonDisabled = false
            hapticFeedback()
            localeManager.setLocale(languageCode: selectedSourceLanguage)
        }
    }
    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "" {
        didSet {
            hapticFeedback()
            startLearningButtonDisabled = false
        }
    }
    
    @State private var nextButtonDisabled = true
    @State private var startLearningButtonDisabled = true
    
    let languages = [
        "tr": "Türkçe (Turkish)",
        "en": "English",
        "es": "Español (Spanish)",
        "id": "Bahasa (Indonesian)",
        "fr": "Français (French)",
        "it": "Italiano (Italian)",
        "pt": "Português (Portuguese)",
        "zh": "中文 (Chinese)",
        "ru": "Русский (Russian)",
        "ja": "日本語 (Japanese)",
        "hi": "हिन्दी (Hindi)",
        "fil": "Filipino",
        "th": "ไทย (Thai)",
        "ko": "한국어 (Korean)",
        "nl": "Nederlands (Dutch)",
        "sv": "Svenska (Swedish)",
        "pl": "Polski (Polish)",
        "el": "Ελληνικά (Greek)",
        "de": "Deutsch (German)"
    ]
    
    private var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                welcomeView
                    .tag(0)
                    
                AppearanceSelectionView()
                    .tag(1)
                
                nativeLanguageView
                    .tag(2)
                
                targetLanguageView
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            if currentPage > 0 {
                VStack {
                    Spacer()
                    HStack(spacing: 5) {
                        backButton
                            .widthAsPercentage(15)
                        if currentPage == 1 || currentPage == 2 {
                            nextButton
                                .widthAsPercentage(75)
                        } else if currentPage == 3 {
                            startButton
                                .widthAsPercentage(75)
                        }
                    }
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .ignoresSafeArea(.all)
        .preferredColorScheme(colorScheme)
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            FloatingHelloAnimation()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)
            Spacer()

            VStack(spacing: 16) {
                Text("Welcome".localized(language: localeManager.currentLocale))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Learn a new word one at a time, right on your home screen".localized(language: localeManager.currentLocale))
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
            
            Button(action: {
                hapticFeedback()
                withAnimation { currentPage = 1 }
            }) {
                Text("Get Started".localized(language: localeManager.currentLocale))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(radius: 5, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    private var nativeLanguageView: some View {
        VStack(spacing: 20) {
            Text("What's your native language?".localized(language: localeManager.currentLocale))
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top)
                .padding(.horizontal, 30)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(Array(languages.keys.sorted()), id: \.self) { key in
                        LanguageSelectionCard(
                            languageCode: key,
                            languageName: languages[key] ?? "",
                            isSelected: selectedSourceLanguage == key
                        ) {
                            selectedSourceLanguage = key
                        }
                    }
                }.padding(.bottom, 60)
            }.padding(.horizontal)
        }
        .onAppear {
            // Eğer henüz bir dil seçilmemişse
            if selectedSourceLanguage.isEmpty {
                if let sourceLanguage = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") {
                    selectedSourceLanguage = sourceLanguage
                    nextButtonDisabled = false
                }
            } else {
                nextButtonDisabled = false
            }
        }
    }
    
    private var targetLanguageView: some View {
        VStack(spacing: 20) {
            Text("What language do you want to learn?".localized(language: localeManager.currentLocale))
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top)
                .padding(.horizontal, 30)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(Array(languages.keys.sorted()), id: \.self) { key in
                        if key != selectedSourceLanguage {
                            LanguageSelectionCard(
                                languageCode: key,
                                languageName: languages[key] ?? "",
                                isSelected: selectedTargetLanguage == key
                            ) {
                                selectedTargetLanguage = key
                            }
                        }
                    }
                }.padding(.bottom, 60)
            }.padding(.horizontal)
        }
    }
    
    private var nextButton: some View {
        Button(action: {
            withAnimation {
                if currentPage == 2 && selectedSourceLanguage.isEmpty {
                    return
                }
                currentPage += 1
                hapticFeedback()
            }
        }) {
            Text("Next".localized(language: localeManager.currentLocale))
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(nextButtonDisabled && currentPage == 2 ? .white.opacity(0.5) : .clear)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
        }
        .disabled(nextButtonDisabled && currentPage == 2)
        .padding(.bottom, 30)
    }

    private var startButton: some View {
        Button(action: {
            hapticFeedback()
            withAnimation {
                if !selectedTargetLanguage.isEmpty {
                    completeOnboarding()
                }
            }
        }) {
            Text("Start Learning".localized(language: localeManager.currentLocale))
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(startLearningButtonDisabled ? .white.opacity(0.5) : .clear)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
        }
        .disabled(startLearningButtonDisabled)
        .padding(.bottom, 30)
    }
    
    private var backButton: some View {
        Button(action: {
            hapticFeedback()
            withAnimation {
                currentPage -= 1
            }
        }) {
            Text("<")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
        }
        .padding(.bottom, 30)
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct LanguageSelectionCard: View {
    let languageCode: String
    let languageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(languageCode)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                
                Text(languageName)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LocaleManager())
}
// Preview Helper için özel initializer
extension OnboardingView {
    init(currentPage: Int = 0) {
        _currentPage = State(initialValue: currentPage)
    }
}
