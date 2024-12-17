//
//  LargeLingoWidget.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 17.12.2224.
//


import SwiftUI
import WidgetKit

struct LargeLingoWidget: View {
    let word: Word
    let recentWords: [Word]
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "en"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "es"
    }
    
    private var shouldShowRomanized: Bool {
        guard let targetTranslation = word.translations[targetLanguage] else { return false }
        return !targetTranslation.text.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            mainContentSection
            
            if !recentWords.isEmpty {
                Divider()
                recentWordsSection
            }
        }
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        }
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 5) {
            // Target language section
            ViewThatFits(in: .horizontal) {
                targetLanguageFullWidth
                targetLanguageCompact
            }
            
            Divider()
            // Source language section
            ViewThatFits(in: .horizontal) {
                sourceLanguageFullWidth
                sourceLanguageCompact
            }
            Divider()
            // Example section
            if let exampleSentence = word.translations[targetLanguage]?.exampleSentence {
                exampleSection(exampleSentence)
            }
        }
    }
    
    private func romanizedView(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "character.textbox")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            
            Text(text)
                .italic()
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    private func pronunciationView(_ text: String) -> some View {
        Text("🗣️ \(text)")
            .italic()
            .font(.system(size: 24, weight: .light))
            .foregroundColor(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
    
    private var targetLanguageFullWidth: some View {
        HStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(targetLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                
                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(2) 
                        .minimumScaleFactor(0.7) 
                }
            }
            
            if shouldShowRomanized,
               let romanized = word.translations[targetLanguage]?.romanized {
                Divider().frame(height: 20)
                romanizedView(romanized)
            }
            
            if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage] {
                Divider().frame(height: 20)
                pronunciationView(pronunciation)
            }
            
            Spacer(minLength: 0)
            
            Link(destination: URL(string: "lingowidget://speak?text=word")!) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.blue)
            }.buttonStyle(.bordered)
        }
    }
    
    private var targetLanguageCompact: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(targetLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                
                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(2) 
                        .minimumScaleFactor(0.7) 
                }
                
                Spacer()
                
                Link(destination: URL(string: "lingowidget://speak?text=word")!) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }.buttonStyle(.bordered)
            }
            
            if shouldShowRomanized,
               let romanized = word.translations[targetLanguage]?.romanized {
                romanizedView(romanized)
            }
            
            if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage] {
                pronunciationView(pronunciation)
            }
        }
    }
    
    private var sourceLanguageFullWidth: some View {
        HStack {
            HStack(spacing: 6) {
                Image(sourceLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                
                if let sourceText = word.translations[sourceLanguage]?.text {
                    Text(sourceText)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(2) 
                        .minimumScaleFactor(0.7) 
                }
            }
            
            Spacer()
            
            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
                
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var sourceLanguageCompact: some View {
        HStack {
            Image(sourceLanguage)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
            
            if let sourceText = word.translations[sourceLanguage]?.text {
                Text(sourceText)
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(2) 
                    .minimumScaleFactor(0.7) 
            }
            
            Spacer()
            
            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func exampleSection(_ exampleSentence: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exampleSentence)
                    .font(.system(size: 20))
                    .lineLimit(3)
                    .minimumScaleFactor(0.7) 
                
                Spacer()
                
                Link(destination: URL(string: "lingowidget://speak?text=example")!) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }.buttonStyle(.bordered)
            }
            
            if shouldShowRomanized,
               let romanizedExample = word.translations[targetLanguage]?.romanizedExample {
                Text(romanizedExample)
                    .font(.system(size: 20, weight: .light))
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7) 
            }
            
            if let sourceExample = word.translations[sourceLanguage]?.exampleSentence {
                Text(sourceExample)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7) 
            }
        }
    }
    
    private var recentWordsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing:4) {
                Text("Recent Words")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.7))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.7))
            }.padding(.top, 4)
            
            HStack(spacing: 4) {
                ForEach(recentWords.prefix(2), id: \.id) { recentWord in
                    recentWordView(for: recentWord)
                }
            }
        }
    }
    
    private func recentWordView(for word: Word) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(targetLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
                    .shadow(color: .black.opacity(0.5), radius: 2)

                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7) 
                }
                Spacer()
            }
            
            HStack(spacing: 4) {
                Image(sourceLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
                    .shadow(color: .black.opacity(0.5), radius: 2)
                
                if let sourceText = word.translations[sourceLanguage]?.text {
                    Text(sourceText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .padding(.leading, 4)
        .padding(4)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
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
}


struct LargeLingoWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // İngilizce-Rusça örneği (romanization ve uzun metinler için)
            LargeLingoWidget(
                word: .placeholder,
                recentWords: [
                    .placeholder,
                    .placeholder
                ]
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            // Boş recent words örneği
            LargeLingoWidget(
                word: Word(
                    id: "hello",
                    translations: [
                        "en": Word.Translation(
                            text: "good evening",
                            exampleSentence: "Good evening! How was your day?",
                            romanized: "romanized",
                            romanizedExample: "romanizedExample",
                            pronunciations: ["ru": "gud·iv·ning"]
                        ),
                        "ru": Word.Translation(
                            text: "добрый вечер",
                            exampleSentence: "Добрый вечер! Как прошел день?",
                            romanized: "dobryy vecher",
                            romanizedExample: "Dobryy vecher! Kak proshel den'?",
                            pronunciations: ["en": "dob·riy·ve·cher"]
                        )
                    ]
                ),
                recentWords: []
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("No Recent Words")
        }
    }
}
