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
            word: Word.placeholder,
            recentWords: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if sharedDefaults?.string(forKey: "sourceLanguage") == nil {
            sharedDefaults?.set("es", forKey: "sourceLanguage")
        }
        if sharedDefaults?.string(forKey: "targetLanguage") == nil {
            sharedDefaults?.set("en", forKey: "targetLanguage")
        }
        
        let entry = SimpleEntry(
            date: Date(),
            word: .placeholder,
            recentWords: []
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
        
        let entry = SimpleEntry(
            date: currentDate,
            word: Word(
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
            ),
            recentWords: viewModel.recentWords
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
        word: .placeholder,
        recentWords: [.placeholder, .placeholder]
    )
}
