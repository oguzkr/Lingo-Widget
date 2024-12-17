//
//  Lingo_Widget_Extension.swift
//  Lingo Widget Extension
//
//  Created by Oguz Doruk on 16.12.2024.
//
import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: Word
    let recentWords: [Word]
}

struct Provider: TimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")
    
    func placeholder(in context: Context) -> SimpleEntry {
       return SimpleEntry(
           date: Date(),
           word: Word(
               id: "hello",
               translations: [
                   "en": Word.Translation(
                       text: "hello",
                       exampleSentence: "Hello, how are you?",
                       romanized: nil,
                       romanizedExample: nil,
                       pronunciations: ["es": "he·lou"]
                   ),
                   "es": Word.Translation(
                       text: "hola",
                       exampleSentence: "¡Hola! ¿Cómo estás?",
                       romanized: nil,
                       romanizedExample: nil,
                       pronunciations: ["en": "o·la"]
                   )
               ]
           ),
           recentWords: [
               Word(
                   id: "how_are_you",
                   translations: [
                       "en": Word.Translation(
                           text: "how are you",
                           exampleSentence: "How are you today?",
                           romanized: nil,
                           romanizedExample: nil,
                           pronunciations: ["es": "hau·ar·yu"]
                       ),
                       "es": Word.Translation(
                           text: "cómo estás",
                           exampleSentence: "¿Cómo estás hoy?",
                           romanized: nil,
                           romanizedExample: nil,
                           pronunciations: ["en": "ko·mo·es·tas"]
                       )
                   ]
               ),
               Word(
                   id: "good_morning",
                   translations: [
                       "en": Word.Translation(
                           text: "good morning",
                           exampleSentence: "Good morning! Have a nice day!",
                           romanized: nil,
                           romanizedExample: nil,
                           pronunciations: ["es": "gud·mor·ning"]
                       ),
                       "es": Word.Translation(
                           text: "buenos días",
                           exampleSentence: "¡Buenos días! ¡Que tengas un buen día!",
                           romanized: nil,
                           romanizedExample: nil,
                           pronunciations: ["en": "bue·nos·di·as"]
                       )
                   ]
               )
           ]
       )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            word: Word(
                id: "hello",
                translations: [
                    "en": Word.Translation(
                        text: "hello",
                        exampleSentence: "Hello, how are you?",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["es": "he·lou"]
                    ),
                    "es": Word.Translation(
                        text: "hola",
                        exampleSentence: "¡Hola! ¿Cómo estás?",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["en": "o·la"]
                    )
                ]
            ),
            recentWords: [
                Word(
                    id: "how_are_you",
                    translations: [
                        "en": Word.Translation(
                            text: "how are you",
                            exampleSentence: "How are you today?",
                            romanized: nil,
                            romanizedExample: nil,
                            pronunciations: ["es": "hau·ar·yu"]
                        ),
                        "es": Word.Translation(
                            text: "cómo estás",
                            exampleSentence: "¿Cómo estás hoy?",
                            romanized: nil,
                            romanizedExample: nil,
                            pronunciations: ["en": "ko·mo·es·tas"]
                        )
                    ]
                ),
                Word(
                    id: "good_morning",
                    translations: [
                        "en": Word.Translation(
                            text: "good morning",
                            exampleSentence: "Good morning! Have a nice day!",
                            romanized: nil,
                            romanizedExample: nil,
                            pronunciations: ["es": "gud·mor·ning"]
                        ),
                        "es": Word.Translation(
                            text: "buenos días",
                            exampleSentence: "¡Buenos días! ¡Que tengas un buen día!",
                            romanized: nil,
                            romanizedExample: nil,
                            pronunciations: ["en": "bue·nos·di·as"]
                        )
                    ]
                )
            ]
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        
        let sourceLanguage = sharedDefaults?.string(forKey: "sourceLanguage") ?? "es"
        let targetLanguage = sharedDefaults?.string(forKey: "targetLanguage") ?? "en"
        
        let viewModel = DailyWordViewModel()
        viewModel.fetchDailyWord(from: sourceLanguage, to: targetLanguage)
        
        let currentWord = Word(
            id: viewModel.currentWordId,
            translations: [
                sourceLanguage: Word.Translation(
                    text: viewModel.sourceWord,
                    exampleSentence: viewModel.sourceExampleSentence,
                    romanized: nil,
                    romanizedExample: nil,
                    pronunciations: [:]
                ),
                targetLanguage: Word.Translation(
                    text: viewModel.targetWord,
                    exampleSentence: viewModel.exampleSentence,
                    romanized: viewModel.romanized,
                    romanizedExample: viewModel.romanizedExample,
                    pronunciations: [sourceLanguage: viewModel.pronunciation]
                )
            ]
        )
        
        // Recent words'ü mevcut kelimeyi dahil etmeden al
        let recentWords = viewModel.recentWords.filter { $0.id != currentWord.id }
        
        let entry = SimpleEntry(
            date: currentDate,
            word: currentWord,
            recentWords: Array(recentWords.prefix(2))
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct Lingo_Widget_ExtensionEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallLingoWidget(word: entry.word)
        case .systemMedium:
            MediumLingoWidget(word: entry.word)
        case .systemLarge:
            LargeLingoWidget(word: entry.word, recentWords: entry.recentWords)
        default:
            SmallLingoWidget(word: entry.word)
        }
    }
}

// Widget yapılandırmasını güncelle
struct Lingo_Widget_Extension: Widget {
    let kind: String = "Lingo_Widget_Extension"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Lingo_Widget_ExtensionEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                }
        }
        .configurationDisplayName("Lingo Daily Word")
        .description("Learn a new word every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemLarge) {
   Lingo_Widget_Extension()
} timeline: {
   SimpleEntry(
       date: .now,
       word: Word(
           id: "hello",
           translations: [
               "en": Word.Translation(
                   text: "hello",
                   exampleSentence: "Hello, how are you?",
                   romanized: nil,
                   romanizedExample: nil,
                   pronunciations: ["es": "he·lou"]
               ),
               "es": Word.Translation(
                   text: "hola",
                   exampleSentence: "¡Hola! ¿Cómo estás?",
                   romanized: nil,
                   romanizedExample: nil,
                   pronunciations: ["en": "o·la"]
               )
           ]
       ),
       recentWords: [
           Word(
               id: "how_are_you",
               translations: [
                   "en": Word.Translation(
                       text: "how are you",
                       exampleSentence: "How are you today?",
                       romanized: nil,
                       romanizedExample: nil,
                       pronunciations: ["es": "hau·ar·yu"]
                   ),
                   "es": Word.Translation(
                       text: "cómo estás",
                       exampleSentence: "¿Cómo estás hoy?",
                       romanized: nil,
                       romanizedExample: nil,
                       pronunciations: ["en": "ko·mo·es·tas"]
                   )
               ]
           ),
           Word(
               id: "good_morning",
               translations: [
                   "en": Word.Translation(
                       text: "good morning",
                       exampleSentence: "Good morning! Have a nice day!",
                       romanized: nil,
                       romanizedExample: nil,
                       pronunciations: ["es": "gud·mor·ning"]
                   ),
                   "es": Word.Translation(
                       text: "buenos días",
                       exampleSentence: "¡Buenos días! ¡Que tengas un buen día!",
                       romanized: nil,
                       romanizedExample: nil,
                       pronunciations: ["en": "bue·nos·di·as"]
                   )
               ]
           )
       ]
   )
}
