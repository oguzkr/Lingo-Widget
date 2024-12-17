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
          let sourceLang = sharedDefaults?.string(forKey: "sourceLanguage") ?? "es"
          let targetLang = sharedDefaults?.string(forKey: "targetLanguage") ?? "en"
          
          guard let helloUrl = Bundle.main.url(forResource: "hello", withExtension: "json"),
                let howAreYouUrl = Bundle.main.url(forResource: "how_are_you", withExtension: "json"),
                let goodMorningUrl = Bundle.main.url(forResource: "good_morning", withExtension: "json"),
                let helloData = try? Data(contentsOf: helloUrl),
                let howAreYouData = try? Data(contentsOf: howAreYouUrl),
                let goodMorningData = try? Data(contentsOf: goodMorningUrl),
                let hello = try? JSONDecoder().decode(Word.self, from: helloData),
                let howAreYou = try? JSONDecoder().decode(Word.self, from: howAreYouData),
                let goodMorning = try? JSONDecoder().decode(Word.self, from: goodMorningData),
                let helloSourceTrans = hello.translations[sourceLang],
                let helloTargetTrans = hello.translations[targetLang],
                let howAreYouSourceTrans = howAreYou.translations[sourceLang],
                let howAreYouTargetTrans = howAreYou.translations[targetLang],
                let goodMorningSourceTrans = goodMorning.translations[sourceLang],
                let goodMorningTargetTrans = goodMorning.translations[targetLang] else {
              return SimpleEntry(date: Date(), word: Word.placeholder, recentWords: [])
          }
          
          // Ana kelime için Word objesi
          let mainWord = Word(
              id: "hello",
              translations: [
                  sourceLang: helloSourceTrans,
                  targetLang: helloTargetTrans
              ]
          )
          
          // Son kelimeler için Word objeleri
          let recentWord1 = Word(
              id: "how_are_you",
              translations: [
                  sourceLang: howAreYouSourceTrans,
                  targetLang: howAreYouTargetTrans
              ]
          )
          
          let recentWord2 = Word(
              id: "good_morning",
              translations: [
                  sourceLang: goodMorningSourceTrans,
                  targetLang: goodMorningTargetTrans
              ]
          )
          
          return SimpleEntry(
              date: Date(),
              word: mainWord,
              recentWords: [recentWord1, recentWord2]
          )
      }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sourceLang = sharedDefaults?.string(forKey: "sourceLanguage") ?? "es"
        let targetLang = sharedDefaults?.string(forKey: "targetLanguage") ?? "en"
        
        guard let helloUrl = Bundle.main.url(forResource: "hello", withExtension: "json"),
              let howAreYouUrl = Bundle.main.url(forResource: "how_are_you", withExtension: "json"),
              let goodMorningUrl = Bundle.main.url(forResource: "good_morning", withExtension: "json"),
              let helloData = try? Data(contentsOf: helloUrl),
              let howAreYouData = try? Data(contentsOf: howAreYouUrl),
              let goodMorningData = try? Data(contentsOf: goodMorningUrl),
              let hello = try? JSONDecoder().decode(Word.self, from: helloData),
              let howAreYou = try? JSONDecoder().decode(Word.self, from: howAreYouData),
              let goodMorning = try? JSONDecoder().decode(Word.self, from: goodMorningData),
              let helloSourceTrans = hello.translations[sourceLang],
              let helloTargetTrans = hello.translations[targetLang],
              let howAreYouSourceTrans = howAreYou.translations[sourceLang],
              let howAreYouTargetTrans = howAreYou.translations[targetLang],
              let goodMorningSourceTrans = goodMorning.translations[sourceLang],
              let goodMorningTargetTrans = goodMorning.translations[targetLang] else {
            completion(SimpleEntry(date: Date(), word: Word.placeholder, recentWords: []))
            return
        }
        
        // Ana kelime için Word objesi
        let mainWord = Word(
            id: "hello",
            translations: [
                sourceLang: helloSourceTrans,
                targetLang: helloTargetTrans
            ]
        )
        
        // Son kelimeler için Word objeleri
        let recentWord1 = Word(
            id: "how_are_you",
            translations: [
                sourceLang: howAreYouSourceTrans,
                targetLang: howAreYouTargetTrans
            ]
        )
        
        let recentWord2 = Word(
            id: "good_morning",
            translations: [
                sourceLang: goodMorningSourceTrans,
                targetLang: goodMorningTargetTrans
            ]
        )
        
        let entry = SimpleEntry(
            date: Date(),
            word: mainWord,
            recentWords: [recentWord1, recentWord2]
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
        word: .placeholder,
        recentWords: [.placeholder, .placeholder]
    )
}
