//
//  DailyWordViewSmall.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 13.12.2024.
//

import SwiftUI

struct DailyWordViewSmall: View {
    @StateObject private var viewModel: DailyWordViewModel
    
    @AppStorage("sourceLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedSourceLanguage = "tr"

    @AppStorage("targetLanguage", store: UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget"))
    private var selectedTargetLanguage = "en"
    
    @Environment(\.colorScheme) private var colorScheme

    @State private var isWordVisible = false
    @State private var isExampleVisible = false

    init(viewModel: DailyWordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DailyWordViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Üst içerik - Dinamik alan
            VStack(spacing: 0) {
                Spacer(minLength: 0) // Üst boşluk

                topWordSection

                if let romanized = viewModel.romanized, !romanized.isEmpty {
                    Spacer(minLength: 0)
                    secondWordSection(romanized: romanized)
                }

                let pronunciation = viewModel.pronunciation
                if !pronunciation.isEmpty {
                    Spacer(minLength: 0)
                    thirdWordSection(pronunciation: pronunciation)
                }

                Spacer(minLength: 0)
                bottomWordSection

                Spacer(minLength: 0) // Alt boşluk
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Alt butonlar - sabit alan
            bottomButtonsSection
                .frame(height: 40)
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundGradient)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: shadowColor, radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                isWordVisible = true
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                isExampleVisible = true
            }
            if viewModel.targetWord.isEmpty {
                viewModel.refreshWord(from: selectedSourceLanguage,
                                      to: selectedTargetLanguage,
                                      nativeLanguage: selectedSourceLanguage)
            }
        }
        .heightAsPercentage(20.8)
        .widthAsPercentage(41.6)
    }

    // MARK: - Subviews
    private var topWordSection: some View {
        HStack(spacing: 5) {
            Image(viewModel.targetLanguageCode)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .shadow(color: shadowColor, radius: 4)

            Text(viewModel.targetWord)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }

    private func secondWordSection(romanized: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "character.textbox")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Text(romanized)
                .font(.system(size: 18).weight(.light))
                .foregroundColor(.secondary)
                .opacity(isExampleVisible ? 1 : 0)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }

    private func thirdWordSection(pronunciation: String) -> some View {
        HStack {
            Text("🗣️ \(pronunciation)")
                .italic()
                .font(.system(size: 18, weight: .light))
                .shadow(color: .black.opacity(0.5), radius: 5)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomWordSection: some View {
        HStack(spacing: 5) {
            Image(viewModel.sourceLanguageCode)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .shadow(color: shadowColor, radius: 4)
            
            Text(viewModel.sourceWord)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity)
    }

    private var bottomButtonsSection: some View {
        VStack(spacing: 0) {
            Divider().padding(.bottom, 2)
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        viewModel.refreshWord(from: selectedSourceLanguage,
                                              to: selectedTargetLanguage,
                                              nativeLanguage: selectedSourceLanguage)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                Spacer()
                Divider()
                Spacer()
                Button {
                    viewModel.speakWord(text: viewModel.targetWord)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 20))
                        .foregroundStyle(.blue)
                }
                Spacer()
            }
            Spacer()
        }
    }

    // MARK: - Styling
    private var backgroundGradient: some ShapeStyle {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(white: 0.2) : .white,
                colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.97)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.5)
    }
}

#Preview {
    DailyWordViewSmall(viewModel: DailyWordViewModel())
}
