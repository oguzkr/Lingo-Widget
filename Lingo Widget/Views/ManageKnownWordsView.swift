//
//  ManageKnownWordsView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 29.12.2024.
//


import SwiftUI

struct ManageKnownWordsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DailyWordViewModel
    @State private var selectedWords = Set<String>()
    @State private var showingDeleteConfirmation = false
    @State private var showingResetConfirmation = false
    
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "en"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "ru"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.knownWords.isEmpty {
                    ContentUnavailableView(
                        "No Words Yet",
                        systemImage: "book.closed",
                        description: Text("Words you mark as known will appear here")
                    )
                } else {
                    List {
                        ForEach(viewModel.getKnownWordsForCurrentLanguages(), id: \.id) { word in
                            KnownWordListItem(
                                word: word,
                                isSelected: selectedWords.contains(word.id)
                            ) {
                                if selectedWords.contains(word.id) {
                                    selectedWords.remove(word.id)
                                } else {
                                    selectedWords.insert(word.id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Known Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if !selectedWords.isEmpty {
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Selected", systemImage: "trash")
                            }
                        }
                        
                        if !viewModel.knownWords.isEmpty {
                            Button(role: .destructive) {
                                showingResetConfirmation = true
                            } label: {
                                Label("Reset All", systemImage: "trash.slash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(viewModel.knownWords.isEmpty)
                }
            }
            .alert("Delete Selected Words?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteSelectedWords()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .alert("Reset All Words?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllWords()
                }
            } message: {
                Text("This will remove all known words. This action cannot be undone.")
            }
        }
    }
    
    private func deleteSelectedWords() {
        viewModel.knownWords.removeAll { wordWithLangs in
            selectedWords.contains(wordWithLangs.word.id)
        }
        selectedWords.removeAll()
        viewModel.saveKnownWords()
    }
    
    private func resetAllWords() {
        viewModel.knownWords.removeAll()
        selectedWords.removeAll()
        viewModel.saveKnownWords()
    }
}

struct KnownWordListItem: View {
    let word: Word
    let isSelected: Bool
    let onTap: () -> Void
    
    private var sourceLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "sourceLanguage") ?? "en"
    }
    
    private var targetLanguage: String {
        UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")?.string(forKey: "targetLanguage") ?? "ru"
    }
    
    private var shouldShowRomanized: Bool {
        guard let targetTranslation = word.translations[targetLanguage] else { return false }
        return !targetTranslation.text.allSatisfy { $0.isLetter && $0.isASCII }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(targetLanguage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                        
                        if let targetText = word.translations[targetLanguage]?.text {
                            Text(targetText)
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    
                    if shouldShowRomanized,
                       let romanized = word.translations[targetLanguage]?.romanized {
                        Text(romanized)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    
                    HStack(spacing: 4) {
                        Image(sourceLanguage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                        
                        if let sourceText = word.translations[sourceLanguage]?.text {
                            Text(sourceText)
                                .font(.system(size: 17))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .font(.system(size: 22))
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    let viewModel = DailyWordViewModel()
    
    // Mock data oluşturuyoruz
    viewModel.knownWords = [
        WordWithLanguages(
            word: Word(
                id: "hello",
                translations: [
                    "en": Word.Translation(
                        text: "hello",
                        exampleSentence: "Hello, how are you?",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["ja": "he·lou"]
                    ),
                    "ja": Word.Translation(
                        text: "こんにちは",
                        exampleSentence: "こんにちは、お元気ですか?",
                        romanized: "konnichiwa",
                        romanizedExample: "Konnichiwa, ogenkidesuka?",
                        pronunciations: ["en": "kon·ni·chi·wa"]
                    )
                ]
            ),
            sourceLanguage: "en",
            targetLanguage: "ja"
        ),
        WordWithLanguages(
            word: Word(
                id: "good_morning",
                translations: [
                    "en": Word.Translation(
                        text: "good morning",
                        exampleSentence: "Good morning! Have a nice day!",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["ja": "gud·mor·ning"]
                    ),
                    "ja": Word.Translation(
                        text: "おはようございます",
                        exampleSentence: "おはようございます！良い一日を！",
                        romanized: "ohayou gozaimasu",
                        romanizedExample: "Ohayou gozaimasu! Yoi ichinichi wo!",
                        pronunciations: ["en": "o·ha·you·go·zai·ma·su"]
                    )
                ]
            ),
            sourceLanguage: "en",
            targetLanguage: "ja"
        ),
        WordWithLanguages(
            word: Word(
                id: "thank_you",
                translations: [
                    "en": Word.Translation(
                        text: "thank you",
                        exampleSentence: "Thank you very much!",
                        romanized: nil,
                        romanizedExample: nil,
                        pronunciations: ["ja": "thank·you"]
                    ),
                    "ja": Word.Translation(
                        text: "ありがとう",
                        exampleSentence: "ありがとうございます！",
                        romanized: "arigatou",
                        romanizedExample: "Arigatou gozaimasu!",
                        pronunciations: ["en": "a·ri·ga·tou"]
                    )
                ]
            ),
            sourceLanguage: "en",
            targetLanguage: "ja"
        )
    ]
    
    // UserDefaults mock değerlerini ayarlıyoruz
    let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!
    defaults.set("en", forKey: "sourceLanguage")
    defaults.set("ja", forKey: "targetLanguage")
    
    return ManageKnownWordsView(viewModel: viewModel)
}

// Boş liste durumu için preview
#Preview("Empty State") {
    let viewModel = DailyWordViewModel()
    viewModel.knownWords = [] // Boş liste
    
    return ManageKnownWordsView(viewModel: viewModel)
}
