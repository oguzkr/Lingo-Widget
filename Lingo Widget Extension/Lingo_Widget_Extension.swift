//
//  Lingo_Widget_Extension.swift
//  Lingo Widget Extension
//
//  Created by Oguz Doruk on 16.12.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            word: Word.placeholder
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) { // Bu method eklendi
        // Default dil ayarlarını kaydet
        if sharedDefaults?.string(forKey: "sourceLanguage") == nil {
            sharedDefaults?.set("es", forKey: "sourceLanguage")
        }
        if sharedDefaults?.string(forKey: "targetLanguage") == nil {
            sharedDefaults?.set("en", forKey: "targetLanguage")
        }

        let entry = SimpleEntry(date: Date(), word: .placeholder)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) { // Bu method eklendi
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
            )
        )

        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: Word
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
    SimpleEntry(date: .now, word: .placeholder)
}
