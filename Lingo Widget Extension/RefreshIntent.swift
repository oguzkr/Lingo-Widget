//
//  RefreshIntent.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 16.12.2024.
//

//import AppIntents
//import WidgetKit
//
//struct RefreshIntent: AppIntent {
//    static var title: LocalizedStringResource = "Refresh Word"
//    
//    func perform() async throws -> some IntentResult {
//        let sharedDefaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!
//        let viewModel = DailyWordViewModel()
//
//        let sourceLanguage = sharedDefaults.string(forKey: "sourceLanguage") ?? "es"
//        let targetLanguage = sharedDefaults.string(forKey: "targetLanguage") ?? "en"
//
//        viewModel.refreshWord(from: sourceLanguage, to: targetLanguage, nativeLanguage: sourceLanguage)
//        
//        WidgetCenter.shared.reloadAllTimelines()
//        
//        return .result()
//    }
//}
