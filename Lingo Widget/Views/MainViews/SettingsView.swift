//
//  SettingsView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 26.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("preferredColorScheme") private var preferredColorScheme = 0
    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "en"
    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "es"
    @StateObject private var dailyWordViewModel = DailyWordViewModel()
    @State private var showResetConfirmation = false
    @State private var showLanguageSelection = false
    @State private var isSelectingSourceLanguage = true
    
    private let languages = [
        "tr": "Türkçe",
        "en": "English",
        "es": "Español",
        "id": "Bahasa",
        "fr": "Français",
        "it": "Italiano",
        "pt": "Português",
        "zh": "中文",
        "ru": "Русский",
        "ja": "日本語",
        "hi": "हिन्दी",
        "fil": "Filipino",
        "th": "ไทย",
        "ko": "한국어",
        "nl": "Nederlands",
        "sv": "Svenska",
        "pl": "Polski",
        "el": "Ελληνικά",
        "de": "Deutsch"
    ]

    var body: some View {
        NavigationView {
            List {
                languageSection
                appearanceSection
                wordManagementSection
                otherAppsSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showLanguageSelection) {
            languageSelectionSheet
        }
        .alert("Reset All Known Words?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dailyWordViewModel.knownWords.removeAll()
                dailyWordViewModel.saveKnownWords()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .preferredColorScheme(colorScheme)
    }
    
    private var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
    
    private var languageSection: some View {
        Section("Languages") {
            languageRow(title: "I speak", code: selectedSourceLanguage) {
                isSelectingSourceLanguage = true
                showLanguageSelection = true
            }
            
            languageRow(title: "I want to learn", code: selectedTargetLanguage) {
                isSelectingSourceLanguage = false
                showLanguageSelection = true
            }
            
            Button(action: switchLanguages) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Switch Languages")
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Appearance", selection: $preferredColorScheme) {
                Text("System")
                    .tag(0)
                Text("Light")
                    .tag(1)
                Text("Dark")
                    .tag(2)
            }
            .pickerStyle(.menu)
        }
    }
    
    private var wordManagementSection: some View {
        Section("Word Management") {
            NavigationLink {
                ManageKnownWordsView(viewModel: dailyWordViewModel)
            } label: {
                Label("Manage Known Words", systemImage: "list.bullet")
            }
            
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("Reset Knowledge", systemImage: "trash")
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            Link(destination: URL(string: "mailto:contact@oguzdoruk.com")!) {
                Label("Send Feedback", systemImage: "envelope")
            }
            
//            Link(destination: URL(string: "https://apps.apple.com/app/id6474726385?action=write-review")!) {
//                Label("Leave a Review", systemImage: "star")
//            }
            
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var otherAppsSection: some View {
        Section("Our Other Apps") {
            OtherAppRow(
                icon: "kalory_icon",
                title: "Kalory",
                subtitle: "AI Calorie Tracker",
                appStoreUrl: "https://apps.apple.com/id/app/kalory-ai-calorie-counter/id6503200291"
            )
            
            OtherAppRow(
                icon: "prtracker_icon",
                title: "PR Tracker",
                subtitle: "1RM, Cardio & Wods",
                appStoreUrl: "https://apps.apple.com/id/app/pr-tracker-1rm-cardio-wods/id6738637692"
            )
            
            OtherAppRow(
                icon: "iread_icon",
                title: "iRead",
                subtitle: "Minimalist Reader",
                appStoreUrl: "https://apps.apple.com/id/app/iread-minimalist-pdf-reader/id6736560524"
            )
        }
    }
    
    
    private var languageSelectionSheet: some View {
        NavigationView {
            List {
                ForEach(Array(languages.keys.sorted()), id: \.self) { code in
                    Button {
                        if isSelectingSourceLanguage {
                            if code != selectedTargetLanguage {
                                selectedSourceLanguage = code
                                showLanguageSelection = false
                            }
                        } else {
                            if code != selectedSourceLanguage {
                                selectedTargetLanguage = code
                                showLanguageSelection = false
                            }
                        }
                    } label: {
                        HStack {
                            Image(code)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            
                            Text(languages[code] ?? code)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if (isSelectingSourceLanguage && code == selectedSourceLanguage) ||
                                (!isSelectingSourceLanguage && code == selectedTargetLanguage) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .disabled((isSelectingSourceLanguage && code == selectedTargetLanguage) ||
                            (!isSelectingSourceLanguage && code == selectedSourceLanguage))
                }
            }
            .navigationTitle(isSelectingSourceLanguage ? "I speak" : "I want to learn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showLanguageSelection = false
                    }
                }
            }
        }
    }
    
    private func languageRow(title: String, code: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(code)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                Text(languages[code] ?? code)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func switchLanguages() {
        let tempSource = selectedSourceLanguage
        selectedSourceLanguage = selectedTargetLanguage
        selectedTargetLanguage = tempSource
    }
}

#Preview {
    SettingsView()
}
