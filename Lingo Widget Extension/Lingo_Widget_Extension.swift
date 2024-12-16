//
//  Lingo_Widget_Extension.swift
//  Lingo Widget Extension
//
//  Created by Oguz Doruk on 16.12.2024.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            word: Word.placeholder,
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return SimpleEntry(date: Date(), word: .placeholder, configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        // Mevcut tarihi al
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        
        // Dil ayarlarını al
        let sourceLanguage = sharedDefaults?.string(forKey: "sourceLanguage") ?? "de"
        let targetLanguage = sharedDefaults?.string(forKey: "targetLanguage") ?? "en"
        
        // ViewModel'i oluştur ve kelimeleri yükle
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
            configuration: configuration
        )

        return Timeline(entries: [entry], policy: .after(nextMidnight))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: Word
    let configuration: ConfigurationAppIntent
}

struct Lingo_Widget_ExtensionEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        SmallLingoWidget(word: entry.word)
    }
}

struct Lingo_Widget_Extension: Widget {
    let kind: String = "Lingo_Widget_Extension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Lingo_Widget_ExtensionEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                }
        }
        .configurationDisplayName("Lingo Daily Word")
        .description("Learn a new word every day.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    Lingo_Widget_Extension()
} timeline: {
    SimpleEntry(date: .now, word: .placeholder, configuration: .init())
}
