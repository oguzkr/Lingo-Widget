//
//  FloatingHelloAnimation.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 24.12.2024.
//


import SwiftUI

struct FloatingWord: Identifiable {
    let id = UUID()
    let text: String
    let size: CGFloat
    let offset: CGSize
    let rotation: Double
    let animationDuration: Double
    let initialPosition: CGPoint
    let fontWeight: Font.Weight
}

struct FloatingHelloAnimation: View {
    @State private var phase = 0.0
    @State private var words: [FloatingWord] = []
    
    private let greetings = [
        "tr": "merhaba",
        "en": "hello",
        "es": "hola",
        "id": "halo",
        "fr": "bonjour",
        "it": "ciao",
        "pt": "olá",
        "zh": "你好",
        "ru": "привет",
        "ja": "こんにちは",
        "hi": "नमस्ते",
        "fil": "kamusta",
        "th": "สวัสดี",
        "ko": "안녕하세요",
        "nl": "hallo",
        "sv": "hej",
        "pl": "cześć",
        "el": "γεια",
        "de": "hallo"
    ]
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(words) { word in
                    Text(word.text)
                        .font(.system(size: word.size, weight: word.fontWeight, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .position(
                            x: word.initialPosition.x
                            + calculateDelta(for: word.offset.width, phase: phase, duration: word.animationDuration),
                            y: word.initialPosition.y
                            + calculateDelta(for: word.offset.height, phase: phase, duration: word.animationDuration)
                        )
                        .rotationEffect(.degrees(word.rotation))
                }
            }
            .onAppear {
                generateWords(in: geometry.size)
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.01)) {
                phase += 0.01
            }
        }
    }
    
    /// Rastgele konum + çakışma engelleme
    private func generateWords(in size: CGSize) {
        var placedPositions = [CGPoint]()
        let minDistance: CGFloat = 60  // Kelimeler arasındaki minimum mesafe
        let maxAttempts = 100          // Bir kelime için deneme sayısı
        
        words = greetings.values.map { greeting in
            var finalPosition = CGPoint(x: size.width / 2, y: size.height / 2)
            
            var attempt = 0
            var isPlaced = false
            
            while !isPlaced && attempt < maxAttempts {
                // Kelimeyi ekran içindeki rastgele bir noktaya yerleştir
                let x = CGFloat.random(in: 50...(size.width - 50))
                let y = CGFloat.random(in: 50...(size.height - 50))
                let candidate = CGPoint(x: x, y: y)
                
                // Bu konum, daha önce yerleştirdiğimiz kelimelere yeterince uzak mı?
                let tooClose = placedPositions.contains { other in
                    distance(candidate, other) < minDistance
                }
                
                if !tooClose {
                    // Yeterince uzaksa bu konumu onayla
                    finalPosition = candidate
                    placedPositions.append(candidate)
                    isPlaced = true
                }
                
                attempt += 1
            }
            
            return FloatingWord(
                text: greeting,
                size: CGFloat.random(in: 25...30),
                // Daha küçük offsets vererek çakışmayı azaltabilirsin
                offset: CGSize(width: CGFloat.random(in: -30...30),
                               height: CGFloat.random(in: -30...30)),
                rotation: Double.random(in: -15...15),
                animationDuration: Double.random(in: 10...15),
                initialPosition: finalPosition,
                fontWeight: [.regular, .medium].randomElement() ?? .regular
            )
        }
    }
    
    /// İki noktadaki mesafeyi hesaplayan yardımcı fonksiyon
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
    
    /// x veya y eksenindeki sin dalgası salınımını döndürür
    private func calculateDelta(for offset: CGFloat, phase: Double, duration: Double) -> CGFloat {
        let progress = sin((phase.truncatingRemainder(dividingBy: duration) / duration) * .pi * 2)
        return offset * progress
    }
}

#Preview {
    FloatingHelloAnimation()
}
