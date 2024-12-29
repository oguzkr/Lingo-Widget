//
//  PremiumButton.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 29.12.2024.
//


import SwiftUI

struct PremiumButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("Try Premium for Free")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    PremiumButton {
        print("Premium tapped")
    }
}