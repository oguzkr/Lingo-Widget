//
//  WidgetGuideView.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 8.01.2025.
//

import SwiftUI
import Foundation
import WebKit

struct WidgetGuideView: View {
    @AppStorage("hasSeenWidgetGuide") private var hasSeenWidgetGuide = false
    @EnvironmentObject var localeManager: LocaleManager

    @State private var dontShowAgain = false
    
    @Binding var isPresented: Bool
    @Binding var showVideo: Bool
    
    var body: some View {
        ZStack {
            Color.secondary.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title)
                    }
                }
                
                if showVideo {
                    VideoPlayerView(urlString: "https://youtube.com/shorts/tlK7d-w7naQ")
                        .heightAsPercentage(70)
                        .cornerRadius(12)
                } else {
                    Text("Add Widget to Your Home Screen".localized(language: localeManager.currentLocale))
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Learn how to add the Lingo Widget to your home screen for quick access to your daily words.".localized(language: localeManager.currentLocale))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Button("Watch Tutorial".localized(language: localeManager.currentLocale)) {
                        showVideo = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Toggle("Don't show this again".localized(language: localeManager.currentLocale), isOn: $dontShowAgain)
                    .onChange(of: dontShowAgain) { _, newValue in
                        hasSeenWidgetGuide = newValue
                    }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .primary.opacity(0.3), radius: 10)
            .padding()
        }
    }
}

// VideoPlayerView.swift
struct VideoPlayerView: View {
    let urlString: String
    
    var body: some View {
        WebView(url: URL(string: urlString)!)
    }
}

// WebView.swift
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    WidgetGuideView(isPresented: .constant(true), showVideo: .constant(false))
}
