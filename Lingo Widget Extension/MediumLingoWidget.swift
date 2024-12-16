//
//  MediumLingoWidget.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 16.12.2024.
//


import SwiftUI
import WidgetKit

struct MediumLingoWidget: View {
    let word: Word
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "ru"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "en"
    }
    
    private var shouldShowRomanized: Bool {
        guard let targetTranslation = word.translations[targetLanguage] else { return false }
        return !targetTranslation.text.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    private var shouldShowDivider: Bool {
        if shouldShowRomanized,
           let romanized = word.translations[targetLanguage]?.romanized,
           !romanized.isEmpty {
            return true
        }
        if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage],
           !pronunciation.isEmpty {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                targetLanguageSection
                
                if shouldShowDivider {
                    Divider()
                        .padding(.vertical, 2)
                }
                
                sourceLanguageSection
                
                if let exampleSentence = word.translations[targetLanguage]?.exampleSentence,
                   !exampleSentence.isEmpty {
                    if shouldShowDivider {
                        Divider()
                            .padding(.vertical, 2)
                    }
                    exampleSection
                }
            }
        }
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        }
    }
    
    private var targetLanguageSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            
            ViewThatFits(in: .horizontal) {
                fullWidthLayout
                mediumWidthLayout
                compactLayout
            }
            .padding(.vertical, 2)
        }
    }
    
    private var fullWidthLayout: some View {
        HStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(targetLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                
                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            if shouldShowRomanized,
               let romanized = word.translations[targetLanguage]?.romanized {
                Divider()
                    .frame(height: 20)
                
                romanizedView(romanized)
            }
            
            if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage],
               !pronunciation.isEmpty {
                Divider()
                    .frame(height: 20)
                
                pronunciationView(pronunciation)
            }
             
            Spacer(minLength: 0)
            speakButton
        }
    }
    
    private var mediumWidthLayout: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(targetLanguage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                    
                    if let targetText = word.translations[targetLanguage]?.text {
                        Text(targetText)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                
                if shouldShowRomanized,
                   let romanized = word.translations[targetLanguage]?.romanized {
                    Divider()
                        .frame(height: 20)
                    
                    romanizedView(romanized)
                }
                
                Spacer(minLength: 0)
                
                speakButton
            }
            
            if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage],
               !pronunciation.isEmpty {
                pronunciationView(pronunciation)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(targetLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                
                if let targetText = word.translations[targetLanguage]?.text {
                    Text(targetText)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                
                speakButton
            }
            
            if shouldShowRomanized,
               let romanized = word.translations[targetLanguage]?.romanized {
                romanizedView(romanized)
            }
            
            if let pronunciation = word.translations[targetLanguage]?.pronunciations[sourceLanguage],
               !pronunciation.isEmpty {
                pronunciationView(pronunciation)
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
            .font(.system(size: 20, weight: .light))
            .foregroundColor(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
    
    private var speakButton: some View {
        Link(destination: URL(string: "lingowidget://speak?text=word")!) {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundStyle(.blue)
        }
    }
    
    private var sourceLanguageSection: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(spacing: 4) {
                Image(sourceLanguage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                
                if let sourceText = word.translations[sourceLanguage]?.text {
                    Text(sourceText)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let exampleSentence = word.translations[targetLanguage]?.exampleSentence {
                HStack(alignment: .top) {
                    Text(exampleSentence)
                        .font(.system(size: 18))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Spacer()
                    
                    Link(destination: URL(string: "lingowidget://speak?text=example")!) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            if shouldShowRomanized,
               let romanizedExample = word.translations[targetLanguage]?.romanizedExample {
                Text(romanizedExample)
                    .italic()
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            if let sourceExample = word.translations[sourceLanguage]?.exampleSentence,
               !sourceExample.isEmpty {
                Text(sourceExample)
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
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

struct MediumLingoWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MediumLingoWidget(word: Word(
                id: "good_night",
                translations: [
                    "en": Word.Translation(
                        text: "good night",
                        exampleSentence: "Good night, sweet dreams!",
                        romanized: "XXXX",
                        romanizedExample: "XXXXXXVVVVVVV asl;fka;",
                        pronunciations: ["ru": "AAAAX"]
                    ),
                    "ru": Word.Translation(
                        text: "спокойной ночи",
                        exampleSentence: "Спокойной ночи, сладких снов!",
                        romanized: "spokoynoy nochi",
                        romanizedExample: "Spokoynoy nochi, sladkikh snov!",
                        pronunciations: ["en": "spa·koy·noy no·chi"]
                    )
                ]
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .containerBackground(for: .widget) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
            }
            .previewDisplayName("Russian-English Example")
        }
    }
}
