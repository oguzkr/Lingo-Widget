//
//  SmallLingoWidget.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 16.12.2024.
//


import SwiftUI
import WidgetKit
import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Word"
    
    func perform() async throws -> some IntentResult {
        let sharedDefaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!
        let viewModel = DailyWordViewModel()

        let sourceLanguage = sharedDefaults.string(forKey: "sourceLanguage") ?? "es"
        let targetLanguage = sharedDefaults.string(forKey: "targetLanguage") ?? "en"

        viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}

struct SmallLingoWidget: View {
    let word: Word
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    // UserDefaults'dan dil ayarlarını al
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "es"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "en"
    }
    
    // Romanized gösterim gerekiyor mu?
    private var shouldShowRomanized: Bool {
        guard let targetTranslation = word.translations[targetLanguage] else { return false }
        return !targetTranslation.text.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    topWordSection//.background(.red)
                    
                    if let romanized = word.translations[targetLanguage]?.romanized,
                       !romanized.isEmpty {
                        Spacer(minLength: 0)
                        secondWordSection(romanized: romanized)//.background(.blue)
                    }
                    
                    if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage],
                       !pronunciation.isEmpty {
                        Spacer(minLength: 0)
                        thirdWordSection(pronunciation: pronunciation)//.background(.orange)
                    }
                    
                    Spacer(minLength: 0)
                    bottomWordSection//.background(.green)
                    Spacer(minLength: 0)
                    
                    
                }
                bottomButtonsSection
                    //.background(.purple)
                    //.frame(height: 10)
                
            }
        }
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        }
    }
    
    private var topWordSection: some View {
        HStack(spacing: 5) {
            Image(targetLanguage)
                .resizable()
                .scaledToFill()
                .frame(width: 22, height: 22)
                .shadow(color: shadowColor, radius: 4)
            
            if let targetText = word.translations[targetLanguage]?.text {
                Text(targetText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
            }
        }
        .frame(maxWidth: .infinity)
        
    }
    
    private func secondWordSection(romanized: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "character.textbox")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Text(romanized)
                .font(.system(size: 16).weight(.light))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func thirdWordSection(pronunciation: String) -> some View {
        HStack {
            Text("🗣️ \(pronunciation)")
                .italic()
                .font(.system(size: 16, weight: .light))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var bottomWordSection: some View {
        HStack(spacing: 5) {
            Image(sourceLanguage)
                .resizable()
                .scaledToFill()
                .frame(width: 22, height: 22)
                .shadow(color: shadowColor, radius: 4)
            
            if let sourceText = word.translations[sourceLanguage]?.text {
                Text(sourceText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .allowsTightening(true)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var bottomButtonsSection: some View {
        VStack(spacing: 0) {
            Spacer()
            Divider()
            Spacer(minLength: 5)
            HStack {
                Spacer()
                Button(intent: RefreshIntent()) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
                Divider()
                Spacer()
                
                Link(destination: URL(string: "lingowidget://speak")!) {
                    Image(systemName: "speaker.wave.2.fill")
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                Spacer()
            }
            Spacer()
        }
        .offset(y: 5)
        .frame(height: 30)
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(white: 0.2) : .white,
                colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.97)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.5)
    }
}

struct SmallLingoWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode preview
            SmallLingoWidget(word: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .containerBackground(for: .widget) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                }
                .previewDisplayName("Light Mode")
            
            // Dark mode preview
            SmallLingoWidget(word: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .containerBackground(for: .widget) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                }
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
            
            // Chinese example preview
            SmallLingoWidget(word: Word(
                id: "hello",
                translations: [
                    "tr": Word.Translation(
                        text: "MerhabaCC",
                        exampleSentence: "Merhaba, nasılsın?",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["en": "mer·ha·ba"]
                    ),
                    "en": Word.Translation(
                        text: "HelloBB",
                        exampleSentence: "Hello, how are you?",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["tr": "he·lou"]
                    )
                ]
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .containerBackground(for: .widget) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
            }
            .previewDisplayName("English Example")
        }
    }
}
